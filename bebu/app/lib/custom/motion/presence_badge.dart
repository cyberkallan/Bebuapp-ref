import 'package:flutter/material.dart';
import 'package:talk_in/utils/app_theme.dart';

enum Presence { online, busy, offline }

extension PresenceX on Presence {
  Color get color => switch (this) {
        Presence.online => BebuTheme.green,
        Presence.busy => BebuTheme.amber,
        Presence.offline => BebuTheme.textFaint,
      };

  String get label => switch (this) {
        Presence.online => 'Online now',
        Presence.busy => 'On a call',
        Presence.offline => 'Offline',
      };

  static Presence from({bool? online, bool? busy}) {
    if (busy == true) return Presence.busy;
    return online == true ? Presence.online : Presence.offline;
  }
}

/// Presence dot: solid colour, a border that matches the surface it sits on,
/// a soft glow and — when online — a slow "breathing" halo. Replaces the flat
/// green dot everywhere an avatar shows status.
class PresenceBadge extends StatefulWidget {
  const PresenceBadge({super.key, required this.presence, this.size = 14, this.borderColor, this.pulse = true});

  final Presence presence;
  final double size;
  final Color? borderColor;
  final bool pulse;

  @override
  State<PresenceBadge> createState() => _PresenceBadgeState();
}

class _PresenceBadgeState extends State<PresenceBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

  bool get _animates => widget.pulse && widget.presence == Presence.online && !BebuTheme.reducedMotion;

  @override
  void initState() {
    super.initState();
    if (_animates) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant PresenceBadge old) {
    super.didUpdateWidget(old);
    if (_animates && !_c.isAnimating) _c.repeat();
    if (!_animates && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.presence.color;
    final border = widget.borderColor ?? BebuTheme.bg;
    final s = widget.size;
    final dot = Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: border, width: (s * 0.16).clamp(1.5, 2.5)),
        boxShadow: widget.presence == Presence.online ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: s * 0.6)] : null,
      ),
      child: widget.presence == Presence.busy
          ? Center(child: Container(width: s * 0.42, height: (s * 0.12).clamp(1.5, 2.0), decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))))
          : null,
    );
    if (!_animates) return SizedBox(width: s, height: s, child: dot);
    return SizedBox(
      width: s,
      height: s,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            final t = Curves.easeOut.transform(_c.value);
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: s * (1 + 1.1 * t),
                  height: s * (1 + 1.1 * t),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color.withValues(alpha: (1 - t) * 0.7), width: 1.5)),
                ),
                child!,
              ],
            );
          },
          child: dot,
        ),
      ),
    );
  }
}

/// "● Online now" pill for headers, cards and the match preview.
class PresencePill extends StatelessWidget {
  const PresencePill({super.key, required this.presence, this.label, this.onPhoto = false, this.dense = false});

  final Presence presence;
  final String? label;

  /// Draw for use over a photo (frosted dark glass, light text).
  final bool onPhoto;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final color = presence.color;
    final text = label ?? presence.label;
    final fg = onPhoto ? BebuTheme.onPhoto : (presence == Presence.offline ? BebuTheme.textMuted : color);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 9 : 12, vertical: dense ? 5 : 7),
      decoration: BoxDecoration(
        color: onPhoto ? Colors.black.withValues(alpha: 0.38) : color.withValues(alpha: BebuTheme.isLight ? 0.12 : 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: onPhoto ? Colors.white.withValues(alpha: 0.22) : color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PresenceBadge(presence: presence, size: dense ? 9 : 10, borderColor: Colors.transparent),
          SizedBox(width: dense ? 6 : 8),
          Text(text, style: BebuTheme.label(size: dense ? 11.5 : 12.5, color: fg)),
        ],
      ),
    );
  }
}
