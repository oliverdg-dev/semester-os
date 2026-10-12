import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';

/// Headline, one sentence and at most one action (DESIGN_SYSTEM §7), placed at
/// the top of the page on the gutter, where the content will appear once it
/// exists, so the layout does not jump. The action is omitted until the
/// feature behind it exists: every visible control works.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.headline,
    required this.message,
    this.actionLabel,
    this.onAction,
  }) : assert((actionLabel == null) == (onAction == null));

  final String headline;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: Space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(headline, style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: Space.xs),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (onAction != null) ...[
            const SizedBox(height: Space.lg),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
