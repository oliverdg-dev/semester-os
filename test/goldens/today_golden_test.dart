@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semester_os/app/app.dart';

import '../support/load_fonts.dart';
import '../support/pump_app.dart';

/// Light and dark goldens of the Today empty state with the bundled font.
/// Run on macOS only (IMPLEMENTATION_PLAN Phase 6); `tool/check.sh` excludes
/// the golden tag. Refresh with: flutter test --tags golden --update-goldens
void main() {
  setUpAll(loadAppFonts);

  for (final (name, brightness, width) in [
    ('compact_light', Brightness.light, 360.0),
    ('compact_dark', Brightness.dark, 360.0),
    ('expanded_light', Brightness.light, 1024.0),
  ]) {
    testWidgets('Today empty state, $name', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await pumpApp(tester, width: width);
      await expectLater(
        find.byType(SemesterOsApp),
        matchesGoldenFile('today_empty_$name.png'),
      );
    });
  }
}
