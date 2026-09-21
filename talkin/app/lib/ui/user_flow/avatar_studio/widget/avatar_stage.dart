import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:talk_in/custom/listeners/listener_photo_card.dart';
import 'package:talk_in/ui/user_flow/avatar_studio/model/avatar_studio_model.dart';
import 'package:talk_in/utils/app_theme.dart';

/// Renders a studio item: the bundled WebP when the key ships with the app,
/// otherwise the server copy (admin-uploaded items).
class StudioImage extends StatelessWidget {
  const StudioImage(this.item, {super.key, this.size, this.fit = BoxFit.contain});
  final AvatarItem item;
  final double? size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final cache = size == null ? null : (size! * MediaQuery.devicePixelRatioOf(context)).round().clamp(64, 1024);
    Widget network() => item.image.isEmpty
        ? SizedBox(width: size, height: size)
        : SizedBox(
            width: size,
            height: size,
            child: CachedNetworkImage(
              imageUrl: listenerImageUrl(item.image),
              fit: fit,
              memCacheWidth: cache,
              fadeInDuration: const Duration(milliseconds: 200),
              errorWidget: (_, __, ___) => Icon(Icons.broken_image_outlined, color: Colors.white.withValues(alpha: 0.4), size: (size ?? 40) * 0.4),
            ),
          );
    if (item.key.isEmpty) return network();
    return Image.asset(
      'assets/avatar_studio/${item.key}.webp',
      width: size,
      height: size,
      fit: fit,
      cacheWidth: cache,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => network(),
    );
  }
}

/// The diorama: scene gradient, home at the back, sky item floating, the
/// avatar centre stage with its accessory, pet and ride in front. One ticker
/// drives idle motion (breathing, bob, wiggle); a drag tilts the whole scene
/// with per-layer parallax and springs back on release.
class AvatarStage extends StatefulWidget {
  const AvatarStage({
    super.key,
    required this.look,
    this.revision = 0,
    this.interactive = true,
    this.compact = false,
    this.borderRadius,
  });

  final Map<StudioSlot, AvatarItem?> look;
  final int revision;
  final bool interactive;

  /// Smaller layout for the profile hero: less floor, tighter items.
  final bool compact;
  final BorderRadius? borderRadius;

  @override
  State<AvatarStage> createState() => _AvatarStageState();
}

class _AvatarStageState extends State<AvatarStage> with TickerProviderStateMixin {
  late final AnimationController _idle = AnimationController(vsync: this, duration: const Duration(seconds: 6));
  late final AnimationController _spring = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
  Offset _tilt = Offset.zero; // -1..1 each axis
  Offset _tiltFrom = Offset.zero;

  @override
  void initState() {
    super.initState();
    if (!BebuTheme.reducedMotion) _idle.repeat();
    _spring.addListener(() {
      final t = Curves.elasticOut.transform(_spring.value);
      setState(() => _tilt = Offset.lerp(_tiltFrom, Offset.zero, t)!);
    });
  }

  @override
  void dispose() {
    _idle.dispose();
    _spring.dispose();
    super.dispose();
  }

  void _onPan(DragUpdateDetails d, Size size) {
    _spring.stop();
    setState(() {
      _tilt = Offset(
        (_tilt.dx + d.delta.dx / (size.width * 0.45)).clamp(-1.0, 1.0),
        (_tilt.dy + d.delta.dy / (size.height * 0.45)).clamp(-1.0, 1.0),
      );
    });
  }

  void _release() {
    _tiltFrom = _tilt;
    _spring.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.look[StudioSlot.background];
    final colors = (bg?.colors.length ?? 0) >= 2 ? bg!.colors : const [Color(0xFF1B1033), Color(0xFF3A1C71), Color(0xFF0E0B14)];
    final radius = widget.borderRadius ?? BorderRadius.circular(BebuTheme.radiusXl);

    return LayoutBuilder(
      builder: (context, c) {
        final size = Size(c.maxWidth, c.maxHeight);
        final h = size.height, w = size.width;
        final avatarSize = (widget.compact ? h * 0.62 : h * 0.56).clamp(80.0, 360.0);

        Widget scene = ClipRRect(
          borderRadius: radius,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _idle,
              builder: (context, _) {
                final t = _idle.value * math.pi * 2;
                final breathe = 1 + 0.012 * math.sin(t);
                final bob = 4 * math.sin(t);
                final sway = _tilt.dx, lift = _tilt.dy;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // ---- scene
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
                      ),
                    ),
                    if (bg != null)
                      Positioned(
                        left: -w * 0.05 + sway * 6,
                        top: -h * 0.08 + lift * 4,
                        child: Opacity(opacity: 0.55, child: StudioImage(bg, size: w * 0.62)),
                      ),
                    // stars / bokeh
                    Positioned.fill(child: CustomPaint(painter: _BokehPainter(seed: colors.first.hashCode, t: _idle.value))),
                    // ---- floor + spotlight
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: h * (widget.compact ? 0.26 : 0.32),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.35)]),
                        ),
                      ),
                    ),
                    Positioned(
                      left: w * 0.15 + sway * 10,
                      right: w * 0.15 - sway * 10,
                      bottom: h * 0.10,
                      height: h * 0.10,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.elliptical(w * 0.35, h * 0.05)),
                          gradient: RadialGradient(colors: [Colors.white.withValues(alpha: 0.28), Colors.white.withValues(alpha: 0)]),
                        ),
                      ),
                    ),
                    // ---- home (back, left)
                    if (widget.look[StudioSlot.home] != null)
                      _Layer(
                        key: ValueKey('home-${widget.look[StudioSlot.home]!.id}'),
                        left: w * 0.02 + sway * 14,
                        bottom: h * 0.18 + lift * 6,
                        size: avatarSize * 0.72,
                        item: widget.look[StudioSlot.home]!,
                        shadow: true,
                      ),
                    // ---- sky (top right, floating)
                    if (widget.look[StudioSlot.sky] != null)
                      _Layer(
                        key: ValueKey('sky-${widget.look[StudioSlot.sky]!.id}'),
                        right: w * 0.04 - sway * 22,
                        top: h * 0.06 + 6 * math.sin(t + 1.3) - lift * 10,
                        size: avatarSize * 0.5,
                        item: widget.look[StudioSlot.sky]!,
                        rotate: 0.04 * math.sin(t + 0.6),
                      ),
                    // ---- avatar (+ accessory)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: h * 0.11 + bob - lift * 4,
                      child: Center(
                        child: Transform(
                          alignment: Alignment.bottomCenter,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.0012)
                            ..rotateY(sway * 0.28)
                            ..rotateX(-lift * 0.12)
                            ..scale(breathe, breathe),
                          child: _Avatar(
                            key: ValueKey('avatar-${widget.look[StudioSlot.avatar]?.id}-${widget.look[StudioSlot.accessory]?.id}'),
                            avatar: widget.look[StudioSlot.avatar],
                            accessory: widget.look[StudioSlot.accessory],
                            size: avatarSize,
                          ),
                        ),
                      ),
                    ),
                    // ---- pet (front left)
                    if (widget.look[StudioSlot.pet] != null)
                      _Layer(
                        key: ValueKey('pet-${widget.look[StudioSlot.pet]!.id}'),
                        left: w * 0.12 + sway * 30,
                        bottom: h * 0.06 - lift * 2,
                        size: avatarSize * 0.36,
                        item: widget.look[StudioSlot.pet]!,
                        rotate: 0.06 * math.sin(t * 2 + 2),
                        shadow: true,
                      ),
                    // ---- vehicle (front right)
                    if (widget.look[StudioSlot.vehicle] != null)
                      _Layer(
                        key: ValueKey('veh-${widget.look[StudioSlot.vehicle]!.id}'),
                        right: w * 0.06 - sway * 30,
                        bottom: h * 0.05 + 1.5 * math.sin(t * 3) - lift * 2,
                        size: avatarSize * 0.5,
                        item: widget.look[StudioSlot.vehicle]!,
                        shadow: true,
                      ),
                    // vignette
                    IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          gradient: RadialGradient(radius: 1.1, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.22)]),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );

        if (!widget.interactive) return scene;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: (d) => _onPan(d, size),
          onPanEnd: (_) => _release(),
          onPanCancel: _release,
          child: scene,
        );
      },
    );
  }
}

/// A companion item that pops in when it changes.
class _Layer extends StatelessWidget {
  const _Layer({super.key, required this.item, required this.size, this.left, this.right, this.top, this.bottom, this.rotate = 0, this.shadow = false});
  final AvatarItem item;
  final double size;
  final double? left, right, top, bottom;
  final double rotate;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: _PopIn(
        child: Transform.rotate(
          angle: rotate,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StudioImage(item, size: size),
              if (shadow)
                Transform.translate(
                  offset: Offset(0, -size * 0.08),
                  child: Container(
                    width: size * 0.7,
                    height: size * 0.12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.elliptical(size * 0.35, size * 0.06)),
                      color: Colors.black.withValues(alpha: 0.35),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: size * 0.08)],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({super.key, required this.avatar, required this.accessory, required this.size});
  final AvatarItem? avatar;
  final AvatarItem? accessory;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (avatar == null) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Container(
            width: size * 0.6,
            height: size * 0.6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08), border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2)),
            child: Icon(Icons.person_rounded, size: size * 0.32, color: Colors.white.withValues(alpha: 0.7)),
          ),
        ),
      );
    }
    // Where the accessory sits relative to the bust.
    final k = accessory?.key ?? '';
    final onEyes = k.contains('shades');
    final onEars = k.contains('headphone');
    final accSize = onEyes ? size * 0.42 : size * 0.5;
    final accTop = onEyes ? size * 0.30 : (onEars ? size * 0.02 : -size * 0.18);

    return SizedBox(
      width: size * 1.3,
      height: size * 1.15,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // ground shadow
          Positioned(
            bottom: -size * 0.02,
            child: Container(
              width: size * 0.8,
              height: size * 0.14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.elliptical(size * 0.4, size * 0.07)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: size * 0.1, spreadRadius: -size * 0.02)],
              ),
            ),
          ),
          Positioned(bottom: 0, child: _PopIn(child: StudioImage(avatar!, size: size))),
          if (accessory != null)
            Positioned(
              bottom: size - accTop - accSize,
              child: _PopIn(child: StudioImage(accessory!, size: accSize)),
            ),
        ],
      ),
    );
  }
}

/// Scale/fade in on first build; the parent gives each item a fresh key when
/// it changes so swapping reads as a pop.
class _PopIn extends StatefulWidget {
  const _PopIn({required this.child});
  final Widget child;

  @override
  State<_PopIn> createState() => _PopInState();
}

class _PopInState extends State<_PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: BebuTheme.reducedMotion ? Duration.zero : const Duration(milliseconds: 520))..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final t = Curves.elasticOut.transform(_c.value);
        return Opacity(opacity: Curves.easeOut.transform(_c.value), child: Transform.scale(scale: 0.6 + 0.4 * t, child: child));
      },
      child: widget.child,
    );
  }
}

/// Soft drifting light specks so the scene never looks like a flat gradient.
class _BokehPainter extends CustomPainter {
  _BokehPainter({required this.seed, required this.t});
  final int seed;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed);
    final paint = Paint();
    for (var i = 0; i < 22; i++) {
      final x = rnd.nextDouble(), y = rnd.nextDouble() * 0.75, r = 1.5 + rnd.nextDouble() * 3.5, phase = rnd.nextDouble() * math.pi * 2;
      final a = 0.18 + 0.22 * (0.5 + 0.5 * math.sin(t * math.pi * 2 + phase));
      paint
        ..color = Colors.white.withValues(alpha: a)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.8);
      canvas.drawCircle(Offset(x * size.width, (y + 0.01 * math.sin(t * math.pi * 2 + phase)) * size.height), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BokehPainter old) => old.t != t || old.seed != seed;
}
