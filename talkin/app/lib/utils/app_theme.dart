import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dark design system for the redesigned user flow (home, explore, profile).
///
/// Everything here is additive: legacy screens keep using [AppColors] and
/// [AppFontStyle]; the redesigned screens use these tokens.
class BebuTheme {
  BebuTheme._();

  // Surfaces
  static const Color bg = Color(0xFF0E0E10);
  static const Color surface = Color(0xFF1A1A1E);
  static const Color surface2 = Color(0xFF242429);
  static const Color surface3 = Color(0xFF2E2E34);
  static const Color border = Color(0x1FFFFFFF);
  static const Color borderStrong = Color(0x33FFFFFF);

  // Text
  static const Color text = Color(0xFFF7F7F8);
  static const Color textMuted = Color(0xB3F7F7F8);
  static const Color textFaint = Color(0x73F7F7F8);

  // Accents
  static const Color violet = Color(0xFF8B5CF6);
  static const Color violetDeep = Color(0xFF6D28D9);
  static const Color pink = Color(0xFFFF3D8A);
  static const Color pinkDeep = Color(0xFFE11D74);
  static const Color amber = Color(0xFFFFB020);
  static const Color green = Color(0xFF34D399);
  static const Color red = Color(0xFFFF5A5F);
  static const Color blue = Color(0xFF38BDF8);

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFFFF5FA2), Color(0xFFE11D74)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient violetGradient = LinearGradient(
    colors: [Color(0xFFA78BFA), Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Bottom-to-top scrim used over photos so text stays legible.
  static const LinearGradient photoScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.45, 0.72, 1.0],
    colors: [Color(0x55000000), Color(0x00000000), Color(0x99000000), Color(0xE6000000)],
  );

  static const double radiusXl = 32;
  static const double radiusLg = 24;
  static const double radiusMd = 18;
  static const double radiusSm = 12;

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 320);
  static const Curve curve = Curves.easeOutCubic;

  // Typography — Inter with tight display tracking, like the reference.
  static TextStyle display({double size = 32, Color color = text, FontWeight weight = FontWeight.w800}) =>
      GoogleFonts.inter(fontSize: size, color: color, fontWeight: weight, letterSpacing: -0.9, height: 1.05);

  static TextStyle title({double size = 20, Color color = text, FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.inter(fontSize: size, color: color, fontWeight: weight, letterSpacing: -0.4, height: 1.2);

  static TextStyle body({double size = 14, Color color = textMuted, FontWeight weight = FontWeight.w400, double? height}) =>
      GoogleFonts.inter(fontSize: size, color: color, fontWeight: weight, height: height ?? 1.45);

  static TextStyle label({double size = 12, Color color = text, FontWeight weight = FontWeight.w600}) => GoogleFonts.inter(fontSize: size, color: color, fontWeight: weight, letterSpacing: 0.1);

  static Color statusColor(String? status) {
    switch (status) {
      case 'Available':
        return green;
      case 'On Call':
        return red;
      default:
        return textFaint;
    }
  }

  static String statusText(String? status) {
    switch (status) {
      case 'Available':
        return 'In real time';
      case 'On Call':
        return 'On a call';
      default:
        return 'Offline';
    }
  }
}

/// Frosted circular icon button used on top of photos and in headers.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 44,
    this.iconSize = 20,
    this.color,
    this.iconColor = BebuTheme.text,
    this.tooltip,
    this.child,
    this.blur = true,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color? color;
  final Color iconColor;
  final String? tooltip;
  final Widget? child;

  /// Backdrop blur costs a saveLayer per button; turn it off inside lists and
  /// grids where many buttons sit over photos.
  final bool blur;

  @override
  Widget build(BuildContext context) {
    final surface = Material(
      color: color ?? const Color(0x33FFFFFF),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: child ?? Icon(icon, size: iconSize, color: iconColor)),
        ),
      ),
    );
    final button = ClipOval(
      child: blur ? BackdropFilter(filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14), child: surface) : surface,
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Small pill: "● In real time", "Hindi", "20 coins/min"...
class BebuChip extends StatelessWidget {
  const BebuChip({
    super.key,
    required this.label,
    this.icon,
    this.dotColor,
    this.background,
    this.foreground = BebuTheme.text,
    this.selected = false,
    this.onTap,
    this.onRemove,
    this.dense = false,
  });

  final String label;
  final IconData? icon;
  final Color? dotColor;
  final Color? background;
  final Color foreground;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? BebuTheme.text : (background ?? BebuTheme.surface2);
    final fg = selected ? BebuTheme.bg : foreground;
    final chip = AnimatedContainer(
      duration: BebuTheme.fast,
      padding: EdgeInsets.symmetric(horizontal: dense ? 10 : 12, vertical: dense ? 6 : 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: selected ? Colors.transparent : BebuTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(width: 7, height: 7, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            Icon(icon, size: dense ? 13 : 15, color: fg),
            const SizedBox(width: 5),
          ],
          Text(label, style: BebuTheme.label(size: dense ? 11.5 : 12.5, color: fg)),
          if (onRemove != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close_rounded, size: 14, color: fg.withValues(alpha: 0.8)),
            ),
          ],
        ],
      ),
    );
    if (onTap == null) return chip;
    return GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: chip);
  }
}

/// Live status pill with a soft pulsing dot when the caller is available.
class StatusPill extends StatefulWidget {
  const StatusPill({super.key, required this.status, this.dense = false});

  final String? status;
  final bool dense;

  @override
  State<StatusPill> createState() => _StatusPillState();
}

class _StatusPillState extends State<StatusPill> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = BebuTheme.statusColor(widget.status);
    final live = widget.status == 'Available';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: widget.dense ? 8 : 10, vertical: widget.dense ? 4 : 6),
      decoration: BoxDecoration(
        color: const Color(0x33000000),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x2EFFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) {
              final glow = live ? 2 + 4 * _pulse.value : 0.0;
              return Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: live ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: glow, spreadRadius: glow / 2)] : null,
                ),
              );
            },
          ),
          const SizedBox(width: 6),
          Text(BebuTheme.statusText(widget.status), style: BebuTheme.label(size: widget.dense ? 11 : 12)),
        ],
      ),
    );
  }
}

/// Blue verified badge shown next to names.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.size = 18});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.verified_rounded, size: size, color: BebuTheme.blue);
  }
}

/// Staggered fade + slide-up entrance used for lists and grids.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.delayMs = 0, this.offset = 18});

  final Widget child;
  final int delayMs;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + delayMs),
      curve: Interval(delayMs / (380 + delayMs), 1, curve: Curves.easeOutCubic),
      builder: (_, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * offset), child: child),
      ),
      child: child,
    );
  }
}

/// Press feedback: scales the child down slightly while pressed.
class PressScale extends StatefulWidget {
  const PressScale({super.key, required this.child, this.onTap, this.scale = 0.96});

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Segmented pill control ("For You | Online").
class SegmentedPill extends StatelessWidget {
  const SegmentedPill({super.key, required this.segments, required this.index, required this.onChanged, this.height = 44});

  final List<SegmentItem> segments;
  final int index;
  final ValueChanged<int> onChanged;

  /// Outer height including the 3px inset around the thumb.
  final double height;

  @override
  Widget build(BuildContext context) {
    const inset = 3.0;
    return Container(
      height: height,
      padding: const EdgeInsets.all(inset),
      decoration: BoxDecoration(
        color: BebuTheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: BebuTheme.border),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth / segments.length;
          return SizedBox(
            height: height - inset * 2 - 2,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: BebuTheme.normal,
                  curve: BebuTheme.curve,
                  left: index * w,
                  top: 0,
                  bottom: 0,
                  width: w,
                  child: Container(
                    decoration: BoxDecoration(
                      color: BebuTheme.surface3,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: BebuTheme.border),
                      boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 2))],
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < segments.length; i++)
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onChanged(i),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(segments[i].icon, size: 14, color: i == index ? (segments[i].activeColor ?? BebuTheme.text) : BebuTheme.textFaint),
                                    const SizedBox(width: 5),
                                    Text(
                                      segments[i].label,
                                      style: BebuTheme.label(size: 12.5, color: i == index ? BebuTheme.text : BebuTheme.textFaint),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SegmentItem {
  const SegmentItem(this.label, this.icon, {this.activeColor});
  final String label;
  final IconData icon;

  /// Icon tint when this segment is selected (e.g. green for "Live").
  final Color? activeColor;
}

/// Full-screen dark backdrop with soft violet/pink glows.
///
/// [intensity] scales the glow alpha; the random-match and onboarding screens
/// use a stronger version, lists a subtler one.
class AuroraBackground extends StatelessWidget {
  const AuroraBackground({super.key, this.intensity = 1, this.child});

  final double intensity;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: BebuTheme.bg),
        IgnorePointer(
          child: Stack(
            children: [
              Positioned(top: -160, left: -60, child: _blob(BebuTheme.violet.withValues(alpha: 0.30 * intensity), 380)),
              Positioned(top: 120, right: -160, child: _blob(BebuTheme.violetDeep.withValues(alpha: 0.28 * intensity), 360)),
              Positioned(bottom: -140, left: -40, child: _blob(BebuTheme.pink.withValues(alpha: 0.16 * intensity), 340)),
            ],
          ),
        ),
        if (child != null) child!,
      ],
    );
  }

  static Widget _blob(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      );
}

/// Pill-shaped primary button with gradient fill, glow and loading state.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.gradient = BebuTheme.violetGradient,
    this.glow = BebuTheme.violet,
    this.loading = false,
    this.height = 56,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Gradient gradient;
  final Color glow;
  final bool loading;
  final double height;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final content = loading
        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: BebuTheme.text))
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: 20, color: BebuTheme.text), const SizedBox(width: 8)],
                Text(label, style: BebuTheme.label(size: 16, weight: FontWeight.w700)),
              ],
            ),
          );
    return PressScale(
      onTap: loading ? null : onTap,
      child: AnimatedOpacity(
        duration: BebuTheme.fast,
        opacity: onTap == null && !loading ? 0.5 : 1,
        child: Container(
          height: height,
          width: expanded ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [BoxShadow(color: glow.withValues(alpha: 0.45), blurRadius: 26, offset: const Offset(0, 10))],
          ),
          child: Center(child: content),
        ),
      ),
    );
  }
}

/// Quiet secondary pill button.
class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.label, required this.onTap, this.icon, this.height = 56, this.expanded = true});

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final double height;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: Container(
        height: height,
        width: expanded ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: BebuTheme.surface2,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: BebuTheme.borderStrong),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: 19, color: BebuTheme.text), const SizedBox(width: 8)],
                Text(label, style: BebuTheme.label(size: 15)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Frosted card with a subtle violet tint, used for list rows and panels.
class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(14), this.radius = BebuTheme.radiusMd, this.onTap, this.tint});

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final VoidCallback? onTap;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tint ?? BebuTheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: BebuTheme.border),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return PressScale(scale: 0.985, onTap: onTap, child: card);
  }
}

/// Circular avatar with an optional online ring/dot.
class BebuAvatar extends StatelessWidget {
  const BebuAvatar({super.key, required this.child, this.size = 52, this.online, this.ring = false});

  final Widget child;
  final double size;
  final bool? online;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(ring ? 2 : 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: ring ? BebuTheme.violetGradient : null,
            ),
            child: ClipOval(child: child),
          ),
          if (online != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: (size * 0.26).clamp(10.0, 18.0),
                height: (size * 0.26).clamp(10.0, 18.0),
                decoration: BoxDecoration(
                  color: online! ? BebuTheme.green : BebuTheme.textFaint,
                  shape: BoxShape.circle,
                  border: Border.all(color: BebuTheme.bg, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
