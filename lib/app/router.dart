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
  static const settings = 'settings';
}

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/today',
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
            routes: [
              GoRoute(
                path: '/today',
                name: Routes.today,
                builder: (_, _) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/plan',
                name: Routes.plan,
                builder: (_, _) => const PlanScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                name: Routes.tasks,
                builder: (_, _) => const TasksScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/insights',
                name: Routes.insights,
                builder: (_, _) => const InsightsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        name: Routes.settings,
        builder: (_, _) => const SettingsScreen(),
      ),
    ],
  );
}
