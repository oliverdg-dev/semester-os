import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../errors/failure.dart';

/// Shown instead of a screen's content when it fails (DESIGN_SYSTEM §7):
/// what happened, a way forward, and the error code for support.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.error,
    this.onRetry,
    this.onGoToToday,
  });

  final Object error;
  final VoidCallback? onRetry;
  final VoidCallback? onGoToToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final failure = error is Failure
        ? error as Failure
        : const UnexpectedFailure();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(Space.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.error_outline,
                size: 32,
                color: context.semantic.capacity,
              ),
              const SizedBox(height: Space.lg),
              Text(failure.userMessage, style: theme.textTheme.titleLarge),
              const SizedBox(height: Space.sm),
              Text(
                'Error code ${failure.code}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: Space.xl),
              Wrap(
                spacing: Space.sm,
                runSpacing: Space.sm,
                children: [
                  if (onRetry != null)
                    FilledButton(
                      onPressed: onRetry,
                      child: const Text('Retry'),
                    ),
                  if (onGoToToday != null)
                    OutlinedButton(
                      onPressed: onGoToToday,
                      child: const Text('Go to Today'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
