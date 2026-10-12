import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/time/clock_provider.dart';
import '../../../core/widgets/page_scaffold.dart';
import 'widgets/next_action_block.dart';

/// Today (UX_FLOWS §3). The next-action block leads; sessions, progress and
/// deadlines follow as their features land. Until tasks exist it shows the
/// "No tasks" state; its Quick add button arrives with quick add (Phase 2).
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).now();
    return PageScaffold(
      title: 'Today',
      dateLine: DateFormat('EEEE d MMMM').format(now),
      body: const NextActionBlock(
        headline: 'Add your first deadline',
        supporting: 'SemesterOS plans the rest.',
      ),
    );
  }
}
