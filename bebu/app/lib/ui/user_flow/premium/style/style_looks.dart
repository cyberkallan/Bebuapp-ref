import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:talk_in/ui/user_flow/premium/model/premium_model.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/pro.dart';

/// Colours and background of a chat theme, resolved from a Style Studio item.
/// `null` from [ChatLook.current] means "use the stock look".
class ChatLook {
  const ChatLook({
    required this.bg,
    required this.mine,
    required this.theirs,
    required this.text,
    required this.theirsText,
    required this.accent,
    required this.composer,
    required this.pattern,
    this.wallpaperUrl = '',
    this.light = false,
    this.name = '',
  });

  final List<Color> bg;
  final List<Color> mine;
  final Color theirs;
  final Color text;
  final Color theirsText;
  final Color accent;
  final Color composer;
  final String pattern; // hearts | waves | dots | stars | petals | aurora | none
  final String wallpaperUrl;
  final bool light;
  final String name;

  LinearGradient get mineGradient => LinearGradient(colors: mine, begin: Alignment.topLeft, end: Alignment.bottomRight);
  LinearGradient get bgGradient => LinearGradient(colors: bg, begin: Alignment.topCenter, end: Alignment.bottomCenter);
  Color get onBg => light ? const Color(0xFF17151E) : Colors.white;
  Color get onBgMuted => onBg.withValues(alpha: 0.65);

  static ChatLook fromData(Map<String, dynamic> d, {String wallpaperUrl = '', String name = ''}) {
    return ChatLook(
      bg: parseHexList(d['bg'], const [Color(0xFF0E0E10), Color(0xFF1A1A1E)]),
      mine: parseHexList(d['mine'], const [Color(0xFFFF5FA2), Color(0xFFE11D74)]),
      theirs: parseHex(d['theirs']) ?? const Color(0xFF242429),
      text: parseHex(d['text']) ?? Colors.white,
      theirsText: parseHex(d['theirsText']) ?? Colors.white,
      accent: parseHex(d['accent']) ?? const Color(0xFFFF3D8A),
      composer: parseHex(d['composer']) ?? const Color(0xFF1A1A1E),
      pattern: (d['pattern'] ?? 'none').toString(),
      wallpaperUrl: wallpaperUrl,
      light: d['light'] == true,
      name: name,
    );
  }

  /// Stock look painted with the current BebuTheme tokens (used for previews
  /// of fonts / wallpapers when no chat theme is applied).
  static ChatLook stock({String wallpaperUrl = ''}) => ChatLook(
        bg: [BebuTheme.bg, BebuTheme.bg],
        mine: [BebuTheme.accent.light, BebuTheme.accent.deep],
        theirs: BebuTheme.surface2,
        text: Colors.white,
        theirsText: BebuTheme.text,
        accent: BebuTheme.pink,
        composer: BebuTheme.surface,
        pattern: 'none',
        wallpaperUrl: wallpaperUrl,
        light: BebuTheme.isLight,
        name: 'Default',
      );

  /// What the chat screen should use right now, or null for the stock UI.
  static ChatLook? current() {
    if (!Pro.studioEnabled) return null;
    final theme = Pro.style.chatTheme;
    final wp = Pro.style.wallpaper;
    if (theme == null && wp == null) return null;
    final wallpaperUrl = wp != null ? Pro.assetUrl(wp.image) : (theme?.data['wallpaper']?.toString().isNotEmpty == true ? Pro.assetUrl('premium/wallpapers/${theme!.data['wallpaper']}.jpg') : '');
    if (theme == null) return stock(wallpaperUrl: wallpaperUrl);
    return fromData(theme.data, wallpaperUrl: wallpaperUrl, name: theme.name);
  }

  /// Resolve a wallpaper key referenced by a theme to a server URL.
  static String wallpaperUrlForKey(String key) => key.isEmpty ? '' : Pro.assetUrl('premium/wallpapers/$key.jpg');
}

/// Look of the voice-call screen.
class CallLook {
  const CallLook({required this.bg, required this.ring, required this.controls, this.wallpaperUrl = '', this.usePhoto = true, this.particles = 'none', this.name = ''});
  final List<Color> bg;
  final List<Color> ring;
  final String controls; // glass | neon | gold
  final String wallpaperUrl;
  final bool usePhoto;
  final String particles; // none | pulse | sparks | stars | hearts | aurora
  final String name;

  LinearGradient get bgGradient => LinearGradient(colors: bg, begin: Alignment.topLeft, end: Alignment.bottomRight);
  SweepGradient get ringGradient => SweepGradient(colors: [...ring, ring.first]);
  Color get accent => ring.first;

  static CallLook fromData(Map<String, dynamic> d, {String name = ''}) {
    final wpKey = (d['wallpaper'] ?? '').toString();
    return CallLook(
      bg: parseHexList(d['bg'], const [Color(0xFF141018), Color(0xFF2A1030)]),
      ring: parseHexList(d['ring'], const [Color(0xFFFF3D8A), Color(0xFF8B5CF6)]),
      controls: (d['controls'] ?? 'glass').toString(),
      wallpaperUrl: ChatLook.wallpaperUrlForKey(wpKey),
      usePhoto: d['usePhoto'] != false,
      particles: (d['particles'] ?? 'none').toString(),
      name: name,
    );
  }

  static CallLook stock() => CallLook(bg: const [Color(0xFF141018), Color(0xFF2A1030)], ring: [BebuTheme.accent.primary, BebuTheme.violet], controls: 'glass', name: 'Default');

  static CallLook current() {
    if (!Pro.studioEnabled) return stock();
    final t = Pro.style.callTheme;
    return t == null ? stock() : fromData(t.data, name: t.name);
  }
}

/// Background of a themed chat: gradient, optional 4K wallpaper with a scrim,
/// and a subtle repeating pattern. Cheap: one image, one static painter.
class ChatCanvas extends StatelessWidget {
  const ChatCanvas({super.key, required this.look, required this.child, this.dim = 0.35});
  final ChatLook look;
  final Widget child;
  final double dim;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(decoration: BoxDecoration(gradient: look.bgGradient)),
        if (look.wallpaperUrl.isNotEmpty)
          CachedNetworkImage(
            imageUrl: look.wallpaperUrl,
            fit: BoxFit.cover,
            memCacheWidth: 1080,
            fadeInDuration: const Duration(milliseconds: 300),
            errorWidget: (_, __, ___) => const SizedBox.shrink(),
          ),
        if (look.wallpaperUrl.isNotEmpty) DecoratedBox(decoration: BoxDecoration(color: (look.light ? Colors.white : Colors.black).withValues(alpha: dim))),
        if (look.pattern != 'none' && look.wallpaperUrl.isEmpty) RepaintBoundary(child: CustomPaint(painter: PatternPainter(kind: look.pattern, color: look.accent.withValues(alpha: 0.10)))),
        child,
      ],
    );
  }
}

/// Repeating decorative motifs for chat themes.
class PatternPainter extends CustomPainter {
  PatternPainter({required this.kind, required this.color});
  final String kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final rnd = math.Random(7);
    switch (kind) {
      case 'hearts':
        for (var i = 0; i < 26; i++) {
          final c = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height);
          final s = 8 + rnd.nextDouble() * 14;
          canvas.save();
          canvas.translate(c.dx, c.dy);
          canvas.rotate((rnd.nextDouble() - 0.5) * 0.8);
          canvas.drawPath(_heart(s), paint);
          canvas.restore();
        }
      case 'petals':
        for (var i = 0; i < 30; i++) {
          final c = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height);
          canvas.save();
          canvas.translate(c.dx, c.dy);
          canvas.rotate(rnd.nextDouble() * math.pi);
          canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 6 + rnd.nextDouble() * 6, height: 14 + rnd.nextDouble() * 10), paint);
          canvas.restore();
        }
      case 'stars':
        for (var i = 0; i < 70; i++) {
          canvas.drawCircle(Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height), 0.6 + rnd.nextDouble() * 1.6, paint);
        }
      case 'dots':
        const step = 26.0;
        for (var y = 0.0; y < size.height; y += step) {
          for (var x = (y / step).floor().isEven ? 0.0 : step / 2; x < size.width; x += step) {
            canvas.drawCircle(Offset(x, y), 1.4, paint);
          }
        }
      case 'waves':
        final p = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        for (var y = 30.0; y < size.height; y += 46) {
          final path = Path()..moveTo(0, y);
          for (var x = 0.0; x <= size.width; x += 8) {
            path.lineTo(x, y + math.sin(x / 22) * 5);
          }
          canvas.drawPath(path, p);
        }
      case 'aurora':
        for (var i = 0; i < 4; i++) {
          final rect = Rect.fromLTWH(-size.width * 0.2, size.height * (0.1 + i * 0.22), size.width * 1.4, size.height * 0.18);
          canvas.save();
          canvas.rotate(-0.25 + i * 0.05);
          canvas.drawOval(rect, Paint()..shader = LinearGradient(colors: [color.withValues(alpha: 0), color, color.withValues(alpha: 0)]).createShader(rect));
          canvas.restore();
        }
    }
  }

  static Path _heart(double s) {
    final p = Path();
    p.moveTo(0, s * 0.35);
    p.cubicTo(-s * 0.9, -s * 0.5, -s * 0.2, -s * 0.9, 0, -s * 0.3);
    p.cubicTo(s * 0.2, -s * 0.9, s * 0.9, -s * 0.5, 0, s * 0.35);
    return p;
  }

  @override
  bool shouldRepaint(covariant PatternPainter old) => old.kind != kind || old.color != color;
}

/// Animated backdrop for the call screen: gradient / wallpaper / blurred
/// photo, plus the template's particle layer driven by one controller.
class CallBackdrop extends StatefulWidget {
  const CallBackdrop({super.key, required this.look, this.photo, this.animate = true});
  final CallLook look;
  final Widget? photo; // blurred full-bleed photo when look.usePhoto
  final bool animate;

  @override
  State<CallBackdrop> createState() => _CallBackdropState();
}

class _CallBackdropState extends State<CallBackdrop> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 9));

  @override
  void initState() {
    super.initState();
    if (widget.animate && !BebuTheme.reducedMotion && widget.look.particles != 'none') _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final look = widget.look;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(decoration: BoxDecoration(gradient: look.bgGradient)),
        if (look.wallpaperUrl.isNotEmpty)
          CachedNetworkImage(imageUrl: look.wallpaperUrl, fit: BoxFit.cover, memCacheWidth: 1080, errorWidget: (_, __, ___) => const SizedBox.shrink()),
        if (look.usePhoto && widget.photo != null) widget.photo!,
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withValues(alpha: 0.25), Colors.black.withValues(alpha: 0.15), Colors.black.withValues(alpha: 0.6)]),
          ),
        ),
        if (look.particles != 'none')
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) => CustomPaint(painter: CallParticlesPainter(kind: look.particles, t: _c.value, colors: look.ring)),
            ),
          ),
      ],
    );
  }
}

/// Slow ambient particles for call templates. Deterministic positions, one
/// pass per frame, no allocations in paint.
class CallParticlesPainter extends CustomPainter {
  CallParticlesPainter({required this.kind, required this.t, required this.colors});
  final String kind;
  final double t;
  final List<Color> colors;

  static final _rnd = List.generate(160, (i) => math.Random(i * 31 + 7).nextDouble());
  double r(int i) => _rnd[i % _rnd.length];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    switch (kind) {
      case 'stars':
        for (var i = 0; i < 60; i++) {
          final tw = 0.5 + 0.5 * math.sin((t * 2 * math.pi * (1 + r(i + 90))) + r(i) * 6);
          paint.color = Colors.white.withValues(alpha: 0.25 + 0.6 * tw);
          canvas.drawCircle(Offset(r(i) * size.width, (r(i + 30) * size.height + t * 20) % size.height), 0.7 + r(i + 60) * 1.6, paint);
        }
      case 'hearts':
        for (var i = 0; i < 16; i++) {
          final p = (t * (0.6 + r(i + 40) * 0.6) + r(i)) % 1;
          final x = r(i + 20) * size.width + math.sin(p * 6 + i) * 18;
          final y = size.height * (1.05 - p * 1.15);
          paint.color = colors[i % colors.length].withValues(alpha: (1 - p) * 0.7);
          canvas.save();
          canvas.translate(x, y);
          canvas.drawPath(PatternPainter._heart(6 + r(i + 70) * 8), paint);
          canvas.restore();
        }
      case 'sparks':
        for (var i = 0; i < 40; i++) {
          final p = (t * (0.8 + r(i + 40)) + r(i)) % 1;
          final x = r(i + 20) * size.width + math.sin(p * 9 + i) * 10;
          final y = size.height * (1.05 - p * 1.2);
          paint.color = colors[i % colors.length].withValues(alpha: (1 - p) * 0.8);
          canvas.drawCircle(Offset(x, y), 1 + r(i + 70) * 2.2, paint);
        }
      case 'pulse':
        final c = Offset(size.width / 2, size.height * 0.36);
        for (var i = 0; i < 3; i++) {
          final p = (t * 3 + i / 3) % 1;
          final rad = 90 + p * size.shortestSide * 0.7;
          paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2 * (1 - p)
            ..color = colors[i % colors.length].withValues(alpha: (1 - p) * 0.55);
          canvas.drawCircle(c, rad, paint);
        }
      case 'aurora':
        for (var i = 0; i < 3; i++) {
          final phase = t * 2 * math.pi + i * 2.1;
          final rect = Rect.fromLTWH(-size.width * 0.3 + math.sin(phase) * 40, size.height * (0.05 + i * 0.2) + math.cos(phase) * 30, size.width * 1.6, size.height * 0.22);
          canvas.save();
          canvas.rotate(-0.3 + i * 0.08);
          final col = colors[i % colors.length];
          canvas.drawOval(rect, Paint()..shader = LinearGradient(colors: [col.withValues(alpha: 0), col.withValues(alpha: 0.28), col.withValues(alpha: 0)]).createShader(rect));
          canvas.restore();
        }
    }
  }

  @override
  bool shouldRepaint(covariant CallParticlesPainter old) => old.t != t || old.kind != kind;
}

/// Avatar ring in the template's colours, slowly rotating.
class CallRing extends StatefulWidget {
  const CallRing({super.key, required this.look, required this.child, this.size = 150, this.animate = true});
  final CallLook look;
  final Widget child;
  final double size;
  final bool animate;

  @override
  State<CallRing> createState() => _CallRingState();
}

class _CallRingState extends State<CallRing> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 6));

  @override
  void initState() {
    super.initState();
    if (widget.animate && !BebuTheme.reducedMotion) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _c,
            builder: (_, __) => Transform.rotate(
              angle: _c.value * 2 * math.pi,
              child: Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.look.ringGradient,
                  boxShadow: [BoxShadow(color: widget.look.accent.withValues(alpha: 0.45), blurRadius: 30, spreadRadius: 2)],
                ),
              ),
            ),
          ),
          Container(width: s - 8, height: s - 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0E0E10))),
          ClipOval(child: SizedBox(width: s - 14, height: s - 14, child: widget.child)),
        ],
      ),
    );
  }
}
