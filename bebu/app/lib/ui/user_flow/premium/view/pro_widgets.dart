import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/motion/sfx.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/pro.dart';

/// Golden verified tick shown next to a Pro user's name. A slow specular
/// sweep runs across the gold when [animate] is on (keep it off in lists).
class GoldenTick extends StatefulWidget {
  const GoldenTick({super.key, this.size = 18, this.animate = false});
  final double size;
  final bool animate;

  @override
  State<GoldenTick> createState() => _GoldenTickState();
}

class _GoldenTickState extends State<GoldenTick> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));

  @override
  void initState() {
    super.initState();
    if (widget.animate && !BebuTheme.reducedMotion) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant GoldenTick old) {
    super.didUpdateWidget(old);
    final on = widget.animate && !BebuTheme.reducedMotion;
    if (on && !_c.isAnimating) _c.repeat();
    if (!on && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = Icon(Icons.verified_rounded, size: widget.size, color: Colors.white);
    return Semantics(
      label: '${Pro.name} member',
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final t = _c.value;
          return ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (r) => LinearGradient(
              begin: Alignment(-1 + 3 * t - 1.5, -1),
              end: Alignment(-1 + 3 * t + 0.5, 1),
              colors: const [Color(0xFFC98A12), Color(0xFFF5C451), Color(0xFFFFF3C4), Color(0xFFF5C451), Color(0xFFC98A12)],
              stops: const [0, 0.35, 0.5, 0.65, 1],
            ).createShader(r),
            child: icon,
          );
        },
      ),
    );
  }
}

/// Name + optional golden tick, ellipsised. Drop-in for a bare [Text].
class NameWithTick extends StatelessWidget {
  const NameWithTick({super.key, required this.name, required this.style, this.showTick = false, this.tickSize, this.gap = 4, this.maxLines = 1, this.textAlign});
  final String name;
  final TextStyle style;
  final bool showTick;
  final double? tickSize;
  final double gap;
  final int maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final text = Text(name, maxLines: maxLines, overflow: TextOverflow.ellipsis, style: style, textAlign: textAlign);
    if (!showTick) return text;
    final size = tickSize ?? ((style.fontSize ?? 14) * 1.05);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: textAlign == TextAlign.center ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [Flexible(child: text), SizedBox(width: gap), GoldenTick(size: size)],
    );
  }
}

/// Small "PRO" gold pill.
class ProPill extends StatelessWidget {
  const ProPill({super.key, this.label, this.dense = false, this.onTap});
  final String? label;
  final bool dense;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 7 : 10, vertical: dense ? 2 : 4),
      decoration: BoxDecoration(
        gradient: BebuTheme.goldGradient,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [BoxShadow(color: BebuTheme.gold.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded, size: dense ? 11 : 13, color: const Color(0xFF3B2A05)),
          SizedBox(width: dense ? 3 : 4),
          Text(label ?? 'PRO', style: BebuTheme.label(size: dense ? 9.5 : 11, color: const Color(0xFF3B2A05), weight: FontWeight.w800)),
        ],
      ),
    );
    return onTap == null ? pill : GestureDetector(onTap: onTap, child: pill);
  }
}

/// The bebu Pro crest: a gold rounded shield with a crown, on a soft glow.
class ProCrest extends StatelessWidget {
  const ProCrest({super.key, this.size = 88, this.glow = true});
  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: BebuTheme.goldGradient,
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: glow ? [BoxShadow(color: BebuTheme.gold.withValues(alpha: 0.45), blurRadius: size * 0.5, spreadRadius: size * 0.04)] : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * 0.08,
            left: size * 0.1,
            right: size * 0.1,
            child: Container(
              height: size * 0.32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.2),
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0)]),
              ),
            ),
          ),
          Icon(Icons.workspace_premium_rounded, size: size * 0.56, color: const Color(0xFF3B2A05)),
        ],
      ),
    );
  }
}

/// Bottom sheet shown wherever a free user hits a Pro-only perk.
class ProUpsellSheet extends StatelessWidget {
  const ProUpsellSheet({super.key, required this.title, required this.body, this.icon = Icons.workspace_premium_rounded, this.extra});
  final String title;
  final String body;
  final IconData icon;
  final Widget? extra;

  /// Returns true if the user went to the Pro screen.
  static Future<bool> show(BuildContext context, {required String title, required String body, IconData icon = Icons.workspace_premium_rounded, Widget? extra}) async {
    if (!Pro.enabled) return false;
    Sfx.deny();
    final r = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ProUpsellSheet(title: title, body: body, icon: icon, extra: extra),
    );
    return r == true;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      padding: EdgeInsets.fromLTRB(20, 14, 20, 16 + bottom),
      decoration: BoxDecoration(
        color: BebuTheme.surface,
        borderRadius: BorderRadius.circular(BebuTheme.radiusXl),
        border: Border.all(color: BebuTheme.gold.withValues(alpha: 0.35)),
        boxShadow: [BoxShadow(color: BebuTheme.gold.withValues(alpha: 0.18), blurRadius: 40, offset: const Offset(0, -6))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: BebuTheme.borderStrong, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 18),
          ProCrest(size: 72),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: BebuTheme.title(size: 20)),
          const SizedBox(height: 8),
          Text(body, textAlign: TextAlign.center, style: BebuTheme.body(size: 13.5)),
          if (extra != null) ...[const SizedBox(height: 14), extra!],
          const SizedBox(height: 18),
          GradientButton(
            label: 'See ${Pro.name}',
            icon: Icons.workspace_premium_rounded,
            gradient: BebuTheme.goldGradient,
            glow: BebuTheme.gold,
            onTap: () {
              Navigator.of(context).pop(true);
              Get.toNamed(AppRoutes.pro);
            },
          ),
          const SizedBox(height: 8),
          GhostButton(label: 'Not now', height: 48, onTap: () => Navigator.of(context).pop(false)),
        ],
      ),
    );
  }
}

/// Full-screen celebration when a pass activates: a gold burst, the crest
/// dropping in with a ring shockwave, the pass name and a golden tick reveal.
class ProBlast extends StatefulWidget {
  const ProBlast({super.key, required this.passName, required this.untilLabel, required this.onDone});
  final String passName;
  final String untilLabel;
  final VoidCallback onDone;

  static Future<void> show(BuildContext context, {required String passName, required String untilLabel}) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    final done = Completer<void>();
    entry = OverlayEntry(
      builder: (_) => ProBlast(
        passName: passName,
        untilLabel: untilLabel,
        onDone: () {
          entry.remove();
          if (!done.isCompleted) done.complete();
        },
      ),
    );
    overlay.insert(entry);
    return done.future;
  }

  @override
  State<ProBlast> createState() => _ProBlastState();
}

class _ProBlastState extends State<ProBlast> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3400));
  late final List<_Spark> _sparks = List.generate(BebuTheme.reducedMotion ? 0 : 70, (i) => _Spark(i));

  @override
  void initState() {
    super.initState();
    Sfx.unlock();
    Future.delayed(const Duration(milliseconds: 420), Sfx.mediumTap);
    Future.delayed(const Duration(milliseconds: 1250), Sfx.lightTap);
    _c.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: GestureDetector(
          onTap: () {
            if (_c.value > 0.45) _c.animateTo(1, duration: const Duration(milliseconds: 220));
          },
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final t = _c.value;
              final fadeIn = Curves.easeOut.transform((t / 0.12).clamp(0, 1));
              final fadeOut = 1 - Curves.easeIn.transform(((t - 0.86) / 0.14).clamp(0, 1));
              final alpha = fadeIn * fadeOut;
              final drop = Curves.elasticOut.transform(((t - 0.08) / 0.42).clamp(0, 1));
              final textIn = Curves.easeOutCubic.transform(((t - 0.36) / 0.22).clamp(0, 1));
              final tickIn = Curves.elasticOut.transform(((t - 0.5) / 0.3).clamp(0, 1));
              final size = MediaQuery.sizeOf(context);
              return Opacity(
                opacity: alpha,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(center: const Alignment(0, -0.2), radius: 1.1, colors: [const Color(0xFF3A2A05).withValues(alpha: 0.96), const Color(0xFF0B0A0E).withValues(alpha: 0.97)]),
                      ),
                    ),
                    RepaintBoundary(child: CustomPaint(painter: _GoldBurstPainter(t: t, sparks: _sparks, center: Offset(size.width / 2, size.height * 0.4)))),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 3),
                        Transform.translate(
                          offset: Offset(0, (1 - drop) * -140),
                          child: Transform.scale(scale: 0.6 + 0.4 * drop, child: const ProCrest(size: 124)),
                        ),
                        const SizedBox(height: 26),
                        Opacity(
                          opacity: textIn,
                          child: Transform.translate(
                            offset: Offset(0, (1 - textIn) * 16),
                            child: Column(
                              children: [
                                Text('Welcome to ${Pro.name}', style: BebuTheme.display(size: 30, color: Colors.white)),
                                const SizedBox(height: 8),
                                Text(widget.passName, style: BebuTheme.title(size: 16, color: BebuTheme.gold)),
                                const SizedBox(height: 4),
                                Text(widget.untilLabel, style: BebuTheme.body(size: 13, color: Colors.white.withValues(alpha: 0.7))),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Transform.scale(
                          scale: tickIn,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(999), border: Border.all(color: BebuTheme.gold.withValues(alpha: 0.5))),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const GoldenTick(size: 20, animate: true),
                                const SizedBox(width: 8),
                                Text('Golden tick unlocked', style: BebuTheme.label(size: 13, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(flex: 4),
                        Opacity(opacity: textIn, child: Text('Tap to continue', style: BebuTheme.label(size: 12, color: Colors.white.withValues(alpha: 0.45), weight: FontWeight.w500))),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Spark {
  _Spark(int i) {
    final r = math.Random(i * 7919);
    angle = r.nextDouble() * math.pi * 2;
    speed = 140 + r.nextDouble() * 260;
    size = 2 + r.nextDouble() * 4;
    delay = r.nextDouble() * 0.12;
    spin = r.nextDouble() * 6;
    gold = r.nextDouble() > 0.35;
  }
  late final double angle, speed, size, delay, spin;
  late final bool gold;
}

class _GoldBurstPainter extends CustomPainter {
  _GoldBurstPainter({required this.t, required this.sparks, required this.center});
  final double t;
  final List<_Spark> sparks;
  final Offset center;

  @override
  void paint(Canvas canvas, Size size) {
    // Shockwave rings.
    for (var i = 0; i < 2; i++) {
      final p = ((t - 0.1 - i * 0.08) / 0.7).clamp(0.0, 1.0);
      if (p <= 0 || p >= 1) continue;
      final r = ui.lerpDouble(40, size.shortestSide * 0.9, Curves.easeOut.transform(p))!;
      canvas.drawCircle(center, r, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * (1 - p)
        ..color = BebuTheme.gold.withValues(alpha: (1 - p) * 0.55));
    }
    // Sparks.
    final paint = Paint();
    for (final s in sparks) {
      final p = ((t - 0.1 - s.delay) / 0.85).clamp(0.0, 1.0);
      if (p <= 0) continue;
      final e = Curves.easeOutCubic.transform(p);
      final d = s.speed * e;
      final pos = center + Offset(math.cos(s.angle) * d, math.sin(s.angle) * d + 60 * p * p);
      paint.color = (s.gold ? BebuTheme.gold : Colors.white).withValues(alpha: (1 - p) * 0.95);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(s.spin * p);
      final sz = s.size * (1 - p * 0.4);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: sz, height: sz * 1.6), Radius.circular(sz * 0.3)), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _GoldBurstPainter old) => old.t != t;
}
