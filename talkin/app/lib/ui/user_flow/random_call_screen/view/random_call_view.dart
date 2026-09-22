import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/custom/listeners/listener_photo_card.dart';
import 'package:talk_in/custom/motion/coin_pill.dart';
import 'package:talk_in/custom/motion/presence_badge.dart';
import 'package:talk_in/custom/motion/sfx.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/home_screen/api/user_coin_api.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:talk_in/ui/user_flow/random_call_screen/controller/random_call_controller.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';

/// Random match. One photo-first card: a softly blurred reel of hosts who are
/// live right now (the "who will it be?" hook), the live count, an Audio /
/// Video switch with the per-minute rate, and a single Start button. While
/// searching the reel shuffles fast and can be cancelled. Dark and light.
class RandomCallScreen extends StatefulWidget {
  const RandomCallScreen({super.key});

  @override
  State<RandomCallScreen> createState() => _RandomCallScreenState();
}

class _RandomCallScreenState extends State<RandomCallScreen> {
  final RandomCallController controller = Get.put(RandomCallController());

  bool _searching = false;
  int _searchToken = 0;

  Future<void> _start() async {
    if (_searching) return;
    Sfx.select();
    final token = ++_searchToken;
    setState(() => _searching = true);
    // Give the shuffle a beat so a fast API answer still reads as a search.
    final minWait = Future.delayed(BebuTheme.reducedMotion ? Duration.zero : const Duration(milliseconds: 1400));
    await controller.getaAvailableListener();
    await minWait;
    if (!mounted || token != _searchToken) return; // cancelled meanwhile
    setState(() => _searching = false);
    final found = controller.randomAvailableListenerModel?.data;
    if (found != null) {
      Sfx.matchFound();
      Get.toNamed(AppRoutes.randomMatchView)?.then((_) async {
        controller.userCoinModel = await UserCoinApi.callApi();
        Database.onSetUserCoin(controller.userCoinModel?.coin.toString() ?? '0');
        controller.update([Constant.idCoinUpdate]);
        Utils.onChangeStatusBar(brightness: BebuTheme.statusBarIcons);
      });
    } else {
      log('No available listener found');
      Sfx.deny();
      Utils.showToast(Get.context!, controller.randomAvailableListenerModel?.message ?? 'No one is free right now. Try again in a moment.');
    }
  }

  void _cancel() {
    Sfx.tick();
    _searchToken++;
    setState(() => _searching = false);
  }

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: BebuTheme.statusBarIcons);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_searching) {
          _cancel();
          return;
        }
        Get.dialog(
          barrierColor: AppColors.black.withValues(alpha: 0.8),
          Dialog(backgroundColor: AppColors.transparent, shadowColor: Colors.transparent, surfaceTintColor: Colors.transparent, elevation: 0, child: const ExitAppDialog()),
        );
      },
      child: Scaffold(
        backgroundColor: BebuTheme.bg,
        body: Stack(
          fit: StackFit.expand,
          children: [
            AuroraBackground(intensity: BebuTheme.isLight ? 0.5 : 0.8),
            SafeArea(
              bottom: false,
              child: Builder(
                builder: (context) {
                  final bottomInset = MediaQuery.paddingOf(context).bottom;
                  final compact = MediaQuery.sizeOf(context).height < 720;
                  return Column(
                    children: [
                      const _Header(),
                      SizedBox(height: compact ? 10 : 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: GetBuilder<RandomCallController>(
                            id: Constant.idGetListener,
                            builder: (c) => _MeetCard(
                              hosts: c.allListener,
                              searching: _searching,
                              liveCount: c.liveCount,
                              onCancel: _cancel,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(18, compact ? 12 : 16, 18, 92 + bottomInset),
                        child: _Controls(searching: _searching, onStart: _start),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Random match', style: BebuTheme.display(size: 26)),
                const SizedBox(height: 3),
                GetBuilder<RandomCallController>(
                  id: Constant.idGetListener,
                  builder: (c) => Row(
                    children: [
                      PresenceBadge(presence: c.liveCount > 0 ? Presence.online : Presence.offline, size: 8, pulse: c.liveCount > 0),
                      const SizedBox(width: 7),
                      Text(
                        c.liveCount > 0 ? '${c.liveCount} ${c.liveCount == 1 ? 'host is' : 'hosts are'} live right now' : 'Finding who is online…',
                        style: BebuTheme.body(size: 12.5, color: BebuTheme.textMuted, weight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GetBuilder<RandomCallController>(
            id: Constant.idCoinUpdate,
            builder: (_) => CoinPill(
              coins: int.tryParse(Database.userCoin) ?? 0,
              height: 38,
              onTap: () => Get.toNamed(AppRoutes.myWalletScreen)?.then((_) => Utils.onChangeStatusBar(brightness: BebuTheme.statusBarIcons)),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The card
// ---------------------------------------------------------------------------

class _MeetCard extends StatefulWidget {
  const _MeetCard({required this.hosts, required this.searching, required this.liveCount, required this.onCancel});
  final List<TopListeners> hosts;
  final bool searching;
  final int liveCount;
  final VoidCallback onCancel;

  @override
  State<_MeetCard> createState() => _MeetCardState();
}

class _MeetCardState extends State<_MeetCard> {
  Timer? _timer;
  int _index = 0;
  List<TopListeners> _reel = const [];

  @override
  void initState() {
    super.initState();
    _rebuildReel();
    _schedule();
  }

  @override
  void didUpdateWidget(covariant _MeetCard old) {
    super.didUpdateWidget(old);
    if (old.hosts.length != widget.hosts.length) _rebuildReel();
    if (old.searching != widget.searching) _schedule();
  }

  void _rebuildReel() {
    final withPhoto = widget.hosts.where((h) => (h.image ?? '').isNotEmpty).toList()..shuffle(math.Random(3));
    // Online hosts first so the reel reflects who you can actually reach.
    withPhoto.sort((a, b) => (_live(b) ? 1 : 0) - (_live(a) ? 1 : 0));
    _reel = withPhoto.take(14).toList();
    if (_index >= _reel.length) _index = 0;
  }

  static bool _live(TopListeners h) => h.isOnline == true || h.statusLabel == 'Available';

  void _schedule() {
    _timer?.cancel();
    if (_reel.length < 2 || BebuTheme.reducedMotion) return;
    final period = widget.searching ? const Duration(milliseconds: 420) : const Duration(milliseconds: 3200);
    _timer = Timer.periodic(period, (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % _reel.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BebuTheme.radiusXl;
    final current = _reel.isEmpty ? null : _reel[_index];
    final avatars = _reel.where(_live).take(3).toList();
    final extra = math.max(0, widget.liveCount - avatars.length);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: BebuTheme.isLight ? 0.18 : 0.55), blurRadius: 40, offset: const Offset(0, 18))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo reel. Blurred on purpose: you find out who it is when you match.
            RepaintBoundary(
              child: AnimatedSwitcher(
                duration: widget.searching ? const Duration(milliseconds: 260) : const Duration(milliseconds: 900),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                layoutBuilder: (current, previous) => Stack(fit: StackFit.expand, children: [...previous, if (current != null) current]),
                child: current == null
                    ? const _EmptyArt(key: ValueKey('empty'))
                    : ImageFiltered(
                        key: ValueKey(current.id ?? _index),
                        imageFilter: ui.ImageFilter.blur(sigmaX: 9, sigmaY: 9, tileMode: TileMode.decal),
                        child: Transform.scale(scale: 1.1, child: ListenerPhoto(image: current.image, scrim: false, cacheWidth: 480)),
                      ),
              ),
            ),
            // Scrims: keep the top readable, make the bottom a solid stage for copy.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.3, 0.6, 1],
                  colors: [Color(0x4D000000), Color(0x0A000000), Color(0x80000000), Color(0xE0000000)],
                ),
              ),
            ),
            // Top row: live pill + stacked avatars.
            Positioned(
              left: 14,
              right: 14,
              top: 14,
              child: Row(
                children: [
                  PresencePill(presence: widget.liveCount > 0 ? Presence.online : Presence.offline, label: widget.liveCount > 0 ? '${widget.liveCount} live' : 'Quiet right now', onPhoto: true),
                  const Spacer(),
                  if (avatars.isNotEmpty) _AvatarStack(hosts: avatars, extra: extra),
                ],
              ),
            ),
            // Body: idle copy or the searching state.
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: BebuTheme.normal,
                child: widget.searching ? _Searching(key: const ValueKey('s'), onCancel: widget.onCancel) : const _IdleCopy(key: ValueKey('i')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyArt extends StatelessWidget {
  const _EmptyArt({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [BebuTheme.violetDeep, BebuTheme.pinkDeep]),
      ),
      child: Center(child: Icon(Icons.people_alt_rounded, size: 72, color: Colors.white.withValues(alpha: 0.25))),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.hosts, required this.extra});
  final List<TopListeners> hosts;
  final int extra;

  @override
  Widget build(BuildContext context) {
    const size = 30.0;
    const overlap = 20.0;
    final width = size + overlap * (hosts.length - 1) + (extra > 0 ? overlap + 6 : 0);
    return Container(
      height: size + 8,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(999)),
      child: SizedBox(
        width: width,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            for (var i = 0; i < hosts.length; i++)
              Positioned(
                left: i * overlap,
                child: Container(
                  width: size,
                  height: size,
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
                  child: ClipOval(child: ListenerPhoto(image: hosts[i].image, scrim: false, cacheWidth: 96)),
                ),
              ),
            if (extra > 0)
              Positioned(
                left: hosts.length * overlap,
                child: Container(
                  height: size,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(999), color: Colors.white.withValues(alpha: 0.92)),
                  alignment: Alignment.center,
                  child: Text('+$extra', style: BebuTheme.label(size: 11.5, color: const Color(0xFF1D1D1F), weight: FontWeight.w800)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _IdleCopy extends StatelessWidget {
  const _IdleCopy({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Who will\nyou meet?', style: BebuTheme.display(size: 34, color: BebuTheme.onPhoto).copyWith(height: 1.02)),
            const SizedBox(height: 10),
            Text(
              'Real hosts, live right now. We pick one for you — the face is a surprise until you match.',
              style: BebuTheme.body(size: 14, color: BebuTheme.onPhotoMuted, height: 1.4),
            ),
            const SizedBox(height: 14),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Fact(icon: Icons.verified_rounded, text: 'Verified hosts'),
                _Fact(icon: Icons.timer_outlined, text: 'Pay per minute'),
                _Fact(icon: Icons.call_end_rounded, text: 'Leave any time'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 6, 11, 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: BebuTheme.onPhoto),
          const SizedBox(width: 5),
          Text(text, style: BebuTheme.label(size: 11.5, color: BebuTheme.onPhoto)),
        ],
      ),
    );
  }
}

/// Searching state: two slow expanding rings, copy, cancel.
class _Searching extends StatefulWidget {
  const _Searching({super.key, required this.onCancel});
  final VoidCallback onCancel;

  @override
  State<_Searching> createState() => _SearchingState();
}

class _SearchingState extends State<_Searching> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

  @override
  void initState() {
    super.initState();
    if (!BebuTheme.reducedMotion) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, __) => CustomPaint(painter: _RingsPainter(t: _c.value, color: BebuTheme.pink)),
                child: Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(shape: BoxShape.circle, gradient: BebuTheme.pinkGradient, boxShadow: [BoxShadow(color: BebuTheme.pink.withValues(alpha: 0.5), blurRadius: 24)]),
                    child: const Icon(Icons.shuffle_rounded, color: BebuTheme.onPhoto, size: 28),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text('Finding someone for you…', style: BebuTheme.title(size: 18, color: BebuTheme.onPhoto)),
          const SizedBox(height: 6),
          Text('Usually takes a few seconds', style: BebuTheme.body(size: 13, color: BebuTheme.onPhotoMuted)),
          const SizedBox(height: 22),
          PressScale(
            onTap: widget.onCancel,
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white.withValues(alpha: 0.22))),
              alignment: Alignment.center,
              child: Text('Cancel', style: BebuTheme.label(size: 14, color: BebuTheme.onPhoto)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  _RingsPainter({required this.t, required this.color});
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.isFinite || size.isEmpty) return;
    final c = size.center(Offset.zero);
    final maxR = size.shortestSide / 2;
    for (var i = 0; i < 2; i++) {
      final p = (t + i * 0.5) % 1.0;
      final r = ui.lerpDouble(34, maxR, p)!;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color.withValues(alpha: (1 - p) * 0.55);
      canvas.drawCircle(c, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter old) => old.t != t || old.color != color;
}

// ---------------------------------------------------------------------------
// Controls
// ---------------------------------------------------------------------------

class _Controls extends StatelessWidget {
  const _Controls({required this.searching, required this.onStart});
  final bool searching;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RandomCallController>(
      builder: (c) {
        final s = Database.settingApiModel?.data;
        final audioRate = s?.audioCallRateRandom ?? 0;
        final videoRate = s?.videoCallRateRandom ?? 0;
        final rate = c.selectedIndex == 0 ? audioRate : videoRate;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ModeSegment(selected: c.selectedIndex, audioRate: audioRate, videoRate: videoRate, onChanged: searching ? null : c.selectCallType),
            const SizedBox(height: 12),
            GradientButton(
              label: searching ? 'Finding someone…' : 'Start matching',
              icon: searching ? null : Icons.shuffle_rounded,
              gradient: BebuTheme.pinkGradient,
              glow: BebuTheme.pink,
              height: 58,
              loading: searching,
              onTap: onStart,
            ),
            const SizedBox(height: 10),
            GetBuilder<RandomCallController>(
              id: Constant.idCoinUpdate,
              builder: (_) {
                final coins = int.tryParse(Database.userCoin) ?? 0;
                final minutes = rate > 0 ? coins ~/ rate : 0;
                final String footnote;
                if (rate <= 0) {
                  footnote = 'Charged per minute from your coin balance · no subscription';
                } else if (minutes <= 0) {
                  footnote = 'You need at least $rate coins for a minute · tap your balance to top up';
                } else {
                  footnote = 'Your balance covers about $minutes min · charged per minute, no subscription';
                }
                return Text(footnote, textAlign: TextAlign.center, maxLines: 2, style: BebuTheme.label(size: 11.5, color: BebuTheme.textFaint, weight: FontWeight.w500));
              },
            ),
          ],
        );
      },
    );
  }
}

class _ModeSegment extends StatelessWidget {
  const _ModeSegment({required this.selected, required this.audioRate, required this.videoRate, required this.onChanged});
  final int selected;
  final int audioRate;
  final int videoRate;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: BebuTheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: BebuTheme.border),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth / 2;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: BebuTheme.normal,
                curve: BebuTheme.curve,
                left: selected * w,
                top: 0,
                bottom: 0,
                width: w,
                child: Container(
                  decoration: BoxDecoration(
                    color: BebuTheme.isLight ? const Color(0xFF15151A) : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(child: _Segment(icon: Icons.call_rounded, label: EnumLocale.txtAudioCall.name.tr, rate: audioRate, active: selected == 0, onTap: onChanged == null ? null : () => onChanged!(0))),
                  Expanded(child: _Segment(icon: Icons.videocam_rounded, label: EnumLocale.txtVideoCall.name.tr, rate: videoRate, active: selected == 1, onTap: onChanged == null ? null : () => onChanged!(1))),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.icon, required this.label, required this.rate, required this.active, required this.onTap});
  final IconData icon;
  final String label;
  final int rate;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final onThumb = BebuTheme.isLight ? Colors.white : const Color(0xFF15151A);
    final fg = active ? onThumb : BebuTheme.textMuted;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap == null
          ? null
          : () {
              Sfx.tick();
              onTap!();
            },
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: BebuTheme.label(size: 14, weight: FontWeight.w700, color: fg)),
                  if (rate > 0) Text('$rate coins/min', style: BebuTheme.label(size: 10.5, weight: FontWeight.w600, color: active ? onThumb.withValues(alpha: 0.7) : BebuTheme.textFaint)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
