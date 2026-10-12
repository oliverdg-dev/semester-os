import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('the engine imports no Flutter, Drift or platform packages', () {
    final forbidden = RegExp(
      r'''^\s*(import|export)\s+['"](package:(flutter|drift|sqlite3|path_provider)[/:]|dart:ui)''',
      multiLine: true,
    );
    final offenders = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        if (forbidden.hasMatch(entity.readAsStringSync())) {
          offenders.add(entity.path);
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('pubspec declares no Flutter dependency', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(
      pubspec.contains(RegExp(r'^\s+(flutter|sdk: flutter)', multiLine: true)),
      isFalse,
    );
  });
}
