import 'package:flutter/widgets.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/page_scaffold.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Plan',
      body: EmptyState(
        headline: 'No plan yet',
        message: 'Add a deadline and your study times, then generate a plan.',
      ),
    );
  }
}
