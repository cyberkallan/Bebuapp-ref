import 'package:flutter/material.dart';

import '../../core/network/api_error.dart';

/// Neutral bootstrap screen shown before tenant branding is available.
class StartupScreen extends StatelessWidget {
  const StartupScreen.loading({super.key})
      : error = null,
        onRetry = null;

  const StartupScreen.error({
    super.key,
    required Object this.error,
    required VoidCallback this.onRetry,
  });

  final Object? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = this.error;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: error == null
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
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
                        Text(
                          'Ref ${error.requestId}',
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: onRetry,
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
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
