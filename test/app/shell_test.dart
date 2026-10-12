import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_app.dart';

void main() {
  testWidgets('boots to the Today empty state', (tester) async {
    await pumpApp(tester);
    expect(find.text('Add your first deadline'), findsOneWidget);
    expect(find.text('SemesterOS plans the rest.'), findsOneWidget);
  });

  group('adaptive navigation (RESPONSIVE_DESIGN §1)', () {
    testWidgets(
      'compact 360 dp uses a bottom NavigationBar with 4 destinations',
      (tester) async {
        await pumpApp(tester, width: 360);
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
        expect(find.byType(NavigationDestination), findsNWidgets(4));
      },
    );

    testWidgets('medium 700 dp uses a collapsed NavigationRail', (
      tester,
    ) async {
      await pumpApp(tester, width: 700);
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isFalse);
      expect(rail.destinations, hasLength(4));
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('expanded 1024 dp uses an extended NavigationRail', (
      tester,
    ) async {
      await pumpApp(tester, width: 1024);
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isTrue);
      expect(rail.destinations, hasLength(4));
    });
  });

  testWidgets('each destination shows its documented empty state', (
    tester,
  ) async {
    await pumpApp(tester, width: 360);
    final expected = {
      'Plan': 'No plan yet',
      'Tasks': 'Nothing due yet',
      'Insights': 'Insights appear after your first studied session',
      'Today': 'Add your first deadline',
    };
    for (final entry in expected.entries) {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(entry.key),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget, reason: entry.key);
    }
  });

  testWidgets('Settings opens from the header and shows About & diagnostics', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('About & diagnostics'), findsOneWidget);
    await tester.tap(find.text('About & diagnostics'));
    await tester.pumpAndSettle();
    expect(find.text('Copy diagnostics'), findsOneWidget);
    expect(find.text('None'), findsOneWidget);
  });

  testWidgets('no quick-add button is shown until quick add exists', (
    tester,
  ) async {
    await pumpApp(tester, width: 360);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  for (final width in [360.0, 700.0, 1024.0]) {
    testWidgets('no overflow at $width dp with text scale 2.0', (tester) async {
      setWindowSize(tester, width);
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpApp(tester, width: width);
      expect(tester.takeException(), isNull);
    });
  }
}
