import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';

/// Page frame for a top-level destination (DESIGN_SYSTEM §7 PageHeader):
/// - iOS: a large title that collapses to an inline title on scroll, with
///   Settings at the trailing edge (HIG).
/// - Android: a pinned Material top app bar with Settings as an action.
/// The page always scrolls, so content never clips at large text sizes, and
/// the body is capped at the reading width, aligned to the start edge
/// (RESPONSIVE_DESIGN §1).
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.dateLine,
    this.showSettings = true,
  });

  final String title;
  final Widget body;

  /// Optional line under the title, e.g. "Monday 12 October" on Today.
  final String? dateLine;
  final bool showSettings;

  @override
  Widget build(BuildContext context) {
    final cupertino = isCupertinoPlatform(Theme.of(context).platform);
    final gutter = pageGutter(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          if (cupertino) _iosBar(context) else _materialBar(context, gutter),
          SliverSafeArea(
            top: false,
            sliver: SliverPadding(
              padding: EdgeInsets.fromLTRB(gutter, 0, gutter, Space.xxl),
              sliver: SliverToBoxAdapter(
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: Space.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (dateLine != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: Space.lg),
                            child: Text(
                              dateLine!,
                              style: context.appText.dateLine,
                            ),
                          ),
                        body,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iosBar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // The bar shares the page color; its separator appears only once content
    // scrolls under it (HIG).
    return CupertinoSliverNavigationBar(
      largeTitle: Text(title),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      trailing: showSettings
          ? Semantics(
              label: 'Settings',
              button: true,
              excludeSemantics: true,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(44, 44),
                onPressed: () =>
                    context.pushNamed(Routes.settingsHere(context)),
                child: Icon(CupertinoIcons.gear, color: scheme.primary),
              ),
            )
          : null,
    );
  }

  Widget _materialBar(BuildContext context, double gutter) => SliverAppBar(
    pinned: true,
    title: Text(title),
    titleSpacing: gutter,
    actions: [
      if (showSettings)
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
          onPressed: () => context.pushNamed(Routes.settingsHere(context)),
        ),
      const SizedBox(width: Space.sm),
    ],
  );
}

/// Page gutter for the current window (RESPONSIVE_DESIGN §1). On iOS it
/// matches the navigation bar's 16 pt inset at every size so content lines up
/// with the large title.
double pageGutter(BuildContext context) =>
    isCupertinoPlatform(Theme.of(context).platform) ||
        WidthClass.ofSize(MediaQuery.sizeOf(context)) == WidthClass.compact
    ? Space.gutterCompact
    : Space.xl;

/// Frame for a pushed screen (Settings, details). iOS gets the system
/// navigation bar with a centered title and the back chevron; Android a
/// Material top app bar. The body is responsible for its own scrolling.
class DetailScaffold extends StatelessWidget {
  const DetailScaffold({super.key, required this.title, required this.body});

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isCupertinoPlatform(theme.platform)) {
      return Scaffold(
        appBar: CupertinoNavigationBar(
          middle: Text(title),
          backgroundColor: theme.scaffoldBackgroundColor,
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outlineVariant,
              width: 0.5,
            ),
          ),
        ),
        body: body,
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: body,
    );
  }
}
