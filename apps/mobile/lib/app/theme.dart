import 'package:flutter/material.dart';

import '../features/tenant/tenant_config.dart';

/// Builds Material 3 themes from tenant branding so every white-label build
/// looks native to its brand without any per-tenant Dart code.
class BebuTheme {
  const BebuTheme._();

  static ThemeData light(TenantBranding? branding) =>
      _build(branding, Brightness.light);

  static ThemeData dark(TenantBranding? branding) =>
      _build(branding, Brightness.dark);

  static ThemeData _build(TenantBranding? branding, Brightness brightness) {
    final seed = branding?.primaryColor ?? _fallbackPrimary;
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      primary: brightness == Brightness.light ? seed : null,
      tertiary: branding?.accentColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }

  /// Used only before the tenant config has loaded.
  static const _fallbackPrimary = Color(0xFF6D28D9);
}
