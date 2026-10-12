import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_app.dart';

final android = TargetPlatformVariant.only(TargetPlatform.android);
final ios = TargetPlatformVariant.only(TargetPlatform.iOS);

void main() {
  testWidgets('boots to Today with the date line and the next action', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Monday 12 October'), findsOneWidget);
    expect(find.text('Add your first deadline'), findsOneWidget);
    expect(find.text('SemesterOS plans the rest.'), findsOneWidget);
  }, variant: TargetPlatformVariant.all());

  group('Android navigation (RESPONSIVE_DESIGN §1)', () {
    testWidgets('compact 360 dp: bottom NavigationBar with 4 destinations', (
      tester,
    ) async {
      await pumpApp(tester, width: 360);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(NavigationDestination), findsNWidgets(4));
    }, variant: android);

    testWidgets('medium 700 dp: NavigationRail with labels', (tester) async {
      await pumpApp(tester, width: 700);
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isFalse);
      expect(rail.labelType, NavigationRailLabelType.all);
      expect(rail.destinations, hasLength(4));
      expect(find.byType(NavigationBar), findsNothing);
    }, variant: android);

    testWidgets('expanded 1024 dp: permanent NavigationDrawer', (tester) async {
      await pumpApp(tester, width: 1024);
      expect(find.byType(NavigationDrawer), findsOneWidget);
      expect(find.byType(NavigationDrawerDestination), findsNWidgets(4));
      expect(find.byType(NavigationBar), findsNothing);
    }, variant: android);

    for (final (w, h) in [(852.0, 393.0), (667.0, 375.0)]) {
      testWidgets('a landscape phone ($w×$h) keeps the NavigationBar', (
        tester,
      ) async {
        await pumpApp(tester, width: w, height: h);
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(NavigationDrawer), findsNothing);
        expect(find.byType(NavigationRail), findsNothing);
      }, variant: android);
    }
  });

  group('iOS navigation (BD6)', () {
    for (final width in [360.0, 700.0, 1024.0]) {
      testWidgets('$width pt: the system tab bar, no Material navigation', (
        tester,
      ) async {
        await pumpApp(tester, width: width);
        expect(find.byType(CupertinoTabBar), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
        expect(find.byType(NavigationRail), findsNothing);
        expect(find.byType(NavigationDrawer), findsNothing);
        expect(find.byType(CupertinoSliverNavigationBar), findsOneWidget);
      }, variant: ios);
    }

    testWidgets('Settings opens inside the tab as an inset grouped list', (
      tester,
    ) async {
      await pumpApp(tester, width: 390);
      await tester.tap(find.bySemanticsLabel('Settings'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoListSection), findsOneWidget);
      expect(find.byType(CupertinoTabBar), findsOneWidget);
      await tester.tap(find.text('About & diagnostics'));
      await tester.pumpAndSettle();
      expect(find.text('Copy diagnostics'), findsOneWidget);
    }, variant: ios);
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
  }, variant: android);

  testWidgets('Settings opens inside the tab and shows About & diagnostics', (
    tester,
  ) async {
    await pumpApp(tester, width: 1024);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('About & diagnostics'), findsOneWidget);
    expect(find.byType(NavigationDrawer), findsOneWidget);
    await tester.tap(find.text('About & diagnostics'));
    await tester.pumpAndSettle();
    expect(find.text('Copy diagnostics'), findsOneWidget);
    expect(find.text('None'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Add your first deadline'), findsOneWidget);
  }, variant: android);

  testWidgets('no quick-add button is shown until quick add exists', (
    tester,
  ) async {
    await pumpApp(tester, width: 360);
    expect(find.byType(FloatingActionButton), findsNothing);
  }, variant: android);

  for (final (w, h) in [
    (360.0, 800.0),
    (700.0, 1000.0),
    (1024.0, 768.0),
    (852.0, 393.0),
    (667.0, 375.0),
  ]) {
    testWidgets('no overflow at $w×$h with text scale 2.0 on every tab', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpApp(tester, width: w, height: h);
      for (final label in ['Plan', 'Tasks', 'Insights', 'Today']) {
        await tester.tap(find.text(label).last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: label);
      }
    }, variant: TargetPlatformVariant.all());
  }
}
