import 'dart:io';

import 'package:semester_scheduler/semester_scheduler.dart';
import 'package:test/test.dart';

/// Reads the `SchedulerConfig` table from docs/SCHEDULING_ALGORITHM.md §7.
Map<String, String> _documentedDefaults() {
  final doc = File('../../docs/SCHEDULING_ALGORITHM.md').readAsStringSync();
  final section = doc.split('## 7. Configuration').last.split('\n## ').first;
  final rows = <String, String>{};
  final rowPattern = RegExp(r'^\| `([^`]+)` \| ([^|]+) \|', multiLine: true);
  for (final match in rowPattern.allMatches(section)) {
    rows[match.group(1)!] = match.group(2)!.trim();
  }
  return rows;
}

Map<String, double> _parsePairs(String text) {
  final pairs = <String, double>{};
  for (final part in text.split(',')) {
    final bits = part.trim().split(RegExp(r'\s+'));
    pairs[bits.first] = double.parse(bits.last);
  }
  return pairs;
}

void main() {
  const config = SchedulerConfig();
  final documented = _documentedDefaults();

  test('the configuration table is present in the scheduling doc', () {
    expect(documented, isNotEmpty);
  });

  test('scoring weights match the documented defaults', () {
    expect(
      config.weights.urgency,
      double.parse(documented['weights.urgency']!),
    );
    expect(
      config.weights.priority,
      double.parse(documented['weights.priority']!),
    );
    expect(
      config.weights.importance,
      double.parse(documented['weights.importance']!),
    );
    expect(
      config.weights.pressure,
      double.parse(documented['weights.pressure']!),
    );
  });

  test('weights sum to 1 so scores stay in [0, 1]', () {
    final w = config.weights;
    expect(
      w.urgency + w.priority + w.importance + w.pressure,
      closeTo(1.0, 1e-9),
    );
  });

  test('priority values match the documented defaults', () {
    final doc = _parsePairs(documented['priorityValues']!);
    for (final p in TaskPriority.values) {
      expect(config.priorityValues[p], doc[p.name], reason: p.name);
    }
  });

  test('type importance matches the documented defaults', () {
    final doc = _parsePairs(documented['typeImportance']!);
    for (final t in TaskType.values) {
      expect(config.typeImportance[t], doc[t.name], reason: t.name);
    }
  });

  test('integer limits match the documented defaults', () {
    expect(
      config.minSessionMinutes,
      int.parse(documented['minSessionMinutes']!),
    );
    expect(
      config.maxSessionsPerTaskPerDay,
      int.parse(documented['maxSessionsPerTaskPerDay']!),
    );
    expect(
      config.defaultHorizonCapDays,
      int.parse(documented['defaultHorizonCapDays']!),
    );
    expect(
      config.startRoundingMinutes,
      int.parse(documented['startRoundingMinutes']!),
    );
    expect(
      config.overloadLookaheadDays,
      int.parse(documented['overloadLookaheadDays']!),
    );
  });
}
