import 'package:flutter/material.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/page_scaffold.dart';

/// Today. Phase 1 shows the no-tasks state from docs/UX_FLOWS.md §13; the
/// next-action block and real data arrive in Phases 2 and 4.
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Today',
      body: EmptyState(
        icon: Icons.today_outlined,
        headline: 'Add your first deadline',
        message: 'SemesterOS plans the rest.',
      ),
    );
  }
}
