import 'dart:convert';

import 'package:talk_in/utils/database.dart';

/// A way to sign in. Order here is the fallback display order after the
/// admin-chosen primary method.
enum LoginMethod {
  google,
  phone,
  quick,
  email;

  static LoginMethod? parse(String? v) {
    for (final m in values) {
      if (m.name == v) return m;
    }
    return null;
  }

  /// Server-side `loginType` for this method.
  int get loginType => switch (this) { google => 1, quick => 2, phone => 3, email => 4 };
}

/// Admin-controlled sign-in configuration (`setting.login`). Fetched before
/// login through the public app-configuration endpoint and cached locally so
/// the sign-in screen renders the right buttons even when offline.
class LoginConfig {
  const LoginConfig({
    this.google = true,
    this.phone = true,
    this.quick = true,
    this.email = false,
    this.primary = LoginMethod.google,
    this.showWelcomeBonus = true,
    this.requireConsentCheckbox = false,
    this.headline = '',
  });

  final bool google;
  final bool phone;
  final bool quick;
  final bool email;
  final LoginMethod primary;
  final bool showWelcomeBonus;
  final bool requireConsentCheckbox;
  final String headline;

  static const defaults = LoginConfig();

  bool isEnabled(LoginMethod m) => switch (m) { LoginMethod.google => google, LoginMethod.phone => phone, LoginMethod.quick => quick, LoginMethod.email => email };

  /// Enabled methods with the primary first. Never empty.
  List<LoginMethod> get ordered {
    final list = <LoginMethod>[
      if (isEnabled(primary)) primary,
      for (final m in LoginMethod.values)
        if (m != primary && isEnabled(m)) m,
    ];
    return list.isEmpty ? const [LoginMethod.google, LoginMethod.phone] : list;
  }

  LoginMethod get hero => ordered.first;
  List<LoginMethod> get secondary => ordered.skip(1).toList();

  factory LoginConfig.fromJson(Map<String, dynamic>? j) {
    if (j == null) return defaults;
    bool b(String k, bool d) => j[k] is bool ? j[k] as bool : d;
    final cfg = LoginConfig(
      google: b('google', true),
      phone: b('phone', true),
      quick: b('quick', true),
      email: b('email', false),
      primary: LoginMethod.parse(j['primary'] as String?) ?? LoginMethod.google,
      showWelcomeBonus: b('showWelcomeBonus', true),
      requireConsentCheckbox: b('requireConsentCheckbox', false),
      headline: (j['headline'] as String?)?.trim() ?? '',
    );
    return cfg;
  }

  Map<String, dynamic> toJson() => {
        'google': google,
        'phone': phone,
        'quick': quick,
        'email': email,
        'primary': primary.name,
        'showWelcomeBonus': showWelcomeBonus,
        'requireConsentCheckbox': requireConsentCheckbox,
        'headline': headline,
      };

  static const _key = 'loginConfig';

  /// Last config received from the server, or defaults.
  static LoginConfig get current {
    final raw = Database.localStorage.read(_key);
    if (raw is String && raw.isNotEmpty) {
      try {
        return LoginConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {}
    }
    return defaults;
  }

  static void remember(Map<String, dynamic>? json) {
    if (json == null) return;
    Database.localStorage.write(_key, jsonEncode(LoginConfig.fromJson(json).toJson()));
  }
}

/// Public part of the daily reward config plus the welcome bonus, used on the
/// sign-in screen as a teaser before the user has an account.
class RewardTeaser {
  const RewardTeaser({this.welcomeCoins = 0, this.dailyEnabled = true, this.dailyCoins = const [10, 15, 20, 25, 30, 40, 60]});

  final int welcomeCoins;
  final bool dailyEnabled;
  final List<int> dailyCoins;

  int get dayOne => dailyCoins.isEmpty ? 0 : dailyCoins.first;
  int get cycleTotal => dailyCoins.fold(0, (a, b) => a + b);

  factory RewardTeaser.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const RewardTeaser();
    final daily = j['dailyReward'];
    final coins = daily is Map && daily['coins'] is List ? (daily['coins'] as List).map((e) => (e as num).toInt()).toList() : const [10, 15, 20, 25, 30, 40, 60];
    return RewardTeaser(
      welcomeCoins: (j['welcomeCoins'] as num?)?.toInt() ?? 0,
      dailyEnabled: daily is Map ? daily['enabled'] != false : true,
      dailyCoins: coins.isEmpty ? const [10] : coins,
    );
  }

  Map<String, dynamic> toJson() => {
        'welcomeCoins': welcomeCoins,
        'dailyReward': {'enabled': dailyEnabled, 'coins': dailyCoins},
      };

  static const _key = 'rewardTeaser';

  static RewardTeaser get current {
    final raw = Database.localStorage.read(_key);
    if (raw is String && raw.isNotEmpty) {
      try {
        return RewardTeaser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {}
    }
    return const RewardTeaser();
  }

  static void remember(Map<String, dynamic>? appConfigData) {
    if (appConfigData == null) return;
    Database.localStorage.write(_key, jsonEncode(RewardTeaser.fromJson(appConfigData).toJson()));
  }
}
