import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semester_os/app/theme/app_theme.dart';

/// DESIGN_SYSTEM §3: IBM Plex Sans 400/500/600 is bundled, declared in
/// pubspec.yaml and used by every text style. Nothing is fetched at runtime.
void main() {
  const weights = {400: 'Regular', 500: 'Medium', 600: 'SemiBold'};

  test('the font files and the OFL licence are bundled', () {
    for (final name in weights.values) {
      final file = File('assets/fonts/IBMPlexSans-$name.ttf');
      expect(file.existsSync(), isTrue, reason: file.path);
      expect(file.lengthSync(), greaterThan(100000), reason: file.path);
    }
    expect(
      File('assets/fonts/OFL.txt').readAsStringSync(),
      contains('SIL Open Font License'),
    );
  });

  test('pubspec declares each weight under the family kAppFontFamily', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('- family: $kAppFontFamily'));
    for (final MapEntry(key: weight, value: name) in weights.entries) {
      expect(
        pubspec,
        contains(
          '- asset: assets/fonts/IBMPlexSans-$name.ttf\n'
          '          weight: $weight',
        ),
      );
    }
  });

  test('every text style in both themes uses the bundled family', () {
    for (final brightness in Brightness.values) {
      final theme = buildTheme(brightness);
      final styles = [
        theme.textTheme.displayLarge,
        theme.textTheme.headlineSmall,
        theme.textTheme.titleMedium,
        theme.textTheme.bodyLarge,
        theme.textTheme.bodyMedium,
        theme.textTheme.labelLarge,
        theme.textTheme.labelSmall,
      ];
      for (final style in styles) {
        expect(style?.fontFamily, kAppFontFamily, reason: '$brightness');
      }
    }
  });
}
