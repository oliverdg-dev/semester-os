import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semester_os/app/app.dart';
import 'package:semester_os/app/bootstrap.dart';
import 'package:semester_os/core/database/app_database.dart';
import 'package:semester_os/core/errors/error_log.dart';
import 'package:semester_os/core/errors/error_log_observer.dart';

/// Sets the test window to [width] × [height] logical pixels.
void setWindowSize(WidgetTester tester, double width, [double height = 900]) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.reset);
}

/// Pumps the real app with an in-memory database and the production retry and
/// error-logging configuration.
Future<ErrorLog> pumpApp(WidgetTester tester, {double width = 400}) async {
  setWindowSize(tester, width);
  final log = ErrorLog();
  final db = AppDatabase.memory();
  addTearDown(db.close);
  await tester.pumpWidget(
    ProviderScope(
      retry: noRetry,
      observers: [ErrorLogObserver(log)],
      overrides: [
        errorLogProvider.overrideWithValue(log),
        appDatabaseProvider.overrideWithValue(db),
      ],
      child: const SemesterOsApp(),
    ),
  );
  await tester.pumpAndSettle();
  return log;
}
