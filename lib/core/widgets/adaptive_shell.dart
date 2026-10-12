import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';

/// One top-level destination (docs/UX_FLOWS.md §1) with Material and iOS
/// icons (BD6).
class ShellDestination {
  const ShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.iosIcon,
    required this.iosSelectedIcon,
  });
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final IconData iosIcon;
  final IconData iosSelectedIcon;
}

const shellDestinations = [
  ShellDestination(
    label: 'Today',
    icon: Icons.wb_sunny_outlined,
    selectedIcon: Icons.wb_sunny,
    iosIcon: CupertinoIcons.sun_max,
    iosSelectedIcon: CupertinoIcons.sun_max_fill,
  ),
  ShellDestination(
    label: 'Plan',
    icon: Icons.calendar_month_outlined,
    selectedIcon: Icons.calendar_month,
    iosIcon: CupertinoIcons.rectangle_split_3x1,
    iosSelectedIcon: CupertinoIcons.rectangle_split_3x1_fill,
  ),
  ShellDestination(
    label: 'Tasks',
    icon: Icons.checklist_outlined,
    selectedIcon: Icons.checklist,
    iosIcon: CupertinoIcons.checkmark_square,
    iosSelectedIcon: CupertinoIcons.checkmark_square_fill,
  ),
  ShellDestination(
    label: 'Insights',
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart,
    iosIcon: CupertinoIcons.chart_bar,
    iosSelectedIcon: CupertinoIcons.chart_bar_fill,
  ),
];

/// Top-level navigation, adapted per platform and window size
/// (docs/RESPONSIVE_DESIGN.md §1, BD6):
/// - iOS: the system tab bar at every size (HIG: sections, never actions).
/// - Android: NavigationBar on compact, NavigationRail on medium, a permanent
///   NavigationDrawer on expanded.
/// The layout class comes from the window, so split screen, rotation and
/// landscape phones re-evaluate it.
class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
    this.onQuickAdd,
    this.sessionBar,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  /// Quick add on Android (FAB or rail button). On iOS it lives in the
  /// navigation bar of the screen instead (PageScaffold).
  final VoidCallback? onQuickAdd;

  /// Mini session bar slot (Phase 4); hidden when null.
  final Widget? sessionBar;

  @override
  Widget build(BuildContext context) {
    if (isCupertinoPlatform(Theme.of(context).platform)) {
      return _CupertinoShell(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        sessionBar: sessionBar,
        child: child,
      );
    }
    final layout = WidthClass.ofSize(MediaQuery.sizeOf(context));
    return switch (layout) {
      WidthClass.compact => _compact(),
      WidthClass.medium => _withSideNavigation(context, _rail()),
      WidthClass.expanded => _withSideNavigation(context, _drawer(context)),
    };
  }

  Widget _compact() => Scaffold(
    body: child,
    floatingActionButton: onQuickAdd == null
        ? null
        : FloatingActionButton(
            onPressed: onQuickAdd,
            tooltip: 'Quick add',
            child: const Icon(Icons.add),
          ),
    bottomNavigationBar: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ?sessionBar,
        NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: [
            for (final d in shellDestinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
          ],
        ),
      ],
    ),
  );

  Widget _rail() => NavigationRail(
    selectedIndex: selectedIndex,
    onDestinationSelected: onDestinationSelected,
    labelType: NavigationRailLabelType.all,
    leading: onQuickAdd == null
        ? null
        : Padding(
            padding: const EdgeInsets.only(bottom: Space.lg),
            child: FloatingActionButton(
              onPressed: onQuickAdd,
              tooltip: 'Quick add',
              child: const Icon(Icons.add),
            ),
          ),
    destinations: [
      for (final d in shellDestinations)
        NavigationRailDestination(
          icon: Icon(d.icon),
          selectedIcon: Icon(d.selectedIcon),
          label: Text(d.label),
        ),
    ],
  );

  /// Expanded: a permanent drawer whose indicator spans icon and label.
  Widget _drawer(BuildContext context) => SizedBox(
    // Widens with the text size so labels are never cut off.
    width: MediaQuery.textScalerOf(context)
        .scale(_drawerWidth)
        .clamp(_drawerWidth, _drawerMaxWidth),
    child: NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      tilePadding: const EdgeInsets.symmetric(horizontal: Space.md),
      children: [
        const SizedBox(height: Space.lg),
        if (onQuickAdd != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.lg),
            child: FloatingActionButton.extended(
              onPressed: onQuickAdd,
              icon: const Icon(Icons.add),
              label: const Text('Quick add'),
            ),
          ),
        for (final d in shellDestinations)
          NavigationDrawerDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: Text(d.label),
          ),
      ],
    ),
  );

  static const double _drawerWidth = 240;
  static const double _drawerMaxWidth = 360;

  /// The navigation surface runs edge to edge, under the status bar and the
  /// gesture bar; only its content is inset.
  Widget _withSideNavigation(BuildContext context, Widget navigation) =>
      Scaffold(
        body: Row(
          children: [
            ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: SafeArea(right: false, child: navigation),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                children: [
                  Expanded(child: child),
                  ?sessionBar,
                ],
              ),
            ),
          ],
        ),
      );
}

/// iOS: the system tab bar (49 pt, tint-only selection, hairline top border,
/// SF labels) under the current tab's content.
class _CupertinoShell extends StatelessWidget {
  const _CupertinoShell({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
    this.sessionBar,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;
  final Widget? sessionBar;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?sessionBar,
          CupertinoTabBar(
            currentIndex: selectedIndex,
            onTap: onDestinationSelected,
            activeColor: scheme.primary,
            inactiveColor: scheme.onSurfaceVariant,
            backgroundColor: scheme.surface,
            border: Border(
              top: BorderSide(color: scheme.outlineVariant, width: 0.5),
            ),
            items: [
              for (final d in shellDestinations)
                BottomNavigationBarItem(
                  icon: Icon(d.iosIcon),
                  activeIcon: Icon(d.iosSelectedIcon),
                  label: d.label,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
