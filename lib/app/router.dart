import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/adaptive_shell.dart';
import '../features/dashboard/presentation/today_screen.dart';
import '../features/insights/presentation/insights_screen.dart';
import '../features/planner/presentation/plan_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/tasks/presentation/tasks_screen.dart';

/// Route names. Navigate by name, never by hard-coded path.
abstract final class Routes {
  static const today = 'today';
  static const plan = 'plan';
  static const tasks = 'tasks';
  static const insights = 'insights';

  /// Top-level destinations in navigation order.
  static const branches = [today, plan, tasks, insights];

  /// Settings opens inside the current tab, so the tab bar or rail stays
  /// visible and Back returns to where the student was.
  static String settings(String branch) => '$branch.settings';
  static String about(String branch) => '$branch.settings.about';

  /// Settings route of the tab that [context] belongs to.
  static String settingsHere(BuildContext context) =>
      settings(branches[StatefulNavigationShell.of(context).currentIndex]);

  /// About route of the tab that [context] belongs to.
  static String aboutHere(BuildContext context) =>
      about(branches[StatefulNavigationShell.of(context).currentIndex]);
}

GoRoute _branchRoute(String name, Widget screen) => GoRoute(
  path: '/$name',
  name: name,
  builder: (_, _) => screen,
  routes: [
    GoRoute(
      path: 'settings',
      name: Routes.settings(name),
      builder: (_, _) => const SettingsScreen(),
      routes: [
        GoRoute(
          path: 'about',
          name: Routes.about(name),
          builder: (_, _) => const AboutDiagnosticsScreen(),
        ),
      ],
    ),
  ],
);

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/${Routes.today}',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AdaptiveShell(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          child: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            routes: [_branchRoute(Routes.today, const TodayScreen())],
          ),
          StatefulShellBranch(
            routes: [_branchRoute(Routes.plan, const PlanScreen())],
          ),
          StatefulShellBranch(
            routes: [_branchRoute(Routes.tasks, const TasksScreen())],
          ),
          StatefulShellBranch(
            routes: [_branchRoute(Routes.insights, const InsightsScreen())],
          ),
        ],
      ),
    ],
  );
}
