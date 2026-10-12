import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/database/app_database.dart';
import '../core/database/db_guard.dart';
import '../core/errors/error_log.dart';
import '../core/errors/error_log_observer.dart';
import '../core/errors/failure.dart';
import 'app.dart';
import 'recovery_app.dart';

/// Default retry policy for every provider: no automatic retries, so failures
/// surface as ErrorState immediately (ARCHITECTURE §4). Database read providers
/// opt in to one retry with [databaseReadRetry].
Duration? noRetry(int retryCount, Object error) => null;

/// One retry after 200 ms for providers that read the database.
Duration? databaseReadRetry(int retryCount, Object error) =>
    retryCount < 1 ? const Duration(milliseconds: 200) : null;

/// Routes uncaught framework and platform errors into [log] instead of a blank
/// screen. Error widgets come from each screen's ErrorState.
void installGlobalErrorHandlers(ErrorLog log) {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    log.record(details.exception, details.stack);
    if (kDebugMode) previous?.call(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    log.record(error, stack);
    return true;
  };
}

/// Opens the database safely and returns the root widget: the app, or the
/// recovery screen when the file must not be opened.
Future<Widget> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final log = ErrorLog();
  installGlobalErrorHandlers(log);

  final dir = await getApplicationSupportDirectory();
  final path = p.join(dir.path, AppDatabase.fileName);
  final guard = DbGuard.check(
    path,
    supportedSchemaVersion: AppDatabase.currentSchemaVersion,
  );
  if (!guard.canOpen) {
    final Failure failure = guard.status == DbGuardStatus.tooNew
        ? DatabaseTooNewFailure(
            found: guard.foundVersion ?? 0,
            supported: AppDatabase.currentSchemaVersion,
          )
        : const DatabaseCorruptFailure();
    log.record(failure);
    return RecoveryApp(failure: failure);
  }

  final db = AppDatabase.file(File(path));
  try {
    await db.customSelect('SELECT 1').get();
  } catch (error, stack) {
    log.record(error, stack);
    await db.close();
    return const RecoveryApp(failure: DatabaseCorruptFailure());
  }

  return ProviderScope(
    retry: noRetry,
    observers: [ErrorLogObserver(log)],
    overrides: [
      errorLogProvider.overrideWithValue(log),
      appDatabaseProvider.overrideWithValue(db),
    ],
    child: const SemesterOsApp(),
  );
}
