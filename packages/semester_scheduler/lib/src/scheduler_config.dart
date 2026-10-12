import 'task_kind.dart';

/// Weights for the task score. Heuristic defaults chosen by judgment, not
/// scientifically validated; see docs/SCHEDULING_ALGORITHM.md §5 and §7.
class ScoringWeights {
  const ScoringWeights({
    this.urgency = 0.40,
    this.priority = 0.20,
    this.importance = 0.15,
    this.pressure = 0.25,
  });

  final double urgency;
  final double priority;
  final double importance;
  final double pressure;
}

/// Every tunable the scheduling engine reads. Defaults must match the table in
/// docs/SCHEDULING_ALGORITHM.md §7 (a test compares them).
class SchedulerConfig {
  const SchedulerConfig({
    this.weights = const ScoringWeights(),
    this.priorityValues = const {
      TaskPriority.low: 0.25,
      TaskPriority.medium: 0.5,
      TaskPriority.high: 1.0,
    },
    this.typeImportance = const {
      TaskType.exam: 0.8,
      TaskType.project: 0.6,
      TaskType.quiz: 0.4,
      TaskType.assignment: 0.4,
      TaskType.reading: 0.2,
      TaskType.other: 0.2,
    },
    this.minSessionMinutes = 15,
    this.maxSessionsPerTaskPerDay = 2,
    this.defaultHorizonCapDays = 55,
    this.startRoundingMinutes = 5,
    this.overloadLookaheadDays = 2,
  });

  final ScoringWeights weights;
  final Map<TaskPriority, double> priorityValues;

  /// Importance used when a task has no grade weight.
  final Map<TaskType, double> typeImportance;

  /// Fragments shorter than this are never scheduled.
  final int minSessionMinutes;

  /// Spreads work across days instead of cramming one task.
  final int maxSessionsPerTaskPerDay;

  /// Default horizon ends at most this many days after today (8 weeks).
  final int defaultHorizonCapDays;

  /// Generated sessions start at now rounded up to this many minutes.
  final int startRoundingMinutes;

  /// Look-ahead used by the overloaded-day warning.
  final int overloadLookaheadDays;
}
