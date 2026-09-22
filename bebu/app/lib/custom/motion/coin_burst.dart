import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:talk_in/utils/app_theme.dart';

/// One-shot celebration: coins and confetti burst from [origin] (fractional
/// offset of the widget's size), fly out with gravity, spin and fade.
/// Draws with a single [CustomPainter] so a few dozen particles cost one
/// layer; wrap it in a [RepaintBoundary] (done here) and lay it over content
/// with an [IgnorePointer].
class CoinBurst extends StatefulWidget {
  const CoinBurst({
    super.key,
    this.coins = 26,
    this.confetti = 44,
    this.origin = const Alignment(0, -0.2),
    this.duration = const Duration(milliseconds: 2600),
    this.delay = Duration.zero,
    this.repeat = false,
    this.onDone,
  });

  final int coins;
  final int confetti;
  final Alignment origin;
  final Duration duration;
  final Duration delay;
  final bool repeat;
  final VoidCallback? onDone;

  @override
  State<CoinBurst> createState() => _CoinBurstState();
}

class _CoinBurstState extends State<CoinBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.duration);
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random(7);
    _particles = [
      for (var i = 0; i < widget.coins; i++) _Particle.coin(rnd),
      for (var i = 0; i < widget.confetti; i++) _Particle.confetti(rnd, BebuTheme.accent),
    ];
    if (BebuTheme.reducedMotion) return;
    Future.delayed(widget.delay, () {
      if (!mounted) return;
      if (widget.repeat) {
        _c.repeat();
      } else {
        _c.forward().whenComplete(() => widget.onDone?.call());
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) => CustomPaint(
            painter: _BurstPainter(_particles, _c.value, widget.origin),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.spin,
    required this.color,
    required this.isCoin,
    required this.drift,
    required this.delay,
  });

  final double angle; // launch direction, radians
  final double speed; // fraction of min(width,height) per second
  final double size;
  final double spin;
  final Color color;
  final bool isCoin;
  final double drift; // horizontal sway
  final double delay; // 0..0.25 of the timeline

  factory _Particle.coin(math.Random r) {
    // Mostly upwards, fan of ~150°.
    final a = -math.pi / 2 + (r.nextDouble() - 0.5) * math.pi * 0.85;
    return _Particle(
      angle: a,
      speed: 0.9 + r.nextDouble() * 1.1,
      size: 12 + r.nextDouble() * 12,
      spin: (r.nextDouble() - 0.5) * 8,
      color: const Color(0xFFFFC44D),
      isCoin: true,
      drift: (r.nextDouble() - 0.5) * 0.3,
      delay: r.nextDouble() * 0.12,
    );
  }

  factory _Particle.confetti(math.Random r, BebuAccent accent) {
    final palette = [accent.light, accent.primary, BebuTheme.violet, const Color(0xFFA78BFA), BebuTheme.green, BebuTheme.blue, Colors.white];
    final a = -math.pi / 2 + (r.nextDouble() - 0.5) * math.pi * 1.4;
    return _Particle(
      angle: a,
      speed: 0.7 + r.nextDouble() * 1.4,
      size: 5 + r.nextDouble() * 6,
      spin: (r.nextDouble() - 0.5) * 14,
      color: palette[r.nextInt(palette.length)],
      isCoin: false,
      drift: (r.nextDouble() - 0.5) * 0.6,
      delay: r.nextDouble() * 0.2,
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter(this.particles, this.t, this.origin);

  final List<_Particle> particles;
  final double t;
  final Alignment origin;

  static const _gravity = 1.9; // fraction of min side per s²

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0) return;
    final base = math.min(size.width, size.height);
    final o = Offset(size.width * (origin.x + 1) / 2, size.height * (origin.y + 1) / 2);
    final paint = Paint();
    final total = 2.6; // seconds represented by t=1

    for (final p in particles) {
      final lt = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (lt <= 0) continue;
      final s = lt * total; // seconds since launch
      final vx = math.cos(p.angle) * p.speed * base;
      final vy = math.sin(p.angle) * p.speed * base;
      final x = o.dx + vx * s * 0.55 + math.sin(s * 5 + p.angle) * p.drift * base * 0.08;
      final y = o.dy + vy * s * 0.55 + 0.5 * _gravity * base * s * s * 0.45;
      if (y > size.height + 40) continue;

      final fade = lt < 0.75 ? 1.0 : (1 - (lt - 0.75) / 0.25).clamp(0.0, 1.0);
      final pop = lt < 0.08 ? Curves.easeOutBack.transform(lt / 0.08) : 1.0;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spin * s);
      canvas.scale(pop);

      if (p.isCoin) {
        // Flip by squashing the x axis; the coin is a disc with a rim.
        final flip = math.cos(s * 6 + p.angle).abs().clamp(0.18, 1.0);
        canvas.scale(flip, 1);
        final r = p.size / 2;
        paint
          ..style = PaintingStyle.fill
          ..shader = RadialGradient(center: const Alignment(-0.35, -0.35), colors: [const Color(0xFFFFE08A), p.color, const Color(0xFFD98A00)], stops: const [0, 0.55, 1])
              .createShader(Rect.fromCircle(center: Offset.zero, radius: r))
          ..color = p.color.withValues(alpha: fade);
        canvas.drawCircle(Offset.zero, r, paint..color = paint.color.withValues(alpha: fade));
        paint
          ..shader = null
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, r * 0.18)
          ..color = const Color(0xFFB86E00).withValues(alpha: fade);
        canvas.drawCircle(Offset.zero, r * 0.78, paint);
        // star glint
        paint
          ..style = PaintingStyle.fill
          ..color = Colors.white.withValues(alpha: 0.85 * fade);
        canvas.drawCircle(Offset(-r * 0.3, -r * 0.3), r * 0.16, paint);
      } else {
        paint
          ..shader = null
          ..style = PaintingStyle.fill
          ..color = p.color.withValues(alpha: fade);
        final w = p.size, h = p.size * 0.55;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: w, height: h), Radius.circular(h / 3)), paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter old) => old.t != t;
}

/// Pulsing rings that expand behind a hero element (used behind the big coin
/// on the purchase-success screen).
class PulseRings extends StatefulWidget {
  const PulseRings({super.key, required this.color, this.size = 220, this.rings = 3});
  final Color color;
  final double size;
  final int rings;

  @override
  State<PulseRings> createState() => _PulseRingsState();
}

class _PulseRingsState extends State<PulseRings> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));

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
    return IgnorePointer(
      child: RepaintBoundary(
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) => CustomPaint(painter: _RingsPainter(_c.value, widget.color, widget.rings)),
          ),
        ),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  _RingsPainter(this.t, this.color, this.rings);
  final double t;
  final Color color;
  final int rings;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final maxR = size.width / 2;
    final paint = Paint()..style = PaintingStyle.stroke;
    for (var i = 0; i < rings; i++) {
      final k = (t + i / rings) % 1;
      final r = maxR * (0.35 + 0.65 * k);
      paint
        ..strokeWidth = 2 - k
        ..color = color.withValues(alpha: (1 - k) * 0.45);
      canvas.drawCircle(c, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter old) => old.t != t;
}
