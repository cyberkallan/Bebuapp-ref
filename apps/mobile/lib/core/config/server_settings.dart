import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_flavor.dart';

/// Loaded in `main()` before the first frame so reads are synchronous.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

/// Lets testers point a single build at any API host (LAN IP, staging, prod)
/// without recompiling. Persisted on the device; `null` means "use the URL
/// compiled into this flavor".
class ServerOverride extends Notifier<String?> {
  static const _key = 'api_base_url_override';

  @override
  String? build() => ref.watch(sharedPreferencesProvider).getString(_key);

  Future<void> set(String? url) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final normalised = _normalise(url);
    if (normalised == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, normalised);
    }
    state = normalised;
  }

  static String? _normalise(String? raw) {
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    final withScheme = trimmed.contains('://') ? trimmed : 'http://$trimmed';
    return withScheme.endsWith('/')
        ? withScheme.substring(0, withScheme.length - 1)
        : withScheme;
  }

  /// Returns a validation message, or null when [raw] is acceptable.
  static String? validate(String raw) {
    final value = _normalise(raw);
    if (value == null) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || uri.host.isEmpty || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      return 'Enter a URL like http://192.168.1.10:4180';
    }
    return null;
  }
}

final serverOverrideProvider = NotifierProvider<ServerOverride, String?>(ServerOverride.new);

/// The API base URL actually in use: the override when set, else the flavor's.
final effectiveApiBaseUrlProvider = Provider<String>((ref) {
  return ref.watch(serverOverrideProvider) ?? ref.watch(appFlavorProvider).apiBaseUrl;
});
