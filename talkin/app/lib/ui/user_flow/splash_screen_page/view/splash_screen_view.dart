import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/controller/splash_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/utils.dart';

/// Welcome splash: the logo rises out of a violet glow while the controller
/// loads configuration and decides where to route.
class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light);
    return Scaffold(
      backgroundColor: BebuTheme.bg,
      body: AuroraBackground(
        intensity: 1.5,
        child: GetBuilder<SplashScreenController>(
          builder: (_) => const _SplashBody(),
        ),
      ),
    );
  }
}

class _SplashBody extends StatefulWidget {
  const _SplashBody();

  @override
  State<_SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<_SplashBody> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();
  late final AnimationController _rings = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();

  @override
  void dispose() {
    _intro.dispose();
    _rings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoIn = CurvedAnimation(parent: _intro, curve: const Interval(0, 0.6, curve: Curves.easeOutBack));
    final textIn = CurvedAnimation(parent: _intro, curve: const Interval(0.45, 1, curve: Curves.easeOutCubic));
    return SafeArea(
      child: Column(
        children: [
          const Spacer(flex: 5),
          AnimatedBuilder(
            animation: Listenable.merge([_intro, _rings]),
            builder: (context, _) {
              return SizedBox(
                width: 260,
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    for (var i = 0; i < 3; i++)
                      Builder(builder: (_) {
                        final t = (_rings.value + i / 3) % 1.0;
                        return Container(
                          width: 120 + 140 * t,
                          height: 120 + 140 * t,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: BebuTheme.violet.withValues(alpha: (1 - t) * 0.45 * _intro.value), width: 1.5),
                          ),
                        );
                      }),
                    Transform.scale(
                      scale: 0.6 + 0.4 * logoIn.value,
                      child: Opacity(
                        opacity: logoIn.value.clamp(0, 1),
                        child: Container(
                          width: 116,
                          height: 116,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [BoxShadow(color: BebuTheme.violet.withValues(alpha: 0.55), blurRadius: 48, offset: const Offset(0, 16))],
                          ),
                          child: ClipRRect(borderRadius: BorderRadius.circular(32), child: Image.asset(AppAsset.appLogo, fit: BoxFit.cover)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: textIn,
            builder: (context, child) => Opacity(
              opacity: textIn.value,
              child: Transform.translate(offset: Offset(0, (1 - textIn.value) * 14), child: child),
            ),
            child: Column(
              children: [
                Text('bebu', style: BebuTheme.display(size: 40)),
                const SizedBox(height: 8),
                Text('Real people. Real conversations.', style: BebuTheme.body(size: 15, color: BebuTheme.textMuted)),
              ],
            ),
          ),
          const Spacer(flex: 6),
          const _LoadingBar(),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

/// Thin indeterminate bar that reads as "getting things ready".
class _LoadingBar extends StatefulWidget {
  const _LoadingBar();

  @override
  State<_LoadingBar> createState() => _LoadingBarState();
}

class _LoadingBarState extends State<_LoadingBar> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 120,
          height: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(color: BebuTheme.surface3),
                AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) {
                    final t = Curves.easeInOut.transform(_c.value);
                    return Align(
                      alignment: Alignment(-1.6 + 3.2 * t, 0),
                      child: Container(width: 44, height: 4, decoration: const BoxDecoration(gradient: BebuTheme.violetGradient, borderRadius: BorderRadius.all(Radius.circular(999)))),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('Getting things ready', style: BebuTheme.body(size: 12, color: BebuTheme.textFaint)),
      ],
    );
  }
}
