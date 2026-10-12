import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';

/// One top-level destination (docs/UX_FLOWS.md §1).
class ShellDestination {
  const ShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const shellDestinations = [
  ShellDestination(
    label: 'Today',
    icon: Icons.today_outlined,
    selectedIcon: Icons.today,
  ),
  ShellDestination(
    label: 'Plan',
    icon: Icons.calendar_view_week_outlined,
    selectedIcon: Icons.calendar_view_week,
  ),
  ShellDestination(
    label: 'Tasks',
    icon: Icons.checklist_outlined,
    selectedIcon: Icons.checklist,
  ),
  ShellDestination(
    label: 'Insights',
    icon: Icons.insights_outlined,
    selectedIcon: Icons.insights,
  ),
];

/// Bottom NavigationBar on compact widths, NavigationRail on medium, extended
/// rail on expanded (docs/RESPONSIVE_DESIGN.md §1). The width comes from the
/// window, so split screen and rotation re-evaluate it.
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

  /// Quick add appears only once a callback exists (Phase 2 adds it).
  final VoidCallback? onQuickAdd;

  /// Mini session bar slot (Phase 4); hidden when null.
  final Widget? sessionBar;

  @override
  Widget build(BuildContext context) {
    final widthClass = WidthClass.of(MediaQuery.sizeOf(context).width);

    if (widthClass == WidthClass.compact) {
      return Scaffold(
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
    }

    final extended = widthClass == WidthClass.expanded;
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            extended: extended,
            labelType: extended
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            leading: onQuickAdd == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(bottom: Space.lg),
                    child: extended
                        ? FloatingActionButton.extended(
                            onPressed: onQuickAdd,
                            icon: const Icon(Icons.add),
                            label: const Text('Quick add'),
                          )
                        : FloatingActionButton(
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
}
