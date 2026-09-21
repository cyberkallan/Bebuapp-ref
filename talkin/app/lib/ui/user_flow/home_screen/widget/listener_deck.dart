import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/custom/listeners/listener_actions.dart';
import 'package:talk_in/custom/listeners/listener_photo_card.dart';
import 'package:talk_in/custom/motion/ringing_call_button.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/constant.dart';

/// Tinder-style stack of listener cards.
///
/// Drag left to skip, drag right (or tap the heart) to open the call chooser.
/// The two cards behind the front one are scaled and lifted so the deck reads
/// as a physical stack, and they ease forward as the top card leaves.
class ListenerDeck extends StatefulWidget {
  const ListenerDeck({super.key});

  @override
  State<ListenerDeck> createState() => _ListenerDeckState();
}

class _ListenerDeckState extends State<ListenerDeck> with SingleTickerProviderStateMixin {
  Offset _drag = Offset.zero;
  late final AnimationController _fly = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
  Animation<Offset>? _flyAnim;
  TopListeners? _flying;
  int? _flyDirection; // -1 skip, +1 call

  static const double _threshold = 110;

  @override
  void dispose() {
    _fly.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_fly.isAnimating) return;
    setState(() => _drag += d.delta);
  }

  void _onPanEnd(DragEndDetails d, TopListeners top) {
    if (_fly.isAnimating) return;
    final vx = d.velocity.pixelsPerSecond.dx;
    if (_drag.dx > _threshold || vx > 900) {
      _flyOut(top, 1);
    } else if (_drag.dx < -_threshold || vx < -900) {
      _flyOut(top, -1);
    } else {
      setState(() => _drag = Offset.zero);
    }
  }

  void _flyOut(TopListeners top, int direction) {
    final width = MediaQuery.sizeOf(context).width;
    final end = Offset(direction * (width * 1.3), _drag.dy + 40);
    _flying = top;
    _flyDirection = direction;
    _flyAnim = Tween(begin: _drag, end: end).animate(CurvedAnimation(parent: _fly, curve: Curves.easeInCubic));
    _fly.forward(from: 0).whenComplete(() {
      final controller = Get.find<HomeScreenController>();
      final l = _flying;
      final dir = _flyDirection;
      setState(() {
        _drag = Offset.zero;
        _flying = null;
        _flyDirection = null;
        _flyAnim = null;
      });
      if (l == null) return;
      controller.dismissListener(l);
      if (dir == 1) ListenerActions.openTalkNowFor(l);
    });
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
        return LayoutBuilder(
          builder: (context, c) {
            return AnimatedBuilder(
              animation: _fly,
              builder: (context, _) {
                final drag = _flyAnim?.value ?? _drag;
                final progress = (drag.dx.abs() / _threshold).clamp(0.0, 1.0);
                return Column(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          for (var i = visible.length - 1; i >= 0; i--)
                            if (i == 0) _frontCard(visible[0], drag, c) else _backCard(visible[i], i, progress, c),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _DeckActions(
                      onSkip: () => _flyOut(visible[0], -1),
                      onCall: () => _flyOut(visible[0], 1),
                      onChat: () => ListenerActions.openChatFor(visible[0]),
                      canCall: ListenerActions.canCall(visible[0]),
                      live: visible[0].statusLabel == 'Available',
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

  Widget _backCard(TopListeners l, int depth, double progress, BoxConstraints c) {
    // depth 1 sits just behind the front card, depth 2 behind that.
    final t = depth - progress; // eases towards the front as the top card leaves
    final scale = 1 - 0.045 * t;
    // Scale from the top edge so the peek is exactly [_peek] per depth and
    // never creeps up into the header; the shrink happens behind the front card.
    return Positioned.fill(
      child: Transform.translate(
        offset: Offset(0, -_peek * t),
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topCenter,
          child: Opacity(
            opacity: (1 - 0.3 * t).clamp(0.0, 1.0),
            child: RepaintBoundary(child: _ListenerCard(listener: l, showDetails: false)),
          ),
        ),
      ),
    );
  }

  Widget _frontCard(TopListeners l, Offset drag, BoxConstraints c) {
    final angle = (drag.dx / c.maxWidth) * 0.35;
    final callOpacity = (drag.dx / _threshold).clamp(0.0, 1.0);
    final skipOpacity = (-drag.dx / _threshold).clamp(0.0, 1.0);
    return Positioned.fill(
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: (d) => _onPanEnd(d, l),
        onTap: () => ListenerActions.openProfile(l),
        child: Transform.translate(
          offset: drag,
          child: Transform.rotate(
            angle: angle,
            alignment: Alignment.bottomCenter,
            child: _ListenerCard(
              listener: l,
              showDetails: true,
              overlay: Stack(
                children: [
                  _SwipeStamp(label: 'CALL', color: BebuTheme.pink, opacity: callOpacity, alignment: Alignment.topLeft, angle: -0.25),
                  _SwipeStamp(label: 'SKIP', color: BebuTheme.textMuted, opacity: skipOpacity, alignment: Alignment.topRight, angle: 0.25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ListenerCard extends StatelessWidget {
  const _ListenerCard({required this.listener, required this.showDetails, this.overlay});

  final TopListeners listener;
  final bool showDetails;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    final l = listener;
    final topics = (l.talkTopics ?? []).take(2).toList();
    final languages = (l.language ?? []).take(1).toList();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BebuTheme.radiusXl),
        boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 30, offset: Offset(0, 18))],
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
                          for (final t in topics) BebuChip(label: t, dense: true, background: const Color(0x33FFFFFF)),
                          for (final lang in languages) BebuChip(label: lang, dense: true, icon: Icons.translate_rounded, background: const Color(0x33FFFFFF)),
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
                            style: BebuTheme.display(size: 30),
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
          Text('$rate/min', style: BebuTheme.label(size: 11.5)),
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
                  child: Container(width: s, height: s, decoration: const BoxDecoration(color: BebuTheme.surface, shape: BoxShape.circle)),
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
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: BebuTheme.bg))
                    : Text('Start over', style: BebuTheme.label(size: 14, color: BebuTheme.bg)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
