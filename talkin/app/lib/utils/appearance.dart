import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

/// Theme the user (or admin default) asked for.
enum BebuThemeMode {
  system,
  dark,
  light;

  static BebuThemeMode parse(String? v, {BebuThemeMode fallback = BebuThemeMode.dark}) {
    for (final m in values) {
      if (m.name == v) return m;
    }
    return fallback;
  }

  String get label => switch (this) { system => 'System', dark => 'Dark', light => 'Light' };
  IconData get icon => switch (this) { system => Icons.brightness_auto_rounded, dark => Icons.dark_mode_rounded, light => Icons.light_mode_rounded };
  String get description => switch (this) {
        system => 'Matches phone',
        dark => 'Night friendly',
        light => 'Bright & clean',
      };
}

/// Admin-controlled appearance settings (`setting.appearance` from the API).
class AppearanceConfig {
  const AppearanceConfig({
    this.defaultTheme = BebuThemeMode.dark,
    this.allowUserThemeChoice = true,
    this.askThemeOnOnboarding = true,
    this.accent = 'pink',
    this.ambientGlow = true,
    this.motion = 'full',
    this.cornerStyle = 'rounded',
    this.liveRings = true,
    this.coinAnimation = true,
    this.soundEffects = true,
  });

  final BebuThemeMode defaultTheme;
  final bool allowUserThemeChoice;
  final bool askThemeOnOnboarding;
  final String accent;
  final bool ambientGlow;
  final String motion; // full | reduced
  final String cornerStyle; // rounded | soft | sharp
  final bool liveRings;
  final bool coinAnimation;
  final bool soundEffects;

  static const defaults = AppearanceConfig();

  factory AppearanceConfig.fromJson(Map<String, dynamic>? j) {
    if (j == null) return defaults;
    bool b(String k, bool d) => j[k] is bool ? j[k] as bool : d;
    String s(String k, String d) => j[k] is String && (j[k] as String).isNotEmpty ? j[k] as String : d;
    return AppearanceConfig(
      defaultTheme: BebuThemeMode.parse(j['defaultTheme'] as String?),
      allowUserThemeChoice: b('allowUserThemeChoice', true),
      askThemeOnOnboarding: b('askThemeOnOnboarding', true),
      accent: s('accent', 'pink'),
      ambientGlow: b('ambientGlow', true),
      motion: s('motion', 'full'),
      cornerStyle: s('cornerStyle', 'rounded'),
      liveRings: b('liveRings', true),
      coinAnimation: b('coinAnimation', true),
      soundEffects: b('soundEffects', true),
    );
  }

  Map<String, dynamic> toJson() => {
        'defaultTheme': defaultTheme.name,
        'allowUserThemeChoice': allowUserThemeChoice,
        'askThemeOnOnboarding': askThemeOnOnboarding,
        'accent': accent,
        'ambientGlow': ambientGlow,
        'motion': motion,
        'cornerStyle': cornerStyle,
        'liveRings': liveRings,
        'coinAnimation': coinAnimation,
        'soundEffects': soundEffects,
      };

  double get radiusScale => switch (cornerStyle) { 'soft' => 0.72, 'sharp' => 0.45, _ => 1.0 };
}

/// Resolves the effective look from the admin config, the user's saved choice
/// and the platform brightness, pushes it into [BebuTheme] and rebuilds the
/// app when it changes.
class Appearance {
  Appearance._();

  static AppearanceConfig config = AppearanceConfig.defaults;
  static BebuThemeMode? _userChoice;

  /// Widget tests drive the palette directly and skip the app-wide rebuild.
  @visibleForTesting
  static bool rebuildOnChange = true;
  static bool _listening = false;

  /// What the user picked, or null if they never chose.
  static BebuThemeMode? get userChoice => _userChoice;

  /// Whether the theme picker should be shown in the profile / onboarding.
  static bool get canChoose => config.allowUserThemeChoice;
  static bool get askOnOnboarding => config.allowUserThemeChoice && config.askThemeOnOnboarding;

  /// Mode in effect (user choice wins only while the admin allows it).
  static BebuThemeMode get mode => (config.allowUserThemeChoice && _userChoice != null) ? _userChoice! : config.defaultTheme;

  static bool get resolvedIsLight {
    switch (mode) {
      case BebuThemeMode.light:
        return true;
      case BebuThemeMode.dark:
        return false;
      case BebuThemeMode.system:
        return _platformBrightness() == Brightness.light;
    }
  }

  static Brightness _platformBrightness() {
    final d = SchedulerBinding.instance.platformDispatcher;
    return d.platformBrightness;
  }

  /// Load the cached admin config and the user's choice from local storage
  /// so the very first frame already uses the right theme.
  static void init() {
    final raw = Database.localStorage.read('appearanceConfig');
    if (raw is String && raw.isNotEmpty) {
      try {
        config = AppearanceConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        config = AppearanceConfig.defaults;
      }
    }
    final choice = Database.localStorage.read('themeMode');
    _userChoice = choice is String && choice.isNotEmpty ? BebuThemeMode.parse(choice) : null;
    _apply(rebuild: false);
    if (!_listening) {
      _listening = true;
      final d = SchedulerBinding.instance.platformDispatcher;
      final prev = d.onPlatformBrightnessChanged;
      d.onPlatformBrightnessChanged = () {
        prev?.call();
        if (mode == BebuThemeMode.system) _apply(rebuild: true);
      };
    }
  }

  /// Apply the `appearance` object from the settings API (and cache it).
  static void applyServer(Map<String, dynamic>? json) {
    final next = AppearanceConfig.fromJson(json);
    final changed = jsonEncode(next.toJson()) != jsonEncode(config.toJson());
    config = next;
    Database.localStorage.write('appearanceConfig', jsonEncode(next.toJson()));
    if (changed) _apply(rebuild: true);
  }

  /// User picked a theme from the profile page or onboarding.
  static void setUserChoice(BebuThemeMode m) {
    _userChoice = m;
    Database.localStorage.write('themeMode', m.name);
    _apply(rebuild: true);
  }

  static bool _lastLight = false;

  static void _apply({required bool rebuild}) {
    final light = resolvedIsLight;
    _lastLight = light;
    BebuTheme.configure(
      palette: light ? BebuPalette.light : BebuPalette.dark,
      accent: BebuAccent.byId(config.accent),
      radiusScale: config.radiusScale,
      reducedMotion: config.motion == 'reduced',
      ambientGlow: config.ambientGlow,
      liveRings: config.liveRings,
      coinAnimation: config.coinAnimation,
      soundEffects: config.soundEffects,
    );
    if (rebuild && rebuildOnChange) {
      Utils.onChangeStatusBar(brightness: Brightness.light);
      // Rebuild every widget so the token getters are re-read.
      Get.forceAppUpdate();
    }
  }

  /// Convenience for previews: the palette a given mode would resolve to.
  static bool isLightFor(BebuThemeMode m) => switch (m) {
        BebuThemeMode.light => true,
        BebuThemeMode.dark => false,
        BebuThemeMode.system => _platformBrightness() == ui.Brightness.light,
      };

  static bool get isLight => _lastLight;
}
