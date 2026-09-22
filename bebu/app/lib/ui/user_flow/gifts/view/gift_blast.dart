import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:talk_in/custom/motion/coin_3d.dart';
import 'package:talk_in/custom/motion/sfx.dart';
import 'package:talk_in/ui/user_flow/gifts/view/gift_picture.dart';
import 'package:talk_in/utils/app_theme.dart';

/// Full-screen gift celebration drawn in the root overlay, so it plays above
/// chat, calls or anything else. Roughly 2.6 s: the gift shoots up from the
/// bottom with a bounce, light rays and a particle burst bloom behind it, the
/// caption and coin chip pop in, then everything lifts away. Tap to skip.
class GiftBlast extends StatefulWidget {
  const GiftBlast({super.key, required this.image, required this.name, required this.accent, required this.coins, required this.toName, this.incoming = false, this.fromName = '', required this.onDone});

  final String image;
  final String name;
  final Color accent;
  final int coins;
  final String toName;
  final bool incoming;
  final String fromName;
  final VoidCallback onDone;

  static OverlayEntry? _entry;

  static void show(BuildContext context, {required String image, required String name, required Color accent, required int coins, required String toName, bool incoming = false, String fromName = ''}) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    _entry?.remove();
    _entry = null;
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => GiftBlast(
        image: image,
        name: name,
        accent: accent,
        coins: coins,
        toName: toName,
        incoming: incoming,
        fromName: fromName,
        onDone: () {
          if (_entry == entry) _entry = null;
          entry.remove();
        },
      ),
    );
    _entry = entry;
    overlay.insert(entry);
  }

  @override
  State<GiftBlast> createState() => _GiftBlastState();
}

class _GiftBlastState extends State<GiftBlast> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Spark> _sparks;
  bool _done = false;

  static const _total = Duration(milliseconds: 2600);

  @override
  void initState() {
    super.initState();
    final rnd = math.Random(widget.name.hashCode);
    _sparks = List.generate(BebuTheme.reducedMotion ? 0 : 56, (i) => _Spark.random(rnd, i));
    _c = AnimationController(vsync: this, duration: BebuTheme.reducedMotion ? const Duration(milliseconds: 900) : _total)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _finish();
      })
      ..forward();
    widget.incoming ? Sfx.giftReceived() : Sfx.giftSend();
  }

  void _finish() {
    if (_done) return;
    _done = true;
    widget.onDone();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final giftSize = math.min(size.width * 0.52, 230.0);
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _c.animateTo(1, duration: const Duration(milliseconds: 220), curve: Curves.easeIn),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            // Timeline (fractions of the whole): in 0–.22, hold, out .82–1.
            final scrim = _seg(t, 0, .18) * (1 - _seg(t, .82, 1));
            final rise = Curves.easeOutBack.transform(_seg(t, .04, .34));
            final pop = Curves.easeOutCubic.transform(_seg(t, .28, .5));
            final chip = Curves.easeOutBack.transform(_seg(t, .42, .62));
            final out = Curves.easeInCubic.transform(_seg(t, .82, 1));
            final glow = math.sin(math.min(1, _seg(t, .1, .9)) * math.pi);
            final rays = _seg(t, .16, .5);
            final wobble = math.sin(t * math.pi * 6) * (1 - _seg(t, .3, .6)) * 0.12;

            return Stack(
              fit: StackFit.expand,
              children: [
                // Scrim with an accent glow at the centre.
                Opacity(
                  opacity: scrim.clamp(0, 1),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.1),
                        radius: 0.95,
                        colors: [widget.accent.withValues(alpha: 0.42 * glow), Colors.black.withValues(alpha: 0.72), Colors.black.withValues(alpha: 0.82)],
                        stops: const [0, 0.55, 1],
                      ),
                    ),
                  ),
                ),
                // Light rays + sparks (one paint, cheap).
                if (!BebuTheme.reducedMotion)
                  RepaintBoundary(
                    child: CustomPaint(
                      painter: _BlastPainter(t: t, rays: rays * (1 - out), sparks: _sparks, accent: widget.accent, center: Alignment(0, -0.1), fade: 1 - out),
                    ),
                  ),
                // Gift, caption and chip.
                Align(
                  alignment: const Alignment(0, -0.1),
                  child: Transform.translate(
                    offset: Offset(0, (1 - rise) * size.height * 0.55 - out * 160),
                    child: Opacity(
                      opacity: (1 - out).clamp(0, 1),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.rotate(
                            angle: wobble,
                            child: Transform.scale(
                              scale: (0.55 + 0.45 * rise) * (1 + 0.04 * math.sin(t * math.pi * 2.2)),
                              child: _GlowRing(
                                accent: widget.accent,
                                strength: glow,
                                size: giftSize,
                                child: GiftPicture(image: widget.image, size: giftSize, accent: widget.accent, shadow: false),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Transform.translate(
                            offset: Offset(0, (1 - pop) * 26),
                            child: Opacity(
                              opacity: pop.clamp(0, 1),
                              child: Column(
                                children: [
                                  Text(widget.name, style: BebuTheme.display(size: 30, color: Colors.white)),
                                  const SizedBox(height: 6),
                                  Text(_caption(), textAlign: TextAlign.center, style: BebuTheme.body(size: 15, color: Colors.white.withValues(alpha: 0.82))),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Transform.scale(
                            scale: chip.clamp(0, 1.2),
                            child: Opacity(opacity: chip.clamp(0, 1), child: _CoinChip(coins: widget.coins, incoming: widget.incoming, accent: widget.accent)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 36 + MediaQuery.paddingOf(context).bottom,
                  child: Opacity(
                    opacity: (scrim * 0.7).clamp(0, 1),
                    child: Text('Tap to continue', textAlign: TextAlign.center, style: BebuTheme.label(size: 12, color: Colors.white.withValues(alpha: 0.6))),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _caption() {
    if (widget.incoming) return '${widget.fromName.isEmpty ? 'Someone' : widget.fromName} sent you a gift';
    return widget.toName.isEmpty ? 'Gift sent' : 'Sent to ${widget.toName}';
  }

  static double _seg(double t, double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);
}

class _GlowRing extends StatelessWidget {
  const _GlowRing({required this.accent, required this.strength, required this.size, required this.child});
  final Color accent;
  final double strength;
  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: accent.withValues(alpha: 0.55 * strength), blurRadius: size * 0.42, spreadRadius: size * 0.04),
          BoxShadow(color: Colors.white.withValues(alpha: 0.18 * strength), blurRadius: size * 0.2),
        ],
      ),
      child: Padding(padding: EdgeInsets.all(size * 0.06), child: child),
    );
  }
}

class _CoinChip extends StatelessWidget {
  const _CoinChip({required this.coins, required this.incoming, required this.accent});
  final int coins;
  final bool incoming;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Coin3D(size: 20),
          const SizedBox(width: 8),
          Text(incoming ? '+$coins coins earned' : '$coins coins', style: BebuTheme.label(size: 14, color: Colors.white)),
        ],
      ),
    );
  }
}

class _Spark {
  _Spark({required this.angle, required this.speed, required this.size, required this.kind, required this.delay, required this.spin});
  final double angle;
  final double speed;
  final double size;
  final int kind; // 0 dot, 1 star, 2 heart
  final double delay;
  final double spin;

  factory _Spark.random(math.Random r, int i) => _Spark(
        angle: r.nextDouble() * math.pi * 2,
        speed: 0.35 + r.nextDouble() * 0.65,
        size: 3 + r.nextDouble() * 7,
        kind: i % 5 == 0 ? 2 : (i % 3 == 0 ? 1 : 0),
        delay: r.nextDouble() * 0.12,
        spin: (r.nextDouble() - 0.5) * 6,
      );
}

class _BlastPainter extends CustomPainter {
  _BlastPainter({required this.t, required this.rays, required this.sparks, required this.accent, required this.center, required this.fade});
  final double t;
  final double rays;
  final List<_Spark> sparks;
  final Color accent;
  final Alignment center;
  final double fade;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || fade <= 0) return;
    final c = Offset(size.width / 2 + center.x * size.width / 2, size.height / 2 + center.y * size.height / 2);
    final maxR = size.shortestSide * 0.62;

    // Rotating light rays.
    if (rays > 0) {
      final rayPaint = Paint()
        ..shader = RadialGradient(colors: [Colors.white.withValues(alpha: 0.22 * rays * fade), accent.withValues(alpha: 0.10 * rays * fade), Colors.transparent], stops: const [0, 0.5, 1]).createShader(Rect.fromCircle(center: c, radius: maxR))
        ..blendMode = BlendMode.plus;
      final rot = t * math.pi * 0.6;
      const n = 14;
      for (var i = 0; i < n; i++) {
        final a = rot + i * math.pi * 2 / n;
        final w = 0.09 + 0.04 * math.sin(i * 1.7);
        final path = Path()
          ..moveTo(c.dx, c.dy)
          ..lineTo(c.dx + math.cos(a - w) * maxR * rays, c.dy + math.sin(a - w) * maxR * rays)
          ..lineTo(c.dx + math.cos(a + w) * maxR * rays, c.dy + math.sin(a + w) * maxR * rays)
          ..close();
        canvas.drawPath(path, rayPaint);
      }
    }

    // Particle burst: launched at ~0.3, out by ~0.9.
    final p = ((t - 0.3) / 0.6).clamp(0.0, 1.0);
    if (p <= 0) return;
    final paint = Paint();
    for (final s in sparks) {
      final lp = ((p - s.delay) / (1 - s.delay)).clamp(0.0, 1.0);
      if (lp <= 0) continue;
      final ease = 1 - math.pow(1 - lp, 3).toDouble();
      final dist = ease * maxR * s.speed;
      final gravity = lp * lp * 60;
      final pos = Offset(c.dx + math.cos(s.angle) * dist, c.dy + math.sin(s.angle) * dist + gravity);
      final alpha = (1 - lp) * fade;
      final color = s.kind == 2 ? const Color(0xFFFF5FA2) : (s.kind == 1 ? Colors.white : accent);
      paint.color = color.withValues(alpha: alpha.clamp(0, 1));
      final sz = s.size * (1 - lp * 0.4);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(s.spin * lp);
      switch (s.kind) {
        case 1:
          _star(canvas, sz, paint);
          break;
        case 2:
          _heart(canvas, sz, paint);
          break;
        default:
          canvas.drawCircle(Offset.zero, sz * 0.5, paint);
      }
      canvas.restore();
    }
  }

  void _star(Canvas canvas, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final rad = i.isEven ? r : r * 0.4;
      final a = i * math.pi / 4;
      final pt = Offset(math.cos(a) * rad, math.sin(a) * rad);
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _heart(Canvas canvas, double r, Paint paint) {
    final path = Path()
      ..moveTo(0, r * 0.9)
      ..cubicTo(-r * 1.3, r * 0.1, -r * 0.7, -r * 0.9, 0, -r * 0.3)
      ..cubicTo(r * 0.7, -r * 0.9, r * 1.3, r * 0.1, 0, r * 0.9)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BlastPainter old) => old.t != t || old.fade != fade;
}
