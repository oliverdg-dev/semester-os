import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Returns the presentation files that break the layer rule (ARCHITECTURE §3):
/// presentation code must not import a data/ layer or Drift.
List<String> layerViolations(Map<String, String> filesByPath) {
  final forbidden = RegExp(
    r'''^\s*import\s+['"]([^'"]*/data/[^'"]*|package:drift/[^'"]*)['"]''',
    multiLine: true,
  );
  return [
    for (final entry in filesByPath.entries)
      if (entry.key.contains('/presentation/') &&
          forbidden.hasMatch(entry.value))
        entry.key,
  ];
}

Map<String, String> _libFiles() => {
  for (final f in Directory('lib').listSync(recursive: true).whereType<File>())
    if (f.path.endsWith('.dart')) f.path: f.readAsStringSync(),
};

void main() {
  test('no presentation file imports data/ or drift', () {
    expect(layerViolations(_libFiles()), isEmpty);
  });

  test('the check catches a planted violation', () {
    final planted = {
      'lib/features/tasks/presentation/x.dart':
          "import '../data/task_repository.dart';",
      'lib/features/tasks/presentation/y.dart':
          "import 'package:drift/drift.dart';",
      'lib/features/tasks/application/z.dart':
          "import '../data/task_repository.dart';",
    };
    expect(layerViolations(planted), [
      'lib/features/tasks/presentation/x.dart',
      'lib/features/tasks/presentation/y.dart',
    ]);
  });
}
