import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:talk_in/utils/app_theme.dart';

/// Small bouncing gift sticker pinned to the coin pill while a daily reward
/// is waiting. Loops a gentle hop with a tilt so it reads as "alive" without
/// competing with the coin flip next to it.
class GiftBadge extends StatefulWidget {
  const GiftBadge({super.key, this.size = 22});

  final double size;

  @override
  State<GiftBadge> createState() => _GiftBadgeState();
}

class _GiftBadgeState extends State<GiftBadge> with SingleTickerProviderStateMixin {
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
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          // Hop twice quickly, then rest: t in [0, .35] animates, rest idles.
          final t = _c.value;
          final phase = t < 0.35 ? t / 0.35 : 0.0;
          final hop = math.sin(phase * math.pi * 2).abs() * 4;
          final tilt = math.sin(phase * math.pi * 4) * 0.18;
          return Transform.translate(
            offset: Offset(0, -hop),
            child: Transform.rotate(angle: tilt, child: child),
          );
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: BebuTheme.pinkGradient,
            border: Border.all(color: BebuTheme.bg, width: 2),
            boxShadow: [BoxShadow(color: BebuTheme.pink.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Icon(Icons.redeem_rounded, size: widget.size * 0.5, color: Colors.white),
        ),
      ),
    );
  }
}
