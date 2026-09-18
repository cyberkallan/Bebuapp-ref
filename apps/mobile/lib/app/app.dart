import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/tenant/tenant_config_provider.dart';
import '../features/startup/startup_screen.dart';
import 'router.dart';
import 'theme.dart';

class BebuApp extends ConsumerWidget {
  const BebuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(tenantConfigProvider);

    // Until the tenant config resolves the app has no brand, so we render a
    // neutral bootstrap screen instead of the router. Errors (offline, wrong
    // tenant key, suspended tenant) are shown with a retry.
    return config.when(
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: BebuTheme.light(null),
        darkTheme: BebuTheme.dark(null),
        home: const StartupScreen.loading(),
      ),
      error: (error, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: BebuTheme.light(null),
        darkTheme: BebuTheme.dark(null),
        home: StartupScreen.error(
          error: error,
          onRetry: () => ref.invalidate(tenantConfigProvider),
        ),
      ),
      data: (tenant) {
        final router = ref.watch(routerProvider);
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: tenant.branding.displayName,
          theme: BebuTheme.light(tenant.branding),
          darkTheme: BebuTheme.dark(tenant.branding),
          routerConfig: router,
        );
      },
    );
  }
}
