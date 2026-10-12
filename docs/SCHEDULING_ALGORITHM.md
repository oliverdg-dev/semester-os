# SemesterOS Scheduling Algorithm

Status: specification written in Phase 0 (2026-10-12), implemented in Phase 3 in `packages/semester_scheduler` (pure Dart, no Flutter or database imports).

All weights and thresholds below are **heuristic defaults chosen by judgment, not scientifically validated**. They live in `SchedulerConfig` and are documented here; a test fails if the code defaults and this document disagree.

## 1. Contract

```
ScheduleResult plan(SchedulerInput input)
```

The function is pure and deterministic: identical input produces identical output, including order. It never generates ids, reads the clock or touches I/O; `now` and the time-zone converter are part of the input.

### Input

| Field | Meaning |
|---|---|
| `now` | current instant (UTC) |
| `zone` | `ZoneConverter` for civil date/minute ↔ instant |
| `horizonStart`, `horizonEnd` | civil dates, inclusive |
| `tasks` | incomplete, non-deleted tasks: id, type, priority, gradeWeightPct?, deadline (civil date + minute), remainingEffortMinutes, createdAt |
| `sessions` | non-deleted existing sessions: taskId, plannedStart/End, status, isPinned, isAdHoc, segmentStartedAt?, accumulatedSeconds |
| `availability` | weekly windows (dayOfWeek, startMinute, endMinute, enabled) |
| `exceptions` | one-off busy windows (date, startMinute, endMinute) |
| `settings` | preferredSessionMinutes, breakMinutes, dailyLimitMinutes, examRevisionDays |
| `config` | `SchedulerConfig` (weights and limits, §7) |

### Output

| Field | Meaning |
|---|---|
| `sessions` | proposed sessions (taskId, start, end, reason codes); no ids |
| `unscheduled` | per task: minutes not placed + reason (`beyondPlanningWindow`, `notEnoughTime`, `noAvailability`) |
| `warnings` | `overdue(task)`, `deadlineAtRisk(task, minutesShort)`, `overloadedDay(date, minutesOver)`, `pinnedConflict(session, kind)`, `sessionAfterDeadline(session)`, `taskAlreadyComplete(session)`, `termOverload(minutesShort)` |
| `capacity` | whole-term capacity summary: available minutes vs required minutes |
| `explanations` | per proposed session: ordered reason codes with parameters for "Why here?" |

The engine emits **structured reason codes only**. The app renders all user-facing copy, so the engine contains no English messages and can be localized later.

## 2. Effort

```
remainingEffort(task) = max(0, estimatedMinutes
                              − Σ actualMinutes of its completed and skipped sessions
                              − elapsed minutes of its active/paused session)

effortToSchedule(task, horizon) = max(0, remainingEffort
                              − Σ planned minutes of its pinned sessions with plannedStart ≥ now
                              − Σ planned minutes of its unpinned planned sessions outside the horizon)
```

The app computes `remainingEffort`; the engine computes `effortToSchedule`. A short-horizon run ("Plan this week") therefore never duplicates work already planned later (rule 5).

## 3. Horizon

- Default for "Generate plan": today through `max(latest incomplete deadline date, today + 6)`, capped at `today + 55` (8 weeks).
- "Plan this week": today through today + 6.
- Generated sessions never start before `now` rounded up to the next 5 minutes.
- Tasks whose deadline is after `horizonEnd` are labeled **planned later (from <date>)** when the whole-term capacity check (§6) says they fit, and **notEnoughTime** when it does not.

## 4. Free time (slot expansion)

For each civil date in the horizon:
1. Take enabled availability windows for that weekday.
2. Subtract that date's exceptions.
3. Convert to instants with the zone converter (DST rules in §8).
4. Subtract busy time: pinned sessions, ad-hoc sessions, completed/skipped sessions on that date, and an active session's interval `[segmentStartedAt, max(plannedEnd, now + remaining planned minutes)]`, each padded by `breakMinutes` on both sides.
5. Drop everything before `now` (rounded up to 5 minutes).

Unpinned planned sessions inside the horizon with `plannedStart ≥ generatedAt` are **not** treated as busy: the proposal replaces them.

## 5. Prioritization and allocation

### Score

For a task on a given civil day `d`:

```
daysLeft   = max(0, deadlineDate − d)                         (civil days)
urgency    = 1 / (1 + daysLeft)                               ∈ (0, 1]
priority   = {low: 0.25, medium: 0.5, high: 1.0}
importance = gradeWeightPct / 100 if set, else type default:
             exam 0.8, project 0.6, quiz 0.4, assignment 0.4, reading 0.2, other 0.2
pressure   = clamp(effortToSchedule / max(1, free minutes from d to the deadline), 0, 1)

score = 0.40·urgency + 0.20·priority + 0.15·importance + 0.25·pressure
```

Ordering on each day: overdue tasks first, then descending score, then earlier deadline, then earlier `createdAt`, then id (lexicographic). The last two make ties deterministic.

### Allocation (greedy, day by day)

```
for each civil day d in horizon (ascending):
  dayBudget = dailyLimitMinutes − minutes already busy on d (pinned, ad-hoc, completed, active)
  for each free slot on d (ascending start):
    while slot has ≥ minSessionMinutes and dayBudget ≥ minSessionMinutes:
      candidates = tasks with effortToSchedule > 0
                   and deadline instant ≥ slot cursor + minSessionMinutes
                   and sessionsToday(task) < maxSessionsPerTaskPerDay
                   and (task.type != exam or d ≥ deadlineDate − examRevisionDays or revisionWindowExhausted(task))
      if none: break
      task  = highest-ordered candidate (score order above)
      len   = min(preferredSessionMinutes, effortToSchedule(task), slot remaining, dayBudget,
                  minutes until task deadline)
      if len < minSessionMinutes: mark candidate exhausted for this slot; continue
      emit session(task, cursor, cursor + len, reasons)
      cursor += len + breakMinutes; dayBudget −= len; effortToSchedule(task) −= len
```

- Large tasks split naturally into `preferredSessionMinutes` chunks across days (rule 7); `maxSessionsPerTaskPerDay` spreads work instead of cramming.
- Exam revision (rule 8): exam sessions are placed inside the `examRevisionDays` window before the exam; if that window cannot hold the effort, the window is extended earlier day by day (`revisionWindowExtended` reason) before reporting `notEnoughTime`.
- Sessions never end after their task's deadline instant.
- Completed tasks are never inputs (rule 3); completed and skipped sessions are busy time and are never moved (rule 4).
- Pinned sessions are never moved, deleted or overlapped; rules 1 and 6 constrain generated sessions only. A pinned session that now violates availability, an exception, the daily limit or its deadline stays and produces `pinnedConflict(kind)` with an Unpin action.

### Reason codes on each proposed session

`highestScore`, `overdue`, `deadlineSoon(daysLeft)`, `highPriority`, `highImportance(weight)`, `examRevisionWindow(daysBefore)`, `revisionWindowExtended`, `fitsBeforeDeadline`, `splitLargeTask(part, total)`. The "Why here?" line renders the first two.

## 6. Capacity and warnings

- **Whole-term capacity** (no 8-week cap): free minutes from now to the latest deadline vs Σ `effortToSchedule` over all incomplete tasks. Shortfall → `termOverload(minutesShort)`.
- **Deadline at risk**: after allocation, a task with effort left and a deadline inside the horizon → `deadlineAtRisk(task, minutesShort)` and an unscheduled entry `notEnoughTime`.
- **Overloaded day**: busy + proposed minutes on a day exceed `dailyLimitMinutes` (possible only through pinned/ad-hoc sessions), or a day is fully used while a task due within 2 days still has effort left → `overloadedDay(date, minutesOver)`.
- **Overdue**: deadline instant < now → `overdue(task)`; scheduled at the earliest free slots.
- **Session after deadline**: an existing session for a task that now ends after the task's deadline → `sessionAfterDeadline`; a deadline change regenerates the task's full span in the next proposal.
- **No availability at all**: every task unscheduled with `noAvailability`.

Nothing is ever silently dropped (rule 10): every minute of effort is either in a proposed session, in an existing session, or in `unscheduled` with a reason.

## 7. Configuration (`SchedulerConfig`)

| Key | Default | Notes |
|---|---|---|
| `weights.urgency` | 0.40 | heuristic |
| `weights.priority` | 0.20 | heuristic |
| `weights.importance` | 0.15 | heuristic |
| `weights.pressure` | 0.25 | heuristic |
| `priorityValues` | low 0.25, medium 0.5, high 1.0 | heuristic |
| `typeImportance` | exam 0.8, project 0.6, quiz 0.4, assignment 0.4, reading 0.2, other 0.2 | used when gradeWeightPct is unset |
| `minSessionMinutes` | 15 | shorter fragments are not scheduled |
| `maxSessionsPerTaskPerDay` | 2 | spreads work |
| `defaultHorizonCapDays` | 55 | 8 weeks |
| `startRoundingMinutes` | 5 | |
| `overloadLookaheadDays` | 2 | for `overloadedDay` |

User settings that feed the engine: preferred session length, break length, daily limit, exam revision days, availability and exceptions.

## 8. Time and DST

The engine works in civil dates and minutes-of-day and converts through the injected `ZoneConverter`:
- Nonexistent local time (spring forward): moves forward to the first valid minute.
- Ambiguous local time (fall back): uses the earlier occurrence.
- Durations are real elapsed minutes; a window that spans a DST jump is shorter or longer accordingly.
- Tests construct explicit America/New_York and Europe/London transition dates and pass with the host set to any zone (`TZ=UTC`, `TZ=Asia/Manila`).

## 9. Performance

The engine runs in `Isolate.run` with plain input types. Budget: 200 tasks over a 16-week horizon in under 500 ms on CI (benchmark test). Complexity is O(days × slots × candidate tasks) with small constants.

## 10. Considered alternatives (deferred)

- **Daily effort budgets instead of time slots** ("today: 90 min Chem lab, 45 min reading"). More robust to missed sessions and simpler, but answers "what do I do next" less concretely. Revisit with tester feedback; the engine could emit budgets as a projection of slots.
- **On-device models** (Apple Foundation Models, Android on-device GenAI) for syllabus parsing or explanation wording. Free, offline and keyless on supported devices; deferred because coverage is limited and the rule-based path must exist anyway. "Gemini APIs" in the brief's ban means cloud APIs.
- **Optimization solvers** (ILP/CP) for globally optimal plans. Rejected for v1: harder to explain, harder to keep deterministic and fast on phones.

## 11. Required tests

Brief list: no tasks; no available time; overdue tasks; equal priorities (tie-break order); long tasks (splitting); insufficient weekly capacity; existing completed sessions; exam revision windows; deadline collisions; day and week boundaries; DST transitions (both directions, two zones); skipped sessions; changed availability; repeated identical generation (byte-equal outputs, no ids); no overlaps; no scheduling of completed tasks.

Added by review: pinned preservation, overlap and break spacing around pinned, daily-limit accounting with pinned, pinned conflict cases (availability changed, limit lowered, deadline moved before it); exceptions splitting a window, covering a day, overlapping a pinned session; one-week run over an 8-week plan schedules only unallocated minutes; no session before now (generate at 15:00); all-overdue horizon; 8-week cap; both unscheduled reasons; exam 12 weeks out labeled planned later; over-full term reports `termOverload`; grade weight set/unset; missed pinned session not subtracted; deadline moved earlier flags sessions after deadline; active session interval treated as busy; benchmark; config defaults match this document.
