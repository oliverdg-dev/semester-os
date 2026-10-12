import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semester_os/core/errors/failure.dart';

void main() {
  // Every Failure the app defines, with representative instances.
  final failures = <Failure>[
    const UnexpectedFailure(),
    const DatabaseCorruptFailure(),
    const DatabaseTooNewFailure(found: 2, supported: 1),
    const DatabaseWriteFailure(),
    const DatabaseRuntimeCorruptFailure(),
  ];

  test('every Failure subclass in failure.dart is listed in this test', () {
    final source = File('lib/core/errors/failure.dart').readAsStringSync();
    final declared = RegExp(r'final class (\w+) extends Failure')
        .allMatches(source)
        .map((m) => m.group(1))
        .toSet();
    expect(failures.map((f) => f.runtimeType.toString()).toSet(), declared);
  });

  test('every failure code has a row in docs/ERRORS.md', () {
    final doc = File('docs/ERRORS.md').readAsStringSync();
    for (final f in failures) {
      expect(doc, contains('| ${f.code} |'), reason: f.runtimeType.toString());
    }
  });

  test('codes are unique and well-formed', () {
    final codes = failures.map((f) => f.code).toList();
    expect(codes.toSet(), hasLength(codes.length));
    for (final c in codes) {
      expect(c, matches(RegExp(r'^SEM-[A-Z]+-\d{3}$')));
    }
  });
}
