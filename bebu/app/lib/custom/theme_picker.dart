import 'package:flutter/material.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/appearance.dart';

/// Three-way theme picker (System / Dark / Light) with miniature previews.
/// Selecting a mode applies it immediately through [Appearance].
class ThemePicker extends StatelessWidget {
  const ThemePicker({super.key, this.onChanged, this.compact = false});

  final ValueChanged<BebuThemeMode>? onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final current = Appearance.mode;
    // IntrinsicHeight gives the stretch a finite height when the picker sits
    // in a scrolling column (unbounded height would otherwise fail layout).
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final m in BebuThemeMode.values) ...[
            Expanded(
              child: _ThemeOption(
                mode: m,
                selected: current == m,
                compact: compact,
                onTap: () {
                  Appearance.setUserChoice(m);
                  onChanged?.call(m);
                },
              ),
            ),
            if (m != BebuThemeMode.values.last) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({required this.mode, required this.selected, required this.onTap, required this.compact});

  final BebuThemeMode mode;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = BebuTheme.pink;
    return Semantics(
      button: true,
      selected: selected,
      label: '${mode.label} theme',
      child: PressScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: BebuTheme.normal,
          curve: BebuTheme.curve,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: BebuTheme.surface,
            borderRadius: BorderRadius.circular(BebuTheme.radiusMd),
            border: Border.all(color: selected ? accent : BebuTheme.border, width: selected ? 1.8 : 1),
            boxShadow: selected ? [BoxShadow(color: accent.withValues(alpha: 0.28), blurRadius: 18, offset: const Offset(0, 6))] : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MiniPreview(mode: mode, height: compact ? 54 : 70),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(mode.icon, size: 14, color: selected ? accent : BebuTheme.textMuted),
                  const SizedBox(width: 5),
                  Text(mode.label, style: BebuTheme.label(size: 12.5, color: selected ? BebuTheme.text : BebuTheme.textMuted)),
                ],
              ),
              if (!compact) ...[
                const SizedBox(height: 2),
                FittedBox(fit: BoxFit.scaleDown, child: Text(mode.description, maxLines: 1, style: BebuTheme.body(size: 10.5, color: BebuTheme.textFaint))),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Tiny app mock-up in the palette a mode resolves to (system shows a split).
class _MiniPreview extends StatelessWidget {
  const _MiniPreview({required this.mode, required this.height});

  final BebuThemeMode mode;
  final double height;

  @override
  Widget build(BuildContext context) {
    Widget panel(BebuPalette p, {bool leftHalf = false, bool rightHalf = false}) {
      return ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(leftHalf || !rightHalf ? 10 : 0),
          bottomLeft: Radius.circular(leftHalf || !rightHalf ? 10 : 0),
          topRight: Radius.circular(rightHalf || !leftHalf ? 10 : 0),
          bottomRight: Radius.circular(rightHalf || !leftHalf ? 10 : 0),
        ),
        child: Container(
          height: height,
          color: p.bg,
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: p.surface3)),
                  const SizedBox(width: 4),
                  Expanded(child: Container(height: 6, decoration: BoxDecoration(color: p.surface2, borderRadius: BorderRadius.circular(99)))),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [BebuTheme.violet.withValues(alpha: 0.55), BebuTheme.pink.withValues(alpha: 0.75)]),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Container(height: 5, width: 34, decoration: BoxDecoration(color: p.text.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(99))),
            ],
          ),
        ),
      );
    }

    switch (mode) {
      case BebuThemeMode.dark:
        return panel(BebuPalette.dark);
      case BebuThemeMode.light:
        return panel(BebuPalette.light);
      case BebuThemeMode.system:
        return Row(
          children: [
            Expanded(child: panel(BebuPalette.dark, leftHalf: true)),
            Expanded(child: panel(BebuPalette.light, rightHalf: true)),
          ],
        );
    }
  }
}
