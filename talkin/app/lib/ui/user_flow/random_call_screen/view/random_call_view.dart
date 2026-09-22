import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/custom/listeners/listener_photo_card.dart';
import 'package:talk_in/custom/motion/coin_pill.dart';
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

/// Random match: a layered proximity radar over a faint map, hosts orbiting
/// on the discs, a tappable core that starts the match. Works on the dark and
/// light palettes.
class RandomCallScreen extends StatefulWidget {
  const RandomCallScreen({super.key});

  @override
  State<RandomCallScreen> createState() => _RandomCallScreenState();
}

class _RandomCallScreenState extends State<RandomCallScreen> {
  final RandomCallController controller = Get.put(RandomCallController());

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: BebuTheme.statusBarIcons);
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
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _RadarBackdrop(),
            SafeArea(
              bottom: false,
              child: GetBuilder<RandomCallController>(
                builder: (controller) {
                  final bottomInset = MediaQuery.paddingOf(context).bottom;
                  return Column(
                    children: [
                      const _RandomHeader(),
                      const SizedBox(height: 10),
                      const _StatusPill(),
                      Expanded(
                        child: GetBuilder<RandomCallController>(
                          id: Constant.idGetListener,
                          builder: (c) => _Radar(
                            listeners: c.randomDisplayList,
                            searching: c.isLoading,
                            onReplace: c.replaceListenerAt,
                            onCoreTap: () => startMatch(c),
                          ),
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
          ],
        ),
      ),
    );
  }
}

/// Shared by the core and the button.
void startMatch(RandomCallController controller) {
  if (controller.isLoading) return;
  Sfx.select();
  controller.getaAvailableListener().then((_) {
    if (controller.randomAvailableListenerModel?.data != null) {
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
      Utils.showToast(Get.context!, controller.randomAvailableListenerModel?.message ?? 'No one is available right now. Try again in a moment.');
    }
  });
}

/// Page background: the aurora, plus a faint street-map texture under the
/// radar (light: grey blocks on white, dark: hairline grid) and a violet
/// glow that pools toward the bottom like the reference.
class _RadarBackdrop extends StatelessWidget {
  const _RadarBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          AuroraBackground(intensity: BebuTheme.isLight ? 0.6 : 1.0),
          RepaintBoundary(child: CustomPaint(painter: _MapPainter(light: BebuTheme.isLight))),
          if (BebuTheme.ambientGlow)
            Positioned(
              left: -80,
              right: -80,
              bottom: -120,
              height: 420,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      (BebuTheme.isLight ? const Color(0xFFD8B4FE) : const Color(0xFF7C3AED)).withValues(alpha: BebuTheme.isLight ? 0.35 : 0.45),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({required this.light});
  final bool light;

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.isFinite || size.isEmpty) return;
    final rnd = math.Random(7);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = (light ? Colors.black : Colors.white).withValues(alpha: light ? 0.05 : 0.045);
    final block = Paint()..color = (light ? Colors.black : Colors.white).withValues(alpha: light ? 0.035 : 0.03);
    const cell = 64.0;
    // Irregular "streets": every grid line jitters slightly.
    for (var x = -cell; x < size.width + cell; x += cell) {
      final dx = x + rnd.nextDouble() * 14 - 7;
      canvas.drawLine(Offset(dx, 0), Offset(dx + rnd.nextDouble() * 20 - 10, size.height), line);
    }
    for (var y = -cell; y < size.height + cell; y += cell) {
      final dy = y + rnd.nextDouble() * 14 - 7;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy + rnd.nextDouble() * 20 - 10), line);
    }
    // City blocks.
    for (var i = 0; i < 26; i++) {
      final w = 22 + rnd.nextDouble() * 46;
      final h = 18 + rnd.nextDouble() * 40;
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height * 0.85;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), const Radius.circular(4)), block);
    }
    // Fade the texture toward the bottom so the controls sit on a calm area.
    final fade = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.55, 1],
        colors: [Colors.transparent, BebuTheme.bg.withValues(alpha: 0.9)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, fade);
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => old.light != light;
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
              height: 38,
              onTap: () => Get.toNamed(AppRoutes.myWalletScreen)?.then((_) => Utils.onChangeStatusBar(brightness: BebuTheme.statusBarIcons)),
            ),
          ),
          const SizedBox(width: 8),
          PressScale(
            onTap: () => Get.toNamed(AppRoutes.myProfileScreen)?.then((_) => Utils.onChangeStatusBar(brightness: BebuTheme.statusBarIcons)),
            child: BebuAvatar(size: 40, ring: true, child: ListenerPhoto(image: Database.loginUserProfilePic, scrim: false)),
          ),
        ],
      ),
    );
  }
}

/// "((•)) 12 live now · Audio · Edit" — Edit opens the call-type sheet.
class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RandomCallController>(
      builder: (c) {
        final count = c.liveCount;
        final isAudio = c.selectedIndex == 0;
        return PressScale(
          scale: 0.97,
          onTap: () => showCallTypeSheet(c),
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width - 32),
            padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
            decoration: BoxDecoration(
              color: BebuTheme.surface.withValues(alpha: BebuTheme.isLight ? 0.92 : 0.82),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: BebuTheme.border),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: BebuTheme.isLight ? 0.06 : 0.3), blurRadius: 14, offset: const Offset(0, 6))],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sensors_rounded, size: 15, color: count == 0 ? BebuTheme.textFaint : BebuTheme.green),
                  const SizedBox(width: 7),
                  Text(
                    count == 0 ? 'Looking for hosts online' : '$count live now',
                    style: BebuTheme.label(size: 12.5),
                  ),
                  Container(width: 1, height: 12, margin: const EdgeInsets.symmetric(horizontal: 9), color: BebuTheme.border),
                  Icon(isAudio ? Icons.call_rounded : Icons.videocam_rounded, size: 13, color: BebuTheme.textMuted),
                  const SizedBox(width: 5),
                  Text(isAudio ? 'Audio' : 'Video', style: BebuTheme.body(size: 12.5, color: BebuTheme.textMuted)),
                  const SizedBox(width: 8),
                  Text('Edit', style: BebuTheme.label(size: 12.5, color: BebuTheme.pink)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

void showCallTypeSheet(RandomCallController c) {
  Sfx.tick();
  Get.bottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    GetBuilder<RandomCallController>(
      builder: (c) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusXl), border: Border.all(color: BebuTheme.border)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: BebuTheme.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 14),
            Text('How do you want to meet?', style: BebuTheme.title(size: 18)),
            const SizedBox(height: 4),
            Text('Coins are charged per minute once the call connects.', style: BebuTheme.body(size: 12.5, color: BebuTheme.textFaint)),
            const SizedBox(height: 14),
            for (final (i, label, icon, hint) in [
              (0, EnumLocale.txtAudioCall.name.tr, Icons.call_rounded, 'Voice only — relaxed and private'),
              (1, EnumLocale.txtVideoCall.name.tr, Icons.videocam_rounded, 'Face to face — see who you are talking to'),
            ])
              _SheetOption(
                label: label,
                hint: hint,
                icon: icon,
                selected: c.selectedIndex == i,
                onTap: () {
                  Sfx.tick();
                  c.selectCallType(i);
                  Get.back();
                },
              ),
          ],
        ),
      ),
    ),
  );
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({required this.label, required this.hint, required this.icon, required this.selected, required this.onTap});
  final String label;
  final String hint;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      scale: 0.98,
      onTap: onTap,
      child: AnimatedContainer(
        duration: BebuTheme.fast,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? BebuTheme.pink.withValues(alpha: BebuTheme.isLight ? 0.1 : 0.16) : BebuTheme.surface2,
          borderRadius: BorderRadius.circular(BebuTheme.radiusMd),
          border: Border.all(color: selected ? BebuTheme.pink.withValues(alpha: 0.6) : BebuTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: selected ? BebuTheme.pinkGradient : null, color: selected ? null : BebuTheme.surface3),
              child: Icon(icon, size: 20, color: selected ? BebuTheme.onPhoto : BebuTheme.textMuted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: BebuTheme.label(size: 14.5)),
                  const SizedBox(height: 2),
                  Text(hint, style: BebuTheme.body(size: 12, color: BebuTheme.textFaint)),
                ],
              ),
            ),
            Icon(selected ? Icons.check_circle_rounded : Icons.circle_outlined, color: selected ? BebuTheme.pink : BebuTheme.textFaint, size: 22),
          ],
        ),
      ),
    );
  }
}

/// Layered discs (the reference's proximity rings), a searching sweep, a
/// breathing pulse, hosts orbiting on the rings, anonymous chips for empty
/// slots and a tappable core.
class _Radar extends StatefulWidget {
  const _Radar({required this.listeners, required this.searching, required this.onReplace, required this.onCoreTap});

  final List<TopListeners> listeners;
  final bool searching;
  final void Function(int index) onReplace;
  final VoidCallback onCoreTap;

  @override
  State<_Radar> createState() => _RadarState();
}

class _RadarState extends State<_Radar> with TickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600));
  late final AnimationController _sweep = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  late final AnimationController _drift = AnimationController(vsync: this, duration: const Duration(seconds: 70));

  @override
  void initState() {
    super.initState();
    if (!BebuTheme.reducedMotion) {
      _pulse.repeat();
      _drift.repeat();
    }
  }

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

  // (ring, base angle, avatar size). Ring 0 is the inner disc edge.
  static const _slots = <(int, double, double)>[
    (1, -2.35, 56),
    (2, -0.75, 46),
    (1, 0.35, 34),
    (2, 1.75, 30),
    (1, 2.75, 40),
    (2, -2.95, 30),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final size = math.min(c.maxWidth, c.maxHeight);
        final radii = [size * 0.17, size * 0.33, size * 0.46];
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
                    RepaintBoundary(
                      child: CustomPaint(
                        size: Size.square(size),
                        painter: _DiscPainter(light: BebuTheme.isLight, pulse: _pulse.value, sweep: widget.searching ? _sweep.value : null, radii: radii),
                      ),
                    ),
                    for (var i = 0; i < _slots.length; i++) _slotWidget(i, radii, size),
                    _Core(searching: widget.searching, onTap: widget.onCoreTap),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _slotWidget(int i, List<double> radii, double size) {
    final slot = _slots[i];
    final dir = slot.$1.isEven ? 1 : -1;
    final angle = slot.$2 + _drift.value * 2 * math.pi * dir * 0.35;
    final r = radii[slot.$1] * (slot.$1 == 1 ? 0.92 : 0.97);
    final d = slot.$3;
    final Widget child;
    if (i < widget.listeners.length) {
      final l = widget.listeners[i];
      child = _RadarAvatar(key: ValueKey('${l.id}-$i'), listener: l, size: d, onDone: () => widget.onReplace(i));
    } else {
      child = _AnonChip(size: math.min(d, 32), seed: i);
    }
    return Positioned(
      left: size / 2 + r * math.cos(angle) - d / 2,
      top: size / 2 + r * math.sin(angle) - d / 2,
      width: d,
      height: d,
      child: Center(child: child),
    );
  }
}

class _DiscPainter extends CustomPainter {
  _DiscPainter({required this.light, required this.pulse, required this.sweep, required this.radii});
  final bool light;
  final double pulse;
  final double? sweep;
  final List<double> radii;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    // Colours tuned per palette: lavender fills on white, deep violet on dark.
    final outer = light ? const Color(0xFFC084FC) : const Color(0xFF6D28D9);
    final mid = light ? const Color(0xFFA855F7) : const Color(0xFF7E22CE);
    final inner = light ? const Color(0xFF9333EA) : const Color(0xFF9333EA);

    // Soft halo beyond the outer disc.
    canvas.drawCircle(
      center,
      radii[2] * 1.12,
      Paint()
        ..color = outer.withValues(alpha: light ? 0.28 : 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );
    // Offset secondary disc for depth (the reference's layered look).
    canvas.drawCircle(center.translate(-radii[2] * 0.12, radii[2] * 0.1), radii[2] * 0.98, Paint()..color = outer.withValues(alpha: light ? 0.22 : 0.22));

    void disc(double r, Color c, double a0, double a1) {
      canvas.drawCircle(
        center,
        r,
        Paint()..shader = RadialGradient(colors: [c.withValues(alpha: a1), c.withValues(alpha: a0)], stops: const [0.55, 1]).createShader(Rect.fromCircle(center: center, radius: r)),
      );
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white.withValues(alpha: light ? 0.55 : 0.12),
      );
    }

    disc(radii[2], outer, light ? 0.55 : 0.40, light ? 0.42 : 0.30);
    disc(radii[1], mid, light ? 0.72 : 0.62, light ? 0.60 : 0.50);
    disc(radii[0], inner, light ? 0.92 : 0.95, light ? 0.85 : 0.85);

    // Breathing pulse travelling outward.
    final pr = radii[0] + (radii[2] - radii[0]) * pulse;
    canvas.drawCircle(
      center,
      pr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = (light ? Colors.white : const Color(0xFFE9D5FF)).withValues(alpha: (1 - pulse) * (light ? 0.9 : 0.5)),
    );

    // Searching sweep.
    if (sweep != null) {
      final rect = Rect.fromCircle(center: center, radius: radii[2]);
      final start = sweep! * 2 * math.pi;
      canvas.drawArc(
        rect,
        start,
        math.pi / 2,
        true,
        Paint()
          ..shader = SweepGradient(
            startAngle: start,
            endAngle: start + math.pi / 2,
            colors: [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: light ? 0.55 : 0.35)],
          ).createShader(rect),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DiscPainter old) => old.pulse != pulse || old.sweep != sweep || old.light != light;
}

/// The reference's black / white squircle with a soft rounded-triangle glyph.
/// Tapping it starts the match; while searching it shows a spinner ring.
class _Core extends StatelessWidget {
  const _Core({required this.searching, required this.onTap});
  final bool searching;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final light = BebuTheme.isLight;
    final fill = light ? const Color(0xFF111114) : Colors.white;
    final glyph = light ? Colors.white : const Color(0xFF111114);
    return PressScale(
      scale: 0.92,
      onTap: onTap,
      child: Semantics(
        button: true,
        label: 'Find a match',
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: BebuTheme.normal,
              width: searching ? 80 : 68,
              height: searching ? 80 : 68,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(searching ? 40 : 24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: light ? 0.28 : 0.35), blurRadius: 22, offset: const Offset(0, 10)),
                  BoxShadow(color: Colors.white.withValues(alpha: light ? 0.0 : 0.5), blurRadius: searching ? 34 : 18),
                ],
              ),
              child: Center(
                child: searching
                    ? SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2.5, color: glyph))
                    : CustomPaint(size: const Size(30, 30), painter: _TriGlyphPainter(glyph)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TriGlyphPainter extends CustomPainter {
  _TriGlyphPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Rounded triangle pointing up, slightly squat like the reference mark.
    final p = Path()
      ..moveTo(w * 0.5, h * 0.14)
      ..lineTo(w * 0.92, h * 0.82)
      ..lineTo(w * 0.08, h * 0.82)
      ..close();
    canvas.drawPath(
      p,
      Paint()
        ..color = color
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = w * 0.22
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(p, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TriGlyphPainter old) => old.color != color;
}

/// Small frosted chip with a person glyph: "someone nearby" placeholder.
class _AnonChip extends StatelessWidget {
  const _AnonChip({required this.size, required this.seed});
  final double size;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final icons = [Icons.person_rounded, Icons.headset_mic_rounded, Icons.favorite_rounded, Icons.chat_bubble_rounded];
    final light = BebuTheme.isLight;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: light ? Colors.white : const Color(0xFF1B1B22),
        border: Border.all(color: light ? Colors.white : Colors.white.withValues(alpha: 0.18), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: light ? 0.14 : 0.45), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Icon(icons[seed % icons.length], size: size * 0.5, color: light ? const Color(0xFF3B0764) : BebuTheme.onPhotoMuted),
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
  late final AnimationController _c = AnimationController(vsync: this, duration: Duration(milliseconds: 6200 + math.Random().nextInt(2600)));

  @override
  void initState() {
    super.initState();
    if (BebuTheme.reducedMotion) {
      _c.value = 0.5;
    } else {
      _cycle();
    }
  }

  void _cycle() {
    _c.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      widget.onDone();
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
    final online = l.statusLabel == 'Available' || l.isOnline == true;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value;
        final opacity = t < 0.12 ? t / 0.12 : (t > 0.88 ? (1 - t) / 0.12 : 1.0);
        final scale = 0.82 + 0.18 * opacity;
        return Opacity(opacity: opacity.clamp(0, 1), child: Transform.scale(scale: scale, child: child));
      },
      child: PressScale(
        onTap: () {
          Sfx.tick();
          Get.toNamed(AppRoutes.profileDetailScreenView, arguments: l.id);
        },
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: BebuTheme.isLight ? 0.18 : 0.5), blurRadius: 14, offset: const Offset(0, 6))]),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(shape: BoxShape.circle, color: BebuTheme.isLight ? Colors.white : const Color(0xFF1B1B22)),
            child: BebuAvatar(
              size: widget.size - 4,
              online: widget.size >= 40 ? online : null,
              pulse: true,
              badgeBorder: BebuTheme.isLight ? Colors.white : const Color(0xFF1B1B22),
              child: ListenerPhoto(image: l.image, scrim: false),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Call type" label, the two chips and the match button.
class _RandomControls extends StatelessWidget {
  const _RandomControls();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RandomCallController>(
      builder: (controller) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Call type', style: BebuTheme.label(size: 14)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Coins charged per minute', textAlign: TextAlign.end, maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.body(size: 11.5, color: BebuTheme.textFaint)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _TypeChip(label: EnumLocale.txtAudioCall.name.tr, icon: Icons.call_rounded, selected: controller.selectedIndex == 0, onTap: () => controller.selectCallType(0))),
                const SizedBox(width: 8),
                Expanded(child: _TypeChip(label: EnumLocale.txtVideoCall.name.tr, icon: Icons.videocam_rounded, selected: controller.selectedIndex == 1, onTap: () => controller.selectCallType(1))),
              ],
            ),
            const SizedBox(height: 12),
            _MatchButton(loading: controller.isLoading, onTap: () => startMatch(controller)),
          ],
        );
      },
    );
  }
}

/// Reference-style chip: solid ink when selected (black on light, white on
/// dark), quiet surface otherwise.
class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.icon, required this.selected, required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final light = BebuTheme.isLight;
    final ink = light ? const Color(0xFF111114) : Colors.white;
    final onInk = light ? Colors.white : const Color(0xFF111114);
    return PressScale(
      scale: 0.95,
      onTap: () {
        Sfx.tick();
        onTap();
      },
      child: AnimatedContainer(
        duration: BebuTheme.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? ink : BebuTheme.surface.withValues(alpha: light ? 0.9 : 0.75),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? ink : BebuTheme.border),
          boxShadow: selected ? [BoxShadow(color: Colors.black.withValues(alpha: light ? 0.2 : 0.4), blurRadius: 14, offset: const Offset(0, 6))] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: selected ? onInk : BebuTheme.textMuted),
            const SizedBox(width: 6),
            Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.label(size: 13, color: selected ? onInk : BebuTheme.text))),
          ],
        ),
      ),
    );
  }
}

class _MatchButton extends StatelessWidget {
  const _MatchButton({required this.loading, required this.onTap});
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      scale: 0.94,
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: BebuTheme.fast,
        height: 52,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: BebuTheme.pinkGradient,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [BoxShadow(color: BebuTheme.pink.withValues(alpha: 0.45), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: BebuTheme.onPhoto))
            else
              const Icon(Icons.shuffle_rounded, size: 17, color: BebuTheme.onPhoto),
            const SizedBox(width: 8),
            Text(loading ? 'Finding someone…' : 'Match now', style: BebuTheme.label(size: 14.5, color: BebuTheme.onPhoto)),
          ],
        ),
      ),
    );
  }
}
