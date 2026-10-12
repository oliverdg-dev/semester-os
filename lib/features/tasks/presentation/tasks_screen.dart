import 'package:flutter/widgets.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/page_scaffold.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Tasks',
      body: EmptyState(
        headline: 'Nothing due yet',
        message: 'Add assignments, exams and readings as they come up.',
      ),
    );
  }
}
