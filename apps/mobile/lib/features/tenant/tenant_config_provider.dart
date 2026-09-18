import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import 'tenant_config.dart';

/// Loads the tenant's public config once at startup. The whole app is gated on
/// this: without it there is no branding and no feature flags.
final tenantConfigProvider = FutureProvider<TenantConfig>((ref) {
  final api = ref.watch(apiClientProvider);
  return api.get<TenantConfig>(
    '/api/v1/tenant/config',
    decode: TenantConfig.fromJson,
  );
});
