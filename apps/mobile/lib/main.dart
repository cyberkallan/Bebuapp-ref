import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/app_flavor.dart';

/// Entry point. Every tenant build passes its identity at compile time:
///
///   flutter run --dart-define=TENANT_KEY=bebu \
///               --dart-define=API_BASE_URL=http://10.0.2.2:4180 \
///               --dart-define=AUTH_MODE=dev
///
/// Nothing tenant-specific is hard-coded in Dart; branding and feature flags
/// are fetched from the API at startup so a tenant can be re-skinned without
/// shipping a new binary.
void main() {
  final flavor = AppFlavor.fromEnvironment();
  runApp(
    ProviderScope(
      overrides: [appFlavorProvider.overrideWithValue(flavor)],
      child: const BebuApp(),
    ),
  );
}
