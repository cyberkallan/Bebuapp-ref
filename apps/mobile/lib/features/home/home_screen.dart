import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_flavor.dart';
import '../tenant/tenant_config.dart';
import '../tenant/tenant_config_provider.dart';

/// Placeholder home for the foundation stage: proves the tenant pipeline
/// (flavor -> API -> branding -> theme) end to end. Replaced by the caller
/// discovery screen in the matching stage.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenant = ref.watch(tenantConfigProvider).requireValue;
    final flavor = ref.watch(appFlavorProvider);
    final scheme = Theme.of(context).colorScheme;

    final enabled = TenantFeature.values.where(tenant.isEnabled).toList();
    final disabled = TenantFeature.values.where((f) => !tenant.isEnabled(f)).toList();

    return Scaffold(
      appBar: AppBar(title: Text(tenant.branding.displayName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                child: Text(tenant.branding.displayName.substring(0, 1).toUpperCase()),
              ),
              title: Text(tenant.branding.displayName),
              subtitle: Text('tenant ${tenant.key} · ${tenant.currency} · ${flavor.apiBaseUrl}'),
            ),
          ),
          const SizedBox(height: 16),
          Text('Enabled features', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in enabled)
                Chip(
                  avatar: const Icon(Icons.check_rounded, size: 16),
                  label: Text(f.key),
                ),
            ],
          ),
          if (disabled.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Disabled features', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in disabled)
                  Chip(
                    label: Text(f.key),
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
              ],
            ),
          ],
          if (flavor.isDevAuth) ...[
            const SizedBox(height: 24),
            Card(
              color: scheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Development auth mode. This build must never be shipped.',
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
