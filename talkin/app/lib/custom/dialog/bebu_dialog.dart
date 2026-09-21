import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talk_in/utils/app_theme.dart';

/// Themed confirmation card used by the app's dialogs. Callers already wrap
/// the body in a transparent [Dialog], so this only draws the card.
class BebuDialog extends StatelessWidget {
  const BebuDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.tone = BebuDialogTone.accent,
    this.illustration,
  });

  final IconData icon;
  final String title;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final BebuDialogTone tone;

  /// Optional artwork shown instead of the icon orb.
  final Widget? illustration;

  @override
  Widget build(BuildContext context) {
    final Color accent;
    final Gradient primaryGradient;
    switch (tone) {
      case BebuDialogTone.danger:
        accent = BebuTheme.red;
        primaryGradient = const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFE11D48)]);
        break;
      case BebuDialogTone.success:
        accent = BebuTheme.green;
        primaryGradient = const LinearGradient(colors: [Color(0xFF34D399), Color(0xFF059669)]);
        break;
      case BebuDialogTone.accent:
        accent = BebuTheme.pink;
        primaryGradient = BebuTheme.pinkGradient;
        break;
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: FadeSlideIn(
          offset: 18,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
            decoration: BoxDecoration(
              color: BebuTheme.surface,
              borderRadius: BorderRadius.circular(BebuTheme.radiusXl),
              border: Border.all(color: BebuTheme.borderStrong),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: BebuTheme.isLight ? 0.18 : 0.6), blurRadius: 50, offset: const Offset(0, 24))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                illustration ??
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: BebuTheme.isLight ? 0.14 : 0.18),
                        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.35), blurRadius: 28, spreadRadius: -6)],
                      ),
                      child: Icon(icon, size: 32, color: accent),
                    ),
                const SizedBox(height: 18),
                Text(title, textAlign: TextAlign.center, style: BebuTheme.title(size: 20)),
                const SizedBox(height: 8),
                Text(body, textAlign: TextAlign.center, style: BebuTheme.body(size: 14, height: 1.45)),
                const SizedBox(height: 22),
                GradientButton(
                  label: primaryLabel,
                  gradient: primaryGradient,
                  glow: accent,
                  height: 52,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onPrimary();
                  },
                ),
                if (secondaryLabel != null) ...[
                  const SizedBox(height: 10),
                  GhostButton(label: secondaryLabel!, height: 48, onTap: onSecondary ?? () => Navigator.of(context).maybePop()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum BebuDialogTone { accent, danger, success }
