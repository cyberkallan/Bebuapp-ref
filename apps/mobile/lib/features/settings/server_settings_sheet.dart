import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_flavor.dart';
import '../../core/config/server_settings.dart';
import '../tenant/tenant_config_provider.dart';

/// Opens the server-address sheet. Resolves after the sheet closes.
Future<void> showServerSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _ServerSettingsSheet(),
  );
}

class _ServerSettingsSheet extends ConsumerStatefulWidget {
  const _ServerSettingsSheet();

  @override
  ConsumerState<_ServerSettingsSheet> createState() => _ServerSettingsSheetState();
}

class _ServerSettingsSheetState extends ConsumerState<_ServerSettingsSheet> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(serverOverrideProvider) ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save(String? value) async {
    final error = value == null ? null : ServerOverride.validate(value);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    await ref.read(serverOverrideProvider.notifier).set(value);
    ref.invalidate(tenantConfigProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final flavor = ref.watch(appFlavorProvider);
    final current = ref.watch(effectiveApiBaseUrlProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        8,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Server address', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Where this app sends requests. Use your computer\'s LAN IP when '
            'running the API locally, e.g. http://192.168.1.10:4180.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.url,
            autocorrect: false,
            textInputAction: TextInputAction.done,
            onSubmitted: _save,
            onChanged: (_) => setState(() => _error = null),
            decoration: InputDecoration(
              labelText: 'API base URL',
              hintText: flavor.apiBaseUrl,
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Currently using $current',
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => _save(_controller.text),
            child: const Text('Save and reconnect'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _save(null),
            child: Text('Reset to default (${flavor.apiBaseUrl})'),
          ),
        ],
      ),
    );
  }
}
