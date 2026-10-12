import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:semester_os/core/config/app_limits.dart';
import 'package:semester_os/core/database/app_database.dart';
import 'package:semester_os/core/domain/statuses.dart';
import 'package:semester_scheduler/semester_scheduler.dart';

/// Schema v1 (ARCHITECTURE §5): columns, singleton rows, DataVersion
/// triggers, the one-live-session index and CHECK constraints.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.memory());
  tearDown(() => db.close());

  Future<List<Map<String, Object?>>> rows(String sql, [List<Object?>? args]) =>
      db
          .customSelect(
            sql,
            variables: [for (final a in args ?? []) Variable(a)],
          )
          .get()
          .then((r) => [for (final row in r) row.data]);

  Future<int> dataVersion() async =>
      (await rows('SELECT value FROM data_version')).single['value']! as int;

  Future<String> tableSql(String table) async =>
      (await rows('SELECT sql FROM sqlite_master WHERE name = ?', [
            table,
          ])).single['sql']!
          as String;

  const now = 1760000000000;

  Future<void> insertSubject(String id, {int colorIndex = 0}) =>
      db.customStatement(
        'INSERT INTO subjects (id, name, color_index, created_at, updated_at) '
        "VALUES (?, 'Biology', ?, $now, $now)",
        [id, colorIndex],
      );

  Future<void> insertTask(
    String id, {
    String? subjectId,
    String date = '2026-10-30',
    int minute = 1439,
    String status = 'incomplete',
    int? completedAt,
  }) => db.customStatement(
    'INSERT INTO tasks (id, subject_id, title, type, deadline_date, '
    'deadline_minute, estimated_minutes, status, completed_at, created_at, '
    "updated_at) VALUES (?, ?, 'Essay', 'assignment', ?, ?, 120, ?, ?, "
    '$now, $now)',
    [id, subjectId, date, minute, status, completedAt],
  );

  Future<void> insertSession(String id, String taskId, String status) =>
      db.customStatement(
        'INSERT INTO study_sessions (id, task_id, planned_start, planned_end, '
        'status, segment_started_at, created_at, updated_at) '
        'VALUES (?, ?, $now, ${now + 3000000}, ?, ?, $now, $now)',
        [id, taskId, status, status == 'active' ? now : null],
      );

  test('every table has exactly the documented columns', () async {
    const expected = {
      'subjects': [
        'id', 'created_at', 'updated_at', 'deleted_at', 'name', //
        'course_code', 'color_index',
      ],
      'tasks': [
        'id', 'created_at', 'updated_at', 'deleted_at', 'subject_id', //
        'title', 'description', 'type', 'deadline_date', 'deadline_minute',
        'estimated_minutes', 'priority', 'grade_weight_pct', 'status',
        'completed_at',
      ],
      'milestones': [
        'id', 'created_at', 'updated_at', 'deleted_at', 'task_id', //
        'title', 'is_completed', 'sort_order',
      ],
      'availability': [
        'id', 'created_at', 'updated_at', 'deleted_at', 'day_of_week', //
        'start_minute', 'end_minute', 'is_enabled',
      ],
      'availability_exceptions': [
        'id', 'created_at', 'updated_at', 'deleted_at', 'date', //
        'start_minute', 'end_minute', 'note',
      ],
      'study_sessions': [
        'id', 'created_at', 'updated_at', 'deleted_at', 'task_id', //
        'planned_start', 'planned_end', 'status', 'is_pinned', 'is_ad_hoc',
        'started_at', 'ended_at', 'segment_started_at', 'accumulated_seconds',
        'actual_minutes',
      ],
      'settings': [
        'id', 'preferred_session_minutes', 'break_minutes', //
        'daily_limit_minutes', 'theme_mode', 'notifications_enabled',
        'show_task_names_in_notifications', 'week_start_day',
        'default_estimate_assignment', 'default_estimate_project',
        'default_estimate_quiz', 'default_estimate_exam',
        'default_estimate_reading', 'default_estimate_other',
        'significant_diff_pct', 'significant_diff_minutes',
        'exam_revision_days', 'last_successful_export_at',
        'backup_nudge_dismissed_at', 'onboarding_completed_at', 'updated_at',
      ],
      'estimate_calibration': [
        'task_type',
        'last_applied_at',
        'dismissed_at_qualifying_count',
      ],
      'data_version': ['id', 'value'],
    };
    final tables = await rows(
      "SELECT name FROM sqlite_master WHERE type = 'table' "
      "AND name NOT LIKE 'sqlite_%' ORDER BY name",
    );
    expect([for (final t in tables) t['name']], unorderedEquals(expected.keys));
    for (final MapEntry(key: table, value: columns) in expected.entries) {
      final info = await rows('PRAGMA table_info($table)');
      expect([for (final c in info) c['name']], columns, reason: table);
    }
  });

  test('a fresh database has one settings row with the defaults', () async {
    final settings = await rows('SELECT * FROM settings');
    expect(settings, hasLength(1));
    expect(settings.single, containsPair('id', 1));
    expect(settings.single, containsPair('preferred_session_minutes', 50));
    expect(settings.single, containsPair('break_minutes', 10));
    expect(settings.single, containsPair('daily_limit_minutes', 240));
    expect(settings.single, containsPair('theme_mode', 'system'));
    expect(settings.single, containsPair('notifications_enabled', 0));
    expect(
      settings.single,
      containsPair('show_task_names_in_notifications', 1),
    );
    expect(settings.single, containsPair('week_start_day', 1));
    expect(settings.single, containsPair('default_estimate_assignment', 120));
    expect(settings.single, containsPair('default_estimate_project', 360));
    expect(settings.single, containsPair('default_estimate_quiz', 90));
    expect(settings.single, containsPair('default_estimate_exam', 240));
    expect(settings.single, containsPair('default_estimate_reading', 60));
    expect(settings.single, containsPair('default_estimate_other', 60));
    expect(settings.single, containsPair('significant_diff_pct', 25));
    expect(settings.single, containsPair('significant_diff_minutes', 30));
    expect(settings.single, containsPair('exam_revision_days', 7));
    expect(await dataVersion(), 0);
    expect(
      db.customStatement('INSERT INTO settings (id, updated_at) VALUES (2, 0)'),
      throwsA(anything),
    );
  });

  group('DataVersion triggers', () {
    test('task insert, edit and soft delete each bump it', () async {
      await insertTask('t1');
      expect(await dataVersion(), 1);
      await db.customStatement("UPDATE tasks SET title = 'Essay 2'");
      expect(await dataVersion(), 2);
      await db.customStatement('UPDATE tasks SET deleted_at = $now');
      expect(await dataVersion(), 3);
    });

    test('sessions, study times and busy times bump it', () async {
      await insertTask('t1');
      await insertSession('s1', 't1', 'planned');
      await db.customStatement(
        'INSERT INTO availability (id, day_of_week, start_minute, end_minute, '
        "created_at, updated_at) VALUES ('a1', 1, 1080, 1260, $now, $now)",
      );
      await db.customStatement(
        'INSERT INTO availability_exceptions (id, date, start_minute, '
        "end_minute, created_at, updated_at) VALUES ('e1', '2026-10-20', 600, "
        '720, $now, $now)',
      );
      expect(await dataVersion(), 4);
    });

    test(
      'a scheduling setting change bumps it, the same value does not',
      () async {
        await db.customStatement(
          'UPDATE settings SET preferred_session_minutes = 45',
        );
        expect(await dataVersion(), 1);
        await db.customStatement(
          'UPDATE settings SET preferred_session_minutes = 45',
        );
        expect(await dataVersion(), 1);
      },
    );

    test(
      'theme, nudge, export and calibration writes do not bump it',
      () async {
        await db.customStatement(
          "UPDATE settings SET theme_mode = 'dark', "
          'backup_nudge_dismissed_at = $now, last_successful_export_at = $now, '
          'notifications_enabled = 1, show_task_names_in_notifications = 0, '
          'default_estimate_quiz = 60, week_start_day = 7',
        );
        await db.customStatement(
          'INSERT INTO estimate_calibration (task_type, last_applied_at) '
          "VALUES ('exam', $now)",
        );
        expect(await dataVersion(), 0);
      },
    );
  });

  test(
    'at most one live session; deleted or finished ones do not count',
    () async {
      await insertTask('t1');
      await insertSession('s1', 't1', 'active');
      await insertSession('s2', 't1', 'completed');
      await expectLater(insertSession('s3', 't1', 'paused'), throwsA(anything));
      await db.customStatement(
        "UPDATE study_sessions SET deleted_at = $now WHERE id = 's1'",
      );
      await insertSession('s4', 't1', 'paused');
    },
  );

  test(
    'a subject with tasks cannot be hard-deleted (soft delete only)',
    () async {
      await insertSubject('sub1');
      await insertTask('t1', subjectId: 'sub1');
      await expectLater(
        db.customStatement("DELETE FROM subjects WHERE id = 'sub1'"),
        throwsA(anything),
      );
    },
  );

  group('CHECK constraints reject invalid rows', () {
    test('impossible dates and minutes', () async {
      await expectLater(
        insertTask('t1', date: '2026-02-30'),
        throwsA(anything),
      );
      await expectLater(
        insertTask('t2', date: '30/10/2026'),
        throwsA(anything),
      );
      await expectLater(insertTask('t3', minute: 1440), throwsA(anything));
      await insertTask('t4', minute: AppLimits.endOfDayMinute);
    });

    test('completedAt is set exactly when the task is completed', () async {
      await expectLater(
        insertTask('t1', status: 'completed'),
        throwsA(anything),
      );
      await expectLater(insertTask('t2', completedAt: now), throwsA(anything));
      await insertTask('t3', status: 'completed', completedAt: now);
    });

    test('subject color outside the palette', () async {
      await expectLater(
        insertSubject('s1', colorIndex: AppLimits.subjectColors),
        throwsA(anything),
      );
    });

    test('a study time that ends before it starts', () async {
      await expectLater(
        db.customStatement(
          'INSERT INTO availability (id, day_of_week, start_minute, '
          "end_minute, created_at, updated_at) VALUES ('a', 1, 600, 600, 0, 0)",
        ),
        throwsA(anything),
      );
    });

    test('an active session without a running segment', () async {
      await insertTask('t1');
      await expectLater(
        db.customStatement(
          'INSERT INTO study_sessions (id, task_id, planned_start, '
          "planned_end, status, created_at, updated_at) VALUES ('s', 't1', 0, "
          "60000, 'active', 0, 0)",
        ),
        throwsA(anything),
      );
    });
  });

  test('CHECK bounds and enum sets match AppLimits and the enums', () async {
    String inSet(Iterable<Enum> values) =>
        "IN (${values.map((v) => "'${v.name}'").join(', ')})";
    final expected = {
      'subjects': [
        'length(name) BETWEEN 1 AND ${AppLimits.subjectNameMax}',
        'length(course_code) BETWEEN 1 AND ${AppLimits.courseCodeMax}',
        'color_index BETWEEN 0 AND ${AppLimits.subjectColors - 1}',
      ],
      'tasks': [
        'length(title) BETWEEN 1 AND ${AppLimits.taskTitleMax}',
        'length(description) <= ${AppLimits.taskDescriptionMax}',
        'type ${inSet(TaskType.values)}',
        'deadline_minute BETWEEN 0 AND ${AppLimits.lastMinuteOfDay}',
        'estimated_minutes BETWEEN ${AppLimits.estimateMinMinutes} AND '
            '${AppLimits.estimateMaxMinutes}',
        'priority ${inSet(TaskPriority.values)}',
        'grade_weight_pct BETWEEN 0 AND ${AppLimits.gradeWeightMaxPct}',
        'status ${inSet(TaskStatus.values)}',
      ],
      'milestones': [
        'length(title) BETWEEN 1 AND ${AppLimits.milestoneTitleMax}',
      ],
      'availability_exceptions': [
        'length(note) BETWEEN 1 AND ${AppLimits.exceptionNoteMax}',
      ],
      'study_sessions': ['status ${inSet(SessionStatus.values)}'],
      'settings': [
        'preferred_session_minutes BETWEEN ${AppLimits.sessionMinMinutes} '
            'AND ${AppLimits.sessionMaxMinutes}',
        'break_minutes BETWEEN 0 AND ${AppLimits.breakMaxMinutes}',
        'daily_limit_minutes BETWEEN ${AppLimits.dailyLimitMinMinutes} AND '
            '${AppLimits.dailyLimitMaxMinutes}',
        'theme_mode ${inSet(ThemePreference.values)}',
        for (final type in TaskType.values)
          'default_estimate_${type.name} BETWEEN '
              '${AppLimits.defaultEstimateMinMinutes} AND '
              '${AppLimits.defaultEstimateMaxMinutes}',
        'significant_diff_pct BETWEEN ${AppLimits.significantDiffPctMin} AND '
            '${AppLimits.significantDiffPctMax}',
        'significant_diff_minutes BETWEEN '
            '${AppLimits.significantDiffMinutesMin} AND '
            '${AppLimits.significantDiffMinutesMax}',
        'exam_revision_days BETWEEN 0 AND ${AppLimits.examRevisionMaxDays}',
      ],
      'estimate_calibration': ['task_type ${inSet(TaskType.values)}'],
    };
    for (final MapEntry(key: table, value: checks) in expected.entries) {
      final sql = await tableSql(table);
      for (final check in checks) {
        expect(sql, contains(check), reason: table);
      }
    }
  });
}
