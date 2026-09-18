import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Compile-time identity of this build. Supplied with `--dart-define`.
class AppFlavor {
  const AppFlavor({
    required this.tenantKey,
    required this.apiBaseUrl,
    required this.authMode,
  });

  /// Sent as `X-Tenant-Key` on every request; the API resolves the tenant.
  final String tenantKey;

  /// Base URL of the bebu API, without a trailing slash.
  final String apiBaseUrl;

  /// `firebase` in real builds; `dev` accepts local dev tokens (never in release).
  final AuthMode authMode;

  bool get isDevAuth => authMode == AuthMode.dev;

  factory AppFlavor.fromEnvironment() {
    const tenantKey = String.fromEnvironment('TENANT_KEY', defaultValue: 'bebu');
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:4180',
    );
    const authMode = String.fromEnvironment('AUTH_MODE', defaultValue: 'firebase');

    const isRelease = bool.fromEnvironment('dart.vm.product');
    if (isRelease && authMode == 'dev') {
      throw StateError('AUTH_MODE=dev is not allowed in release builds');
    }

    return AppFlavor(
      tenantKey: tenantKey,
      apiBaseUrl: apiBaseUrl.endsWith('/')
          ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
          : apiBaseUrl,
      authMode: authMode == 'dev' ? AuthMode.dev : AuthMode.firebase,
    );
  }
}

enum AuthMode { firebase, dev }

/// Overridden in `main()`; throwing by default makes a missing override loud.
final appFlavorProvider = Provider<AppFlavor>(
  (_) => throw UnimplementedError('appFlavorProvider must be overridden'),
);
