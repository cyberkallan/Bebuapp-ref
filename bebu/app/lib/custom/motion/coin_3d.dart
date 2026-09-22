import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:talk_in/utils/app_theme.dart';

/// Vector gold coin drawn with a real edge, so it reads as a solid disc
/// instead of a flat sticker. [yaw] is the rotation around the vertical axis
/// (0 = facing the viewer, π/2 = edge on); [pitch] is a small tilt towards
/// the light so the top rim catches a highlight.
///
/// Everything is computed from [size], so the same painter serves a 12 px
/// inline icon and a 120 px hero. There are no shaders allocated per frame
/// except the face gradient, which is cheap; the widget is wrapped in a
/// [RepaintBoundary] by the animated callers.
class Coin3D extends StatelessWidget {
  const Coin3D({super.key, this.size = 24, this.yaw = -0.42, this.pitch = 0.12, this.shine = 0});

  final double size;
  final double yaw;
  final double pitch;

  /// 0..1 position of a travelling specular sweep across the face, or 0 for none.
  final double shine;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: Coin3DPainter(yaw: yaw, pitch: pitch, shine: shine)),
    );
  }
}

class Coin3DPainter extends CustomPainter {
  const Coin3DPainter({required this.yaw, this.pitch = 0.12, this.shine = 0});

  final double yaw;
  final double pitch;
  final double shine;

  // Gold palette: face light → mid → deep; edge (side) darker with a hot rim.
  static const _faceLight = Color(0xFFFFF0B3);
  static const _faceMid = Color(0xFFFFC53D);
  static const _faceDeep = Color(0xFFE08E00);
  static const _edgeDark = Color(0xFF9A5A00);
  static const _edgeMid = Color(0xFFC77A00);
  static const _edgeLight = Color(0xFFFFD87A);
  static const _relief = Color(0xFFB86E00);

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final c = size.center(Offset.zero);
    // Coin thickness relative to radius; visible width of the face is |cos yaw|.
    final thickness = r * 0.2;
    final cosY = math.cos(yaw);
    final sinY = math.sin(yaw);
    final faceW = r * cosY.abs().clamp(0.06, 1.0);
    final faceH = r * (1 - 0.04 * pitch.abs());
    // Edge is offset opposite to the direction the face is turned.
    final edgeShift = Offset(-thickness * sinY, thickness * 0.35 * pitch);

    // ---- drop shadow under the coin
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(0, r * 0.12), width: faceW * 1.9, height: faceH * 1.6),
      Paint()
        ..color = const Color(0x40000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.18),
    );

    // ---- side (the "thickness"): sweep the ellipse between back and front
    final steps = r > 20 ? 6 : 3;
    for (var i = steps; i >= 1; i--) {
      final k = i / steps;
      final center = c + edgeShift * k;
      final t = (1 - k);
      final color = Color.lerp(_edgeDark, _edgeMid, t)!;
      canvas.drawOval(Rect.fromCenter(center: center, width: faceW * 2, height: faceH * 2), Paint()..color = color);
    }
    // Rim highlight on the lit side of the edge.
    if (sinY.abs() > 0.05) {
      final rimRect = Rect.fromCenter(center: c + edgeShift * 0.5, width: faceW * 2, height: faceH * 2);
      canvas.drawOval(
        rimRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, r * 0.06)
          ..color = _edgeLight.withValues(alpha: 0.55 * sinY.abs()),
      );
    }

    // ---- face
    final faceRect = Rect.fromCenter(center: c, width: faceW * 2, height: faceH * 2);
    canvas.drawOval(
      faceRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.45, -0.5),
          radius: 1.1,
          colors: const [_faceLight, _faceMid, _faceDeep],
          stops: const [0, 0.45, 1],
        ).createShader(faceRect),
    );
    // Outer bevel: dark bottom-right, light top-left.
    final bevelW = math.max(1.0, r * 0.07);
    canvas.drawOval(
      faceRect.deflate(bevelW / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = bevelW
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF6D0), Color(0x00FFFFFF), Color(0xAA9A5A00)],
          stops: [0, 0.5, 1],
        ).createShader(faceRect),
    );
    // Inner ring (the raised lip around the relief), squashed with the face.
    canvas.drawOval(
      faceRect.deflate(r * 0.22),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.8, r * 0.045)
        ..color = _relief.withValues(alpha: 0.55),
    );
    canvas.drawOval(
      faceRect.deflate(r * 0.22).shift(Offset(0, -math.max(0.6, r * 0.03))),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.6, r * 0.03)
        ..color = _faceLight.withValues(alpha: 0.65),
    );

    // ---- relief: embossed star, squashed horizontally with the face
    if (r >= 7) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.scale(faceW / r, faceH / r);
      final star = _starPath(r * 0.42);
      // Shadow (down-right) then light (up-left) then fill.
      canvas.drawPath(star.shift(Offset(r * 0.04, r * 0.05)), Paint()..color = _edgeDark.withValues(alpha: 0.95));
      canvas.drawPath(star.shift(Offset(-r * 0.02, -r * 0.025)), Paint()..color = _faceLight.withValues(alpha: 0.9));
      canvas.drawPath(
        star,
        Paint()
          ..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFE28F), _faceDeep])
              .createShader(Rect.fromCircle(center: Offset.zero, radius: r * 0.42)),
      );
      canvas.restore();
    }

    // ---- specular: soft ellipse at top-left, plus an optional travelling sweep
    canvas.save();
    canvas.clipPath(Path()..addOval(faceRect));
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(-faceW * 0.38, -faceH * 0.45), width: faceW * 0.9, height: faceH * 0.45),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.12),
    );
    if (shine > 0 && shine < 1) {
      final x = faceRect.left - faceW * 0.8 + shine * (faceRect.width + faceW * 1.6);
      canvas.save();
      canvas.translate(x, c.dy);
      canvas.rotate(-0.55);
      final band = Rect.fromCenter(center: Offset.zero, width: faceW * 0.32, height: faceH * 3);
      canvas.drawRect(
        band,
        Paint()
          ..shader = LinearGradient(colors: [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: 0.75), Colors.white.withValues(alpha: 0)]).createShader(band),
      );
      canvas.restore();
    }
    canvas.restore();
  }

  static Path _starPath(double radius) {
    final p = Path();
    const points = 5;
    final inner = radius * 0.46;
    for (var i = 0; i < points * 2; i++) {
      final rr = i.isEven ? radius : inner;
      final a = -math.pi / 2 + i * math.pi / points;
      final pt = Offset(math.cos(a) * rr, math.sin(a) * rr);
      if (i == 0) {
        p.moveTo(pt.dx, pt.dy);
      } else {
        p.lineTo(pt.dx, pt.dy);
      }
    }
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(covariant Coin3DPainter old) => old.yaw != yaw || old.pitch != pitch || old.shine != shine;
}

/// Choreography for an idle coin: it rests almost face-on with a slow
/// breathing wobble, then once per cycle turns a full revolution with an
/// ease-in-out and a light sweep as it lands. [t] is 0..1 over the cycle.
class CoinMotion {
  const CoinMotion._();

  static const double flipPortion = 0.28; // fraction of the cycle spent turning

  static double yaw(double t) {
    const rest = -0.42; // resting angle: turned enough that the edge reads
    if (t < flipPortion) {
      final k = Curves.easeInOutCubic.transform(t / flipPortion);
      return rest + k * math.pi * 2;
    }
    final w = (t - flipPortion) / (1 - flipPortion);
    return rest + 0.12 * math.sin(w * math.pi * 2);
  }

  static double pitch(double t) => 0.12 + 0.05 * math.sin(t * math.pi * 2);

  static double shine(double t) {
    // Sweep just after the flip finishes.
    const start = flipPortion + 0.02, len = 0.16;
    if (t < start || t > start + len) return 0;
    return (t - start) / len;
  }
}

/// Self-driven idle coin (see [CoinMotion]). Static when the admin turns the
/// coin animation off or motion is reduced.
class SpinningCoin extends StatefulWidget {
  const SpinningCoin({super.key, this.size = 24, this.period = const Duration(milliseconds: 5200), this.delay = Duration.zero});

  final double size;
  final Duration period;
  final Duration delay;

  @override
  State<SpinningCoin> createState() => _SpinningCoinState();
}

class _SpinningCoinState extends State<SpinningCoin> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.period);

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void reassemble() {
    super.reassemble();
    _sync();
  }

  void _sync() {
    if (BebuTheme.coinAnimation) {
      if (!_c.isAnimating) {
        Future.delayed(widget.delay, () {
          if (mounted && BebuTheme.coinAnimation) _c.repeat();
        });
      }
    } else {
      _c.stop();
      _c.value = 0.5;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: AnimatedCoin3D(progress: _c, size: widget.size));
  }
}

/// [Coin3D] driven by an external 0..1 animation using [CoinMotion].
class AnimatedCoin3D extends StatelessWidget {
  const AnimatedCoin3D({super.key, required this.progress, this.size = 24});

  final Animation<double> progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (_, __) {
        final t = progress.value;
        return Coin3D(size: size, yaw: CoinMotion.yaw(t), pitch: CoinMotion.pitch(t), shine: CoinMotion.shine(t));
      },
    );
  }
}

/// Small pile of coins seen from slightly above, for the pack cards: bigger
/// packs get taller piles. Pure vector, one paint call per coin.
class CoinStack extends StatelessWidget {
  const CoinStack({super.key, required this.count, this.width = 56});

  /// Number of coins in the pile (1–6 is sensible).
  final int count;
  final double width;

  @override
  Widget build(BuildContext context) {
    final n = count.clamp(1, 6);
    final height = width * 0.62 + (n - 1) * width * 0.11;
    return SizedBox(width: width, height: height, child: CustomPaint(painter: _CoinStackPainter(n)));
  }
}

class _CoinStackPainter extends CustomPainter {
  const _CoinStackPainter(this.n);
  final int n;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final rx = w * 0.46;
    final ry = rx * 0.42;
    final thick = w * 0.11;
    final baseY = size.height - ry - w * 0.04;
    final cx = w / 2;

    // Ground shadow.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, baseY + ry * 0.55), width: rx * 2.3, height: ry * 1.6),
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.06),
    );

    for (var i = 0; i < n; i++) {
      // Slight jitter so it reads as a pile, not a cylinder.
      final jitter = Offset(math.sin(i * 2.1) * w * 0.025, 0);
      final cy = baseY - i * thick;
      final center = Offset(cx, cy) + jitter;
      final side = Rect.fromCenter(center: center, width: rx * 2, height: ry * 2);
      // Side band: draw the lower ellipse then a rect between, then face.
      canvas.drawOval(side.shift(Offset(0, thick)), Paint()..color = Coin3DPainter._edgeDark);
      canvas.drawRect(
        Rect.fromLTRB(side.left, center.dy, side.right, center.dy + thick),
        Paint()
          ..shader = const LinearGradient(colors: [Coin3DPainter._edgeDark, Coin3DPainter._edgeMid, Coin3DPainter._edgeLight, Coin3DPainter._edgeMid, Coin3DPainter._edgeDark], stops: [0, 0.25, 0.5, 0.75, 1])
              .createShader(side),
      );
      final top = i == n - 1;
      canvas.drawOval(
        side,
        Paint()
          ..shader = RadialGradient(center: const Alignment(-0.4, -0.6), radius: 1.2, colors: top ? const [Coin3DPainter._faceLight, Coin3DPainter._faceMid, Coin3DPainter._faceDeep] : const [Coin3DPainter._faceMid, Coin3DPainter._faceDeep, Coin3DPainter._edgeMid], stops: const [0, 0.5, 1])
              .createShader(side),
      );
      canvas.drawOval(
        side.deflate(w * 0.02),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(0.8, w * 0.02)
          ..color = (top ? Coin3DPainter._faceLight : Coin3DPainter._edgeLight).withValues(alpha: 0.7),
      );
      if (top) {
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.scale(1, ry / rx);
        final star = Coin3DPainter._starPath(rx * 0.5);
        canvas.drawPath(star.shift(Offset(rx * 0.04, rx * 0.05)), Paint()..color = Coin3DPainter._relief.withValues(alpha: 0.9));
        canvas.drawPath(star, Paint()..color = const Color(0xFFFFE28F));
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CoinStackPainter old) => old.n != n;
}
