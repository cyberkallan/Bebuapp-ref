import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/custom/listeners/listener_photo_card.dart';
import 'package:talk_in/custom/motion/coin_pill.dart';
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

/// Random match: a radar of callers around a glowing core.
///
/// Uses the existing [RandomCallController] for data (`allListener`,
/// `randomDisplayList`, `selectedIndex`, `getaAvailableListener`) and keeps the
/// same navigation into [AppRoutes.randomMatchView].
class RandomCallScreen extends StatefulWidget {
  const RandomCallScreen({super.key});

  @override
  State<RandomCallScreen> createState() => _RandomCallScreenState();
}

class _RandomCallScreenState extends State<RandomCallScreen> {
  final RandomCallController controller = Get.put(RandomCallController());

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.dialog(
          barrierColor: AppColors.black.withValues(alpha: 0.8),
          Dialog(
            backgroundColor: AppColors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            child: const ExitAppDialog(),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: BebuTheme.bg,
        body: AuroraBackground(
          intensity: 1.4,
          child: SafeArea(
            bottom: false,
            child: GetBuilder<RandomCallController>(
              builder: (controller) {
                final bottomInset = MediaQuery.paddingOf(context).bottom;
                return Column(
                  children: [
                    const _RandomHeader(),
                    const SizedBox(height: 6),
                    const _VisibilityPill(),
                    Expanded(
                      child: GetBuilder<RandomCallController>(
                        id: Constant.idGetListener,
                        builder: (c) => _Radar(listeners: c.randomDisplayList, searching: c.isLoading, onReplace: c.replaceListenerAt),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 96 + bottomInset),
                      child: const _RandomControls(),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _RandomHeader extends StatelessWidget {
  const _RandomHeader();

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
                Text('bebu', style: BebuTheme.display(size: 26)),
                const SizedBox(height: 2),
                Text('Meet someone new. Stay in control.', style: BebuTheme.body(size: 12.5, color: BebuTheme.textFaint)),
              ],
            ),
          ),
          GetBuilder<RandomCallController>(
            id: Constant.idCoinUpdate,
            builder: (_) => CoinPill(
              coins: int.tryParse(Database.userCoin) ?? 0,
              height: 40,
              onTap: () => Get.toNamed(AppRoutes.myWalletScreen)?.then((_) => Utils.onChangeStatusBar(brightness: Brightness.light)),
            ),
          ),
          const SizedBox(width: 8),
          PressScale(
            onTap: () => Get.toNamed(AppRoutes.myProfileScreen)?.then((_) => Utils.onChangeStatusBar(brightness: Brightness.light)),
            child: BebuAvatar(size: 40, ring: true, child: ListenerPhoto(image: Database.loginUserProfilePic, scrim: false)),
          ),
        ],
      ),
    );
  }
}

class _VisibilityPill extends StatelessWidget {
  const _VisibilityPill();

  @override
  Widget build(BuildContext context) {
    final count = Get.find<RandomCallController>().allListener.where((l) => l.statusLabel == 'Available').length;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: BebuTheme.surface.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(999), border: Border.all(color: BebuTheme.border)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.podcasts_rounded, size: 15, color: BebuTheme.green),
          const SizedBox(width: 7),
          Text(count == 0 ? 'Looking for callers online' : '$count ${count == 1 ? 'caller' : 'callers'} live right now', style: BebuTheme.label(size: 12.5)),
        ],
      ),
    );
  }
}

/// Concentric rings, a rotating sweep while searching, and avatars that
/// drift on the rings and fade to a new caller every few seconds.
class _Radar extends StatefulWidget {
  const _Radar({required this.listeners, required this.searching, required this.onReplace});

  final List<TopListeners> listeners;
  final bool searching;
  final void Function(int index) onReplace;

  @override
  State<_Radar> createState() => _RadarState();
}

class _RadarState extends State<_Radar> with TickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  late final AnimationController _sweep = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
  late final AnimationController _drift = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();

  @override
  void didUpdateWidget(covariant _Radar old) {
    super.didUpdateWidget(old);
    if (widget.searching && !_sweep.isAnimating) _sweep.repeat();
    if (!widget.searching && _sweep.isAnimating) _sweep.stop();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _sweep.dispose();
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final size = math.min(c.maxWidth, c.maxHeight) - 8;
        final radii = [size * 0.20, size * 0.33, size * 0.46];
        // Slots: (ring index, base angle in radians)
        const slots = [(1, -2.2), (2, -0.6), (1, 0.9), (2, 2.4)];
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: AnimatedBuilder(
              animation: Listenable.merge([_pulse, _sweep, _drift]),
              builder: (context, _) {
                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    CustomPaint(
                      size: Size.square(size),
                      painter: _RadarPainter(pulse: _pulse.value, sweep: widget.searching ? _sweep.value : null, radii: radii),
                    ),
                    _Core(searching: widget.searching),
                    for (var i = 0; i < math.min(widget.listeners.length, slots.length); i++) _orbiting(i, slots[i], radii, size),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _orbiting(int i, (int, double) slot, List<double> radii, double size) {
    final angle = slot.$2 + _drift.value * 2 * math.pi * (slot.$1.isEven ? 1 : -1) * 0.5;
    final r = radii[slot.$1];
    final l = widget.listeners[i];
    final avatar = slot.$1 == 1 ? 58.0 : 46.0;
    return Positioned(
      left: size / 2 + r * math.cos(angle) - avatar / 2,
      top: size / 2 + r * math.sin(angle) - avatar / 2,
      child: _RadarAvatar(key: ValueKey(l.id), listener: l, size: avatar, onDone: () => widget.onReplace(i)),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({required this.pulse, required this.sweep, required this.radii});
  final double pulse;
  final double? sweep;
  final List<double> radii;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = BebuTheme.violet.withValues(alpha: 0.35);
    final fill = Paint()..color = BebuTheme.violet.withValues(alpha: 0.06);
    for (final r in radii.reversed) {
      canvas.drawCircle(center, r, fill);
      canvas.drawCircle(center, r, ring);
    }
    // Expanding pulse ring
    final pr = radii.first + (radii.last - radii.first) * pulse;
    canvas.drawCircle(
      center,
      pr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = BebuTheme.pink.withValues(alpha: (1 - pulse) * 0.55),
    );
    if (sweep != null) {
      final rect = Rect.fromCircle(center: center, radius: radii.last);
      canvas.drawArc(
        rect,
        sweep! * 2 * math.pi,
        math.pi / 2.2,
        true,
        Paint()
          ..shader = SweepGradient(
            startAngle: sweep! * 2 * math.pi,
            endAngle: sweep! * 2 * math.pi + math.pi / 2.2,
            colors: [BebuTheme.violet.withValues(alpha: 0), BebuTheme.violet.withValues(alpha: 0.45)],
            transform: GradientRotation(0),
          ).createShader(rect),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) => old.pulse != pulse || old.sweep != sweep;
}

class _Core extends StatelessWidget {
  const _Core({required this.searching});
  final bool searching;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: BebuTheme.normal,
      width: searching ? 96 : 84,
      height: searching ? 96 : 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: BebuTheme.violetGradient,
        boxShadow: [BoxShadow(color: BebuTheme.violet.withValues(alpha: 0.6), blurRadius: searching ? 46 : 30, spreadRadius: 2)],
      ),
      child: Center(
        child: searching
            ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5, color: BebuTheme.onPhoto))
            : const Icon(Icons.all_inclusive_rounded, color: BebuTheme.onPhoto, size: 38),
      ),
    );
  }
}

/// Fades in, waits, fades out, then asks the controller for a replacement.
class _RadarAvatar extends StatefulWidget {
  const _RadarAvatar({super.key, required this.listener, required this.size, required this.onDone});
  final TopListeners listener;
  final double size;
  final VoidCallback onDone;

  @override
  State<_RadarAvatar> createState() => _RadarAvatarState();
}

class _RadarAvatarState extends State<_RadarAvatar> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: Duration(milliseconds: 5200 + math.Random().nextInt(2400)));

  @override
  void initState() {
    super.initState();
    _cycle();
  }

  void _cycle() {
    _c.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      widget.onDone();
      // If the controller had nobody else to show, this widget survives with
      // the same key; loop so the avatar fades back in instead of vanishing.
      if (mounted) _cycle();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.listener;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value;
        final opacity = t < 0.15 ? t / 0.15 : (t > 0.85 ? (1 - t) / 0.15 : 1.0);
        final scale = 0.8 + 0.2 * opacity;
        return Opacity(opacity: opacity.clamp(0, 1), child: Transform.scale(scale: scale, child: child));
      },
      child: PressScale(
        onTap: () => Get.toNamed(AppRoutes.profileDetailScreenView, arguments: l.id),
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: BebuTheme.violet.withValues(alpha: 0.5), blurRadius: 18)]),
          child: BebuAvatar(size: widget.size, ring: true, online: l.statusLabel == 'Available', child: ListenerPhoto(image: l.image, scrim: false)),
        ),
      ),
    );
  }
}

class _RandomControls extends StatelessWidget {
  const _RandomControls();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RandomCallController>(
      builder: (controller) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text('Call type', style: BebuTheme.label(size: 12.5, color: BebuTheme.textFaint)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Coins are charged per minute',
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: BebuTheme.body(size: 11.5, color: BebuTheme.textFaint),
                    ),
                  ),
                ],
              ),
            ),
            SegmentedPill(
              index: controller.selectedIndex,
              onChanged: controller.selectCallType,
              segments: [
                SegmentItem(EnumLocale.txtAudioCall.name.tr, Icons.call_rounded),
                SegmentItem(EnumLocale.txtVideoCall.name.tr, Icons.videocam_rounded),
              ],
            ),
            const SizedBox(height: 14),
            GradientButton(
              label: controller.isLoading ? 'Finding someone…' : EnumLocale.txtRandomMatch.name.tr,
              icon: Icons.shuffle_rounded,
              loading: controller.isLoading,
              gradient: const LinearGradient(colors: [Color(0xFFCF00FD), Color(0xFF8400FF)]),
              glow: const Color(0xFFB000FF),
              onTap: () => _startMatch(controller),
            ),
          ],
        );
      },
    );
  }

  void _startMatch(RandomCallController controller) {
    controller.getaAvailableListener().then((_) {
      if (controller.randomAvailableListenerModel?.data != null) {
        Get.toNamed(AppRoutes.randomMatchView)?.then((_) async {
          controller.userCoinModel = await UserCoinApi.callApi();
          Database.onSetUserCoin(controller.userCoinModel?.coin.toString() ?? '0');
          controller.update([Constant.idCoinUpdate]);
          Utils.onChangeStatusBar(brightness: Brightness.light);
        });
      } else {
        log('No available listener found');
        Utils.showToast(Get.context!, controller.randomAvailableListenerModel?.message ?? 'No one is available right now. Try again in a moment.');
      }
    });
  }
}
