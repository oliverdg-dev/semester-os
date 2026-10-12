import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semester_os/app/bootstrap.dart';
import 'package:semester_os/app/theme/app_theme.dart';
import 'package:semester_os/core/errors/error_log.dart';
import 'package:semester_os/core/errors/error_log_observer.dart';
import 'package:semester_os/core/errors/failure.dart';
import 'package:semester_os/core/widgets/async_value_view.dart';
import 'package:semester_os/features/settings/presentation/settings_screen.dart';

void main() {
  testWidgets(
    'a failing provider shows ErrorState once, with no retries, and is logged once',
    (tester) async {
      var calls = 0;
      final failing = FutureProvider<int>((ref) async {
        calls++;
        throw Exception('Chem lab report due Friday');
      });
      final log = ErrorLog();

      await tester.pumpWidget(
        ProviderScope(
          retry: noRetry,
          observers: [ErrorLogObserver(log)],
          child: MaterialApp(
            theme: buildTheme(Brightness.light),
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) => AsyncValueView(
                  value: ref.watch(failing),
                  data: (v) => Text('$v'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Something went wrong on this screen.'), findsOneWidget);
      expect(find.text('Error code SEM-APP-001'), findsOneWidget);
      expect(calls, 1, reason: 'retry policy is none');
      expect(log.entries, hasLength(1));
      expect(log.last!.code, 'SEM-APP-001');
    },
  );

  testWidgets('a coded failure shows its own message and code', (tester) async {
    final failing = FutureProvider<int>(
      (ref) async => throw const DatabaseWriteFailure(),
    );
    await tester.pumpWidget(
      ProviderScope(
        retry: noRetry,
        child: MaterialApp(
          theme: buildTheme(Brightness.light),
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) => AsyncValueView(
                value: ref.watch(failing),
                data: (v) => Text('$v'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text("Couldn't save. Nothing was changed."), findsOneWidget);
    expect(find.text('Error code SEM-DB-003'), findsOneWidget);
  });

  test('the ring buffer keeps code and type but never the message text', () {
    final log = ErrorLog();
    try {
      throw FormatException(
        'Unexpected character in "Thesis draft for Prof. Reyes"',
      );
    } catch (e, st) {
      log.record(e, st);
    }
    final text = AboutDiagnosticsScreen.diagnosticsText(log);
    expect(text, contains('SEM-APP-001'));
    expect(text, contains('FormatException'));
    expect(text, isNot(contains('Thesis')));
    expect(text, isNot(contains('Reyes')));
  });

  test('the ring buffer is capped', () {
    final log = ErrorLog(capacity: 3);
    for (var i = 0; i < 5; i++) {
      log.record(const UnexpectedFailure());
    }
    expect(log.entries, hasLength(3));
  });

  test('global handlers record framework errors', () {
    final log = ErrorLog();
    final previous = FlutterError.onError;
    addTearDown(() => FlutterError.onError = previous);
    installGlobalErrorHandlers(log);
    FlutterError.onError!(FlutterErrorDetails(exception: StateError('boom')));
    expect(log.last?.type, 'StateError');
  });
}
