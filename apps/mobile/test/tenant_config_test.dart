import 'package:bebu_mobile/features/tenant/tenant_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TenantConfig.fromJson', () {
    final json = <String, Object?>{
      'key': 'bebu',
      'name': 'bebu',
      'branding': {
        'displayName': 'bebu',
        'logoUrl': null,
        'primaryColor': '#7c3aed',
        'secondaryColor': '#111827',
        'accentColor': '#f59e0b',
      },
      'legal': {
        'privacyPolicyUrl': 'https://bebuapp.in/privacy',
        'termsUrl': null,
        'supportUrl': null,
        'refundPolicyUrl': null,
      },
      'featureFlags': {'voiceCalls': true, 'chat': false},
      'supportedCountries': ['IN'],
      'currency': 'INR',
    };

    test('parses the public config payload', () {
      final config = TenantConfig.fromJson(json);
      expect(config.key, 'bebu');
      expect(config.branding.primaryColor, const Color(0xFF7C3AED));
      expect(config.branding.logoUrl, isNull);
      expect(config.legal.privacyPolicyUrl, 'https://bebuapp.in/privacy');
      expect(config.supportedCountries, ['IN']);
    });

    test('unknown flags default to disabled', () {
      final config = TenantConfig.fromJson(json);
      expect(config.isEnabled(TenantFeature.voiceCalls), isTrue);
      expect(config.isEnabled(TenantFeature.chat), isFalse);
      expect(config.isEnabled(TenantFeature.videoCalls), isFalse);
    });

    test('rejects malformed payloads', () {
      expect(() => TenantConfig.fromJson('nope'), throwsFormatException);
    });
  });
}
