import 'package:flutter/material.dart';

import '../core/errors/failure.dart';
import '../core/widgets/error_state.dart';
import 'theme/app_theme.dart';

/// Shown instead of the app when DbGuard refuses the database file. Phase 2
/// adds "Restore from a backup" and "Start fresh" (moving the db, -wal and -shm
/// files together); Phase 1 only reports the problem and its code.
class RecoveryApp extends StatelessWidget {
  const RecoveryApp({super.key, required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SemesterOS',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: Scaffold(
        body: SafeArea(child: ErrorState(error: failure)),
      ),
    );
  }
}
