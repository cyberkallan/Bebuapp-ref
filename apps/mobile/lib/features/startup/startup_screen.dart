import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/network/api_error.dart';
import '../settings/server_settings_sheet.dart';

enum _StartupMode { loading, error, setup }

/// Neutral bootstrap screen shown before tenant branding is available.
class StartupScreen extends StatefulWidget {
  const StartupScreen.loading({super.key})
      : _mode = _StartupMode.loading,
        error = null,
        onRetry = null;

  const StartupScreen.error({
    super.key,
    required Object this.error,
    required VoidCallback this.onRetry,
  }) : _mode = _StartupMode.error;

  /// Shown when the build carries no usable API address (see
  /// `needsServerSetupProvider`): asks the tester where the server is instead
  /// of spinning forever.
  const StartupScreen.setup({super.key})
      : _mode = _StartupMode.setup,
        error = null,
        onRetry = null;

  final _StartupMode _mode;
  final Object? error;
  final VoidCallback? onRetry;

  /// How long the plain spinner is shown before offering a way out.
  static const revealActionsAfter = Duration(seconds: 2);

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  Timer? _revealTimer;
  bool _showLoadingActions = false;

  @override
  void initState() {
    super.initState();
    if (widget._mode == _StartupMode.loading) {
      _revealTimer = Timer(StartupScreen.revealActionsAfter, () {
        if (mounted) setState(() => _showLoadingActions = true);
      });
    }
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: switch (widget._mode) {
              _StartupMode.loading => _buildLoading(theme),
              _StartupMode.setup => _buildSetup(theme),
              _StartupMode.error => _buildError(theme, widget.error!),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: _showLoadingActions
              ? Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Column(
                    children: [
                      Text(
                        'Connecting to the server…',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _serverButton(),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSetup(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.dns_outlined, size: 48, color: theme.colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          'Choose a server',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'This test build has no server address built in. Enter the address of '
          'the bebu API you want to test against (for example a staging URL or '
          'your computer\'s IP on the same Wi‑Fi).',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => showServerSettingsSheet(context),
          icon: const Icon(Icons.dns_outlined),
          label: const Text('Set server address'),
        ),
      ],
    );
  }

  Widget _buildError(ThemeData theme, Object error) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.cloud_off_rounded, size: 48, color: theme.colorScheme.error),
        const SizedBox(height: 16),
        Text(
          _title(error),
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _message(error),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        if (error is ApiException && error.requestId != null) ...[
          const SizedBox(height: 8),
          Text('Ref ${error.requestId}', style: theme.textTheme.labelSmall),
        ],
        const SizedBox(height: 24),
        FilledButton(onPressed: widget.onRetry, child: const Text('Try again')),
        const SizedBox(height: 8),
        _serverButton(),
      ],
    );
  }

  Widget _serverButton() {
    return TextButton.icon(
      onPressed: () => showServerSettingsSheet(context),
      icon: const Icon(Icons.dns_outlined),
      label: const Text('Change server address'),
    );
  }

  String _title(Object error) {
    if (error is ApiException) {
      if (error.isNetworkError) return "Can't connect";
      if (error.code == 'TENANT_SUSPENDED') return 'App temporarily unavailable';
      if (error.isTenantProblem) return 'App not configured';
    }
    return 'Something went wrong';
  }

  String _message(Object error) {
    if (error is ApiException) return error.message;
    return 'Please try again in a moment.';
  }
}
