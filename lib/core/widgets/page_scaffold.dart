import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/tokens.dart';

/// Page frame for a top-level destination: title, Settings in the header, and a
/// body limited to the reading width on large screens.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showSettings = true,
  });

  final String title;
  final Widget body;
  final bool showSettings;

  @override
  Widget build(BuildContext context) {
    final compact =
        WidthClass.of(MediaQuery.sizeOf(context).width) == WidthClass.compact;
    final gutter = compact ? Space.gutterCompact : Space.xl;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        titleSpacing: gutter,
        actions: [
          if (showSettings)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
              onPressed: () => context.pushNamed(Routes.settings),
            ),
          const SizedBox(width: Space.sm),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: gutter),
          child: body,
        ),
      ),
    );
  }
}
