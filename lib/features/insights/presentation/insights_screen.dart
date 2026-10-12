import 'package:flutter/widgets.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/page_scaffold.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Insights',
      body: EmptyState(
        headline: 'Insights appear after your first studied session',
        message: 'Start a session and come back here.',
      ),
    );
  }
}
