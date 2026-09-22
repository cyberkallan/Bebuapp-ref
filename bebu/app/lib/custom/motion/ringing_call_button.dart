import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:talk_in/utils/app_theme.dart';

/// Round call button. When [ringing] is true the handset wiggles like an
/// incoming call and two soft rings expand outwards; otherwise it is a
/// plain, static button. No backdrop blur, so a grid full of these stays
/// cheap to paint.
class RingingCallButton extends StatefulWidget {
  const RingingCallButton({
    super.key,
    required this.onTap,
    required this.ringing,
    this.icon = Icons.call_rounded,
    this.size = 40,
    this.iconSize = 18,
    this.color,
    this.ringColor,
    this.gradient,
    this.iconColor,
    this.glow,
    this.semanticLabel,
  });

  final VoidCallback onTap;
  final bool ringing;
  final IconData icon;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? ringColor;
  final Gradient? gradient;
  final Color? iconColor;
  final Color? glow;
  final String? semanticLabel;

  @override
  State<RingingCallButton> createState() => _RingingCallButtonState();
}

class _RingingCallButtonState extends State<RingingCallButton> with SingleTickerProviderStateMixin {
  // 2.4s loop: ~0.9s of ringing, then a pause, like a real ringtone cadence.
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant RingingCallButton old) {
    super.didUpdateWidget(old);
    if (old.ringing != widget.ringing || _c.isAnimating != _active) _sync();
  }

  bool get _active => widget.ringing && BebuTheme.liveRings;

  void _sync() {
    if (_active) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    _sync();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ring = widget.ringColor ?? BebuTheme.green;
    final button = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: widget.gradient,
        color: widget.gradient == null ? (widget.color ?? const Color(0x40FFFFFF)) : null,
        border: widget.gradient == null ? Border.all(color: Colors.white.withValues(alpha: 0.18)) : null,
        boxShadow: widget.glow == null ? null : [BoxShadow(color: widget.glow!.withValues(alpha: 0.45), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Center(child: Icon(widget.icon, size: widget.iconSize, color: widget.iconColor ?? (widget.gradient != null ? BebuTheme.onPhoto : BebuTheme.text))),
    );

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: PressScale(
        scale: 0.9,
        onTap: widget.onTap,
        child: RepaintBoundary(
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: _active
                ? AnimatedBuilder(
                    animation: _c,
                    builder: (context, child) {
                      final t = _c.value;
                      return Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          _Ring(t: t, delay: 0.0, color: ring, size: widget.size),
                          _Ring(t: t, delay: 0.18, color: ring, size: widget.size),
                          Transform.rotate(angle: _wiggle(t), child: child),
                        ],
                      );
                    },
                    child: button,
                  )
                : button,
          ),
        ),
      ),
    );
  }

  /// Quick ±14° shake during the first 38% of the loop, then still.
  static double _wiggle(double t) {
    if (t > 0.38) return 0;
    final k = t / 0.38;
    final envelope = math.sin(k * math.pi); // fade in/out of the shake
    return math.sin(k * math.pi * 7) * 0.24 * envelope;
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.t, required this.delay, required this.color, required this.size});

  final double t;
  final double delay;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final k = ((t - delay) / 0.6).clamp(0.0, 1.0);
    if (k <= 0 || k >= 1) return const SizedBox.shrink();
    final eased = Curves.easeOut.transform(k);
    final scale = 1 + eased * 0.9;
    final alpha = (1 - eased) * 0.55;
    return IgnorePointer(
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: alpha), width: 1.6),
          ),
        ),
      ),
    );
  }
}
