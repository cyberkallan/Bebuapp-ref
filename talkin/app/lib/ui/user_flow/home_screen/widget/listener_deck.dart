import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/custom/listeners/listener_actions.dart';
import 'package:talk_in/custom/listeners/listener_photo_card.dart';
import 'package:talk_in/custom/motion/ringing_call_button.dart';
import 'package:talk_in/custom/motion/sfx.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/constant.dart';

/// Tinder-style stack of listener cards.
///
/// Drag left to skip. Drag right or tap the call button to *choose* the front
/// card: it snaps back to centre, lifts with a slight 3D tilt, a light sweeps
/// across the photo and an accent ring runs around the border while the call
/// chooser opens over it. The chosen host stays on screen the whole time; the
/// card only settles back when the sheet closes. Skipping still flies the
/// card off and reveals the next one.
class ListenerDeck extends StatefulWidget {
  const ListenerDeck({super.key});

  @override
  State<ListenerDeck> createState() => _ListenerDeckState();
}

class _ListenerDeckState extends State<ListenerDeck> with TickerProviderStateMixin {
  Offset _drag = Offset.zero;
  late final AnimationController _fly = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
  Animation<Offset>? _flyAnim;
  TopListeners? _flying;

  /// Choose-for-call animation. Forward = lift + reveal, reverse = settle.
  late final AnimationController _focus = AnimationController(vsync: this, duration: const Duration(milliseconds: 720), reverseDuration: const Duration(milliseconds: 360));
  TopListeners? _focused;
  Offset _focusFrom = Offset.zero; // drag offset when the choose started, snapped back to zero

  static const double _threshold = 110;

  bool get _busy => _fly.isAnimating || _focused != null;

  @override
  void dispose() {
    _fly.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_busy) return;
    setState(() => _drag += d.delta);
  }

  void _onPanEnd(DragEndDetails d, TopListeners top) {
    if (_busy) return;
    final vx = d.velocity.pixelsPerSecond.dx;
    if (_drag.dx > _threshold || vx > 900) {
      _choose(top);
    } else if (_drag.dx < -_threshold || vx < -900) {
      _flyOut(top);
    } else {
      setState(() => _drag = Offset.zero);
    }
  }

  /// Skip: fly the card off to the left and reveal the next host.
  void _flyOut(TopListeners top) {
    final width = MediaQuery.sizeOf(context).width;
    final end = Offset(-(width * 1.3), _drag.dy + 40);
    _flying = top;
    _flyAnim = Tween(begin: _drag, end: end).animate(CurvedAnimation(parent: _fly, curve: Curves.easeInCubic));
    _fly.forward(from: 0).whenComplete(() {
      final controller = Get.find<HomeScreenController>();
      final l = _flying;
      setState(() {
        _drag = Offset.zero;
        _flying = null;
        _flyAnim = null;
      });
      if (l != null) controller.dismissListener(l);
    });
  }

  /// Call: keep this host front and centre, present the card, open the
  /// chooser over it, then settle the card once the sheet is gone.
  Future<void> _choose(TopListeners top) async {
    if (_busy) return;
    setState(() {
      _focused = top;
      _focusFrom = _drag;
      _drag = Offset.zero;
    });
    Sfx.select();
    final reveal = _focus.forward(from: 0);
    // Open the sheet while the ring is still running so both motions overlap
    // and the card is already presented by the time the sheet is up.
    await Future.delayed(BebuTheme.reducedMotion ? Duration.zero : const Duration(milliseconds: 380));
    if (!mounted) return;
    Sfx.tick();
    await ListenerActions.openTalkNowFor(top, barrierColor: Colors.black.withValues(alpha: 0.42));
    await reveal;
    if (!mounted) return;
    await _focus.reverse();
    if (!mounted) return;
    setState(() => _focused = null);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      id: Constant.idGetListener,
      builder: (controller) {
        if (controller.isLoading && controller.topListeners.isEmpty) return const _DeckShimmer();
        final deck = controller.deckListeners;
        if (deck.isEmpty) {
          return _DeckEmpty(
            liveOnly: controller.feedIndex == 1,
            loading: controller.isPaginationLoading,
            onRefresh: () => controller.onRefresh(),
          );
        }
        final visible = deck.take(3).toList();
        // While a host is chosen, keep drawing that host even if the feed
        // refreshes underneath (the sheet is talking about *this* person).
        final front = _focused ?? visible[0];
        return LayoutBuilder(
          builder: (context, c) {
            return AnimatedBuilder(
              animation: Listenable.merge([_fly, _focus]),
              builder: (context, _) {
                final f = _focused == null ? 0.0 : _focus.value;
                final snap = Curves.easeOutCubic.transform((f / 0.4).clamp(0.0, 1.0));
                final drag = _focused != null ? _focusFrom * (1 - snap) : (_flyAnim?.value ?? _drag);
                final progress = _focused != null ? 0.0 : (drag.dx.abs() / _threshold).clamp(0.0, 1.0);
                final recede = Curves.easeOutCubic.transform((f / 0.5).clamp(0.0, 1.0));
                return Column(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          for (var i = visible.length - 1; i >= 1; i--) _backCard(visible[i], i, progress, recede, c),
                          _frontCard(front, drag, f, c),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Opacity(
                      opacity: 1 - 0.5 * recede,
                      child: _DeckActions(
                        onSkip: () => _busy ? null : _flyOut(visible[0]),
                        onCall: () => _choose(visible[0]),
                        onChat: () => ListenerActions.openChatFor(visible[0]),
                        canCall: ListenerActions.canCall(visible[0]),
                        live: visible[0].statusLabel == 'Available',
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  /// How far each back card peeks above the one in front of it.
  static const double _peek = 12;

  Widget _backCard(TopListeners l, int depth, double progress, double recede, BoxConstraints c) {
    // depth 1 sits just behind the front card, depth 2 behind that.
    final t = depth - progress; // eases towards the front as the top card leaves
    final scale = (1 - 0.045 * t) * (1 - 0.03 * recede);
    // Scale from the top edge so the peek is exactly [_peek] per depth and
    // never creeps up into the header; the shrink happens behind the front card.
    // While a host is chosen the stack recedes and dims so only the chosen card reads.
    return Positioned.fill(
      child: Transform.translate(
        offset: Offset(0, -_peek * t + 10 * recede),
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topCenter,
          child: Opacity(
            opacity: ((1 - 0.3 * t) * (1 - 0.6 * recede)).clamp(0.0, 1.0),
            child: RepaintBoundary(child: _ListenerCard(listener: l, showDetails: false)),
          ),
        ),
      ),
    );
  }

  Widget _frontCard(TopListeners l, Offset drag, double f, BoxConstraints c) {
    final angle = (drag.dx / c.maxWidth) * 0.35;
    final callOpacity = (drag.dx / _threshold).clamp(0.0, 1.0);
    final skipOpacity = (-drag.dx / _threshold).clamp(0.0, 1.0);

    // Choose animation: lift with a spring, tilt back then present forward,
    // hold slightly raised while the sheet is open.
    final lift = Curves.easeOutBack.transform((f / 0.55).clamp(0.0, 1.0));
    final tilt = math.sin(math.pi * (f / 0.8).clamp(0.0, 1.0));
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.0011)
      ..translate(0.0, -14 * lift)
      ..scale(1 + 0.035 * lift)
      ..rotateX(-0.12 * tilt)
      ..rotateY(0.05 * tilt);

    return Positioned.fill(
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: (d) => _onPanEnd(d, l),
        onTap: _busy ? null : () => ListenerActions.openProfile(l),
        child: Transform.translate(
          offset: drag,
          child: Transform.rotate(
            angle: angle,
            alignment: Alignment.bottomCenter,
            child: Transform(
              alignment: Alignment.center,
              transform: transform,
              child: _ListenerCard(
                listener: l,
                showDetails: true,
                glow: lift,
                overlay: Stack(
                  children: [
                    _SwipeStamp(label: 'CALL', color: BebuTheme.pink, opacity: callOpacity, alignment: Alignment.topLeft, angle: -0.25),
                    _SwipeStamp(label: 'SKIP', color: BebuTheme.textMuted, opacity: skipOpacity, alignment: Alignment.topRight, angle: 0.25),
                    if (f > 0) _ChosenOverlay(progress: f),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Light sweep + running accent ring drawn over the chosen card.
class _ChosenOverlay extends StatelessWidget {
  const _ChosenOverlay({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final t = progress;
    // Sheen crosses the card between 12% and 70% of the timeline.
    final sweep = ((t - 0.12) / 0.58).clamp(0.0, 1.0);
    final sheenOpacity = sweep == 0 || sweep == 1 ? 0.0 : math.sin(math.pi * sweep);
    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (sheenOpacity > 0)
            ClipRect(
              child: FractionalTranslation(
                translation: Offset(-1.2 + 2.4 * Curves.easeInOut.transform(sweep), 0),
                child: Transform.rotate(
                  angle: -0.45,
                  child: Opacity(
                    opacity: 0.55 * sheenOpacity,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0x00FFFFFF), Color(0x66FFFFFF), Color(0xCCFFFFFF), Color(0x66FFFFFF), Color(0x00FFFFFF)],
                          stops: [0.3, 0.44, 0.5, 0.56, 0.7],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          CustomPaint(painter: _ChosenRingPainter(t, BebuTheme.accent, BebuTheme.radiusXl)),
        ],
      ),
    );
  }
}

/// Accent ring that runs once around the border, then holds as a steady frame.
class _ChosenRingPainter extends CustomPainter {
  _ChosenRingPainter(this.t, this.accent, this.radius);
  final double t;
  final BebuAccent accent;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final fade = Curves.easeOut.transform((t / 0.3).clamp(0.0, 1.0));
    if (fade <= 0) return;
    final rect = Rect.fromLTWH(1.5, 1.5, size.width - 3, size.height - 3);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius - 1.5));
    // Steady frame.
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = accent.primary.withValues(alpha: 0.55 * fade),
    );
    // Travelling highlight: one lap over the first 80% of the timeline.
    final lap = (t / 0.8).clamp(0.0, 1.0);
    final head = lap * math.pi * 2 - math.pi / 2;
    final highlight = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        transform: GradientRotation(head),
        colors: [Colors.white.withValues(alpha: 0.95 * fade * (1 - lap * 0.6)), accent.light.withValues(alpha: 0.9 * fade), accent.primary.withValues(alpha: 0), Colors.transparent],
        stops: const [0.0, 0.08, 0.32, 1.0],
      ).createShader(rect);
    canvas.drawRRect(rrect, highlight);
    // Soft inner glow along the frame.
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..color = accent.primary.withValues(alpha: 0.28 * fade),
    );
  }

  @override
  bool shouldRepaint(covariant _ChosenRingPainter old) => old.t != t || old.accent != accent;
}

class _ListenerCard extends StatelessWidget {
  const _ListenerCard({required this.listener, required this.showDetails, this.overlay, this.glow = 0});

  final TopListeners listener;
  final bool showDetails;
  final Widget? overlay;

  /// 0..1 — how strongly the accent halo shows around the card (chosen state).
  final double glow;

  @override
  Widget build(BuildContext context) {
    final l = listener;
    final topics = (l.talkTopics ?? []).take(2).toList();
    final languages = (l.language ?? []).take(1).toList();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BebuTheme.radiusXl),
        boxShadow: [
          const BoxShadow(color: Color(0x80000000), blurRadius: 30, offset: Offset(0, 18)),
          if (glow > 0) BoxShadow(color: BebuTheme.pink.withValues(alpha: 0.45 * glow.clamp(0.0, 1.0)), blurRadius: 44, spreadRadius: 2),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(BebuTheme.radiusXl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ListenerPhoto(image: l.image, cacheWidth: (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context)).round()),
            if (showDetails) ...[
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GlassIconButton(
                      icon: Icons.more_horiz_rounded,
                      onTap: () => ListenerActions.openProfile(l),
                      tooltip: 'View profile',
                    ),
                    GlassIconButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      iconSize: 18,
                      onTap: () => ListenerActions.openChatFor(l),
                      tooltip: 'Message',
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final t in topics) BebuChip(label: t, dense: true, background: const Color(0x33FFFFFF), foreground: BebuTheme.onPhoto),
                          for (final lang in languages) BebuChip(label: lang, dense: true, icon: Icons.translate_rounded, background: const Color(0x33FFFFFF), foreground: BebuTheme.onPhoto),
                          if ((l.ratePrivateAudioCall ?? 0) > 0) _RateTag(icon: Icons.call_rounded, rate: l.ratePrivateAudioCall!),
                          if ((l.ratePrivateVideoCall ?? 0) > 0) _RateTag(icon: Icons.videocam_rounded, rate: l.ratePrivateVideoCall!),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            l.age == null ? (l.name ?? '') : '${l.name}, ${l.age}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: BebuTheme.display(size: 30, color: BebuTheme.onPhoto),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const VerifiedBadge(size: 22),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        StatusPill(status: l.statusLabel),
                        const Spacer(),
                        GlassIconButton(
                          icon: Icons.keyboard_arrow_down_rounded,
                          size: 34,
                          iconSize: 20,
                          onTap: () => ListenerActions.openProfile(l),
                          tooltip: 'More about ${l.name ?? 'this caller'}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            if (overlay != null) Positioned.fill(child: IgnorePointer(child: overlay)),
          ],
        ),
      ),
    );
  }
}

class _RateTag extends StatelessWidget {
  const _RateTag({required this.icon, required this.rate});
  final IconData icon;
  final int rate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(color: const Color(0x33FFFFFF), borderRadius: BorderRadius.circular(999), border: Border.all(color: BebuTheme.border)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: BebuTheme.amber),
          const SizedBox(width: 4),
          Text('$rate/min', style: BebuTheme.label(size: 11.5, color: BebuTheme.onPhoto)),
        ],
      ),
    );
  }
}

class _SwipeStamp extends StatelessWidget {
  const _SwipeStamp({required this.label, required this.color, required this.opacity, required this.alignment, required this.angle});
  final String label;
  final Color color;
  final double opacity;
  final Alignment alignment;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 78, 26, 0),
        child: Opacity(
          opacity: opacity,
          child: Transform.rotate(
            angle: angle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(border: Border.all(color: color, width: 3), borderRadius: BorderRadius.circular(10)),
              child: Text(label, style: BebuTheme.display(size: 28, color: color)),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeckActions extends StatelessWidget {
  const _DeckActions({required this.onSkip, required this.onCall, required this.onChat, required this.canCall, required this.live});
  final VoidCallback onSkip;
  final VoidCallback onCall;
  final VoidCallback onChat;
  final bool canCall;
  final bool live;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ActionOrb(icon: Icons.close_rounded, onTap: onSkip, size: 56, iconColor: BebuTheme.textMuted, semanticLabel: 'Skip'),
        const SizedBox(width: 18),
        RingingCallButton(
          icon: canCall ? Icons.call_rounded : Icons.chat_bubble_rounded,
          onTap: canCall ? onCall : onChat,
          ringing: canCall && live,
          size: 72,
          iconSize: 30,
          gradient: BebuTheme.pinkGradient,
          glow: BebuTheme.pink,
          ringColor: BebuTheme.pink,
          semanticLabel: canCall ? 'Call' : 'Message',
        ),
        const SizedBox(width: 18),
        ActionOrb(icon: Icons.chat_bubble_outline_rounded, onTap: onChat, size: 56, iconSize: 22, iconColor: BebuTheme.textMuted, semanticLabel: 'Message'),
      ],
    );
  }
}

class _DeckShimmer extends StatelessWidget {
  const _DeckShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Shimmer.fromColors(
            baseColor: BebuTheme.surface,
            highlightColor: BebuTheme.surface3,
            child: Container(decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusXl))),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final s in [56.0, 72.0, 56.0])
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9),
                child: Shimmer.fromColors(
                  baseColor: BebuTheme.surface,
                  highlightColor: BebuTheme.surface3,
                  child: Container(width: s, height: s, decoration: BoxDecoration(color: BebuTheme.surface, shape: BoxShape.circle)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _DeckEmpty extends StatelessWidget {
  const _DeckEmpty({required this.liveOnly, required this.loading, required this.onRefresh});
  final bool liveOnly;
  final bool loading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: Container(
        decoration: BoxDecoration(
          color: BebuTheme.surface,
          borderRadius: BorderRadius.circular(BebuTheme.radiusXl),
          border: Border.all(color: BebuTheme.border),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(gradient: BebuTheme.violetGradient, shape: BoxShape.circle),
              child: Icon(liveOnly ? Icons.podcasts_rounded : Icons.auto_awesome_rounded, size: 38, color: BebuTheme.text),
            ),
            const SizedBox(height: 22),
            Text(liveOnly ? 'Nobody is live right now' : "You've seen everyone", textAlign: TextAlign.center, style: BebuTheme.title(size: 22)),
            const SizedBox(height: 8),
            Text(
              liveOnly ? 'Check back in a bit, or browse everyone under For You.' : 'New callers join every day. Pull down or tap below to start over.',
              textAlign: TextAlign.center,
              style: BebuTheme.body(),
            ),
            const SizedBox(height: 22),
            PressScale(
              onTap: loading ? null : onRefresh,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                decoration: BoxDecoration(color: BebuTheme.text, borderRadius: BorderRadius.circular(999)),
                child: loading
                    ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: BebuTheme.bg))
                    : Text('Start over', style: BebuTheme.label(size: 14, color: BebuTheme.bg)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
