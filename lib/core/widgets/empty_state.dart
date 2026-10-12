import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';

/// Headline, one sentence and at most one action (DESIGN_SYSTEM §7). The action
/// is omitted until the feature behind it exists: every visible control works.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.headline,
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
  }) : assert((actionLabel == null) == (onAction == null));

  final String headline;
  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(Space.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 32, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(height: Space.lg),
              ],
              Text(headline, style: theme.textTheme.titleLarge),
              const SizedBox(height: Space.sm),
              Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (onAction != null) ...[
                const SizedBox(height: Space.xl),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
