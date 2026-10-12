import 'package:drift/drift.dart';
import 'package:semester_scheduler/semester_scheduler.dart';

import '../domain/statuses.dart';

// Schema v1 (ARCHITECTURE §5). Ids are UUID v4 text. Instants (createdAt,
// updatedAt, deletedAt, session times) are UTC epoch milliseconds. Civil
// values (deadlines, study times, busy times) are ISO date text plus
// minutes-of-day so they keep their local meaning across time-zone changes.
// The partial index and the DataVersion triggers live in schema.drift.
// CHECK bounds are literals so Drift can verify them and record them in the
// schema snapshot; test/core/database/schema_test.dart checks them against
// AppLimits and the enums.

/// Columns every soft-deletable, sync-ready row carries (ARCHITECTURE §8, §13).
mixin _Tracked on Table {
  TextColumn get id => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
}

class Subjects extends Table with _Tracked {
  TextColumn get name => text()();
  TextColumn get courseCode => text().nullable()();
  IntColumn get colorIndex => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (length(name) BETWEEN 1 AND 100)',
    'CHECK (length(course_code) BETWEEN 1 AND 20)',
    'CHECK (color_index BETWEEN 0 AND 9)',
  ];
}

@DataClassName('TaskRow')
class Tasks extends Table with _Tracked {
  TextColumn get subjectId => text().nullable().references(
    Subjects,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get type => textEnum<TaskType>()();
  TextColumn get deadlineDate => text()();
  IntColumn get deadlineMinute => integer()();
  IntColumn get estimatedMinutes => integer()();
  TextColumn get priority => textEnum<TaskPriority>().withDefault(
    Constant(TaskPriority.medium.name),
  )();
  IntColumn get gradeWeightPct => integer().nullable()();
  TextColumn get status => textEnum<TaskStatus>().withDefault(
    Constant(TaskStatus.incomplete.name),
  )();
  IntColumn get completedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (length(title) BETWEEN 1 AND 200)',
    'CHECK (description IS NULL OR length(description) <= 5000)',
    "CHECK (type IN ('assignment', 'project', 'quiz', 'exam', 'reading', 'other'))",
    'CHECK (date(deadline_date) IS deadline_date)',
    'CHECK (deadline_minute BETWEEN 0 AND 1439)',
    'CHECK (estimated_minutes BETWEEN 1 AND 10000)',
    "CHECK (priority IN ('low', 'medium', 'high'))",
    'CHECK (grade_weight_pct BETWEEN 0 AND 100)',
    "CHECK (status IN ('incomplete', 'inProgress', 'completed'))",
    "CHECK ((status = 'completed') = (completed_at IS NOT NULL))",
  ];
}

class Milestones extends Table with _Tracked {
  TextColumn get taskId =>
      text().references(Tasks, #id, onDelete: KeyAction.restrict)();
  TextColumn get title => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (length(title) BETWEEN 1 AND 200)',
  ];
}

/// Weekly study times.
@DataClassName('AvailabilityRow')
class Availability extends Table with _Tracked {
  /// ISO weekday: 1 = Monday ... 7 = Sunday.
  IntColumn get dayOfWeek => integer()();
  IntColumn get startMinute => integer()();
  IntColumn get endMinute => integer()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (day_of_week BETWEEN 1 AND 7)',
    'CHECK (start_minute BETWEEN 0 AND 1439)',
    'CHECK (end_minute > start_minute AND end_minute <= 1440)',
  ];
}

/// One-off busy times that remove study time on a date.
@DataClassName('AvailabilityExceptionRow')
class AvailabilityExceptions extends Table with _Tracked {
  TextColumn get date => text()();
  IntColumn get startMinute => integer()();
  IntColumn get endMinute => integer()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (date(date) IS date)',
    'CHECK (start_minute BETWEEN 0 AND 1439)',
    'CHECK (end_minute > start_minute AND end_minute <= 1440)',
    'CHECK (length(note) BETWEEN 1 AND 200)',
  ];
}

@DataClassName('StudySessionRow')
class StudySessions extends Table with _Tracked {
  TextColumn get taskId =>
      text().references(Tasks, #id, onDelete: KeyAction.restrict)();
  IntColumn get plannedStart => integer()();
  IntColumn get plannedEnd => integer()();
  TextColumn get status => textEnum<SessionStatus>().withDefault(
    Constant(SessionStatus.planned.name),
  )();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isAdHoc => boolean().withDefault(const Constant(false))();
  IntColumn get startedAt => integer().nullable()();
  IntColumn get endedAt => integer().nullable()();
  IntColumn get segmentStartedAt => integer().nullable()();
  IntColumn get accumulatedSeconds =>
      integer().withDefault(const Constant(0))();
  IntColumn get actualMinutes => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (planned_end > planned_start)',
    "CHECK (status IN ('planned', 'active', 'paused', 'completed', 'skipped'))",
    'CHECK (accumulated_seconds >= 0)',
    'CHECK (actual_minutes IS NULL OR actual_minutes >= 0)',
    // Only an active session has a running segment.
    "CHECK ((status = 'active') = (segment_started_at IS NOT NULL))",
  ];
}

/// Single row (id = 1) of user settings.
@DataClassName('SettingsRow')
class Settings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get preferredSessionMinutes =>
      integer().withDefault(const Constant(50))();
  IntColumn get breakMinutes => integer().withDefault(const Constant(10))();
  IntColumn get dailyLimitMinutes =>
      integer().withDefault(const Constant(240))();
  TextColumn get themeMode => textEnum<ThemePreference>().withDefault(
    Constant(ThemePreference.system.name),
  )();
  BoolColumn get notificationsEnabled =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get showTaskNamesInNotifications =>
      boolean().withDefault(const Constant(true))();

  /// ISO weekday the week starts on (1 = Monday).
  IntColumn get weekStartDay => integer().withDefault(const Constant(1))();
  IntColumn get defaultEstimateAssignment =>
      integer().withDefault(const Constant(120))();
  IntColumn get defaultEstimateProject =>
      integer().withDefault(const Constant(360))();
  IntColumn get defaultEstimateQuiz =>
      integer().withDefault(const Constant(90))();
  IntColumn get defaultEstimateExam =>
      integer().withDefault(const Constant(240))();
  IntColumn get defaultEstimateReading =>
      integer().withDefault(const Constant(60))();
  IntColumn get defaultEstimateOther =>
      integer().withDefault(const Constant(60))();
  IntColumn get significantDiffPct =>
      integer().withDefault(const Constant(25))();
  IntColumn get significantDiffMinutes =>
      integer().withDefault(const Constant(30))();
  IntColumn get examRevisionDays => integer().withDefault(const Constant(7))();
  IntColumn get lastSuccessfulExportAt => integer().nullable()();
  IntColumn get backupNudgeDismissedAt => integer().nullable()();
  IntColumn get onboardingCompletedAt => integer().nullable()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (id = 1)',
    'CHECK (preferred_session_minutes BETWEEN 15 AND 180)',
    'CHECK (break_minutes BETWEEN 0 AND 60)',
    'CHECK (daily_limit_minutes BETWEEN 30 AND 960)',
    "CHECK (theme_mode IN ('system', 'light', 'dark'))",
    'CHECK (week_start_day BETWEEN 1 AND 7)',
    'CHECK (default_estimate_assignment BETWEEN 15 AND 480)',
    'CHECK (default_estimate_project BETWEEN 15 AND 480)',
    'CHECK (default_estimate_quiz BETWEEN 15 AND 480)',
    'CHECK (default_estimate_exam BETWEEN 15 AND 480)',
    'CHECK (default_estimate_reading BETWEEN 15 AND 480)',
    'CHECK (default_estimate_other BETWEEN 15 AND 480)',
    'CHECK (significant_diff_pct BETWEEN 5 AND 100)',
    'CHECK (significant_diff_minutes BETWEEN 5 AND 240)',
    'CHECK (exam_revision_days BETWEEN 0 AND 30)',
  ];
}

/// Estimate calibration state per task type (E2, Phase 5).
@DataClassName('EstimateCalibrationRow')
class EstimateCalibration extends Table {
  TextColumn get taskType => textEnum<TaskType>()();
  IntColumn get lastAppliedAt => integer().nullable()();
  IntColumn get dismissedAtQualifyingCount => integer().nullable()();

  @override
  Set<Column> get primaryKey => {taskType};

  @override
  List<String> get customConstraints => [
    "CHECK (task_type IN ('assignment', 'project', 'quiz', 'exam', 'reading', 'other'))",
  ];
}

/// Single row (id = 1) bumped by triggers whenever a scheduler input changes.
@DataClassName('DataVersionRow')
class DataVersion extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get value => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK (id = 1)'];
}
