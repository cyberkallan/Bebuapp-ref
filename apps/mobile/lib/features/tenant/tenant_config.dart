import 'package:flutter/material.dart';

/// Public tenant configuration served by `GET /api/v1/tenant/config`.
/// Everything a build needs to look and behave like its brand.
class TenantConfig {
  const TenantConfig({
    required this.key,
    required this.name,
    required this.branding,
    required this.legal,
    required this.featureFlags,
    required this.supportedCountries,
    required this.currency,
  });

  final String key;
  final String name;
  final TenantBranding branding;
  final TenantLegal legal;
  final Map<String, bool> featureFlags;
  final List<String> supportedCountries;
  final String currency;

  bool isEnabled(TenantFeature feature) => featureFlags[feature.key] ?? false;

  factory TenantConfig.fromJson(Object? json) {
    final map = _asMap(json, 'tenant config');
    final flagsJson = _asMap(map['featureFlags'], 'featureFlags');
    return TenantConfig(
      key: map['key'] as String,
      name: map['name'] as String,
      branding: TenantBranding.fromJson(map['branding']),
      legal: TenantLegal.fromJson(map['legal']),
      featureFlags: flagsJson.map((k, v) => MapEntry(k, v == true)),
      supportedCountries:
          (map['supportedCountries'] as List<Object?>).cast<String>(),
      currency: map['currency'] as String,
    );
  }
}

/// Server-defined switches. Keys must match `TenantFeatureFlag` in
/// `@bebu/shared`.
enum TenantFeature {
  voiceCalls('voiceCalls'),
  videoCalls('videoCalls'),
  randomMatching('randomMatching'),
  chat('chat'),
  sharedCallerPool('sharedCallerPool'),
  becomeCaller('becomeCaller'),
  dailyLoginBonus('dailyLoginBonus'),
  inAppPurchases('inAppPurchases'),
  webPayments('webPayments');

  const TenantFeature(this.key);
  final String key;
}

class TenantBranding {
  const TenantBranding({
    required this.displayName,
    required this.logoUrl,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
  });

  final String displayName;
  final String? logoUrl;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  factory TenantBranding.fromJson(Object? json) {
    final map = _asMap(json, 'branding');
    return TenantBranding(
      displayName: map['displayName'] as String,
      logoUrl: map['logoUrl'] as String?,
      primaryColor: _hexToColor(map['primaryColor'] as String),
      secondaryColor: _hexToColor(map['secondaryColor'] as String),
      accentColor: _hexToColor(map['accentColor'] as String),
    );
  }
}

class TenantLegal {
  const TenantLegal({
    required this.privacyPolicyUrl,
    required this.termsUrl,
    required this.supportUrl,
    required this.refundPolicyUrl,
  });

  final String? privacyPolicyUrl;
  final String? termsUrl;
  final String? supportUrl;
  final String? refundPolicyUrl;

  factory TenantLegal.fromJson(Object? json) {
    final map = _asMap(json, 'legal');
    return TenantLegal(
      privacyPolicyUrl: map['privacyPolicyUrl'] as String?,
      termsUrl: map['termsUrl'] as String?,
      supportUrl: map['supportUrl'] as String?,
      refundPolicyUrl: map['refundPolicyUrl'] as String?,
    );
  }
}

Map<String, Object?> _asMap(Object? json, String what) {
  if (json is Map<String, Object?>) return json;
  if (json is Map) return json.cast<String, Object?>();
  throw FormatException('Expected an object for $what');
}

/// `#rrggbb` -> opaque [Color].
Color _hexToColor(String hex) {
  final value = int.parse(hex.replaceFirst('#', ''), radix: 16);
  return Color(0xFF000000 | value);
}
