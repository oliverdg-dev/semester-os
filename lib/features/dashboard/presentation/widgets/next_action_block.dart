import 'package:flutter/material.dart';

import '../../../../app/theme/tokens.dart';

/// Today's single visual anchor (DESIGN_SYSTEM §7, UX_FLOWS §3): what to do
/// next, one supporting line and at most one primary action. It sits at the
/// top of Today on the page gutter. Its headline is one step above every
/// other content heading so it reads first at a glance.
class NextActionBlock extends StatelessWidget {
  const NextActionBlock({
    super.key,
    required this.headline,
    required this.supporting,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  }) : assert((primaryLabel == null) == (onPrimary == null)),
       assert((secondaryLabel == null) == (onSecondary == null));

  final String headline;
  final String supporting;

  /// The only filled button on Today. Omitted until its feature exists.
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(headline, style: theme.textTheme.headlineSmall),
        ),
        const SizedBox(height: Space.xs),
        Text(
          supporting,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (onPrimary != null || onSecondary != null) ...[
          const SizedBox(height: Space.lg),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [
              if (onPrimary != null)
                FilledButton(onPressed: onPrimary, child: Text(primaryLabel!)),
              if (onSecondary != null)
                TextButton(
                  onPressed: onSecondary,
                  child: Text(secondaryLabel!),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
