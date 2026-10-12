/// App-level tunables and value ranges (ARCHITECTURE §2 `core/config`).
/// The database CHECK constraints and form validation both read these, so a
/// range lives in exactly one place. Scheduler tunables live in
/// `SchedulerConfig` in packages/semester_scheduler.
abstract final class AppLimits {
  // Text lengths (ARCHITECTURE §5).
  static const int subjectNameMax = 100;
  static const int courseCodeMax = 20;
  static const int taskTitleMax = 200;
  static const int taskDescriptionMax = 5000;
  static const int milestoneTitleMax = 200;
  static const int exceptionNoteMax = 200;

  /// Subject palette size (DESIGN_SYSTEM §2); colorIndex is 0..subjectColors-1.
  static const int subjectColors = 10;

  /// Minutes of a day: 0..1439. A date-only deadline uses [endOfDayMinute].
  static const int lastMinuteOfDay = 1439;
  static const int endOfDayMinute = lastMinuteOfDay;

  // Task values.
  static const int estimateMinMinutes = 1;
  static const int estimateMaxMinutes = 10000;
  static const int gradeWeightMaxPct = 100;

  // Planning defaults in Settings (IMPLEMENTATION_PLAN Phase 2).
  static const int defaultEstimateMinMinutes = 15;
  static const int defaultEstimateMaxMinutes = 480;
  static const int significantDiffPctMin = 5;
  static const int significantDiffPctMax = 100;
  static const int significantDiffMinutesMin = 5;
  static const int significantDiffMinutesMax = 240;

  // Scheduling settings that feed the engine.
  static const int sessionMinMinutes = 15;
  static const int sessionMaxMinutes = 180;
  static const int breakMaxMinutes = 60;
  static const int dailyLimitMinMinutes = 30;
  static const int dailyLimitMaxMinutes = 960;
  static const int examRevisionMaxDays = 30;

  /// Weekly repeat creates at most this many independent tasks.
  static const int weeklyRepeatMax = 26;
}
