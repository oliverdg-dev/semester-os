# SemesterOS — /autoplan review record (2026-10-12)

Archived record of the CEO, design, DX and eng plan reviews run before any code was written. The working plan is `docs/IMPLEMENTATION_PLAN.md`; this file keeps the reasoning, decision audit trail and accepted obligations as reviewed. Local machine paths were removed. Outside (Codex) coverage was unavailable in every phase; each phase had one independent Claude reviewer.

## URGENT, outside this plan

None.

## Implementation plan
# SemesterOS — Implementation Plan

> Know what matters. Know what to do next. Stay in control of your semester.

## 0. Repository audit (Phase 0, 2026-10-12)

Facts observed in this environment, not assumptions:

| Item | Observed state |
|---|---|
| Working directory | Empty. No files, no Flutter project, no README, no pubspec.yaml, no tests. |
| Git | Not a repository at audit start. `git init -b main` run with user approval. No remote. |
| Flutter SDK | 3.24.0 stable (2024-07-30), Dart 3.5.0, at `~/development/flutter`, not on the default PATH. User approved `flutter upgrade` to current stable. |
| Xcode | 26.6 (17F113). iOS 17.5 simulators present (iPhone 15 family, iPhone SE 3, iPad Pro/Air/mini/10th gen). `flutter doctor` reports the iOS 26.5 simulator runtime is not installed. |
| CocoaPods | Not installed. iOS builds that use plugins (sqlite3_flutter_libs, flutter_local_notifications, path_provider, file_picker) are blocked until it is installed. |
| Android | SDK at `~/Library/Android/sdk` with platforms 33/34/35 and build-tools 35.0.0. JDK 21 (Temurin). Some Android SDK licenses not accepted; `flutter doctor --android-licenses` must be run by the user. |
| Existing features | None. Everything in this plan is new work. |

Implication: there is no existing work to preserve. Phase 1 creates the project with `flutter create` (org id, platforms android + ios only) and builds forward from there.

## 1. Role and objective

Build SemesterOS, a premium, offline-first academic productivity app for Android phones, Android tablets, iPhones and iPads. Functional, production-minded, not a static prototype, generic CRUD project or basic Material demo. Solo developer, zero-dollar budget for hosting, paid APIs, subscriptions and third-party services. Plan, implement, test and document incrementally.

## 2. Non-negotiable requirements

### Zero-budget architecture

Do not use: OpenAI, Claude or Gemini APIs; paid AI inference; Supabase or Firebase; paid backend hosting; paid database hosting; paid auth or notification services; external APIs for core functionality; dependencies requiring paid accounts or commercial subscriptions.

Use: Flutter and Dart; SQLite with Drift; Riverpod; GoRouter; flutter_local_notifications (if supported and configured); fl_chart where useful; uuid; intl; Flutter's testing tools.

Verify dependency licenses, platform compatibility, maintenance status and whether a service or account is required before introducing any dependency.

### Offline-first

1. All core features work without internet.
2. Academic data stored locally on device.
3. Scheduling, prioritization, workload analysis and rescheduling run locally in Dart.
4. Data persists across restarts.
5. No user accounts.
6. No API keys or environment secrets.
7. No academic or personal data transmitted externally.
8. Local export/import backup.
9. Android and iOS business logic shared.
10. Architecture allows optional future cloud sync without a rewrite.

Publishing fees are separate from development costs. Paid distribution services are never prerequisites for building or testing.

## 3. Planning documents

Create and maintain: `docs/IMPLEMENTATION_PLAN.md`, `docs/ARCHITECTURE.md`, `docs/DESIGN_SYSTEM.md`, `docs/UX_FLOWS.md`, `docs/RESPONSIVE_DESIGN.md`, `docs/SCHEDULING_ALGORITHM.md`. Record actual repository state and implementation sequence. If an environment problem blocks progress, explain it and complete independent work.

## 4. Architecture

Feature-first, layered.

```
lib/
  app/        app.dart, router.dart, theme/
  core/       database/, errors/, utils/, widgets/
  features/   onboarding/ dashboard/ subjects/ tasks/ planner/
              availability/ sessions/ insights/ settings/
  main.dart
```

Each feature uses presentation / application / domain / data layers where appropriate.

- Presentation: screens and reusable widgets.
- Application: Riverpod providers and workflows.
- Domain: entities, business rules, scheduling logic.
- Data: Drift tables, DAOs, repositories, persistence.

The scheduling engine is pure Dart, independent of Flutter widgets and the database. Repositories isolate database access. No giant widgets, circular dependencies, duplicated business logic or needless abstraction.

## 5. Database

SQLite via Drift.

- **Subjects**: id, name, courseCode?, color, createdAt, updatedAt.
- **Tasks**: id, subjectId?, title, description?, type (Assignment, Project, Quiz, Exam, Reading, Other), deadline, estimatedMinutes, priority, status (incomplete / in-progress / completed), createdAt, updatedAt.
- **Milestones**: id, taskId, title, isCompleted, createdAt, updatedAt.
- **Availability**: id, dayOfWeek, startTime, endTime, isEnabled. Users configure weekly study availability.
- **Study sessions**: id, taskId, plannedStart, plannedEnd, actualMinutes, status (planned, active, paused, completed, skipped), createdAt, updatedAt.
- **Settings**: preferred session duration, break duration, daily study limit, theme, notification preferences, scheduling settings.

Quality: stable identifiers; foreign keys and deletion behavior; indexes; correct nullability; schema migrations; transactions for all-or-nothing operations; no duplicate or overlapping generated sessions; completed sessions preserved on regeneration; persistence and migration tests; no destructive schema changes that silently erase data.

Local JSON export/import with validation and safe handling of malformed or incompatible backups.

## 6. Product features

**A. Onboarding**: availability, session duration, break duration, daily limit, theme. Short, skippable, sensible defaults, changeable later.

**B. Subjects**: create, edit, delete (with confirmation and clear data handling), colors, associated tasks, task counts, upcoming deadlines.

**C. Tasks**: create, edit, complete, delete; optional subject; deadline; effort estimate; priority; type; description; milestones; overdue and upcoming views; progress. Inline field validation; entered data preserved on validation failure.

**D. Today dashboard**: answers (1) what do I need to do today, (2) what should I work on next, (3) am I on track. Shows greeting and date, today's sessions, next recommended action, start/resume button, upcoming deadlines, planned vs completed time, daily progress, overload warnings. Real persisted data only; no hardcoded or placeholder metrics.

**E. Study planner**: weekly planner with readable blocks showing task, subject, start/end, duration, status; unscheduled tasks; overloaded days; deadline conflicts. Explains prioritization and what changed after rescheduling. Useful empty state.

**F. Session tracking**: start, pause, resume, complete, skip, record actual time. Persist state correctly; survive restarts and interruptions without losing or double-counting time.

**G. Workload insights**: planned vs actual time; weekly workload; workload by subject; deadline concentration; estimated vs actual effort; unscheduled work; workload exceeding available time. All derived from real data, explained in plain language, useful empty states.

**H. Local notifications**: optional, after core is stable. No remote service. Handle permissions, platform scheduling limits, cancellation and changed deadlines. Document limitations instead of claiming they work.

## 7. Scheduling engine

Pure Dart, testable without Flutter or a database.

Inputs: incomplete tasks; remaining effort; deadlines; priorities; task types; exam dates and revision needs; weekly availability; daily limits; session duration; break duration; existing sessions and statuses.

Outputs: proposed sessions; unscheduled tasks / remaining effort; deadline-conflict warnings; overloaded-day warnings; decision explanations.

Rules:
1. Never schedule outside availability.
2. Never create overlapping sessions.
3. Never schedule completed tasks.
4. Preserve completed historical sessions.
5. Avoid duplicating existing sessions.
6. Respect daily limits.
7. Split large tasks into manageable sessions.
8. Schedule exam revision before the exam when feasible.
9. Detect workloads exceeding capacity.
10. Never silently discard tasks that do not fit.
11. Deterministic output for identical input.
12. Explain decisions in plain language.

Transparent prioritization using deadline urgency, user priority, remaining effort and assessment importance. Document the scoring model; make weights configurable where appropriate; do not present heuristic weights as scientifically validated.

Rescheduling triggers: skipped session, deadline change, availability change, actual effort significantly different from estimate. Steps: recalculate remaining work; preserve completed work; reevaluate time; generate a revised proposal; explain important changes; show conflicts and unscheduled work; persist the accepted plan safely. Never silently move the whole schedule.

Required scheduler tests: no tasks; no available time; overdue tasks; equal priorities; long tasks; insufficient weekly capacity; existing completed sessions; exam revision windows; deadline collisions; day and week boundaries; DST transitions; skipped sessions; changed availability; repeated identical generation; no overlaps; no scheduling of completed tasks.

## 8. Premium UI/UX

Polished, cohesive, calm, trustworthy. No generic dashboard templates, card overload, random gradients, decorative clutter, emoji UI icons or gratuitous animation.

Documented design system: brand identity; light and dark themes; semantic colors; typography; spacing; radii; elevation; icons; navigation; forms; buttons; charts; component states; motion.

Reusable components with centralized tokens (examples: AppScaffold, AdaptiveNavigation, PageHeader, TodaySessionCard, DeadlineItem, SubjectCard, TaskListTile, PrimaryActionButton, EmptyState, ErrorState, WorkloadSummary, SessionTimer, DeadlineBadge).

Every visible control works. Loading, empty, error, success and validation states. Undo for practical reversible actions. Clear active / paused / completed / skipped states. Supportive language ("Three tasks remain. Let's find a realistic time for them."), never shaming. Subtle motion that respects reduced-motion.

## 9. Responsive phone and tablet

Shared codebase. Layout from window width, not device model. Breakpoints: compact < 600, medium 600–839, expanded ≥ 840 (adjust if testing shows better values).

- Compact: bottom navigation, clear primary action, readable lists, focused screens, efficient forms.
- Medium: navigation rail, useful two-column layouts, bounded content widths.
- Expanded: persistent rail/sidebar, multi-column dashboard, master-detail subjects and tasks, expanded weekly planner, insight grids.

Test portrait, landscape, resizing and split-screen. No overflow, minimal excess scrolling.

## 10. Accessibility

WCAG 2.2 AA principles where relevant: contrast; screen-reader labels; logical focus order; touch targets; system text scaling; clear interaction states; non-color-only status; reduced motion; accessible chart summaries. Accessibility wins over visual design when they conflict.

## 11. Phases

- **Phase 0 — Audit and planning.** Inspect repo, document architecture, design, UX flows, responsive behavior, scheduling, milestones, risks. Deliverable: documented plan.
- **Phase 1 — Foundation.** Create/repair project, dependencies, routing, Riverpod, themes and tokens, lint/format, Drift setup, smoke tests, free CI. Deliverable: runnable foundation.
- **Phase 2 — Database and core data.** Tables, migrations, repositories, subject and task management, validation, persistence, DB tests. Deliverable: subject/task workflows on SQLite.
- **Phase 3 — Scheduling engine.** Pure Dart domain, prioritization, allocation, capacity and conflict detection, explanations, comprehensive tests. Deliverable: tested scheduler.
- **Phase 4 — Dashboard and planner.** Today dashboard, daily and weekly planner, real data, session tracking, all states. Deliverable: end-to-end planning workflow.
- **Phase 5 — Rescheduling and insights.** Rescheduling proposals, preserved completed sessions, overload detection, analytics, change explanations, persistence edge cases. Deliverable: functioning offline planning system.
- **Phase 6 — Responsive and polish.** Phone and tablet layouts, navigation, forms, typography, spacing, hierarchy, motion, accessibility testing, consistency pass. Deliverable: polished adaptive UI.
- **Phase 7 — Notifications and backups.** Local reminders, preferences, JSON export/import, validation, restore tests. Deliverable: optional reminders and user-controlled backups.
- **Phase 8 — QA.** Format, analyze, unit, widget, integration, migration, restart persistence, offline, responsive; fix defects. Deliverable: documented results, stable RC.
- **Phase 9 — Release prep.** README, setup/build docs, architecture/scheduling docs, known limitations, icon and launch assets, genuine screenshots, Android release config, iOS config when Xcode is available, store listing docs. Deliverable: release-ready project.

## 12. Testing

At minimum: scheduling, prioritization, rescheduling, repositories, migrations, form validation, critical widgets, subject/task create/edit, session completion, restart persistence, JSON export/import, the full core journey.

Critical integration journey: open app → create subject → add task with deadline → configure availability → generate plan → start session → complete or skip → review updated plan → restart app → verify data and session history persist.

Never claim tests passed, builds succeeded or platforms were verified without running the checks. Document exact missing-tool limitations.

## 13. Git and change management

Inspect git status before substantial changes; preserve unrelated work; no destructive commands. Small, understandable change groups. After each phase: format, analyze, test, fix regressions, update docs, summarize files changed and real verification results. Never leave the repo knowingly broken when a smaller working implementation is possible.

## 14. README

Covers: what SemesterOS does; features; screenshots; architecture; database design; scheduling algorithm; offline-first behavior; privacy; backup and restore; prerequisites; setup; run; test; Android build; iOS build; known limitations; roadmap. States clearly that v1 has no cloud sync and data lives on the device. Publishing costs documented separately from development costs.

## 15. Acceptance criteria

Satisfied or explicitly documented as blocked: offline core; no paid APIs or credentials; local persistence; subject and task workflows; scheduling and rescheduling; completed sessions preserved; overload detected; insights on real data; safe backup/restore; phone layouts; tablet layouts; accessibility considered and tested; critical tests pass; docs match implementation; Android build verified when possible; iOS build verified when Xcode is available; no fabricated results or screenshots; no knowingly broken critical workflows.

## 16. How to begin

Phase 0 report: project structure; Flutter/Dart setup; database and state management; existing features; missing requirements; technical risks; recommended order; exact first changes. Create planning docs before large implementation. Proceed incrementally, keeping the app runnable and tested at each phase.

<!-- autoplan-accepted:ceo -->
- Schema v1 contains every column the accepted items need, so v1 ships at schema version 1 with no follow-up migration: Study sessions add `isPinned` (bool, not null, default false); Settings is a single-row table (fixed id) with per-type default estimate columns for all six task types, `weekStartDay` (default Monday), `significantDiffPct` (default 25), `significantDiffMinutes` (default 30), `lastSuccessfulExportAt` (nullable), `backupNudgeDismissedAt` (nullable), plus the brief's settings; an `EstimateCalibration` table keyed by task type holds `lastAppliedAt` (nullable) and `dismissedAtQualifyingCount` (nullable); Tasks add `completedAt` (nullable; set when a task is completed, cleared when it is reopened to incomplete, which the task screen supports). Verify: schema snapshot test lists these columns, `completedAt` and the calibration table; unit test that complete sets and reopen clears `completedAt`; a fresh database has exactly one Settings row.
- Task deadline is a local date-time; a date-only entry (including quick add) defaults to 23:59 local on that date. Verify: unit test that a date-only quick-add deadline persists as 23:59 local.
- Remaining effort for a task = max(0, estimatedMinutes − sum of actualMinutes of its completed and skipped sessions − accrued minutes of its active/paused session). Minutes recorded on a skipped session are real study time. This is the scheduler's "remaining effort" input. Effort to schedule within a horizon = remaining effort − planned minutes of the task's pinned sessions not yet started − planned minutes of its unpinned planned sessions outside the horizon, so a short-horizon run never duplicates work already planned elsewhere (brief rule 5). Verify: unit tests with no sessions, partial sessions, a skipped session with recorded minutes, actual exceeding the estimate (result 0), and a one-week run over an existing 8-week plan that schedules only the not-yet-allocated minutes.
- Missed sessions: a session still `planned` whose plannedEnd is in the past is shown as "Missed" (derived at read time from the injected clock; no extra status column) and is treated like skipped for rescheduling triggers. Verify: unit test that a planned session ending 1 minute before now reads as missed and one ending 1 minute after does not.
- "Actual effort significantly different from estimate" (brief §7 rescheduling trigger) = |actual − estimate| ≥ `significantDiffPct`% of estimate AND ≥ `significantDiffMinutes` minutes [estimated heuristics, documented as such]. Verify: unit tests at 24%/25% and 29/30 minute boundaries with defaults.
- Scheduler inputs gain `horizonStart` and `horizonEnd` (local dates); generation never creates sessions outside the horizon. Generated sessions never start before now (rounded up to the next 5 minutes). Default horizon for "Generate plan" = today through max(latest incomplete task deadline, today+6), capped at today+55 (8 weeks) [estimated]; overdue tasks get top urgency, are placed at the earliest available slots, and carry an "overdue" warning. Effort that does not fit is reported as unscheduled with its reason: "beyond the planning window" or "not enough available time". The planner week view starts on `weekStartDay`. Verify: unit tests that a one-week horizon yields no sessions outside it, no session starts before now when generating at 15:00, the all-overdue case uses today..today+6, the 8-week cap applies, and both unscheduled reasons appear.
- Proposal accept/reject: a generated or rescheduling proposal shows added, moved and removed sessions; Accept replaces, in one transaction, every unpinned session still in `planned` status with plannedStart ≥ now within the horizon with the proposed sessions (missed sessions stay as history); Reject changes nothing. No partial acceptance in v1. Rescheduling triggers (skip, missed, deadline change, availability change, significant effort difference) never generate or accept a proposal on their own: they show a non-modal "Your plan needs attention" banner on the Dashboard and Planner listing the reasons, and tapping it opens a proposal. Verify: repository test that Accept is atomic (simulated failure leaves prior sessions intact) and leaves pinned, completed, skipped, active and missed sessions untouched; test that Reject leaves the database byte-identical; widget test that a skip shows the banner and creates no new sessions until a proposal is accepted.
- Deletion: deleting a task asks for confirmation that states how many tracked minutes will be removed, then deletes the task, its milestones and all its sessions (any status) in one transaction, with an Undo snackbar that restores them exactly. Deleting a subject asks "Keep its tasks without a subject" (default) or "Delete its tasks too" (same rules as task deletion); its Undo restores the subject and, for the keep option, the tasks' subjectId, or for the delete option, the tasks, milestones and sessions. Verify: repository tests for both subject options with undo restoring identical rows, and for task delete + undo restoring identical rows; widget test that the confirmation shows the minutes count.
- E1 Quick add (Phase 2): a task can be created with only title, deadline and type; estimatedMinutes defaults from the Settings per-type default; priority defaults to Medium and status to incomplete. Starting defaults [estimated]: Assignment 120, Project 360, Quiz 90, Exam 240, Reading 60, Other 60 minutes. Verify: widget test creates a task with only the three fields and asserts estimate 120 for an Assignment, priority Medium, status incomplete; unit test for default lookup for all six types.
- Planning defaults in Settings (Phase 2): a "Planning defaults" section edits the six per-type default estimates (15-480 minutes, inline validation), `weekStartDay`, `significantDiffPct` (5-100) and `significantDiffMinutes` (5-240). Verify: widget test edits a default and a quick-added task uses the new value; validation test rejects out-of-range values with a field-level error.
- E2 Estimate calibration (Phase 5): per task type, qualifying tasks are completed tasks with at least 1 tracked minute that were completed after that type's `lastAppliedAt` (all of them when never applied). Ratio = sum(actualMinutes of their completed and skipped sessions) / sum(their estimatedMinutes). Shown on the Insights estimate card only when at least 3 qualifying tasks exist. "Use for new estimates" sets the Settings default to round(currentDefault × ratio) to the nearest 5 minutes, clamped to [15, 480], sets `lastAppliedAt`, clears `dismissedAtQualifyingCount`, and never changes existing tasks; after applying, the suggestion returns only once 3 new qualifying tasks exist. Dismissing records `dismissedAtQualifyingCount`; the suggestion returns when the qualifying count reaches that value + 3. Verify: unit tests with 0, 2, 3 and 10 qualifying tasks, a zero-tracked task excluded, tasks completed before `lastAppliedAt` excluded (by `completedAt`), rounding and both clamps, dismissal re-offer at +3, dismissal cleared on apply, and existing task estimates unchanged after applying.
- E7 Weekly review (Phase 5): reachable from a Planner action at all times and from a Dashboard card shown on the Settings `weekStartDay`. Figures, in local calendar days: "Last 7 days" = today−6 through today; Planned = sum of planned durations of sessions starting in that window, any status; Studied = sum of actualMinutes of completed and skipped sessions whose plannedStart is in that window; "Coming up" = incomplete tasks due today through today+6, with overdue incomplete tasks listed separately. "Plan this week" opens a proposal with horizon = today through today+6, using the accept/reject flow above. Verify: widget test with a fixed seeded dataset asserts literal expected numbers (not values re-derived from the repository); empty-state test with no data.
- E10 Pinned sessions (Phases 3-4): a session can be pinned or unpinned from its detail sheet; editing a planned session's time through an "Edit time" sheet pins it. The edit sheet blocks overlap with any other session and blocks times outside availability, with inline errors; going over the daily limit is allowed with an inline warning. The scheduler never moves, deletes or overlaps a pinned session, counts its minutes against that day's limit as busy time, and keeps breakDuration spacing between generated sessions and pinned ones. Scheduler rules 1 and 6 constrain generated sessions; a pinned session that later violates them (availability changed, limit lowered, deadline moved before it) stays put and produces a conflict warning with an Unpin action. Deleting a task deletes its sessions per the deletion rule above. When a task is completed, its pinned future sessions stay in place with a "task already complete" warning; they still count as busy time against the daily limit but do not count toward planned workload in insights. Verify: scheduler unit tests for preservation across regeneration, overlap and break spacing around a pinned session, daily-limit accounting, and the three conflict cases; widget test that editing time pins the session and that overlap is blocked.
- E11 Backup nudge (Phase 7): Settings shows `lastSuccessfulExportAt` or "Never backed up". Export serializes the backup JSON and validates it with the same validator import uses before writing; it counts as successful when the platform save-file dialog reports a saved location, plus a read-back check where the platform allows reopening that location. No share-sheet path in v1. Phase 7 starts with a spike confirming save-dialog behavior on Android (Storage Access Framework) and iOS (document picker), and records any platform where the result cannot be confirmed in Known limitations. The dashboard reminder shows when at least one task exists AND (no successful export OR elapsed ≥ 30 whole days since the last one) AND it was not dismissed in the last 30 days. Verify: unit tests at 0, 29 and 30 elapsed days (hidden, hidden, shown), never exported, zero tasks (hidden), and dismissed 10 days ago (hidden); test that export refuses to write when validation fails.
- Backup format carries a `schemaVersion` field (1 in v1) and includes `isPinned`, all Settings fields and the calibration table. Import is replace-all: it shows a confirmation naming what will be replaced and offering an export first, validates the whole file, then replaces all data in one transaction; on any validation or write failure the current data is untouched and a plain-language error names the problem. Within a known version, missing optional fields get defaults (`isPinned=false`, Settings defaults); an unknown higher version is rejected with no data change; import never copies `lastSuccessfulExportAt` or `backupNudgeDismissedAt` from the file; the device's current values of both survive the replace; a file with no `schemaVersion` is rejected as "not a SemesterOS backup" with no data change. Verify: round-trip test, a v1 fixture missing optional fields, a higher-version rejection test, a missing-schemaVersion rejection test, a malformed-JSON test, a test that local `lastSuccessfulExportAt` survives import, and a mid-import failure test leaving prior data intact.
- Backup includes Tasks.`completedAt`.
- Tests list (brief §12) and acceptance criteria (brief §15) include E1, E2, E7, E10 and E11 with the verifications above.
- PR5/PR6 environment blockers: Phase 1 creates a README stub with a "Known limitations" section naming `brew install cocoapods` (iOS plugin builds) and `flutter doctor --android-licenses` (Android release builds); the §15 iOS criterion is read as "iOS build verified when Xcode and CocoaPods are available", since Xcode 26.6 is present. Verify: README stub exists after Phase 1 and names both commands.
- Before Phase 1, record the post-upgrade `flutter --version` (Flutter and Dart) in §0 of this plan. Verify: §0 shows the new versions.
- §0 no longer names share_plus (removed from v1 by spec review 2); recorded as a baseline edit below.
- Grade weight (CEO voice F4): Tasks add nullable `gradeWeightPct` (0-100, schema v1). The scheduler's "assessment importance" uses gradeWeightPct when set, otherwise a per-type default documented in docs/SCHEDULING_ALGORITHM.md. Verify: scoring unit tests with weight set, unset, and two tasks differing only by weight.
- One-off busy times (CEO voice F5): an `AvailabilityExceptions` table (id, date, startTime, endTime, note?, timestamps) in schema v1; each exception removes that time from that date's availability. Availability screen offers "Add a one-off busy time". The scheduler never places generated sessions inside an exception; a pinned session inside one gets a conflict warning. Verify: scheduler tests with an exception splitting a window, covering a whole day, and overlapping a pinned session; widget test adding an exception.
- Soft delete (CEO voice F6, brief §2 offline item 10): Subjects, Tasks, Milestones, Study sessions, Availability and AvailabilityExceptions carry nullable `deletedAt` (schema v1). The deletion rules above are implemented by setting `deletedAt` in one transaction; Undo clears it; repository queries and insights exclude deleted rows; backups export only non-deleted rows; tombstones are kept in v1 (no purge). Verify: repository tests that deleted rows disappear from every list and insight query, Undo restores them, and export omits them.
- Work beyond the planning window (CEO voice F7): a whole-term capacity check runs over all incomplete tasks without the 8-week cap to detect overload. Effort for tasks whose deadline is after horizonEnd is labeled "Planned later (from <date>)" when that check says it fits, and "not enough available time" when it does not. Exam revision is placed in the days before the exam once the exam enters the horizon. Verify: unit tests with an exam 12 weeks out (labeled planned later, no overload) and with an over-full term (overload reported).
- OS-level backup coverage (CEO voice F10, taste): the database lives where Android Auto Backup (`allowBackup` plus `dataExtractionRules` including the database) and iOS device backup include it. README Privacy and Backup states that these platform backups are controlled by the user's own device settings and accounts, and the app itself sends nothing. Verify: manifest and data-extraction rules checked in a test or script; manual restore test on an Android emulator recorded with its actual result.
- Weekly repeat (CEO voice F1, taste): the task form offers "Repeat weekly until <date>", which creates independent task instances at save time (at most 26) with deadlines on the same weekday and time. No recurrence engine. Verify: unit test that a 10-week repeat creates 10 tasks with correct local deadlines across a DST change; test of the 26 cap.
- Product framing (CEO voice F3/F14): docs/IMPLEMENTATION_PLAN.md gains a "Product framing" section marked [assumed, confirm with the user]: persona (undergraduate with 4-6 courses, phone-first, plans on Sunday evenings), success metric (5 real students use it for 3 consecutive weeks), and three differentiators: explained scheduling that never silently moves the plan, fully private with no account, and estimates that learn the student's real pace. README uses the same three. Verify: section and README paragraph exist.
- Considered alternatives (CEO voice F12/F13): docs/SCHEDULING_ALGORITHM.md records the daily-effort-budget mode and optional on-device models (Apple Foundation Models, Android on-device GenAI) as considered and deferred; §2's "Gemini APIs" means cloud APIs. README notes that simulator builds need no Apple account, while device builds need a signing team (a free personal team gives 7-day provisioning). Verify: both notes exist.
- Single active session: at most one session is `active` or `paused` at any time, enforced by the repository transaction and a partial unique index; starting another asks to pause or finish the current one. Verify: repository test that a second start fails without changing data; widget test of the prompt.
- Long-running session guard: when an active segment's elapsed wall-clock time exceeds the session's planned duration + 60 minutes (including after an app restart), the app asks the user to confirm the minutes before recording them, suggesting the planned duration. Verify: unit test with a fake clock at +59 and +61 minutes over plan, and across a simulated restart.
- Stale proposal guard: a proposal records the data version it was built from; Accept refuses with "Your plan changed. Regenerate?" if any task, session, availability or setting changed since, and the Accept button is disabled while committing. Verify: repository test of a stale accept; widget test of a double tap producing one commit.
- Backup import hardening: files over 10 MB are rejected before parsing; strings are length-limited (title 200, description 5000, subject name 100, course code 20, milestone 200, note 200); enums, ids, dates and references (each session's taskId and each task's subjectId exist in the file) are validated. Verify: one rejection test per rule.
- Database recovery: if the database cannot be opened (corrupt file) or its schema version is newer than the app, a recovery screen offers Restore from backup, Start fresh (the old file is renamed, never deleted) and Show details. Before any future schema migration runs, the database file is copied to a `.bak` file first. Verify: test with a corrupted-file fixture and a newer-version fixture.
- Resume recompute: on app resume, on local date change and on time-zone change, derived state (missed sessions, today's dashboard, nudges) is recomputed. Verify: test with a fake clock crossing midnight and a time-zone change.
- Local diagnostics: Settings > About shows app version, schema version, database size and the last error message (never task or subject content), with "Copy diagnostics". Verify: widget test that the copied text contains no task titles from seeded data.
- Scheduler package: the scheduling engine lives in `packages/semester_scheduler`, a pure Dart package with no Flutter dependency, tested with `dart test`; the app depends on it by path. Verify: the package pubspec has no flutter dependency and CI runs its tests.
- Notification limits (Phase 7): pending local notifications are capped (at most 50, covering at most the next 30 days) and re-planned on app open and after plan changes, to stay under iOS's 64-pending limit; a "Show task names in notifications" setting (default on) controls lock-screen content. Verify: unit test of the cap with 200 candidate reminders; test that turning the setting off produces generic text.
- CI: a GitHub Actions workflow runs the format check, analyze, `flutter test` and the scheduler's `dart test`; it is labeled unverified in README until it has run on a pushed remote. Verify: workflow file exists and README states its verification status honestly.
- Unsaved changes: leaving a task, subject, availability or settings form with unsaved edits asks "Discard changes?" (Keep editing / Discard); system back and navigation both trigger it. Verify: widget test that back with edits shows the prompt and Keep editing preserves the entered values.
- Global error handling: `FlutterError.onError` and a root zone handler record the last error for diagnostics and show ErrorState with a Retry or Go to Today action instead of a blank screen; no catch-all swallows errors silently inside features. Verify: widget test that an exception thrown in a screen's provider renders ErrorState and records the message.
<!-- /autoplan-accepted:ceo -->

<!-- autoplan-accepted:design -->
- Navigation (taste): four destinations Today / Plan / Tasks (with a Subjects segment) / Insights as bottom navigation (compact), NavigationRail (medium) and extended rail (expanded); Settings opens from the page header; Availability is reachable from Plan and Settings; quick add is a FAB on compact Today, Plan and Tasks and a rail button on medium/expanded. Verify: widget tests at 360, 700 and 1024 dp widths assert the navigation widget type and four destinations.
- Today hierarchy: next-action block first and the only primary button; at most one attention banner (priority: plan needs attention > overload > backup reminder); today's sessions; planned vs studied progress; deadlines for the next 7 days; at most one secondary card (weekly review first). Other notices go to a header "Notices" list. Verify: widget test with all notice conditions true shows exactly one banner (plan needs attention) and one secondary card.
- Next-action states: the eight-row state table in this review (active, paused, next later today, missed with nothing upcoming, nothing planned with open tasks, no tasks, no availability, all done) with its headline, supporting line, primary and secondary actions goes into docs/UX_FLOWS.md; "Study now" starts an ad-hoc pinned session for the most urgent task immediately. Verify: one widget test per row asserting the headline and primary button.
- Plan triggers: task create, edit, delete and complete are added to the "Your plan needs attention" triggers; after saving a task a snackbar offers "Schedule it now?" which opens a proposal; Plan's persistent primary action is "Update plan". Verify: widget test that creating a task shows the snackbar and the banner, and no sessions change until Accept.
- Proposal review: summary line first, sessions grouped by week with counts and expandable "Why here?" lines, unscheduled and conflict sections above Accept; full-screen route on compact and a side panel on expanded; on a first-ever plan Reject reads "Not now". Verify: widget test with a 50-session proposal renders the summary and week groups collapsed; golden test at compact and expanded widths.
- Planner layouts: compact day strip + agenda; medium 3-day view; expanded 7-day time grid with an unscheduled tray; text scale ≥ 1.3 forces the agenda; no drag-to-move in v1. Verify: widget tests at 360/700/1024 dp and at text scale 2.0 with no overflow errors.
- Session UI: mini session bar above navigation on every screen while a session is active or paused, opening the SessionTimer screen; Complete sheet with editable actual minutes prefilled with elapsed; Skip sheet with "Didn't start" or "Studied some: __ min"; long-session dialog copy as written in this review. Verify: widget tests for bar visibility after navigation and after a simulated restart, and for both sheets writing the entered minutes.
- Onboarding ending: availability presets (Weekday evenings 18-21, Weekends 10-16, Custom); onboarding ends in quick add for the first deadline; skipping onboarding sets Mon-Fri 18:00-21:00 and Today shows "Edit study times". Verify: widget test of the skip path producing those availability rows and the link.
- Welcome back: when 2 or more sessions were missed since the last app open, Today shows one summary "A few sessions slipped by. Let's re-plan from today." with a single Re-plan action, and the Planner groups missed sessions into a collapsed history group. Verify: widget test with 3 missed sessions shows one summary and no per-session alarms.
- Warning taxonomy: info / attention / capacity levels, each with one icon, label pattern, placement rule and action, documented in docs/DESIGN_SYSTEM.md and implemented as one WarningBadge/WarningRow component used everywhere. Overload messages give hour counts and the actions Add study time, Review estimates, See what doesn't fit. Verify: unit test mapping every warning type to a level; widget test that overload shows all three actions.
- Visual tokens (taste): IBM Plex Sans bundled as an asset with tabular figures; type scale 12/14/16/20/24/32 with body 16; cool neutral base and deep-teal accent with the hex values in this review; semantic info/attention/capacity/success colors always paired with icon and label; fixed 10-color subject palette validated at 3:1 against light and dark surfaces; 4-pt spacing; radii 4/8/16; flat surfaces with elevation only on sheets, dialogs and FAB; bundled Material Icons; Material 3 with adaptive dialogs, pickers and switches; motion 150-250 ms ease-out, instant under reduced motion. No runtime font fetching. Verify: contrast test computing ratios for every text/background token pair and subject color; golden tests in light and dark.
- Form details: date-only deadlines display as "Due <day>, end of day"; weekly repeat shows a live preview line before saving; task progress = tracked minutes / estimate as a bar plus a milestone checklist with its own count; status becomes in-progress automatically on first session start. Verify: widget tests for each.
- Availability editor: seven day rows with time-range chips and "Copy to weekdays"; one-off busy times as a dated list below. Verify: widget test adding two windows on Monday and copying them to weekdays.
- Master-detail (expanded): empty detail pane shows "Select a task" and quick add; selection survives rotation and resize; switching items with unsaved edits triggers the discard prompt. Verify: widget test resizing 1024→700→1024 dp keeps the selection.
- Copy and small confirmations: empty-state copy for Today, Plan, Tasks, Subjects, Insights and Weekly review written in docs/UX_FLOWS.md; calibration copy suggests a default ("Your Assignments usually take about 2h 45m. Use that for new ones?"); subject delete skips the choice when the subject has 0 tasks; recovery "Start fresh" copy says the current data stays saved as a file. Verify: UX_FLOWS.md copy table exists; widget test for the 0-task subject delete.
- Loading rules: no skeletons for local reads under about 150 ms; proposal generation disables its button with inline progress and never blocks the whole screen. Verify: widget test that generation keeps navigation usable.
- Weekly review card shows all day on weekStartDay and hides when dismissed or when "Plan this week" is accepted. Verify: widget test for both hide paths.
- Notification permission is requested only when the user enables reminders, after a one-line pre-prompt. Verify: widget test that first launch triggers no permission request.
- Insights charts: planned vs studied as 7 paired bars, workload by subject as horizontal bars, deadline concentration as a weekly list, estimate vs actual as per-type rows; each needs ≥ 1 studied session and carries a text summary line used as its semantics label. Verify: widget test that each chart's semantics label equals its summary line.
- Undo: snackbar lasts 10 s and is announced to screen readers; Undo does not survive navigation; undoing a delete of a task with planned sessions raises "plan needs attention". Verify: widget test of the announcement and the banner after undo.
- Accessibility: 48 dp minimum touch targets; 4.5:1 body and 3:1 UI contrast in both themes; layouts checked at text scale 1.0, 1.5, 2.0; semantics label on every session block (task, start-end, status, pinned); status never color-only; timer announces state changes only; visible focus ring on tablets. Verify: Flutter accessibility guideline tests (`meetsGuideline` for tap targets, labels and contrast) on Today, Plan, Tasks and the proposal screen.
- Mockups were not generated (paid OpenAI image API conflicts with the zero-dollar budget); /design-review on the running app after Phase 6 replaces them. Verify: Phase 6 checklist includes it.
<!-- /autoplan-accepted:design -->

<!-- autoplan-accepted:dx -->
- Toolchain pin: `.fvmrc` pins Flutter 3.47.7 (Dart 3.13.5, observed after the approved upgrade on 2026-10-12); pubspec sets matching `environment` SDK and Flutter constraints; CI uses subosito/flutter-action with `flutter-version-file`; README explains fvm or putting `~/development/flutter/bin` on PATH. Verify: `tool/check.sh` fails with a clear message when `flutter --version` differs from the pin.
- Codegen policy: Drift-generated files are gitignored; `tool/bootstrap.sh`, `tool/gen.sh` and CI run `dart run build_runner build --delete-conflicting-outputs`; the decision is recorded in ARCHITECTURE.md. Verify: a clean clone followed by `tool/bootstrap.sh` and `flutter analyze` reports no missing generated symbols.
- Scripts: `tool/bootstrap.sh` (version check, pub get for app and `packages/semester_scheduler`, codegen, readiness lines for Android licenses and CocoaPods with the exact fix command, exit 0 when Android work is possible, prints elapsed time), `tool/check.sh` (format check, analyze, `flutter test`, scheduler `dart test` with `TZ=America/New_York`), `tool/gen.sh`, `tool/test_integration.sh <device-id>`. CI runs `tool/check.sh` and `flutter build apk --debug`. Verify: CI workflow invokes the scripts, not ad-hoc commands; README Test section names them.
- Stack conventions recorded in ARCHITECTURE.md (taste): Riverpod 3 without code generation, GoRouter with route-name constants, `flutter_lints`, `package:clock` for time, `package:timezone` (bundled database, offline) for zone conversion; Drift is the only code generator. A unit test fails if any file under a feature's `presentation/` imports that feature's `data/` layer or any `drift` symbol. Verify: the layer test exists and passes.
- Time-zone model: the scheduler package computes in civil date + minutes-of-day and converts through an injected `ZoneConverter`; DST tests construct explicit America/New_York and Europe/London transition dates and do not depend on the host zone. Verify: the DST tests pass with `TZ=UTC` and `TZ=Asia/Manila`.
- Errors: `core/errors/` defines a typed failure hierarchy with stable codes `SEM-<AREA>-<NNN>`; docs/ERRORS.md lists code, user message, cause and fix for every failure; Copy diagnostics includes codes; each backup rejection test asserts its code. A ring buffer keeps the last 200 error and lifecycle events without task or subject content, shown under Show details. Verify: unit test that every failure class has a docs/ERRORS.md row (parsed in the test); ring-buffer test with seeded content asserts no titles appear.
- Test-precision replacements for CEO obligations: "Reject leaves the database byte-identical" is verified by a row-identical dump of every table; the stale-proposal data version is a `DataVersion` counter row incremented in the same transaction as every repository write; the single-active-session partial unique index applies to rows where status is active or paused AND `deletedAt IS NULL`. Verify: these three tests use the stated mechanisms.
- Docs pass before Phase 1: docs/UX_FLOWS.md holds the next-action state table, empty-state and dialog copy; docs/DESIGN_SYSTEM.md holds the color hex values, type scale and warning taxonomy; docs/IMPLEMENTATION_PLAN.md folds every accepted obligation into its phase checklist under a plain feature name with its Verify clause and adds a glossary for review labels. Verify: each referenced table exists in the named doc; no phase-less obligation remains.
- ARCHITECTURE.md "How to" recipes: add a column and migration (drift_dev schema dump into committed `drift_schemas/`, generated migration tests), add a scheduler rule with tests, add a warning type, update goldens. Phase 2 commits `drift_schemas/drift_schema_v1.json`. CHANGELOG.md starts in Phase 1. Verify: recipes exist; schema file committed in Phase 2.
- Developer menu: debug-only Settings > Developer screen with seed sample semester (the same deterministic fixture used by widget and integration tests), reset database, clock offset, force recovery screen, dump database to JSON; it is compiled out of release builds. Verify: widget test that the screen is unreachable when `kDebugMode` is false (via an injected flag); fixture test shared with widget tests.
- Goldens: bundled fonts load in `test/flutter_test_config.dart`; golden tests are tagged `golden` and run on macOS only (locally and in a macOS CI job); `flutter test --update-goldens --tags golden` is documented. Verify: `flutter test --exclude-tags golden` passes on Linux CI.
- Integration journey: `integration_test/core_journey_test.dart` covers the brief's 10-step journey and runs through `tool/test_integration.sh`; CI runs it on an Android emulator job when the repo is public, otherwise each phase records a manual run with date and device. Verify: script exists; phase summaries record the actual result.
- Config objects: every tunable number (8-week cap, +60-minute guard, 50/30 notification cap, 10 MB import limit, 30-day nudge, 26 repeats, 150 ms loading threshold, string limits, 5-minute rounding, scoring weights) lives in `SchedulerConfig` (with `ScoringWeights`) or `AppLimits`, injected with documented defaults in docs/SCHEDULING_ALGORITHM.md and ARCHITECTURE.md. Verify: grep-based test that these literals do not appear outside the config files.
- Structured reasons: the scheduler package emits reason codes with parameters (for example overdue, unscheduledBeyondHorizon(date), notEnoughTime(minutes), pinnedConflict(kind)); the app's presentation layer renders the copy, including "Why here?" lines. Scheduler tests assert codes; widget tests assert copy. Verify: the scheduler package has no user-facing English strings (test scans its lib/ for string literals used as messages).
- Notifications setup: v1 uses inexact scheduling (no SCHEDULE_EXACT_ALARM); README documents the Android manifest and iOS AppDelegate steps; the Phase 7 spike covers them with the save-dialog spike. Verify: manifest has no exact-alarm permission; README section exists.
- DX measurement: when Phase 1 lands, README records the measured `tool/bootstrap.sh` + `flutter run` time on this Mac with date, labeled measured. Verify: README line exists with a date and a measured label.
- LICENSE and CONTRIBUTING.md are decided in Phase 9 (publishing choice); CONTRIBUTING points to bootstrap and check. Verify: Phase 9 checklist item.
- Docs-match checks (DX F13): tests parse docs/DESIGN_SYSTEM.md and fail if any warning type in code is missing from its taxonomy table, parse docs/SCHEDULING_ALGORITHM.md and fail if the default `ScoringWeights` differ from the documented values, and check that every `tool/*.sh` command named in README exists. Verify: each check fails when its doc row is removed.
<!-- /autoplan-accepted:dx -->

<!-- autoplan-accepted:eng -->
- Session timing (H1): Study sessions add `startedAt`, `endedAt`, `segmentStartedAt` (nullable, UTC epoch) and `accumulatedSeconds` (int, default 0) in schema v1. Elapsed = accumulatedSeconds + (now − segmentStartedAt when active), clamped to ≥ 0 when the device clock moves back; nothing is written per tick. Completing or skipping sets `endedAt` and `actualMinutes` (rounded from seconds, or the user's edited value). The scheduler treats an active session's interval [segmentStartedAt, max(plannedEnd, now + remaining planned minutes)] as busy. Replacement for the weekly-review "Studied" and insights attribution: use `startedAt` when present, else plannedStart. Verify: tests for restart while active and while paused, clock moved back 10 minutes, a session spanning midnight, and 20 pause/resume cycles with zero drift.
- Accept cutoff (H2): a proposal stores `generatedAt`; Accept replaces unpinned planned sessions with plannedStart ≥ generatedAt in the horizon, and refuses with "Your plan changed. Regenerate?" when now has passed the earliest proposed start or the start of any existing planned session in the horizon that began after generatedAt. Verify: test generating at 15:00 with an existing 15:10 session, accepting at 15:12, asserting refusal and no overlap; test accepting at 15:01 succeeds.
- DataVersion scope (H3, replaces the DX "every repository write" wording): the counter is bumped by SQLite AFTER INSERT/UPDATE/DELETE triggers on tasks, study_sessions, availability, availability_exceptions and on updates to the scheduling columns of settings only; theme, notification, backup-nudge, export-time and calibration writes do not bump it. Starting or pausing a session does bump it only when it changes plannedStart/plannedEnd or status of a planned session. Verify: tests that a theme change and a nudge dismissal leave a proposal acceptable, and a task edit makes it stale.
- Database safety (H4): before Drift opens the file, a DbGuard reads `PRAGMA user_version` and runs `PRAGMA quick_check` through raw sqlite3; pre-migration backups use `VACUUM INTO` to `semesteros.db.bak`; "Start fresh" moves the main file and its `-wal`/`-shm` files together; a runtime SqliteException with a corrupt or not-a-database result code routes to the recovery screen. Verify: fixtures for a WAL-mode database with an uncheckpointed WAL, a header-valid corrupted file, and a newer `user_version`.
- Time storage (H5): deadlines, availability and exceptions are stored as civil values (ISO date text plus minutes-of-day integers); only session instants are stored as UTC epoch. The app's ZoneConverter uses Dart local DateTime construction (OS time-zone rules); `package:timezone` is used in scheduler tests and for notification scheduling. Zone changes are detected on resume by comparing `timeZoneOffset` and `timeZoneName`. DST rules: a nonexistent local time moves forward to the first valid minute, an ambiguous local time uses the earlier occurrence, and durations are real elapsed minutes. Verify: travel test (Manila to New York) keeps a 23:59 deadline at 23:59 local; DST tests assert the three rules.
- Notification time zones (taste): Phase 7 adds `flutter_timezone` only if `zonedSchedule` needs the IANA name, after the license/maintenance check, otherwise schedules from computed UTC instants. Verify: Phase 7 spike records the choice and its license.
- Soft-delete consistency (M1): "Keep its tasks without a subject" sets subjectId to null and keeps an in-memory undo token; all reads go through a repository base query (or SQL views) that filters deletedAt. Export runs the import validator before writing. Verify: test that the scheduler input builder excludes deleted rows; export→import round-trip after deleting a subject with "keep tasks".
- Active-session deletion (M2): deleting a task with an active or paused session first asks to finish or skip it; Undo never restores a session as active (restores as paused, or completed if it was completed). Verify: delete + start another + Undo succeeds without violating the single-live-session index.
- Study now (M3): ad-hoc sessions are exempt from the outside-availability conflict; on start, any planned session they overlap is shortened or marked superseded and "plan needs attention" is raised. Verify: test with Study now overlapping a planned session.
- Effort formula clarifications (M4): only pinned sessions with plannedStart ≥ now are subtracted; any planned session after its task's deadline is flagged as a conflict, and a deadline change triggers regeneration of that task's full span in the next proposal. Verify: tests for a missed pinned session and for a deadline moved earlier.
- Proposal diff (M5): the scheduler emits sessions without ids; ProposalDiff matches by same task and nearest start (greedy by time) and labels moved when the start differs; ids are assigned in the app. Verify: ProposalDiff unit tests; scheduler determinism test compares outputs without ids.
- Isolates and performance (M6): generation runs via `Isolate.run` with sendable inputs; import JSON parsing runs off the UI isolate; a benchmark test with 200 tasks over a 16-week term must finish under 500 ms on CI. Verify: benchmark test in the scheduler package.
- Diagnostics sanitizing (M7): the ring buffer and last-error record store failure code, exception type and stack frames only, never `toString()` of foreign exceptions. Verify: malformed-backup and constraint-violation tests built from seeded content show no titles in diagnostics.
- Import invariants (M8): import validation also checks milestone→task references, duplicate ids, availability endTime > startTime, no overlapping sessions, and at most one active/paused session; active sessions are normalized to paused on export; after import, notifications are re-planned and undo tokens cleared. Verify: one rejection test per invariant with its code.
- Riverpod policy (M9): ProviderScope sets retry none for UI providers and one retry for database reads; timer state derives from persisted timestamps, not listener ticks; both documented in ARCHITECTURE.md. Verify: test that a failing provider shows ErrorState without retries and records one diagnostics entry.
- Test replacements (M10, replaces the DX literal-scan and string-scan checks): a test asserts every `SchedulerConfig`/`AppLimits` field is documented and matches the value wired into providers; the scheduler string scan allowlists exception and assert messages. Verify: both tests exist.
- CI budget (M11, replaces the DX "macOS CI job" for goldens): goldens run locally on macOS, and in CI only when the repository is public; README states this. Verify: workflow condition present.
- Low items: partial unique index `one_live_session` created via customStatement on `study_sessions((1)) WHERE status IN ('active','paused') AND deleted_at IS NULL` and included in the schema snapshot; the developer route is gated by `const kDebugMode` (test flag never replaces it) and the clock offset never persists; global errors use `PlatformDispatcher.instance.onError`; Phase 7 handles Android 13+ POST_NOTIFICATIONS, a boot receiver, payload id validation and cold-start routing from a notification; the significant-effort trigger is evaluated when a session completes or is skipped; undo tests compare rows excluding updatedAt and deletedAt; the integration journey simulates restart by disposing the ProviderContainer and reopening the database, with one real cold restart checked manually per phase; README wording says platform backups may send the database to the user's own Google or iCloud account while the app sends nothing. Verify: each item has its test or checklist line.
- Toolchain correction (replaces the CEO PR5 wording): Flutter 3.47.7 enables Swift Package Manager by default (`flutter config --help`), so CocoaPods is needed only for plugins without SwiftPM support; Phase 1 runs `flutter build ios --simulator --no-codesign` with the chosen plugins and records whether CocoaPods is still required; README Known limitations reflects the measured result. Verify: Phase 1 summary records the build result.
<!-- /autoplan-accepted:eng -->
## Review record

### Binding decisions (this session, from the user)

| ID | Decision | Source |
|---|---|---|
| BD1 | Initialize git on `main`, no remote. | User answer D3, 2026-10-12 |
| BD2 | Upgrade Flutter to current stable before Phase 1 (global SDK at `~/development/flutter`). | User answer D4, 2026-10-12 |
| BD3 | Skip /office-hours; the brief is the design input. | User answer D2, 2026-10-12 |

### CEO review — Step 0 (mode: SELECTIVE EXPANSION, set by /autoplan override)

**Pre-review system audit.** Repo created this session: zero commits, no stashes, no TODO/FIXME markers, no CLAUDE.md, no TODOS.md, no prior gstack decisions (`gstack-decision-search` returned nothing), no prior learnings (LEARNINGS: 0). Retrospective check: no prior reviews or reverts. UI scope: yes (screens, forms, dashboard, navigation, responsive layouts). Taste calibration: no repository code exists; reference patterns are Flutter's own Material 3 adaptive components (NavigationBar / NavigationRail / NavigationDrawer); patterns to avoid are card-grid dashboards and codegen-heavy boilerplate the solo developer must maintain.

**Landscape check** (WebSearch; Aside not installed):
- [Layer 1] Tried and true: list-based student planners (MyStudyLife, TrackPrep) plus general auto-schedulers that sit on top of a cloud calendar (Reclaim free tier, Motion paid, FlowSavvy, SkedPal).
- [Layer 2] Current sources: the closest student auto-scheduler (Shovel) computes available time minus required time across the semester but needs desktop setup; offline-first options (TrackPrep) do not auto-schedule. No verified app combines fully offline + automatic rescheduling. Vendor posts cite setup labor, the blank-page problem and loss of control as reasons students abandon planners (vendor claims, not measured research).
- [Layer 3] First principles: the scheduler is only as good as its inputs, and students are bad at effort estimates. The differentiator is not the allocation algorithm but (a) near-zero-effort capture and (b) the app learning from estimated-vs-actual data the plan already collects. That reframes estimate calibration from a chart into a feedback loop.

Sources: [mystudylife.com 2026 roundup](https://mystudylife.com/best-ai-school-planner-apps-for-students-in-2026-free-paid/), [mindomax planner list](https://www.mindomax.com/best-study-planner-apps), [morgen Motion vs Reclaim](https://morgen.so/blog-posts/motion-vs-reclaim), [flowsavvy Reclaim alternatives](https://flowsavvy.app/reclaim-alternatives), [GoodPlans on Product Hunt](https://www.producthunt.com/p/goodplans/goodplans-2-0), [dormway study schedule guide](https://dormway.app/blog/how-to-create-a-study-schedule-that-works-a-data-driven-2026-guide).

#### 0A. Premise challenge

Real problem: a student with 4-6 subjects cannot see whether the remaining work fits the remaining time, so they find out too late. Target outcome: every open task has a realistic slot or an explicit "doesn't fit" warning, and the app always names one next action. Do-nothing cost: students keep using lists or paper and get surprised by deadline clusters. The plan attacks the pain directly (capacity vs workload, next action), not a proxy.

| Premise | Claim | Receipt | Verdict |
|---|---|---|---|
| PR1 | Students want the app to say what to do next, not just store tasks. | Brief §6D; landscape Layer 2 | Valid |
| PR2 | Offline-only, account-free v1 is acceptable. | Brief §2; competitors sync | Valid, with a risk: phone loss = data loss. Mitigated by backup; see E11. |
| PR3 | Students will enter every task with an effort estimate. | Landscape: setup labor and blank page cited as top churn causes | Weak. Mitigated by E1 (quick add + type defaults). |
| PR4 | Students will trust an auto-generated schedule. | Landscape: loss of control; brief §7 "never silently move" | Partly valid. Brief already requires proposal + accept; E10 adds pinning. |
| PR5 | iOS build can be verified on this Mac. | `xcodebuild -version` = 26.6; `flutter doctor`: CocoaPods not installed, iOS 26.5 runtime missing | Blocked until the user installs CocoaPods. iOS 17.5 simulators exist. |
| PR6 | Android build can be verified. | `flutter doctor`: SDK 35.0.0, licenses not accepted | Blocked for release builds until the user runs `flutter doctor --android-licenses`. Debug builds and tests are not blocked. |
| PR7 | Current Drift/Riverpod/GoRouter versions are usable. | `flutter --version` = 3.24.0 / Dart 3.5.0 | Valid after BD2 upgrade completes. |
| PR8 | "SemesterOS" works without a semester entity. | Brief §5 has no Term table | Valid for v1. A term/archive concept is deferred (E9). |

#### 0B. Existing code leverage

No repository code exists. Reuse ladder applied to the plan instead:
- Flutter SDK: NavigationBar / NavigationRail / NavigationDrawer for adaptive nav; `showDatePicker` / `showTimePicker`; `MediaQuery.disableAnimationsOf` for reduced motion; `Semantics` for chart summaries; `SegmentedButton` for type/priority pickers.
- Drift: built-in `MigrationStrategy`, exported schema snapshots and `drift_dev` generated migration tests, so no custom migration framework.
- Dart core: `DateTime` + an injected clock for deterministic scheduler tests; no extra date library.
- Already-listed deps only (drift, sqlite3_flutter_libs, riverpod, go_router, flutter_local_notifications, fl_chart, uuid, intl). New deps proposed later must pass the license/maintenance check in brief §2.

Reality rows:

REALITY: premise-table finding 8 premises, 2 environment blockers (PR5 CocoaPods, PR6 Android licenses), 1 weak premise (PR3) unverified=0 docs/IMPLEMENTATION_PLAN.md:9
REALITY: already-done pass checked: `git log` shows zero commits and no remote exists, so no base-branch work can predate this plan docs/IMPLEMENTATION_PLAN.md:12
REALITY: surface-check finding `flutter create --platforms/--org` and `flutter doctor --android-licenses` must be rechecked against `--help` after the SDK upgrade (BD2) docs/IMPLEMENTATION_PLAN.md:20
REALITY: binding-decisions pass BD1-BD3 recorded; decision log empty; no overruled default reintroduced docs/IMPLEMENTATION_PLAN.md:203
REALITY: numbers finding breakpoints 600/840 come from the brief [estimated]; default session/break/limit values are not yet chosen [estimated]; no measured baselines exist docs/IMPLEMENTATION_PLAN.md:151
REALITY: deferred-asks pass no linked issue; every request in the user's brief stays in scope, and only reviewer-proposed additions were deferred (TODOS.md) docs/IMPLEMENTATION_PLAN.md:198
REALITY: pr-count pass no `.gstack/ship-policy.json`, so the default of one PR per wave applies; no remote yet, so no PR queue cost docs/IMPLEMENTATION_PLAN.md:186

#### 0C. Dream state

```
  CURRENT STATE                THIS PLAN                          12-MONTH IDEAL
  empty repo, no app   --->    offline planner: subjects, tasks,  --->  student opens app, sees one next
                               pure-Dart scheduler, sessions,           action; plan self-corrects from
                               rescheduling proposals, insights,        their real pace; capture takes
                               backups, adaptive phone/tablet UI        seconds; optional sync; store-listed
```
The plan moves directly toward the ideal. Gaps against the ideal: capture friction (E1), learning from real pace (E2), and a recurring ritual that keeps the plan fresh (E7).

#### 0F/0G. Selective expansion

HOLD-scope checks: (1) complexity: greenfield app, far more than 8 files and 2 services by necessity; the layered feature-first structure is the minimum that keeps the scheduler pure and testable, so no reduction proposed. (2) Minimum changes: every brief feature maps to an acceptance criterion; nothing is deferrable without breaking §15. (3) Invariants kept: all 12 scheduling rules and §15 criteria stay mandatory.

10x check: same scheduler, but the app gets more accurate every week because it learns the student's real pace per task type, and adding a task takes 5 seconds. That is the 10x over a list app for roughly 1.2x the effort, because the data is already collected.

Delight scan and cherry-picks (auto-decided per /autoplan P1/P2/P3):

| ID | Proposal | Effort | Risk | Decision | Reason |
|---|---|---|---|---|---|
| E1 | Quick add (title + deadline + type) with default effort per task type, editable later; defaults live in Settings | S | Low | ACCEPTED | In blast radius (tasks feature), <1d; directly answers weak premise PR3 |
| E2 | Estimate calibration: per task type, show "your sessions run about 1.3x your estimates" once at least 3 completed tasks of that type exist; one-tap "use this for new estimates"; never auto-applied | S | Low | ACCEPTED | Uses estimated-vs-actual data the brief already requires; in blast radius |
| E7 | Weekly review sheet: last week planned vs done, next 7 days of deadlines, one-tap "regenerate this week" proposal | S | Low | ACCEPTED | Composes existing insights + rescheduling; gives the plan a recurring refresh point |
| E10 | Pin a session: a user-moved or user-pinned session is never moved by regeneration; scheduler treats pinned sessions as fixed busy time | S | Low | ACCEPTED | Answers PR4 trust risk; small scheduler input addition |
| E11 | Backup nudge: Settings shows "last backup: never / N days ago"; dashboard shows a dismissible reminder after 30 days without export | S | Low | ACCEPTED | Answers PR2 data-loss risk; in blast radius of Phase 7 backup |
| E3 | Optional sample semester in onboarding, clearly labeled, one-tap remove | S | Medium | TASTE: DEFERRED | Conflicts in spirit with "no misleading placeholder statistics"; reasonable people could disagree |
| E5 | Export plan as .ics file through the share sheet (offline, no API) | M | Low | TASTE: DEFERRED | Borderline radius; useful but not needed for §15 |
| E4 | Home-screen widget showing next session | L | Medium | DEFERRED | Needs native Android/iOS widget code; outside blast radius |
| E9 | Semester/term entity with end-of-term archive | M | Medium | DEFERRED | Schema change touching every list view; v1 works without it |

<!-- autoplan-accepted:ceo -->
- Schema v1 contains every column the accepted items need, so v1 ships at schema version 1 with no follow-up migration: Study sessions add `isPinned` (bool, not null, default false); Settings is a single-row table (fixed id) with per-type default estimate columns for all six task types, `weekStartDay` (default Monday), `significantDiffPct` (default 25), `significantDiffMinutes` (default 30), `lastSuccessfulExportAt` (nullable), `backupNudgeDismissedAt` (nullable), plus the brief's settings; an `EstimateCalibration` table keyed by task type holds `lastAppliedAt` (nullable) and `dismissedAtQualifyingCount` (nullable); Tasks add `completedAt` (nullable; set when a task is completed, cleared when it is reopened to incomplete, which the task screen supports). Verify: schema snapshot test lists these columns, `completedAt` and the calibration table; unit test that complete sets and reopen clears `completedAt`; a fresh database has exactly one Settings row.
- Task deadline is a local date-time; a date-only entry (including quick add) defaults to 23:59 local on that date. Verify: unit test that a date-only quick-add deadline persists as 23:59 local.
- Remaining effort for a task = max(0, estimatedMinutes − sum of actualMinutes of its completed and skipped sessions − accrued minutes of its active/paused session). Minutes recorded on a skipped session are real study time. This is the scheduler's "remaining effort" input. Effort to schedule within a horizon = remaining effort − planned minutes of the task's pinned sessions not yet started − planned minutes of its unpinned planned sessions outside the horizon, so a short-horizon run never duplicates work already planned elsewhere (brief rule 5). Verify: unit tests with no sessions, partial sessions, a skipped session with recorded minutes, actual exceeding the estimate (result 0), and a one-week run over an existing 8-week plan that schedules only the not-yet-allocated minutes.
- Missed sessions: a session still `planned` whose plannedEnd is in the past is shown as "Missed" (derived at read time from the injected clock; no extra status column) and is treated like skipped for rescheduling triggers. Verify: unit test that a planned session ending 1 minute before now reads as missed and one ending 1 minute after does not.
- "Actual effort significantly different from estimate" (brief §7 rescheduling trigger) = |actual − estimate| ≥ `significantDiffPct`% of estimate AND ≥ `significantDiffMinutes` minutes [estimated heuristics, documented as such]. Verify: unit tests at 24%/25% and 29/30 minute boundaries with defaults.
- Scheduler inputs gain `horizonStart` and `horizonEnd` (local dates); generation never creates sessions outside the horizon. Generated sessions never start before now (rounded up to the next 5 minutes). Default horizon for "Generate plan" = today through max(latest incomplete task deadline, today+6), capped at today+55 (8 weeks) [estimated]; overdue tasks get top urgency, are placed at the earliest available slots, and carry an "overdue" warning. Effort that does not fit is reported as unscheduled with its reason: "beyond the planning window" or "not enough available time". The planner week view starts on `weekStartDay`. Verify: unit tests that a one-week horizon yields no sessions outside it, no session starts before now when generating at 15:00, the all-overdue case uses today..today+6, the 8-week cap applies, and both unscheduled reasons appear.
- Proposal accept/reject: a generated or rescheduling proposal shows added, moved and removed sessions; Accept replaces, in one transaction, every unpinned session still in `planned` status with plannedStart ≥ now within the horizon with the proposed sessions (missed sessions stay as history); Reject changes nothing. No partial acceptance in v1. Rescheduling triggers (skip, missed, deadline change, availability change, significant effort difference) never generate or accept a proposal on their own: they show a non-modal "Your plan needs attention" banner on the Dashboard and Planner listing the reasons, and tapping it opens a proposal. Verify: repository test that Accept is atomic (simulated failure leaves prior sessions intact) and leaves pinned, completed, skipped, active and missed sessions untouched; test that Reject leaves the database byte-identical; widget test that a skip shows the banner and creates no new sessions until a proposal is accepted.
- Deletion: deleting a task asks for confirmation that states how many tracked minutes will be removed, then deletes the task, its milestones and all its sessions (any status) in one transaction, with an Undo snackbar that restores them exactly. Deleting a subject asks "Keep its tasks without a subject" (default) or "Delete its tasks too" (same rules as task deletion); its Undo restores the subject and, for the keep option, the tasks' subjectId, or for the delete option, the tasks, milestones and sessions. Verify: repository tests for both subject options with undo restoring identical rows, and for task delete + undo restoring identical rows; widget test that the confirmation shows the minutes count.
- E1 Quick add (Phase 2): a task can be created with only title, deadline and type; estimatedMinutes defaults from the Settings per-type default; priority defaults to Medium and status to incomplete. Starting defaults [estimated]: Assignment 120, Project 360, Quiz 90, Exam 240, Reading 60, Other 60 minutes. Verify: widget test creates a task with only the three fields and asserts estimate 120 for an Assignment, priority Medium, status incomplete; unit test for default lookup for all six types.
- Planning defaults in Settings (Phase 2): a "Planning defaults" section edits the six per-type default estimates (15-480 minutes, inline validation), `weekStartDay`, `significantDiffPct` (5-100) and `significantDiffMinutes` (5-240). Verify: widget test edits a default and a quick-added task uses the new value; validation test rejects out-of-range values with a field-level error.
- E2 Estimate calibration (Phase 5): per task type, qualifying tasks are completed tasks with at least 1 tracked minute that were completed after that type's `lastAppliedAt` (all of them when never applied). Ratio = sum(actualMinutes of their completed and skipped sessions) / sum(their estimatedMinutes). Shown on the Insights estimate card only when at least 3 qualifying tasks exist. "Use for new estimates" sets the Settings default to round(currentDefault × ratio) to the nearest 5 minutes, clamped to [15, 480], sets `lastAppliedAt`, clears `dismissedAtQualifyingCount`, and never changes existing tasks; after applying, the suggestion returns only once 3 new qualifying tasks exist. Dismissing records `dismissedAtQualifyingCount`; the suggestion returns when the qualifying count reaches that value + 3. Verify: unit tests with 0, 2, 3 and 10 qualifying tasks, a zero-tracked task excluded, tasks completed before `lastAppliedAt` excluded (by `completedAt`), rounding and both clamps, dismissal re-offer at +3, dismissal cleared on apply, and existing task estimates unchanged after applying.
- E7 Weekly review (Phase 5): reachable from a Planner action at all times and from a Dashboard card shown on the Settings `weekStartDay`. Figures, in local calendar days: "Last 7 days" = today−6 through today; Planned = sum of planned durations of sessions starting in that window, any status; Studied = sum of actualMinutes of completed and skipped sessions whose plannedStart is in that window; "Coming up" = incomplete tasks due today through today+6, with overdue incomplete tasks listed separately. "Plan this week" opens a proposal with horizon = today through today+6, using the accept/reject flow above. Verify: widget test with a fixed seeded dataset asserts literal expected numbers (not values re-derived from the repository); empty-state test with no data.
- E10 Pinned sessions (Phases 3-4): a session can be pinned or unpinned from its detail sheet; editing a planned session's time through an "Edit time" sheet pins it. The edit sheet blocks overlap with any other session and blocks times outside availability, with inline errors; going over the daily limit is allowed with an inline warning. The scheduler never moves, deletes or overlaps a pinned session, counts its minutes against that day's limit as busy time, and keeps breakDuration spacing between generated sessions and pinned ones. Scheduler rules 1 and 6 constrain generated sessions; a pinned session that later violates them (availability changed, limit lowered, deadline moved before it) stays put and produces a conflict warning with an Unpin action. Deleting a task deletes its sessions per the deletion rule above. When a task is completed, its pinned future sessions stay in place with a "task already complete" warning; they still count as busy time against the daily limit but do not count toward planned workload in insights. Verify: scheduler unit tests for preservation across regeneration, overlap and break spacing around a pinned session, daily-limit accounting, and the three conflict cases; widget test that editing time pins the session and that overlap is blocked.
- E11 Backup nudge (Phase 7): Settings shows `lastSuccessfulExportAt` or "Never backed up". Export serializes the backup JSON and validates it with the same validator import uses before writing; it counts as successful when the platform save-file dialog reports a saved location, plus a read-back check where the platform allows reopening that location. No share-sheet path in v1. Phase 7 starts with a spike confirming save-dialog behavior on Android (Storage Access Framework) and iOS (document picker), and records any platform where the result cannot be confirmed in Known limitations. The dashboard reminder shows when at least one task exists AND (no successful export OR elapsed ≥ 30 whole days since the last one) AND it was not dismissed in the last 30 days. Verify: unit tests at 0, 29 and 30 elapsed days (hidden, hidden, shown), never exported, zero tasks (hidden), and dismissed 10 days ago (hidden); test that export refuses to write when validation fails.
- Backup format carries a `schemaVersion` field (1 in v1) and includes `isPinned`, all Settings fields and the calibration table. Import is replace-all: it shows a confirmation naming what will be replaced and offering an export first, validates the whole file, then replaces all data in one transaction; on any validation or write failure the current data is untouched and a plain-language error names the problem. Within a known version, missing optional fields get defaults (`isPinned=false`, Settings defaults); an unknown higher version is rejected with no data change; import never copies `lastSuccessfulExportAt` or `backupNudgeDismissedAt` from the file; the device's current values of both survive the replace; a file with no `schemaVersion` is rejected as "not a SemesterOS backup" with no data change. Verify: round-trip test, a v1 fixture missing optional fields, a higher-version rejection test, a missing-schemaVersion rejection test, a malformed-JSON test, a test that local `lastSuccessfulExportAt` survives import, and a mid-import failure test leaving prior data intact.
- Backup includes Tasks.`completedAt`.
- Tests list (brief §12) and acceptance criteria (brief §15) include E1, E2, E7, E10 and E11 with the verifications above.
- PR5/PR6 environment blockers: Phase 1 creates a README stub with a "Known limitations" section naming `brew install cocoapods` (iOS plugin builds) and `flutter doctor --android-licenses` (Android release builds); the §15 iOS criterion is read as "iOS build verified when Xcode and CocoaPods are available", since Xcode 26.6 is present. Verify: README stub exists after Phase 1 and names both commands.
- Before Phase 1, record the post-upgrade `flutter --version` (Flutter and Dart) in §0 of this plan. Verify: §0 shows the new versions.
- §0 no longer names share_plus (removed from v1 by spec review 2); recorded as a baseline edit below.
- Grade weight (CEO voice F4): Tasks add nullable `gradeWeightPct` (0-100, schema v1). The scheduler's "assessment importance" uses gradeWeightPct when set, otherwise a per-type default documented in docs/SCHEDULING_ALGORITHM.md. Verify: scoring unit tests with weight set, unset, and two tasks differing only by weight.
- One-off busy times (CEO voice F5): an `AvailabilityExceptions` table (id, date, startTime, endTime, note?, timestamps) in schema v1; each exception removes that time from that date's availability. Availability screen offers "Add a one-off busy time". The scheduler never places generated sessions inside an exception; a pinned session inside one gets a conflict warning. Verify: scheduler tests with an exception splitting a window, covering a whole day, and overlapping a pinned session; widget test adding an exception.
- Soft delete (CEO voice F6, brief §2 offline item 10): Subjects, Tasks, Milestones, Study sessions, Availability and AvailabilityExceptions carry nullable `deletedAt` (schema v1). The deletion rules above are implemented by setting `deletedAt` in one transaction; Undo clears it; repository queries and insights exclude deleted rows; backups export only non-deleted rows; tombstones are kept in v1 (no purge). Verify: repository tests that deleted rows disappear from every list and insight query, Undo restores them, and export omits them.
- Work beyond the planning window (CEO voice F7): a whole-term capacity check runs over all incomplete tasks without the 8-week cap to detect overload. Effort for tasks whose deadline is after horizonEnd is labeled "Planned later (from <date>)" when that check says it fits, and "not enough available time" when it does not. Exam revision is placed in the days before the exam once the exam enters the horizon. Verify: unit tests with an exam 12 weeks out (labeled planned later, no overload) and with an over-full term (overload reported).
- OS-level backup coverage (CEO voice F10, taste): the database lives where Android Auto Backup (`allowBackup` plus `dataExtractionRules` including the database) and iOS device backup include it. README Privacy and Backup states that these platform backups are controlled by the user's own device settings and accounts, and the app itself sends nothing. Verify: manifest and data-extraction rules checked in a test or script; manual restore test on an Android emulator recorded with its actual result.
- Weekly repeat (CEO voice F1, taste): the task form offers "Repeat weekly until <date>", which creates independent task instances at save time (at most 26) with deadlines on the same weekday and time. No recurrence engine. Verify: unit test that a 10-week repeat creates 10 tasks with correct local deadlines across a DST change; test of the 26 cap.
- Product framing (CEO voice F3/F14): docs/IMPLEMENTATION_PLAN.md gains a "Product framing" section marked [assumed, confirm with the user]: persona (undergraduate with 4-6 courses, phone-first, plans on Sunday evenings), success metric (5 real students use it for 3 consecutive weeks), and three differentiators: explained scheduling that never silently moves the plan, fully private with no account, and estimates that learn the student's real pace. README uses the same three. Verify: section and README paragraph exist.
- Considered alternatives (CEO voice F12/F13): docs/SCHEDULING_ALGORITHM.md records the daily-effort-budget mode and optional on-device models (Apple Foundation Models, Android on-device GenAI) as considered and deferred; §2's "Gemini APIs" means cloud APIs. README notes that simulator builds need no Apple account, while device builds need a signing team (a free personal team gives 7-day provisioning). Verify: both notes exist.
- Single active session: at most one session is `active` or `paused` at any time, enforced by the repository transaction and a partial unique index; starting another asks to pause or finish the current one. Verify: repository test that a second start fails without changing data; widget test of the prompt.
- Long-running session guard: when an active segment's elapsed wall-clock time exceeds the session's planned duration + 60 minutes (including after an app restart), the app asks the user to confirm the minutes before recording them, suggesting the planned duration. Verify: unit test with a fake clock at +59 and +61 minutes over plan, and across a simulated restart.
- Stale proposal guard: a proposal records the data version it was built from; Accept refuses with "Your plan changed. Regenerate?" if any task, session, availability or setting changed since, and the Accept button is disabled while committing. Verify: repository test of a stale accept; widget test of a double tap producing one commit.
- Backup import hardening: files over 10 MB are rejected before parsing; strings are length-limited (title 200, description 5000, subject name 100, course code 20, milestone 200, note 200); enums, ids, dates and references (each session's taskId and each task's subjectId exist in the file) are validated. Verify: one rejection test per rule.
- Database recovery: if the database cannot be opened (corrupt file) or its schema version is newer than the app, a recovery screen offers Restore from backup, Start fresh (the old file is renamed, never deleted) and Show details. Before any future schema migration runs, the database file is copied to a `.bak` file first. Verify: test with a corrupted-file fixture and a newer-version fixture.
- Resume recompute: on app resume, on local date change and on time-zone change, derived state (missed sessions, today's dashboard, nudges) is recomputed. Verify: test with a fake clock crossing midnight and a time-zone change.
- Local diagnostics: Settings > About shows app version, schema version, database size and the last error message (never task or subject content), with "Copy diagnostics". Verify: widget test that the copied text contains no task titles from seeded data.
- Scheduler package: the scheduling engine lives in `packages/semester_scheduler`, a pure Dart package with no Flutter dependency, tested with `dart test`; the app depends on it by path. Verify: the package pubspec has no flutter dependency and CI runs its tests.
- Notification limits (Phase 7): pending local notifications are capped (at most 50, covering at most the next 30 days) and re-planned on app open and after plan changes, to stay under iOS's 64-pending limit; a "Show task names in notifications" setting (default on) controls lock-screen content. Verify: unit test of the cap with 200 candidate reminders; test that turning the setting off produces generic text.
- CI: a GitHub Actions workflow runs the format check, analyze, `flutter test` and the scheduler's `dart test`; it is labeled unverified in README until it has run on a pushed remote. Verify: workflow file exists and README states its verification status honestly.
- Unsaved changes: leaving a task, subject, availability or settings form with unsaved edits asks "Discard changes?" (Keep editing / Discard); system back and navigation both trigger it. Verify: widget test that back with edits shows the prompt and Keep editing preserves the entered values.
- Global error handling: `FlutterError.onError` and a root zone handler record the last error for diagnostics and show ErrorState with a Retry or Go to Today action instead of a blank screen; no catch-all swallows errors silently inside features. Verify: widget test that an exception thrown in a screen's provider renders ErrorState and records the message.
<!-- /autoplan-accepted:ceo -->
<!-- autoplan-baseline-edits:ceo {"sourceSha256":"5939d7d723dd3f896935724b6f100b719d6026a8bd3a6b0516e4c2bc11915cbe","replacements":[{"oldText":"file_picker/share_plus","newText":"file_picker"}]} -->

### Decision ledger (CEO)

| ID and owner | Contract and evidence | Current | Proposed | Status | Exact approval and scope |
|---|---|---|---|---|---|
| CEO-MODE / CEO | /autoplan fixes CEO mode | SELECTIVE EXPANSION | — | approved | /autoplan ceo-phase override "Mode selection: SELECTIVE EXPANSION" |
| CEO-E1 / tasks | PR3 weak premise | not in plan | quick add + type defaults | approved | /autoplan auto-decision P2 (blast radius, <1d) |
| CEO-E2 / insights | brief §6G est. vs actual | chart only | calibration suggestion | approved | /autoplan auto-decision P2 |
| CEO-E7 / planner | brief §7 rescheduling | not in plan | weekly review sheet | approved | /autoplan auto-decision P2 |
| CEO-E10 / scheduler | PR4, brief §7 rule "never silently move" | not in plan | pinned sessions | approved | /autoplan auto-decision P2 |
| CEO-E11 / settings | PR2 data loss risk | not in plan | backup nudge | approved | /autoplan auto-decision P2 |
| CEO-E3 / onboarding | brief §6D "no placeholder statistics" | not in plan | sample semester | deferred | /autoplan TASTE (surfaced at final gate) |
| CEO-E5 / planner | none | not in plan | .ics export | deferred | /autoplan TASTE (surfaced at final gate) |
| CEO-E4 / platform | native widget code | not in plan | home-screen widget | deferred | /autoplan auto-decision P3 (outside radius) |
| CEO-E9 / data | schema-wide change | not in plan | term entity + archive | deferred | /autoplan auto-decision P3 |

<!-- AUTONOMOUS DECISION LOG -->
## Decision Audit Trail

| # | Phase | Decision | Classification | Principle | Rationale | Rejected |
|---|-------|----------|----------------|-----------|-----------|----------|
| 1 | CEO | Mode = SELECTIVE EXPANSION | Mechanical | override | /autoplan fixes the CEO mode | other modes |
| 2 | CEO | Leave cross-project learnings unset | Mechanical | P5 | Config change is the user's; zero learnings exist anyway | enabling it silently |
| 3 | CEO | Accept E1 quick add + type defaults | Mechanical | P2 | In blast radius, <1d, fixes weak premise PR3 | defer |
| 4 | CEO | Accept E2 estimate calibration | Mechanical | P2 | Reuses required data; small | defer |
| 5 | CEO | Accept E7 weekly review | Mechanical | P2 | Composes existing features | defer |
| 6 | CEO | Accept E10 pinned sessions | Mechanical | P2 | Trust risk PR4; small scheduler input | defer |
| 7 | CEO | Accept E11 backup nudge | Mechanical | P2 | Data-loss risk PR2 | defer |
| 8 | CEO | Defer E3 sample semester | Taste | P3 | Tension with "no placeholder statistics" | accept |
| 9 | CEO | Defer E5 .ics export | Taste | P3 | Borderline radius, not needed for §15 | accept |
| 10 | CEO | Defer E4 home widget | Mechanical | P3 | Native code, outside radius | accept |
| 11 | CEO | Defer E9 term entity | Mechanical | P3 | Schema-wide change | accept |
| 12 | CEO | Spec review 1: add schema columns for E1/E10/E11 to schema v1 (single-row Settings) | Mechanical | P1/P5 | Avoids a v1 follow-up migration; explicit single row | key-value settings table |
| 13 | CEO | E10 includes a minimal "Edit time" sheet that pins, blocks overlap and out-of-availability | Taste | P1 | Accepted E10 assumed manual moves exist; alternative was toggle-only pinning | pin toggle only |
| 14 | CEO | Pinned sessions exempt from rules 1/6, surfaced as conflict warnings | Mechanical | P5 | Resolves contradiction without silently moving user choices | auto-moving pinned sessions |
| 15 | CEO | Define remaining effort, "significant" threshold (25% and 30 min), horizon inputs | Mechanical | P5 | Required inputs were undefined | leave to implementer |
| 16 | CEO | E2/E7/E11 formulas, windows and boundaries fixed (E11 shows at day 30) | Mechanical | P5 | Removes ambiguity | — |
| 17 | CEO | Export success = save-dialog write + read-back; share sheet does not count | Mechanical | P5 | Share sheet cannot report completion reliably | trusting share result |
| 18 | CEO | Backup schemaVersion with forward rejection and backward defaults | Mechanical | P1 | New fields must round-trip safely | unversioned JSON |
| 19 | CEO | README stub in Phase 1; iOS criterion read as Xcode + CocoaPods | Mechanical | P5 | Blockers must be documented from day one | wait for Phase 9 |
| 20 | CEO | Spec review 2: task delete removes all sessions with minutes-count confirmation + Undo; subject delete offers keep/delete tasks | Mechanical | P1 | Brief §6B "clear data handling" and undo requirement | orphaning sessions |
| 21 | CEO | "Missed" derived at read time from clock, treated like skipped | Mechanical | P5 | No schema status needed; deterministic with injected clock | new status column |
| 22 | CEO | Import = replace-all, confirmed, one transaction | Mechanical | P3 | Merge semantics are a sync problem; replace is explicit and safe | merge import |
| 23 | CEO | Proposal Accept atomically replaces unpinned planned sessions in horizon; Reject = no change; no partial accept in v1 | Mechanical | P5 | Defines the brief's "persist accepted plan safely" | per-session accept |
| 24 | CEO | Add significantDiff columns + EstimateCalibration table; E2 counts only tasks completed since last apply | Mechanical | P1 | Removes migration contradiction and compounding drift | all-history ratio |
| 25 | CEO | Default horizon = latest deadline capped at 8 weeks; deadline date-only = 23:59 local; skipped-session minutes count as study time | Mechanical | P5 | Undefined inputs | — |
| 26 | CEO | Drop share-sheet export path from v1 | Mechanical | P4 | Unapproved addition, extra dependency | keep share_plus |
| 27 | CEO | E11 success = validated JSON + dialog-reported save, read-back where possible, Phase 7 platform spike | Mechanical | P5 | Read-back may be impossible on SAF/document picker | mandatory read-back |
| 28 | CEO | Spec review 3: effort-to-schedule excludes already-allocated minutes; no sessions before now; overdue horizon; unscheduled reasons; Planning defaults UI; Tasks.completedAt; trigger banner; Studied by plannedStart; subject Undo; import keeps device timestamps; reject files without schemaVersion; Edit time warns over limit; drop share_plus from §0 (baseline edit) | Mechanical | P1/P5 | Each closes a concrete implementer gap; loop at 3-launch cap | another review launch |
| 29 | CEO | 0H document approval: approve CEO summary + working plan and continue to 0I | Mechanical | P6 | Both documents reflect every decision; spec not re-verified after launch 3 (noted) | revise/pause |
| 30 | CEO | Accept gradeWeightPct (F4) | Mechanical | P1 | Brief names assessment importance; no field existed | infer from type only |
| 31 | CEO | Accept AvailabilityExceptions (F5) | Mechanical | P2 | Trust risk; in radius, <1d | weekly-only availability |
| 32 | CEO | Soft delete with deletedAt (F6) | Taste | P1 | Honors brief offline item 10; adds query filters | hard delete + downgrade req 10 |
| 33 | CEO | Whole-term capacity check + "Planned later" (F7) | Mechanical | P5 | Finals would look unscheduled | exempting exams only |
| 34 | CEO | OS-level backup coverage with disclosure (F10) | Taste | P1 | Covers device loss; data leaves via the user's own OS backup | disabling OS backup |
| 35 | CEO | Weekly repeat creating independent instances (F1c) | Taste | P5 | Common need; no recurrence engine | full recurrence rules / none |
| 36 | CEO | Defer .ics import and syllabus paste (F1a/b) | Taste | P3 | Borderline radius; parser corpus needed | v1 scope |
| 37 | CEO | Keep term entity deferred despite voice (F8) | Taste | P3 | Schema stays additive | add Terms now |
| 38 | CEO | Product framing + alternatives docs (F3/F12/F13/F14) | Mechanical | P1 | Cheap, guides later cuts | none |
| 39 | CEO | Queue UC1 validation gate, UC2 early reminders | User Challenge | — | Changes the brief's phase order | auto-deciding |
| 40 | CEO | Single active session, long-running guard, stale proposal guard | Mechanical | P1 | Sections 1/4 gaps | — |
| 41 | CEO | Import hardening, DB recovery screen, pre-migration .bak | Mechanical | P1 | Sections 2/3 gaps | — |
| 42 | CEO | Resume recompute, diagnostics, notification cap + privacy toggle | Mechanical | P2 | Sections 2/3/8 | — |
| 43 | CEO | Scheduler as pure Dart package; CI labeled unverified | Mechanical | P5 | Enforces purity; honest CI status | folder convention |
| 44 | Design | Skip paid mockup generation | Mechanical | user constraint | Designer calls paid OpenAI API; brief sets zero-dollar budget | generating mockups |
| 45 | Design | Four-destination navigation (Today/Plan/Tasks+Subjects/Insights) | Taste | P5 | Fewest destinations that cover all features | 5 tabs with separate Subjects |
| 46 | Design | Today hierarchy, single banner + single secondary card | Mechanical | P5 | Structural: brief bans card overload | stacked notices |
| 47 | Design | Next-action 8-state table + "Study now" ad-hoc session | Mechanical | P1 | Answers the dashboard's core question in every state | leaving to implementer |
| 48 | Design | Task changes trigger "needs attention" + "Schedule it now?" | Mechanical | P1 | Core journey silently failed otherwise | manual Generate only |
| 49 | Design | Proposal summary + week groups; full-screen/side panel | Mechanical | P5 | 50-session flat list unreadable | flat diff list |
| 50 | Design | Planner compact day strip, medium 3-day, expanded 7-day grid; no drag in v1 | Mechanical | P5 | 7 columns don't fit 360 dp | squeezed grid |
| 51 | Design | Mini session bar, Complete/Skip sheets, long-session copy | Mechanical | P1 | Missing states | — |
| 52 | Design | Onboarding presets + ends in quick add; skip default Mon-Fri 18-21 | Mechanical | P1 | Empty-app arc break | empty Today |
| 53 | Design | Welcome-back summary for 2+ missed | Mechanical | P5 | Supportive tone requirement | per-session alarms |
| 54 | Design | Warning taxonomy (info/attention/capacity) + overload actions | Mechanical | P5 | 10+ warning types without a system | ad-hoc warnings |
| 55 | Design | Visual tokens: IBM Plex Sans bundled, cool neutral + deep teal | Taste | P5 | Specific, offline-safe, avoids default looks | Inter/system font; indigo accent |
| 56 | Design | Form details, availability editor, master-detail, copy, loading, review card, permission timing, charts, undo | Mechanical | P1 | Pass 7 decisions | — |
| 57 | Design | Accessibility specifics with meetsGuideline tests | Mechanical | P1 | WCAG 2.2 AA intent made testable | aspirational a11y |
| 58 | DX | Mode DX POLISH; persona = solo dev + future contributor; TTHW target Competitive (<5 min) | Mechanical | override/P5 | /autoplan DX overrides | Champion target |
| 59 | DX | Pin Flutter 3.47.7 via .fvmrc + CI flutter-version-file | Mechanical | P5 | Observed post-upgrade version; prevents drift | "current stable" |
| 60 | DX | Gitignore generated files; codegen in bootstrap and CI | Taste | P3 | Common practice, clean diffs | committing *.g.dart |
| 61 | DX | Shell scripts (bootstrap/check/gen/test_integration) over melos | Taste | P5 | Two packages; no extra tool | melos |
| 62 | DX | Riverpod 3 without codegen, GoRouter constants, flutter_lints, layer test | Taste | P5 | One generator only (Drift) | riverpod_generator, typed routes |
| 63 | DX | Civil-time scheduler + package:timezone ZoneConverter; host-independent DST tests | Taste | P1 | DST tests otherwise vacuous on UTC CI | TZ env only |
| 64 | DX | Error codes + docs/ERRORS.md + ring buffer | Mechanical | P1 | problem+cause+fix rule | last-error only |
| 65 | DX | Replace byte-identical check with row dumps; DataVersion counter; index filters deletedAt | Mechanical | P5 | Flaky or unspecified mechanisms | PRAGMA data_version |
| 66 | DX | Docs pass inlines tables, folds obligations into phases, glossary, How-to recipes | Mechanical | P1 | Dangling references | — |
| 67 | DX | Debug Developer menu with shared seed fixture | Mechanical | P1 | Reachable states for QA/goldens | manual setup |
| 68 | DX | Goldens macOS-only with font loading | Mechanical | P5 | Cross-platform pixel drift | goldens everywhere |
| 69 | DX | Central SchedulerConfig/AppLimits; structured reason codes; inexact notifications | Mechanical | P5 | Magic numbers, English in engine, exact-alarm policy | — |
| 70 | Eng | Scope accepted as-is; original arrangement | Mechanical | P2 override | /autoplan never reduces scope | smaller arrangement |
| 71 | Eng | Session timing columns + elapsed model (H1) | Mechanical | P1 | Restart and drift requirements had no storage | integer minutes only |
| 72 | Eng | Accept cutoff = generatedAt + time-passed refusal (H2) | Mechanical | P1 | Prevents overlap (rule 2) | accept-time now |
| 73 | Eng | DataVersion via triggers on scheduler inputs only (H3) | Mechanical | P5 | Explicit, can't be forgotten | manual bumps on every write |
| 74 | Eng | DbGuard, VACUUM INTO, move db+wal+shm (H4) | Mechanical | P1 | WAL corruption risk | main-file copy |
| 75 | Eng | Civil-time storage; Dart local ZoneConverter (H5) | Mechanical | P5 | Deadlines must survive travel | UTC deadlines |
| 76 | Eng | flutter_timezone only if zonedSchedule needs it | Taste | P4 | Avoid a native dep unless required | add plugin now |
| 77 | Eng | M1-M11 and low items accepted | Mechanical | P1/P5 | Each closes a concrete defect | — |
| 78 | Eng | CocoaPods blocker narrowed (SwiftPM default) | Mechanical | P5 | Measured on 3.47.7 | keep old wording |

**Spec Review Loop result:** 3 launches (scores 6, 7, 7). Found 54, reviewer-confirmed fixed 40, remaining after launch 3: 14, all applied and checked against the amended plan text (issues verified: 14 of 14; applied edits, not a reviewer verdict). Decision: spec not re-verified after launch 3. Metrics appended to `~/.gstack/analytics/spec-review.jsonl`.

#### 0I. Temporal interrogation

```
  HOUR 1 (foundations):   flutter create (android+ios), pin package versions that resolve on the
                          upgraded SDK, analysis_options, Drift schema v1 with ALL accepted columns,
                          injected Clock, README stub with Known limitations. Needs: final Flutter/Dart
                          versions recorded (obligation), build_runner working.
  HOUR 2-3 (core logic):  Ambiguities: how local wall-clock availability maps to instants across DST
                          (store instants as UTC, availability as local minutes-of-day, expand per local
                          date); session splitting with breaks; scoring weights. All owned by Eng.
  HOUR 4-5 (integration): Surprises: session timer across app kill (needs persisted startedAt/pause
                          segments, Eng), Accept transaction vs Riverpod stream refresh, save-file dialog
                          behavior per platform (Phase 7 spike), notification permission flows.
  HOUR 6+ (polish/tests): Will wish they had: golden/widget tests at 3 widths, text-scale 2.0 checks,
                          a seeded fixture dataset shared by widget and integration tests, a clock fake.
```
Effort (whole v1): human team ~6-8 weeks / CC+gstack ~2-4 focused days across phases [estimated]. Feasibility blockers: none for Android debug and tests; iOS plugin builds blocked on CocoaPods (PR5); release builds blocked on Android licenses (PR6). Pending choices owned by Eng: timer persistence model, DST handling, scoring formula, codegen vs hand-written providers.

### CEO dual voices

Claude CEO subagent: completed (agent ad72ec997051152ca), INPUT `ceo e8d415f1…17be` matched the snapshot. Codex: unavailable (CLI not installed). Mode: `[subagent-only]`.

Subagent findings and dispositions:

| # | Finding | Severity | Disposition |
|---|---|---|---|
| F1 | Data-entry friction; add .ics import, syllabus paste, recurring tasks | Critical | Weekly repeat ACCEPTED (taste). .ics import and syllabus paste DEFERRED (taste) to TODOS.md Capture |
| F2 | Notifications too late (Phase 7) | High | USER CHALLENGE UC2 (changes the brief's explicit phase order) |
| F3 | No persona or success metric | High | ACCEPTED as "Product framing" doc section, marked assumed |
| F4 | "Assessment importance" has no field | High | ACCEPTED: nullable gradeWeightPct in schema v1 |
| F5 | Weekly availability ignores one-off busy times | High | ACCEPTED: AvailabilityExceptions in schema v1; device calendar read DEFERRED |
| F6 | Hard delete breaks future sync claim | Med-High | ACCEPTED (taste): soft delete with deletedAt |
| F7 | 8-week cap makes finals look unscheduled | Medium | ACCEPTED: whole-term capacity check + "Planned later" label |
| F8 | No Semester entity | Medium | Kept DEFERRED (E9), now TASTE since the voice disagrees |
| F9 | No validation with real students before polish | Critical | USER CHALLENGE UC1 |
| F10 | Device loss = data loss | High | ACCEPTED (taste): OS-level backup coverage + disclosure |
| F11 | Tablet polish vs laptop audience | Medium | Tablets stay (brief requirement). Web/desktop DEFERRED to TODOS.md |
| F12 | On-device AI not analyzed | Medium | ACCEPTED as documented alternative; model use DEFERRED |
| F13 | Daily-budget mode not considered | Medium | ACCEPTED as documented alternative |
| F14 | No competitive positioning | High | ACCEPTED: three differentiators in Product framing + README |

```
CEO DUAL VOICES — CONSENSUS TABLE:
  Dimension                            Claude  Codex  Consensus
  1. Premises valid?                    partly  N/A    N/A
  2. Right problem to solve?            yes, but capture friction is the real problem  N/A  N/A
  3. Scope calibration correct?         no: too much before validation  N/A  N/A
  4. Alternatives sufficiently explored? no: daily budgets, on-device models  N/A  N/A
  5. Competitive/market risks covered?  no    N/A    N/A
  6. 6-month trajectory sound?          at risk (ship late, unvalidated)  N/A  N/A
Outside voice unavailable: all Consensus cells N/A, never CONFIRMED.
Single-voice criticals flagged: F1, F9.
```

**User Challenges queued for the final gate (never auto-decided):**
- UC1. Your direction: build Phases 0-9 in order and release. Proposed: after Phase 4 (core journey works end to end), put a phone build in front of 5-10 students for about two weeks before Phase 6 polish, holding E2, E7 and tablet master-detail work until after that check. Why: every heuristic in this plan is a guess until real students use it. Blind spot: you may already have testers or a deadline that makes a pause costly. Cost if wrong: about two weeks of calendar delay; cost of skipping it: polishing features students do not use.
- UC2. Your direction: notifications in Phase 7, after the core is stable. Proposed: a minimal "session starts in 10 minutes" reminder in Phase 4; permission edge cases and the rest stay in Phase 7. Why: an offline, account-free app has no other way to bring the student back. Blind spot: notification permission prompts early in onboarding can hurt opt-in if done badly. Cost if wrong: small; Phase 7 work moves earlier.

### CEO review sections (SELECTIVE EXPANSION, implementation-ready depth)

**Current scope:** mode SELECTIVE EXPANSION (/autoplan override). Accepted: E1, E2, E7, E10, E11, spec-review clarifications, F3/F4/F5/F6/F7/F10/F12/F13/F14 items, weekly repeat, and the section findings below (rows 30-43 of the audit trail). Deferred: E3, E4, E5, E9, .ics import, syllabus paste, device calendar, web/desktop, on-device model. Pending user: UC1, UC2.

#### Section 1: Architecture

```
                   +-------------------- Flutter app (lib/) --------------------+
                   |  app/ (router, theme)                                      |
  user  --->  presentation (screens, widgets) ---> application (Riverpod)       |
                   |                                  |          |              |
                   |                         repositories     PlanService ------+--> packages/semester_scheduler
                   |                                  |       (builds inputs,  |     (pure Dart: scoring,
                   |                         Drift DB (SQLite file)  diffs,     |      allocation, warnings,
                   |                                  |       accept txn)      |      explanations)
                   |  core/: clock, errors, widgets   |                        |
                   +----------------------------------|------------------------+
                                                      v
                                  backup JSON (user-chosen file), local notifications
```
Boundaries: presentation never touches Drift; the scheduler package imports nothing from the app; PlanService is the only caller of the scheduler and the only writer of accepted plans.

Data flow, plan generation:
```
  tasks+sessions+availability+exceptions+settings --(repos)--> SchedulerInput --> engine --> Proposal --> diff UI --> Accept txn
  nil:   no tasks              -> empty proposal + "Add a task" empty state (no error)
  empty: no availability       -> proposal with every task unscheduled, reason "no study time set" + link to availability
  error: DB read fails         -> ErrorState with Retry; nothing written
         Accept txn fails      -> rollback, prior plan intact, snackbar "Couldn't save the plan. Nothing changed."
```

Session state machine (missed is derived, not stored):
```
  planned --start--> active --pause--> paused --resume--> active
     |                 |  \                  \
     |                 |   complete            complete/skip
   skip              skip  v                     v
     v                 v  completed           completed / skipped
  skipped           skipped
  planned + plannedEnd < now  ==> shown as Missed (still planned in DB)
  Invalid: completed->*, skipped->active, starting a 2nd session while one is active/paused
  Prevented by: SessionStateMachine in domain (pure), repository transaction, partial unique index.
```
Findings: (1) single-active-session invariant was missing; ACCEPTED. (2) Scheduler purity was a convention; ACCEPTED as a separate pure Dart package. Scaling: data is small (about 500 tasks and 2,000 sessions per term), so 10x and 100x are fine for SQLite; the scheduler is the first thing to slow down and runs off the UI isolate if a run exceeds about 50 ms (Eng to measure). Single points of failure: the one SQLite file, mitigated by backups, OS backup and the recovery screen. Rollback posture: store builds roll forward only; a database cannot be downgraded, so the recovery screen and the pre-migration `.bak` copy are the rollback path. Value test: the planning docs are user-requested and serve as product documentation; no orphan process artifacts.

#### Section 2: Error and rescue map

```
  CODEPATH                    | WHAT CAN GO WRONG                 | EXCEPTION CLASS
  ----------------------------|-----------------------------------|------------------------------
  AppDatabase.open            | corrupt file / newer schema       | SqliteException / custom DatabaseVersionTooNew
  Repository writes           | constraint or disk-full failure   | SqliteException
  PlanService.accept          | data changed since proposal       | StaleProposalException
                              | txn failure                       | SqliteException
  SessionService.start        | another session active            | ActiveSessionConflict
  BackupService.export        | validation fails before write     | BackupValidationException
                              | user cancels dialog / IO error    | (null result) / FileSystemException, PlatformException
  BackupService.import        | too large / malformed / bad refs  | BackupTooLarge / FormatException / BackupValidationException
                              | higher or missing schemaVersion   | UnsupportedBackupVersion
  NotificationService.schedule| permission denied / platform cap  | PlatformException
  Clock/timezone change       | stale "today" state               | (no exception; resume recompute)

  EXCEPTION CLASS          | RESCUED? | RESCUE ACTION                              | USER SEES
  -------------------------|----------|--------------------------------------------|------------------------------------
  SqliteException (open)   | Y        | recovery screen                            | Restore / Start fresh / Details
  DatabaseVersionTooNew    | Y        | recovery screen                            | "Made by a newer SemesterOS"
  SqliteException (write)  | Y        | rollback, keep form data                   | inline error, entered data kept
  StaleProposalException   | Y        | block accept                               | "Your plan changed. Regenerate?"
  ActiveSessionConflict    | Y        | prompt                                     | pause/finish current first
  BackupValidation (export)| Y        | refuse write                               | "Backup couldn't be created" + details
  Export cancelled         | Y        | no timestamp update                        | nothing (silent is correct here)
  FileSystem/Platform (IO) | Y        | no timestamp update                        | "Couldn't save the file"
  Backup* (import)         | Y        | no data change                             | plain-language reason
  PlatformException (notif)| Y        | mark reminders off, keep app working       | settings shows "Notifications are off"
```
No catch-alls: each handler names its class; a top-level `FlutterError.onError` / zone handler records the last error for diagnostics and shows ErrorState, never a blank screen. Gaps found and ACCEPTED: DB open failure, newer-schema database, stale proposal, double session start.

#### Section 3: Security and threat model

No network surface, no accounts, no secrets. Threats: (1) crafted backup file (huge, deep nesting, oversized strings, dangling references): likelihood Low, impact Medium (crash or bad data); mitigated by size cap, length limits, reference checks, transaction (ACCEPTED). (2) Lock-screen notifications reveal task names: Low/Low; mitigated by the "Show task names" setting (ACCEPTED). (3) OS cloud backups hold academic data: Medium/Low; disclosed in README, controlled by device settings (taste, ACCEPTED). (4) Dependency risk: every package must pass the brief's license and maintenance check; Eng records the table. SQL injection: Drift uses bound parameters; no raw string SQL with user input (Eng rule). No audit logging needed for a single-user local app.

#### Section 4: Data flow and interaction edge cases

```
  INPUT(form) -> VALIDATE(field rules) -> TRANSFORM(local->UTC instant) -> PERSIST(txn) -> OUTPUT(stream refresh)
   nil/empty title -> inline "Add a title"; too long -> inline limit; deadline in past -> allowed with "overdue" warning
   txn failure -> rollback, form kept; duplicate double-submit -> button disabled while saving
```
Async ordering: Proposal built at version V; a session completes (timer) at V+1; Accept at V+1 would overwrite with stale data. Mechanism: version check inside the Accept transaction (ACCEPTED stale guard). Regression proof: test pauses after proposal creation, completes a session, then accepts and expects refusal.

| Interaction | Edge case | Handled? | How |
|---|---|---|---|
| Start session | double tap | Yes | state machine + unique index |
| Active session | app killed for hours | Yes (accepted) | long-running guard asks for minutes |
| Edit task | navigate away with changes | Gap → ACCEPTED in UX flows | "Discard changes?" prompt |
| Accept proposal | double tap | Yes | disabled while committing |
| Rotation/resize mid-form | state loss | Eng | form state in controllers/providers |
| Lists | 0 / 500 items | Yes | empty states; lazy lists |
| Day rollover while open | stale "today" | Yes (accepted) | resume/date-change recompute |

#### Section 5: Code quality

Risks: two code generators (Drift and possibly Riverpod) slow builds and confuse a solo maintainer; scheduler complexity concentrated in one function; repositories growing into god objects. Recommendations owned by Eng: one generator if possible; split the engine into scoring, slot expansion, allocation and explanation units, each under five branches; one repository per aggregate. No duplicated behavior exists yet (greenfield).

#### Section 6: Tests

```
  NEW THING                         | TYPE         | HAPPY                    | FAILURE                      | EDGE
  ----------------------------------|--------------|--------------------------|------------------------------|---------------------------
  Scheduler package                 | unit (dart)  | fits in week             | no capacity -> unscheduled   | DST, overdue, pinned, exceptions
  PlanService accept                | integration  | replaces planned         | txn failure rollback         | stale version, missed kept
  Session state machine + timer     | unit         | start/pause/complete     | 2nd start refused            | restart, long-running guard
  Repositories + soft delete        | integration  | CRUD                     | constraint failure           | undo, deleted excluded
  Backup export/import              | integration  | round trip               | each validation rule         | missing optional fields
  Quick add / forms                 | widget       | 3-field create           | inline errors                | text scale 2.0
  Dashboard / planner / review      | widget       | seeded literal numbers   | ErrorState on repo failure   | empty states, 3 widths
  Core journey (brief §12)          | integration_test | full 10 steps        | —                            | restart persistence
```
Flakiness: every time-dependent path takes an injected clock; DST tests must not depend on the host time zone (Eng decides how: wall-clock domain model in the scheduler, plus a CI job with `TZ` set). Test ambition: the 2am-Friday test is the core journey with restart; the hostile test is import of a crafted backup; the chaos test is killing the app mid-session and mid-accept. No LLM or prompt code exists, so no eval suites apply.

#### Section 7: Performance

Indexes needed: sessions(plannedStart), sessions(taskId), sessions(status) partial unique, tasks(deadline), tasks(subjectId), tasks(deletedAt) or combined filters (Eng). Insights aggregate in SQL, not in Dart loops. Slow paths: scheduler over an 8-week horizon (target under 50 ms on a mid-range phone, Eng to measure), backup import of a full term, weekly planner first render. No connection-pool or N+1 concerns beyond using joins for task+subject lists.

#### Section 8: Observability

No telemetry by design (privacy). Debuggability comes from local diagnostics (ACCEPTED): version, schema, DB size, last error, copyable without personal content. Plan explanations are themselves the user-facing trace of scheduling decisions. No dashboards, alerts or runbooks apply to a local-only app; the runbook equivalent is README troubleshooting for the recovery screen.

#### Section 9: Deployment and rollout

v1 ships schema 1, so no migration in v1. Future migrations: copy DB to `.bak` first, migration test per version with Drift's generated schema helpers. No feature flags. Rollout: Android closed testing track or sideload APK first; iOS needs CocoaPods locally and a signing team for devices. Post-release check: first-launch smoke on a clean emulator and simulator. CI workflow exists but is unverified until pushed.

#### Section 10: Long-term trajectory

Debt introduced: code generation, heuristic weights that need real data, tombstones never purged in v1. Reversibility: 4/5 (local app, schema designed additively; soft delete keeps sync open). The scheduler package is reusable for a future web/desktop build. Cherry-pick retrospective: E10 pinning and the stale-proposal guard are what make "never silently move" credible; E2 depends on enough completed tasks, so its value appears only after several weeks.

#### Section 11: Design and UX

Information architecture (compact): Today (next action first, then today's sessions, then deadlines, then on-track figures) / Planner / Tasks / Subjects / Insights, with Settings from Today's app bar.

| Feature | Loading | Empty | Error | Success | Partial |
|---|---|---|---|---|---|
| Today | skeleton rows | "Add your first task" + quick add | ErrorState + Retry | session started toast | some tasks unscheduled banner |
| Planner | skeleton week | "Generate your first plan" | ErrorState | proposal accepted snackbar | conflicts list |
| Tasks/Subjects | list skeleton | guided empty state | ErrorState | saved + Undo | — |
| Insights | — | "Insights appear after your first studied session" | ErrorState | — | E2 hidden until 3 tasks |
| Backup | progress | "Never backed up" | plain-language reason | "Backup saved" | — |

```
  Onboarding (skippable) -> Today(empty) -> Quick add task -> Availability -> Generate plan -> Proposal diff -> Accept
        -> Today(next action) -> Start session -> Timer (pause/resume) -> Complete|Skip -> "Plan needs attention" banner
        -> Proposal -> Accept -> Weekly review (weekStartDay)
```
AI-slop risk: card-per-metric dashboards; avoided by one dominant next-action block and plain lists. Responsive intention is explicit in the brief. Accessibility basics are specified. Recommendation: run /plan-design-review (Phase 2 of this /autoplan run does this next).

### CEO required outputs

**NOT in scope** (deferred, in TODOS.md): E3 sample semester, E4 home widget, E5 .ics export, E9 term entity, .ics import, syllabus paste, device calendar busy times, web/desktop build, on-device model. Rejected: share-sheet export path (spec review 2; extra dependency, cannot confirm success).

**What already exists:** nothing in the repository. Reused platform pieces: Material 3 adaptive navigation widgets, Drift migration tooling, Dart core DateTime with an injected clock.

**Dream state delta:** after v1 the student has explained, private, self-correcting planning on phone and tablet. Still missing against the 12-month ideal: low-effort capture from LMS files (TODO P1), sync or laptop access, and a home-screen glance.

**Error and Rescue Registry:** the Section 2 tables above (10 codepaths, 10 exception classes, 0 unrescued after accepted fixes).

**Failure Modes Registry:**
```
  CODEPATH              | FAILURE MODE                 | RESCUED? | TEST? | USER SEES?                  | LOGGED?
  ----------------------|------------------------------|----------|-------|-----------------------------|--------
  DB open               | corrupt / newer schema       | Y        | Y     | recovery screen             | Y (diag)
  Accept plan           | stale data / txn failure     | Y        | Y     | message, nothing changed    | Y
  Session timer         | app killed hours             | Y        | Y     | confirm minutes prompt      | Y
  Session start         | second active session        | Y        | Y     | prompt                      | n/a
  Import                | crafted/malformed file       | Y        | Y     | reason, no change           | Y
  Export                | dialog result unconfirmable  | Y        | spike | Known limitation            | Y
  Scheduler             | capacity exceeded            | Y        | Y     | unscheduled + reason        | n/a
  Notifications         | permission denied / iOS cap  | Y        | Y     | "Notifications are off"     | Y
  Date/TZ change        | stale today                  | Y        | Y     | refreshed view              | n/a
```
Critical gaps: 0 (no row with RESCUED=N, TEST=N and silent).

**Diagrams produced:** system architecture, plan-generation data flow with shadow paths, session state machine, error tables, form data flow, user flow. Deployment sequence: Phase 1 project → schema v1 → store track; rollback path: recovery screen + `.bak` (Section 9). **Stale diagram audit:** none exist in the repo.

REALITY: premise-table finding 8 premises, 2 environment blockers (PR5, PR6), 1 weak premise (PR3) unverified=0 docs/IMPLEMENTATION_PLAN.md:9
REALITY: already-done pass checked: `git log` shows zero commits and no remote exists, so no base-branch work can predate this plan docs/IMPLEMENTATION_PLAN.md:12
REALITY: surface-check finding `flutter create --platforms/--org` and `flutter doctor --android-licenses` to be rechecked against --help after the SDK upgrade docs/IMPLEMENTATION_PLAN.md:20
REALITY: binding-decisions pass BD1-BD3 recorded; decision log empty docs/IMPLEMENTATION_PLAN.md:203
REALITY: numbers finding all thresholds and defaults are [estimated]; no measured baselines docs/IMPLEMENTATION_PLAN.md:151
REALITY: deferred-asks pass no linked issue; every request in the user's brief stays in scope, and only reviewer-proposed additions were deferred (TODOS.md) docs/IMPLEMENTATION_PLAN.md:198
REALITY: pr-count pass no `.gstack/ship-policy.json`, so the default of one PR per wave applies; no remote yet, so no PR queue cost docs/IMPLEMENTATION_PLAN.md:186

#### CEO Implementation Tasks

- [ ] **T1 (P1, human: ~2h / CC: ~10min)** — docs — Write Product framing (persona, metric, differentiators) and considered alternatives
  - Surfaced by: CEO voice F3/F12/F13/F14
  - Files: docs/IMPLEMENTATION_PLAN.md, docs/SCHEDULING_ALGORITHM.md, README.md
  - Verify: sections exist and are marked [assumed, confirm]
- [ ] **T2 (P1, human: ~1d / CC: ~30min)** — data — Schema v1 with every accepted column and table (isPinned, completedAt, gradeWeightPct, deletedAt, AvailabilityExceptions, EstimateCalibration, Settings fields)
  - Surfaced by: spec reviews 1-3, CEO voice F4/F5/F6
  - Files: lib/core/database/ (to be determined)
  - Verify: schema snapshot test
- [ ] **T3 (P1, human: ~3d / CC: ~1h)** — scheduler — pure Dart package with horizon, pinned, exceptions, effort-to-schedule, whole-term capacity and unscheduled reasons
  - Surfaced by: Sections 1, 6; spec review 3
  - Files: packages/semester_scheduler/
  - Verify: `dart test` in the package
- [ ] **T4 (P1, human: ~1d / CC: ~30min)** — plan — PlanService accept/reject with stale guard and trigger banner
  - Surfaced by: Sections 2, 4
  - Files: to be determined
  - Verify: repository and widget tests listed in the accepted block
- [ ] **T5 (P1, human: ~1d / CC: ~30min)** — sessions — state machine, single-active index, long-running guard, resume recompute
  - Surfaced by: Sections 1, 4
  - Files: to be determined
  - Verify: unit tests with fake clock
- [ ] **T6 (P1, human: ~1d / CC: ~30min)** — backup — hardened validator, replace-all import, recovery screen, OS backup config
  - Surfaced by: Sections 2, 3; CEO voice F10
  - Files: to be determined; android/app/src/main/AndroidManifest.xml
  - Verify: rejection tests, corrupted-DB fixture test, manifest check
- [ ] **T7 (P2, human: ~2h / CC: ~10min)** — settings — local diagnostics and notification privacy toggle
  - Surfaced by: Sections 3, 8
  - Files: to be determined
  - Verify: diagnostics test without task titles
- [ ] **T8 (P2, human: ~1h / CC: ~10min)** — ci — GitHub Actions workflow labeled unverified until pushed
  - Surfaced by: Section 9
  - Files: .github/workflows/ci.yml
  - Verify: workflow lints locally; README states status

```
  +====================================================================+
  |            MEGA PLAN REVIEW — COMPLETION SUMMARY                   |
  +====================================================================+
  | Mode selected        | SELECTIVE EXPANSION                         |
  | System Audit         | empty repo; Flutter 3.24 (upgrading);       |
  |                      | CocoaPods missing; Android licenses pending |
  | Step 0               | 5 expansions accepted, 4 deferred; 3 spec   |
  |                      | reviews (6,7,7), 54 issues, all applied     |
  | Section 1  (Arch)    | 2 issues found                              |
  | Section 2  (Errors)  | 10 error paths mapped, 4 GAPS (accepted)    |
  | Section 3  (Security)| 3 issues found, 0 High severity             |
  | Section 4  (Data/UX) | 7 edge cases mapped, 1 unhandled -> fixed   |
  | Section 5  (Quality) | 3 issues found (owned by Eng)               |
  | Section 6  (Tests)   | Diagram produced, 1 gap (DST host TZ)       |
  | Section 7  (Perf)    | 1 issue (indexes, owned by Eng)             |
  | Section 8  (Observ)  | 1 gap found (diagnostics, accepted)         |
  | Section 9  (Deploy)  | 2 risks flagged (no DB downgrade, CI unver.)|
  | Section 10 (Future)  | Reversibility: 4/5, debt items: 3           |
  | Section 11 (Design)  | 2 issues (discard prompt, slop risk)        |
  +--------------------------------------------------------------------+
  | NOT in scope         | written (10 items)                          |
  | What already exists  | written                                     |
  | Dream state delta    | written                                     |
  | Error/rescue registry| 10 rows, 0 CRITICAL GAPS                    |
  | Failure modes        | 9 total, 0 CRITICAL GAPS                    |
  | TODOS.md updates     | 9 items proposed                            |
  | Scope proposals      | 9 proposed, 5 accepted (EXP + SEL)          |
  | CEO plan             | written                                     |
  | Outside voice        | codex unavailable (not installed)           |
  | Lake Score           | N/A (no coverage-scored questions asked)    |
  | Diagrams produced    | 6 (arch, data flow, state, error, form, UX) |
  | Stale diagrams found | 0                                           |
  | Unresolved decisions | 2 (UC1, UC2 at final gate)                  |
  | Reality rows         | 7/7 rows, unverified=0                      |
  +====================================================================+
```

### Design review (Phase 2 of /autoplan)

**System audit.** No DESIGN.md (gap: the brief's docs/DESIGN_SYSTEM.md takes that role and is written in Phase 0/1). No existing UI code or patterns. UI scope: large (dashboard, planner, proposal, sessions, tasks, subjects, insights, onboarding, settings, backups). No prior design reviews. Mockups: SKIPPED. The gstack designer binary is installed, but its image generation calls the paid OpenAI API, which conflicts with the user's zero-dollar budget; it was not run without explicit approval. Review is text-only.

**Step 0.** Initial design completeness: 4/10. The plan is precise about data and scheduler behavior but rarely says what the user sees first, what text they read, or how a screen changes across widths. A 10 for this plan names the per-screen hierarchy, every state's copy and action, the navigation map, the type, color and motion tokens, and the compact/medium/expanded layout of each screen. Focus: all 7 passes (/autoplan override).

**Dual voices.** Claude design subagent: completed (agent acabd0ff7f28523fa), INPUT `design 3cc96a70…7eae` matched the snapshot; 25 findings (5 critical, 10 high, 10 medium). Codex: unavailable (not installed). `[subagent-only]`.

```
DESIGN OUTSIDE VOICES — LITMUS SCORECARD:
  Check                                    Claude        Codex  Consensus
  1. Brand unmistakable in first screen?   NO (no brand) N/A    N/A
  2. One strong visual anchor?             NOT SPEC'D    N/A    N/A
  3. Scannable by headlines only?          NOT SPEC'D    N/A    N/A
  4. Each section has one job?             NO (Today)    N/A    N/A
  5. Cards actually necessary?             NO (risk)     N/A    N/A
  6. Motion improves hierarchy?            NOT SPEC'D    N/A    N/A
  7. Premium without decorative shadows?   NOT SPEC'D    N/A    N/A
  Hard rejections triggered:               risk of #7 (stacked cards on Today)  N/A  N/A
```
Classifier: OPERATE (app UI) on every screen; onboarding is OPERATE with one welcome moment.

#### Pass 1: Information architecture — 3/10 → 9/10

Gaps: Today has nine unordered elements plus banners; no navigation map; quick add placement unknown. Fixed (auto, P5; nav composition is TASTE):
```
  Compact (<600)            Medium (600-839)              Expanded (>=840)
  +-------------------+     +--+--------------------+     +--+---------------+-----------+
  | Today  [⚙]        |     |R | Today              |     |R | Today          | Deadlines |
  | [NEXT ACTION]     |     |a | [NEXT] | Sessions  |     |a | [NEXT] Sessions| Week load |
  | attention slot    |     |i | progress| Deadlines|     |i | progress       | Review    |
  | Today's sessions  |     |l |                    |     |l |                |           |
  | Progress          |     +--+--------------------+     +--+---------------+-----------+
  | Deadlines         |     Destinations: Today / Plan / Tasks (Subjects segment) / Insights
  | secondary card    |     Settings: header icon. Availability: from Plan and Settings.
  | [mini session bar]|     Quick add: FAB (compact), rail button (medium/expanded)
  | Today Plan Tasks Ins |
  +-------------------+
```
Today order: (1) next-action block, the single visual anchor, with one primary button; (2) at most one attention banner (priority: plan needs attention > overload > backup reminder); (3) today's sessions as a plain list; (4) planned vs studied progress; (5) upcoming deadlines (7 days); (6) at most one secondary card (weekly review > anything else). Remaining notices go to a "Notices" list in the header.

#### Pass 2: Interaction states — 4/10 → 9/10

Next-action state table (auto-fixed):

| Situation | Headline | Supporting line | Primary | Secondary |
|---|---|---|---|---|
| Session active | "Studying <task>" | elapsed / planned, subject | Pause | Complete |
| Session paused | "Paused: <task>" | "<n> min so far" | Resume | Complete, Skip |
| Next session later today | "Next: <task>" | "<start time> · <duration> · <subject>" | Start now | Details |
| Missed today, nothing upcoming | "A session slipped by" | "Let's find a new time." | Re-plan | — |
| Nothing planned today, tasks open | "Nothing planned today" | "Next deadline: <task>, <day>" | Study now | Open Plan |
| No tasks | "Add your first deadline" | "SemesterOS plans the rest." | Quick add | — |
| No availability | "When can you study?" | "Set your study times to get a plan." | Set study times | — |
| All done today | "Today's plan is done" | "<h m> studied today" | Plan tomorrow | — |

"Study now" starts an ad-hoc pinned session for the most urgent task immediately (session duration = preferred duration). Other state rules:

| Feature | Loading | Empty | Error | Success | Partial |
|---|---|---|---|---|---|
| Any local read | none under ~150 ms; else inline progress | per-screen copy in UX_FLOWS.md | ErrorState + Retry | — | — |
| Proposal generation | button disabled + inline progress; nothing blocks the screen | "Nothing to schedule" | ErrorState, nothing written | "Plan updated" snackbar | unscheduled + conflict sections |
| Session complete | — | — | inline error, timer keeps running | sheet closes, list updates | — |
| Backup export/import | progress in sheet | "Never backed up" | plain-language reason | "Backup saved" / "Restored" | — |
| Insights | — | "Insights appear after your first studied session" | ErrorState | — | E2 hidden below 3 tasks |

#### Pass 3: Journey and emotional arc — 3/10 → 8/10

| Step | User does | User feels | Plan specifies |
|---|---|---|---|
| 1 | Opens app first time | curious, skeptical | welcome screen, one sentence, Start / Skip |
| 2 | Picks availability preset | "that was quick" | presets: Weekday evenings 18-21, Weekends 10-16, Custom |
| 3 | Adds first deadline (quick add) | invested | onboarding ends in quick add, not an empty Today |
| 4 | Sees first proposal | "it gets me" or doubt | summary first + "Why here?" lines |
| 5 | Accepts, sees Today | in control | next-action block |
| 6 | Starts session, leaves app | focused | persistent mini session bar; correct state on reopen |
| 7 | Skips or misses | guilt risk | supportive copy; Skip sheet "Didn't start / Studied some" |
| 8 | Away a week | dread | one "welcome back" summary when 2+ sessions were missed since last open: "A few sessions slipped by. Let's re-plan from today." |
| 9 | Weekly review | reflective | card on weekStartDay, plain numbers |
Skipped onboarding default availability: Mon-Fri 18:00-21:00, shown on Today with "Edit study times".

#### Pass 4: AI slop risk — 4/10 → 8/10

Risk was hard rejection #7 (app UI as stacked cards). Fixed by: one dominant next-action block; sessions, deadlines and tasks as divided lists; cards only for the secondary slot and the proposal summary. Litmus answers after fixes: 2 YES (one anchor), 4 YES (each section one job), 5 YES (cards limited), 7 YES (flat surfaces; elevation only on sheets and dialogs). Use scene: a student glancing between classes in daylight, and planning at a desk on Sunday evening; light by default, follows the system setting. Avoids the three default looks (no cream+serif, no neon-on-black, no hairline broadsheet).

#### Pass 5: Design system — 2/10 → 8/10 (TASTE for visual direction)

Tokens fixed in docs/DESIGN_SYSTEM.md and `lib/app/theme/`:
- Type: IBM Plex Sans bundled as an app asset (OFL), tabular figures for times and timers; scale 12/14/16/20/24/32; body 16. No runtime font fetching (google_fonts runtime loading would break offline-first).
- Color: cool neutral base (light background #F6F7F8, surface #FFFFFF, text #15181C; dark background #111315, surface #1A1D21, text #E8EAED), one accent deep teal (#0F766E light, #5EC4B6 dark). Semantic: info slate, attention amber, capacity red, success green, each paired with an icon and label. A fixed 10-color subject palette validated for 3:1 against both surfaces.
- Spacing 4-pt scale (4, 8, 12, 16, 24, 32). Radii 4 (chips), 8 (inputs, list blocks), 16 (sheets). Elevation: flat surfaces with dividers; elevation only on sheets, dialogs, FAB.
- Icons: Flutter's bundled Material Icons; no emoji. Material 3 widgets on both platforms with adaptive dialogs, date/time pickers and switches.
- Motion: 150-250 ms ease-out (`Curves.easeOutCubic`); reduced motion (`MediaQuery.disableAnimationsOf`) swaps transitions for instant changes.
- Warning taxonomy: info (planned later), attention (overdue, pinned conflict, task already complete), capacity (overload, does not fit). Each level has one icon, one label pattern, one placement rule (inline on a block, the Today attention slot, or the proposal summary) and one action.

#### Pass 6: Responsive and accessibility — 4/10 → 9/10

Planner: compact = 7-day chip strip with load bars above a day agenda; medium = 3-day view; expanded = 7-day time grid with an unscheduled tray. Text scale ≥ 1.3 switches the grid to the agenda. No drag-to-move in v1; "Edit time" is the only way to move a session. Tasks/Subjects on expanded: master-detail; the empty detail pane shows "Select a task" plus quick add; selection survives rotation and resize; switching items with unsaved edits triggers the discard prompt. Proposal: full-screen route on compact, side panel on expanded. Accessibility: 48 dp touch targets; 4.5:1 body text and 3:1 UI contrast in both themes; layouts tested at text scale 1.0, 1.5 and 2.0; every session block has a semantics label ("Chem lab, 16:00 to 16:50, planned, pinned"); status is icon + text, never color alone; timer announces state changes, not every second; visible focus ring for keyboard and switch access on tablets; each chart has a text summary line above it that is its accessible description.

#### Pass 7: Unresolved design decisions — 16 resolved, 0 deferred

| Decision | Resolution |
|---|---|
| New/edited task reaching the plan | task create/edit/delete/complete join the "needs attention" triggers; after saving a task, a snackbar offers "Schedule it now?"; Plan's persistent primary action is "Update plan" |
| Proposal review layout | summary line first ("24 sessions over 3 weeks · 2 tasks don't fit · 1 deadline at risk"), then week groups with counts, each expandable to sessions with a "Why here?" line; unscheduled and conflicts above Accept; first-ever plan labels Reject as "Not now" |
| Active session presence | mini session bar above the nav on every screen; tap opens the SessionTimer screen; reappears in the right state after restart |
| Complete / Skip input | Complete sheet with editable actual minutes (prefilled with elapsed); Skip sheet "Didn't start" / "Studied some: __ min" |
| Long-session dialog copy | "Still studying <task>? You've had it open for <h m>. How long did you actually study?" minutes field prefilled with the planned duration |
| Overload actions | every overload message gives counts ("About 6 hours more than your study time before Fri 14") and actions: Add study time, Review estimates, See what doesn't fit |
| Deadline display | date-only deadlines show "Due Fri, end of day" |
| Weekly repeat preview | live line before saving: "Creates 10 tasks, Mondays 09:00, until Dec 15" |
| Task progress | tracked minutes / estimate as a bar; milestones as a checklist with their own count; status becomes in-progress automatically on first session start |
| Availability editor | seven day rows with time-range chips and "Copy to weekdays"; one-off busy times as a dated list below |
| Calibration copy | "Your Assignments usually take about 2h 45m. Use that for new ones?" never "you're 1.4x slower" |
| Weekly review card lifetime | shown all day on weekStartDay; hides when dismissed or when "Plan this week" is accepted |
| Notification permission | asked only when the user turns reminders on, after a one-line pre-prompt; never at launch |
| Insights charts | planned vs studied: 7 paired bars; workload by subject: horizontal bars; deadline concentration: list by week with counts (no chart); estimate vs actual: per-type rows with plain text; each needs ≥1 studied session and has a text summary line |
| Undo | snackbar 10 s with screen-reader announcement; Undo does not survive navigation; undoing a delete of a task with planned sessions raises "plan needs attention"; a proposal built before the delete is refused by the stale guard with "Your plan changed. Regenerate?" |
| Small confirmations | subject delete skips the keep/delete choice when the subject has 0 tasks; recovery "Start fresh" says "Your current data stays saved as a file; nothing is deleted." |

<!-- autoplan-accepted:design -->
- Navigation (taste): four destinations Today / Plan / Tasks (with a Subjects segment) / Insights as bottom navigation (compact), NavigationRail (medium) and extended rail (expanded); Settings opens from the page header; Availability is reachable from Plan and Settings; quick add is a FAB on compact Today, Plan and Tasks and a rail button on medium/expanded. Verify: widget tests at 360, 700 and 1024 dp widths assert the navigation widget type and four destinations.
- Today hierarchy: next-action block first and the only primary button; at most one attention banner (priority: plan needs attention > overload > backup reminder); today's sessions; planned vs studied progress; deadlines for the next 7 days; at most one secondary card (weekly review first). Other notices go to a header "Notices" list. Verify: widget test with all notice conditions true shows exactly one banner (plan needs attention) and one secondary card.
- Next-action states: the eight-row state table in this review (active, paused, next later today, missed with nothing upcoming, nothing planned with open tasks, no tasks, no availability, all done) with its headline, supporting line, primary and secondary actions goes into docs/UX_FLOWS.md; "Study now" starts an ad-hoc pinned session for the most urgent task immediately. Verify: one widget test per row asserting the headline and primary button.
- Plan triggers: task create, edit, delete and complete are added to the "Your plan needs attention" triggers; after saving a task a snackbar offers "Schedule it now?" which opens a proposal; Plan's persistent primary action is "Update plan". Verify: widget test that creating a task shows the snackbar and the banner, and no sessions change until Accept.
- Proposal review: summary line first, sessions grouped by week with counts and expandable "Why here?" lines, unscheduled and conflict sections above Accept; full-screen route on compact and a side panel on expanded; on a first-ever plan Reject reads "Not now". Verify: widget test with a 50-session proposal renders the summary and week groups collapsed; golden test at compact and expanded widths.
- Planner layouts: compact day strip + agenda; medium 3-day view; expanded 7-day time grid with an unscheduled tray; text scale ≥ 1.3 forces the agenda; no drag-to-move in v1. Verify: widget tests at 360/700/1024 dp and at text scale 2.0 with no overflow errors.
- Session UI: mini session bar above navigation on every screen while a session is active or paused, opening the SessionTimer screen; Complete sheet with editable actual minutes prefilled with elapsed; Skip sheet with "Didn't start" or "Studied some: __ min"; long-session dialog copy as written in this review. Verify: widget tests for bar visibility after navigation and after a simulated restart, and for both sheets writing the entered minutes.
- Onboarding ending: availability presets (Weekday evenings 18-21, Weekends 10-16, Custom); onboarding ends in quick add for the first deadline; skipping onboarding sets Mon-Fri 18:00-21:00 and Today shows "Edit study times". Verify: widget test of the skip path producing those availability rows and the link.
- Welcome back: when 2 or more sessions were missed since the last app open, Today shows one summary "A few sessions slipped by. Let's re-plan from today." with a single Re-plan action, and the Planner groups missed sessions into a collapsed history group. Verify: widget test with 3 missed sessions shows one summary and no per-session alarms.
- Warning taxonomy: info / attention / capacity levels, each with one icon, label pattern, placement rule and action, documented in docs/DESIGN_SYSTEM.md and implemented as one WarningBadge/WarningRow component used everywhere. Overload messages give hour counts and the actions Add study time, Review estimates, See what doesn't fit. Verify: unit test mapping every warning type to a level; widget test that overload shows all three actions.
- Visual tokens (taste): IBM Plex Sans bundled as an asset with tabular figures; type scale 12/14/16/20/24/32 with body 16; cool neutral base and deep-teal accent with the hex values in this review; semantic info/attention/capacity/success colors always paired with icon and label; fixed 10-color subject palette validated at 3:1 against light and dark surfaces; 4-pt spacing; radii 4/8/16; flat surfaces with elevation only on sheets, dialogs and FAB; bundled Material Icons; Material 3 with adaptive dialogs, pickers and switches; motion 150-250 ms ease-out, instant under reduced motion. No runtime font fetching. Verify: contrast test computing ratios for every text/background token pair and subject color; golden tests in light and dark.
- Form details: date-only deadlines display as "Due <day>, end of day"; weekly repeat shows a live preview line before saving; task progress = tracked minutes / estimate as a bar plus a milestone checklist with its own count; status becomes in-progress automatically on first session start. Verify: widget tests for each.
- Availability editor: seven day rows with time-range chips and "Copy to weekdays"; one-off busy times as a dated list below. Verify: widget test adding two windows on Monday and copying them to weekdays.
- Master-detail (expanded): empty detail pane shows "Select a task" and quick add; selection survives rotation and resize; switching items with unsaved edits triggers the discard prompt. Verify: widget test resizing 1024→700→1024 dp keeps the selection.
- Copy and small confirmations: empty-state copy for Today, Plan, Tasks, Subjects, Insights and Weekly review written in docs/UX_FLOWS.md; calibration copy suggests a default ("Your Assignments usually take about 2h 45m. Use that for new ones?"); subject delete skips the choice when the subject has 0 tasks; recovery "Start fresh" copy says the current data stays saved as a file. Verify: UX_FLOWS.md copy table exists; widget test for the 0-task subject delete.
- Loading rules: no skeletons for local reads under about 150 ms; proposal generation disables its button with inline progress and never blocks the whole screen. Verify: widget test that generation keeps navigation usable.
- Weekly review card shows all day on weekStartDay and hides when dismissed or when "Plan this week" is accepted. Verify: widget test for both hide paths.
- Notification permission is requested only when the user enables reminders, after a one-line pre-prompt. Verify: widget test that first launch triggers no permission request.
- Insights charts: planned vs studied as 7 paired bars, workload by subject as horizontal bars, deadline concentration as a weekly list, estimate vs actual as per-type rows; each needs ≥ 1 studied session and carries a text summary line used as its semantics label. Verify: widget test that each chart's semantics label equals its summary line.
- Undo: snackbar lasts 10 s and is announced to screen readers; Undo does not survive navigation; undoing a delete of a task with planned sessions raises "plan needs attention". Verify: widget test of the announcement and the banner after undo.
- Accessibility: 48 dp minimum touch targets; 4.5:1 body and 3:1 UI contrast in both themes; layouts checked at text scale 1.0, 1.5, 2.0; semantics label on every session block (task, start-end, status, pinned); status never color-only; timer announces state changes only; visible focus ring on tablets. Verify: Flutter accessibility guideline tests (`meetsGuideline` for tap targets, labels and contrast) on Today, Plan, Tasks and the proposal screen.
- Mockups were not generated (paid OpenAI image API conflicts with the zero-dollar budget); /design-review on the running app after Phase 6 replaces them. Verify: Phase 6 checklist includes it.
<!-- /autoplan-accepted:design -->

**NOT in scope (design):** drag-to-move sessions (v1 uses Edit time), custom themes beyond light/dark/system, home-screen widget (TODOS.md), visual mockups (budget).

**What already exists:** nothing in the repo; reuse Flutter Material 3 NavigationBar/NavigationRail, showDatePicker/showTimePicker, adaptive constructors, `meetsGuideline` accessibility matchers, bundled Material Icons.

**TODOS.md updates:** none new; drag-to-move is recorded as not in scope rather than a TODO because Edit time fully covers the need.

#### Design Implementation Tasks

- [ ] **D1 (P1, human: ~1d / CC: ~30min)** — docs — Write DESIGN_SYSTEM.md tokens, warning taxonomy and UX_FLOWS.md state and copy tables
  - Surfaced by: Passes 2, 5, 7
  - Files: docs/DESIGN_SYSTEM.md, docs/UX_FLOWS.md
  - Verify: both files contain the tables named in the accepted block
- [ ] **D2 (P1, human: ~1d / CC: ~30min)** — theme — tokens, bundled IBM Plex Sans, contrast test
  - Surfaced by: Pass 5
  - Files: lib/app/theme/, assets/fonts/, pubspec.yaml
  - Verify: contrast unit test; light/dark goldens
- [ ] **D3 (P1, human: ~1d / CC: ~30min)** — shell — adaptive navigation, header settings, FAB/rail quick add, mini session bar
  - Surfaced by: Passes 1, 6, 7
  - Files: lib/app/router.dart, lib/core/widgets/
  - Verify: width-matrix widget tests
- [ ] **D4 (P1, human: ~2d / CC: ~1h)** — today — next-action state table, single banner slot, welcome back
  - Surfaced by: Passes 1-3
  - Files: lib/features/dashboard/
  - Verify: one widget test per state row
- [ ] **D5 (P1, human: ~2d / CC: ~1h)** — planner — day strip/3-day/7-day layouts and proposal review screen
  - Surfaced by: Passes 6, 7
  - Files: lib/features/planner/
  - Verify: width and text-scale widget tests, proposal golden
- [ ] **D6 (P2, human: ~1d / CC: ~30min)** — sessions/forms — Complete/Skip sheets, long-session dialog, repeat preview, availability editor
  - Surfaced by: Pass 7
  - Files: lib/features/sessions/, lib/features/tasks/, lib/features/availability/
  - Verify: widget tests listed in the accepted block
- [ ] **D7 (P2, human: ~4h / CC: ~20min)** — a11y — `meetsGuideline` suite on four main screens
  - Surfaced by: Pass 6
  - Files: test/accessibility/
  - Verify: `flutter test test/accessibility`

```
  +====================================================================+
  |         DESIGN PLAN REVIEW — COMPLETION SUMMARY                    |
  +====================================================================+
  | System Audit         | no DESIGN.md (DESIGN_SYSTEM.md to be written)|
  |                      | large UI scope; mockups skipped (budget)    |
  | Step 0               | 4/10; all 7 passes                          |
  | Pass 1  (Info Arch)  | 3/10 → 9/10 after fixes                     |
  | Pass 2  (States)     | 4/10 → 9/10 after fixes                     |
  | Pass 3  (Journey)    | 3/10 → 8/10 after fixes                     |
  | Pass 4  (AI Slop)    | 4/10 → 8/10 after fixes                     |
  | Pass 5  (Design Sys) | 2/10 → 8/10 after fixes (taste: visuals)    |
  | Pass 6  (Responsive) | 4/10 → 9/10 after fixes                     |
  | Pass 7  (Decisions)  | 16 resolved, 0 deferred                     |
  +--------------------------------------------------------------------+
  | NOT in scope         | written (4 items)                           |
  | What already exists  | written                                     |
  | TODOS.md updates     | 0 items proposed                            |
  | Approved Mockups     | 0 generated, 0 approved (budget)            |
  | Decisions made       | 22 added to plan (auto-decided)             |
  | Decisions deferred   | 0                                           |
  | Overall design score | 2/10 → 8/10                                 |
  +====================================================================+
```

### DX review (Phase 2.5 of /autoplan, mode DX POLISH)

**Product type.** End-user mobile app; the developer-facing surface is the repository workflow (clone, toolchain, codegen, run, test, build, release, docs). DX scope came from the scope tool's term matches; /autoplan does not let a label negate it, so the review covers that workflow.

```
TARGET DEVELOPER PERSONA
========================
Who:       the solo developer (owner) and a future contributor cloning the repo
Context:   fresh Mac or CI runner, wants the app on an emulator and tests green
Tolerance: ~10 minutes and 3 commands before frustration with toolchain present
Expects:   pinned Flutter version, one bootstrap command, one check command, README that matches reality
```

**Empathy narrative (predicted; nothing exists to observe yet).** I clone SemesterOS and open the README. It says Flutter, so I run `flutter pub get` and `flutter run`, and get a wall of "undefined class" errors because Drift's generated files are missing and nothing told me to run build_runner. I find build_runner in a blog post, rerun, then the scheduler package's tests need `dart test` from another folder. CI is green while my DST test fails locally because the runner is on UTC. I want one script that sets everything up and tells me exactly what is missing (CocoaPods, Android licenses) instead of finding out at minute 25.

**Competitive benchmark** (reference practice, not measured):

| Tool / practice | Start → result | Time + evidence | DX choice | Source |
|---|---|---|---|---|
| Typical Flutter app without codegen | clone → `flutter run` | ~2-5 min with toolchain [estimated] | pub get + run | in-distribution knowledge |
| Flutter + Drift/build_runner apps | clone → run | adds a codegen step; stale outputs block builds | gitignored `*.g.dart`, `build_runner build` after pub get, CI runs codegen | [Drift workflow guide](https://claudemarketplaces.com/skills/madteacher/mad-agents-skills/flutter-drift), [MobX build output guide](https://mobx.netlify.com/guides/output) |
| SemesterOS as planned | clone → app on emulator + tests | ~8 manual steps, 5-10 min with toolchain, 30-60 min fresh [estimated] | unspecified | this plan |

TTHW target (auto-decided, P5 fewer steps): Competitive, under 5 minutes with toolchain installed: `tool/bootstrap.sh` then `flutter run`. Magical moment: bootstrap ends by printing "Ready. Android: OK. iOS: needs `brew install cocoapods`." and `flutter run` shows Today with a debug-seeded semester one tap away (debug-only developer menu). Vehicle: shell scripts plus debug menu (existing capabilities only).

**Dual voices.** Claude DX subagent: completed (agent a0a7d7a9391cfd413), INPUT `dx db31935c…af96` matched the snapshot; 19 findings (2 critical, 10 high, 7 medium). Codex: unavailable (not installed). `[subagent-only]`.

```
DX DUAL VOICES — CONSENSUS TABLE:
  Dimension                           Claude  Codex  Consensus
  1. Getting started < 5 min?          no      N/A    N/A
  2. API/CLI naming guessable?         no (no scripts)  N/A  N/A
  3. Error messages actionable?        partly  N/A    N/A
  4. Docs findable & complete?         no (dangling refs)  N/A  N/A
  5. Upgrade path safe?                partly  N/A    N/A
  6. Dev environment friction-free?    no      N/A    N/A
Outside voice unavailable: Consensus N/A. Single-voice criticals: F1 codegen, F14 time zones.
```

**Developer journey map (after fixes):**
```
STAGE           | DEVELOPER DOES                                   | FRICTION POINTS                  | STATUS
1. Discover     | reads README "What/Why", sees Known limitations | none after README stub           | fixed
2. Install      | installs pinned Flutter (fvm or PATH), runs     | unpinned SDK, PATH, CocoaPods,   | fixed (bootstrap
                | tool/bootstrap.sh                               | licenses discovered late         |  reports each)
3. Hello World  | flutter run on emulator                          | missing codegen                  | fixed
4. Real Usage   | debug menu: seed semester, clock offset          | hard-to-reach states             | fixed
5. Debug        | tool/check.sh; error codes in diagnostics        | no single check, no error codes  | fixed
6. Upgrade      | schema bump via drift_dev make-migrations        | no schema baseline workflow      | fixed
```

**First-time developer report (predicted):**
```
T+0:00  clone, read README Setup: "Install Flutter 3.47.7 (see .fvmrc), run tool/bootstrap.sh"
T+1:30  bootstrap: pub get x2, build_runner, prints "iOS: needs brew install cocoapods"
T+3:00  flutter run -d emulator: Today empty state; Developer menu > Seed sample semester
T+4:00  tool/check.sh: format, analyze, flutter test, dart test (TZ-pinned), all green
T+4:30  success
```

#### Pass 1: Getting started — 2/10 → 8/10
Fixed: pinned toolchain (`.fvmrc` = 3.47.7, pubspec `environment: flutter:` and Dart SDK constraint), `tool/bootstrap.sh`, codegen policy (generated files gitignored; bootstrap and CI run `dart run build_runner build --delete-conflicting-outputs`). Residual: Android licenses and CocoaPods still need the user's own commands.

#### Pass 2: Command surface — 2/10 → 8/10
Fixed: `tool/bootstrap.sh`, `tool/check.sh` (format check, analyze, `flutter test`, scheduler `dart test` under `TZ=America/New_York`), `tool/gen.sh`, `tool/test_integration.sh <device>`; CI calls the same scripts. Plain shell scripts chosen over melos (TASTE: no extra tool for a two-package repo). Stack choices recorded in ARCHITECTURE.md in Phase 1 (TASTE): Riverpod 3 without code generation, GoRouter with route-name constants (no typed-route codegen), `flutter_lints`, and a unit test that fails if `presentation/` imports `data/`. Drift stays the only generator.

#### Pass 3: Errors and debugging — 4/10 → 8/10
Fixed: typed failure hierarchy in `core/errors/` with stable codes (`SEM-<AREA>-<NNN>`), a docs/ERRORS.md table (code, message, cause, fix), codes in Copy diagnostics and asserted in rejection tests; local ring buffer of the last 200 error and lifecycle events (no task or subject content) shown in Show details. Test hardening: "Reject leaves the database byte-identical" is replaced by a row-identical table-dump comparison; the stale-proposal "data version" is a `DataVersion` counter row incremented inside every repository write transaction (not `PRAGMA data_version`); the single-active-session partial unique index also filters `deletedAt IS NULL`.

#### Pass 4: Documentation — 3/10 → 8/10
Fixed: before Phase 1, the Phase 0 docs pass writes docs/UX_FLOWS.md (next-action table, copy, dialog text), docs/DESIGN_SYSTEM.md (hex tokens, warning taxonomy), and rewrites docs/IMPLEMENTATION_PLAN.md so every accepted obligation sits in its phase checklist under a plain feature name with its Verify clause, plus a short glossary for review labels (E1, PR5 and so on). ARCHITECTURE.md gets "How to" recipes: add a column/migration (drift_dev schema dump into `drift_schemas/` from v1), add a scheduler rule with tests, add a warning type, update goldens.

#### Pass 5: Upgrade path — 5/10 → 8/10
Fixed: schema baseline `drift_schemas/drift_schema_v1.json` committed in Phase 2 with generated migration-test scaffolding, so v2 has a real starting point; CHANGELOG.md started in Phase 1; Flutter upgrades go through the pin and `tool/check.sh`.

#### Pass 6: Dev environment and tooling — 3/10 → 8/10
Fixed: time-zone strategy (TASTE): the scheduler works in civil date + minutes-of-day and converts through an injected `ZoneConverter` backed by `package:timezone` with its bundled database (offline); tests construct explicit America/New_York and Europe/London transition dates; `Clock` comes from `package:clock` and is named once in ARCHITECTURE.md. Debug-only Developer screen (`kDebugMode`): seed sample semester (same deterministic fixture as tests), reset database, clock offset, force recovery screen, dump database JSON; absent from release builds. Goldens: fonts loaded in `test/flutter_test_config.dart`, golden tests tagged `golden` and run on macOS only (local and a macOS CI job); `flutter test --update-goldens --tags golden` documented. Integration: `integration_test/` journey runs locally via script; CI adds `flutter build apk --debug` and an Android emulator job (reactivecircus/android-emulator-runner) when the repo is public, otherwise the journey is a recorded manual gate per phase.

#### Pass 7: Community and ecosystem — 3/10 → 6/10
Fixed within scope: LICENSE choice and CONTRIBUTING.md deferred to Phase 9 release prep, where publishing is decided; CONTRIBUTING points to bootstrap/check. Residual: no community channel (solo project); honest 6.

#### Pass 8: DX measurement — 1/10 → 6/10
Fixed: README records the measured clone-to-run time of bootstrap on this Mac when Phase 1 lands, labeled measured with date; bootstrap prints elapsed time. Residual: no recurring audit beyond /devex-review after Phase 9.

Also accepted from the voice: magic numbers centralized in `SchedulerConfig` (with `ScoringWeights`) and `AppLimits`, injected with documented defaults (F17); the scheduler emits structured reason codes with parameters and the app renders copy (F18); notifications use inexact scheduling in v1, with manifest/AppDelegate setup steps documented and covered by the Phase 7 spike (F19).

<!-- autoplan-accepted:dx -->
- Toolchain pin: `.fvmrc` pins Flutter 3.47.7 (Dart 3.13.5, observed after the approved upgrade on 2026-10-12); pubspec sets matching `environment` SDK and Flutter constraints; CI uses subosito/flutter-action with `flutter-version-file`; README explains fvm or putting `~/development/flutter/bin` on PATH. Verify: `tool/check.sh` fails with a clear message when `flutter --version` differs from the pin.
- Codegen policy: Drift-generated files are gitignored; `tool/bootstrap.sh`, `tool/gen.sh` and CI run `dart run build_runner build --delete-conflicting-outputs`; the decision is recorded in ARCHITECTURE.md. Verify: a clean clone followed by `tool/bootstrap.sh` and `flutter analyze` reports no missing generated symbols.
- Scripts: `tool/bootstrap.sh` (version check, pub get for app and `packages/semester_scheduler`, codegen, readiness lines for Android licenses and CocoaPods with the exact fix command, exit 0 when Android work is possible, prints elapsed time), `tool/check.sh` (format check, analyze, `flutter test`, scheduler `dart test` with `TZ=America/New_York`), `tool/gen.sh`, `tool/test_integration.sh <device-id>`. CI runs `tool/check.sh` and `flutter build apk --debug`. Verify: CI workflow invokes the scripts, not ad-hoc commands; README Test section names them.
- Stack conventions recorded in ARCHITECTURE.md (taste): Riverpod 3 without code generation, GoRouter with route-name constants, `flutter_lints`, `package:clock` for time, `package:timezone` (bundled database, offline) for zone conversion; Drift is the only code generator. A unit test fails if any file under a feature's `presentation/` imports that feature's `data/` layer or any `drift` symbol. Verify: the layer test exists and passes.
- Time-zone model: the scheduler package computes in civil date + minutes-of-day and converts through an injected `ZoneConverter`; DST tests construct explicit America/New_York and Europe/London transition dates and do not depend on the host zone. Verify: the DST tests pass with `TZ=UTC` and `TZ=Asia/Manila`.
- Errors: `core/errors/` defines a typed failure hierarchy with stable codes `SEM-<AREA>-<NNN>`; docs/ERRORS.md lists code, user message, cause and fix for every failure; Copy diagnostics includes codes; each backup rejection test asserts its code. A ring buffer keeps the last 200 error and lifecycle events without task or subject content, shown under Show details. Verify: unit test that every failure class has a docs/ERRORS.md row (parsed in the test); ring-buffer test with seeded content asserts no titles appear.
- Test-precision replacements for CEO obligations: "Reject leaves the database byte-identical" is verified by a row-identical dump of every table; the stale-proposal data version is a `DataVersion` counter row incremented in the same transaction as every repository write; the single-active-session partial unique index applies to rows where status is active or paused AND `deletedAt IS NULL`. Verify: these three tests use the stated mechanisms.
- Docs pass before Phase 1: docs/UX_FLOWS.md holds the next-action state table, empty-state and dialog copy; docs/DESIGN_SYSTEM.md holds the color hex values, type scale and warning taxonomy; docs/IMPLEMENTATION_PLAN.md folds every accepted obligation into its phase checklist under a plain feature name with its Verify clause and adds a glossary for review labels. Verify: each referenced table exists in the named doc; no phase-less obligation remains.
- ARCHITECTURE.md "How to" recipes: add a column and migration (drift_dev schema dump into committed `drift_schemas/`, generated migration tests), add a scheduler rule with tests, add a warning type, update goldens. Phase 2 commits `drift_schemas/drift_schema_v1.json`. CHANGELOG.md starts in Phase 1. Verify: recipes exist; schema file committed in Phase 2.
- Developer menu: debug-only Settings > Developer screen with seed sample semester (the same deterministic fixture used by widget and integration tests), reset database, clock offset, force recovery screen, dump database to JSON; it is compiled out of release builds. Verify: widget test that the screen is unreachable when `kDebugMode` is false (via an injected flag); fixture test shared with widget tests.
- Goldens: bundled fonts load in `test/flutter_test_config.dart`; golden tests are tagged `golden` and run on macOS only (locally and in a macOS CI job); `flutter test --update-goldens --tags golden` is documented. Verify: `flutter test --exclude-tags golden` passes on Linux CI.
- Integration journey: `integration_test/core_journey_test.dart` covers the brief's 10-step journey and runs through `tool/test_integration.sh`; CI runs it on an Android emulator job when the repo is public, otherwise each phase records a manual run with date and device. Verify: script exists; phase summaries record the actual result.
- Config objects: every tunable number (8-week cap, +60-minute guard, 50/30 notification cap, 10 MB import limit, 30-day nudge, 26 repeats, 150 ms loading threshold, string limits, 5-minute rounding, scoring weights) lives in `SchedulerConfig` (with `ScoringWeights`) or `AppLimits`, injected with documented defaults in docs/SCHEDULING_ALGORITHM.md and ARCHITECTURE.md. Verify: grep-based test that these literals do not appear outside the config files.
- Structured reasons: the scheduler package emits reason codes with parameters (for example overdue, unscheduledBeyondHorizon(date), notEnoughTime(minutes), pinnedConflict(kind)); the app's presentation layer renders the copy, including "Why here?" lines. Scheduler tests assert codes; widget tests assert copy. Verify: the scheduler package has no user-facing English strings (test scans its lib/ for string literals used as messages).
- Notifications setup: v1 uses inexact scheduling (no SCHEDULE_EXACT_ALARM); README documents the Android manifest and iOS AppDelegate steps; the Phase 7 spike covers them with the save-dialog spike. Verify: manifest has no exact-alarm permission; README section exists.
- DX measurement: when Phase 1 lands, README records the measured `tool/bootstrap.sh` + `flutter run` time on this Mac with date, labeled measured. Verify: README line exists with a date and a measured label.
- LICENSE and CONTRIBUTING.md are decided in Phase 9 (publishing choice); CONTRIBUTING points to bootstrap and check. Verify: Phase 9 checklist item.
- Docs-match checks (DX F13): tests parse docs/DESIGN_SYSTEM.md and fail if any warning type in code is missing from its taxonomy table, parse docs/SCHEDULING_ALGORITHM.md and fail if the default `ScoringWeights` differ from the documented values, and check that every `tool/*.sh` command named in README exists. Verify: each check fails when its doc row is removed.
<!-- /autoplan-accepted:dx -->

```
+====================================================================+
|              DX PLAN REVIEW — SCORECARD                             |
+====================================================================+
| Dimension            | Score  | Prior  | Trend  |
| Getting Started      | 8/10   | 2/10   | ↑      |
| API/CLI/SDK          | 8/10   | 2/10   | ↑      |
| Error Messages       | 8/10   | 4/10   | ↑      |
| Documentation        | 8/10   | 3/10   | ↑      |
| Upgrade Path         | 8/10   | 5/10   | ↑      |
| Dev Environment      | 8/10   | 3/10   | ↑      |
| Community            | 6/10   | 3/10   | ↑      |
| DX Measurement       | 6/10   | 1/10   | ↑      |
+--------------------------------------------------------------------+
| TTHW                 | <5 min target | 5-10 min (toolchain) / 30-60 fresh [estimated] |
| Competitive Rank     | Competitive (target)                         |
| Magical Moment       | designed via bootstrap readiness + debug seed|
| Product Type         | end-user app; repo workflow as DX surface    |
| Mode                 | POLISH                                       |
| Overall DX           | 6/10 (lowest 6)  | 1/10   | ↑               |
+====================================================================+
| Zero Friction: covered | Learn by Doing: covered (debug seed)         |
| Fight Uncertainty: covered (error codes) | Opinionated + Escape: covered (config objects) |
| Code in Context: covered (How-to recipes) | Magical Moments: covered |
+====================================================================+
```

```
DX IMPLEMENTATION CHECKLIST
[ ] Time to hello world < 5 min with toolchain (measured in README)
[ ] Installation is one command (tool/bootstrap.sh)
[ ] First run produces meaningful output (readiness lines + Today)
[ ] Magical moment: bootstrap readiness + debug seed
[ ] Every error has code + message + cause + fix (docs/ERRORS.md)
[ ] Script names guessable (bootstrap, check, gen, test_integration)
[ ] Every tunable has a documented default (SchedulerConfig, AppLimits)
[ ] README commands copy-paste and match scripts
[ ] How-to recipes for migrations, rules, warnings, goldens
[ ] Upgrade path: drift_schemas baseline + CHANGELOG
[ ] CI runs the same scripts
[ ] Free tooling only, no accounts required
```

**NOT in scope (DX):** melos (shell scripts suffice), custom_lint/riverpod_lint (extra tooling; layer test covers the main rule), hosted docs site, community channel.

**What already exists:** nothing in the repo; reuse Flutter's `integration_test`, Drift's `drift_dev` schema tools, `package:clock`, `package:timezone`, subosito/flutter-action.

**TODOS.md updates:** none; every finding was absorbed into accepted scope.

#### DX Implementation Tasks
- [ ] **X1 (P1, human: ~3h / CC: ~15min)** — tooling — `.fvmrc`, pubspec constraints, `tool/bootstrap.sh`, `tool/check.sh`, `tool/gen.sh`, `tool/test_integration.sh`
  - Surfaced by: Passes 1, 2 — F1-F4
  - Files: .fvmrc, pubspec.yaml, tool/
  - Verify: clean clone → bootstrap → check green
- [ ] **X2 (P1, human: ~1d / CC: ~30min)** — scheduler — ZoneConverter + package:timezone + DST tests independent of host zone
  - Surfaced by: Pass 6 — F14
  - Files: packages/semester_scheduler/
  - Verify: `TZ=UTC` and `TZ=Asia/Manila` runs both pass
- [ ] **X3 (P1, human: ~4h / CC: ~20min)** — errors — failure hierarchy, codes, docs/ERRORS.md, ring buffer
  - Surfaced by: Pass 3 — F7, F8
  - Files: lib/core/errors/, docs/ERRORS.md
  - Verify: ERRORS.md coverage test
- [ ] **X4 (P1, human: ~4h / CC: ~20min)** — docs — inline tables into UX_FLOWS/DESIGN_SYSTEM, fold obligations into phases, glossary, How-to recipes
  - Surfaced by: Pass 4 — F10-F12
  - Files: docs/
  - Verify: no dangling references
- [ ] **X5 (P2, human: ~4h / CC: ~20min)** — dev menu — debug Developer screen with shared seed fixture
  - Surfaced by: Pass 6 — F15
  - Files: lib/features/settings/, test/fixtures/
  - Verify: release-flag test
- [ ] **X6 (P2, human: ~2h / CC: ~10min)** — tests — golden config, tags, macOS-only job
  - Surfaced by: Pass 6 — F16
  - Files: test/flutter_test_config.dart, .github/workflows/ci.yml
  - Verify: Linux CI passes with goldens excluded
- [ ] **X7 (P2, human: ~3h / CC: ~15min)** — config — SchedulerConfig/AppLimits and structured reason codes
  - Surfaced by: F17, F18
  - Files: packages/semester_scheduler/lib/, lib/core/
  - Verify: literal-scan and no-English-strings tests

### Eng review (Phase 3 of /autoplan, runs last)

**Scope gate:** /autoplan selected the active plan: docs/IMPLEMENTATION_PLAN.md (reviewed through the eng snapshot of its Implementation plan section).

#### Step 0: Scope Challenge

What already exists: no repository code (greenfield). Reuse targets: Flutter SDK widgets, Drift (2.34.x) migration tooling and `customStatement`, SQLite triggers, partial indexes and `VACUUM INTO`, Dart `Isolate.run`, `package:clock`, `package:timezone`, Riverpod 3.4.x, go_router 17/18 ([pub.dev riverpod changelog](https://pub.dev/packages/riverpod/versions/3.4.1/changelog), [drift score page](https://pub.dev/packages/drift/versions/2.34.2/score), [go_router docs](https://pub.dev/documentation/go_router/latest/)). Riverpod's changelog notes a possible 4.0 soon, so the constraint stays `^3`.

Complexity check: far more than 8 files and 2+ new services (estimated: ~120 Dart files in lib/, ~15 in the scheduler package, ~60 test files) [estimated]. Gate B: /autoplan override "never reduce", so no feature cuts. Structure question auto-decided: original arrangement (feature-first layers + separate pure scheduler package), because no smaller arrangement keeps the scheduler purity test and the layer test. Scope record: feature answers none (no cuts proposed); structure: original arrangement (auto-decision, /autoplan P2); accepted scope: all accepted CEO, design and DX obligations; pending remedies: none. **Scope Challenge result: scope accepted as-is.**

TODOS cross-reference: nothing in TODOS.md blocks v1; the Term entity (TODOS Data) needs schema v1 to stay additive (nullable future `termId`), which it does.

Distribution check: Android debug APK in CI, release via Play closed testing or sideload (Phase 9); iOS simulator builds locally; device builds need a signing team. Deferred: store submission automation.

REALITY: premise-table finding 3 environment premises re-checked on the upgraded SDK: Flutter 3.47.7/Dart 3.13.5 [measured: flutter --version]; Swift Package Manager defaults on [measured: flutter config --help], so the CocoaPods blocker narrows to plugins without SwiftPM support; Android licenses still pending; unverified=0 docs/IMPLEMENTATION_PLAN.md:13
REALITY: already-done pass zero commits, no remote; nothing exists to duplicate docs/IMPLEMENTATION_PLAN.md:12
REALITY: surface-check pass `flutter create --org/--platforms` and `flutter doctor --android-licenses` exist in 3.47.7 --help output docs/IMPLEMENTATION_PLAN.md:19
REALITY: binding-decisions pass BD1-BD3 honored (git on main, Flutter upgraded, no office-hours); no default reintroduced docs/IMPLEMENTATION_PLAN.md:203
REALITY: numbers finding all thresholds remain [estimated] heuristics; package versions from search snippets are [re-measure before gate] with `flutter pub outdated` in Phase 1 docs/IMPLEMENTATION_PLAN.md:31
REALITY: deferred-asks pass every brief requirement retained; only reviewer additions were deferred to TODOS.md docs/IMPLEMENTATION_PLAN.md:198
REALITY: pr-count pass no ship policy; default one PR per wave; local repo with no remote docs/IMPLEMENTATION_PLAN.md:186

#### Dual voices

Claude eng subagent: completed (agent ac32fa43af2151af9), INPUT `eng 93c7b83a…59be3` matched the snapshot; 25 findings (5 high, 11 medium, 9 low). Codex: unavailable (not installed). `[subagent-only]`.

```
ENG DUAL VOICES — CONSENSUS TABLE:
  Dimension                           Claude  Codex  Consensus
  1. Architecture sound?               yes, with H1-H5 gaps  N/A  N/A
  2. Test coverage sufficient?         no (10 gaps)          N/A  N/A
  3. Performance risks addressed?      partly (isolate)      N/A  N/A
  4. Security threats covered?         partly (M7, M8)       N/A  N/A
  5. Error paths handled?              partly (H4, M2)       N/A  N/A
  6. Deployment risk manageable?       yes (M11 CI budget)   N/A  N/A
Outside voice unavailable: Consensus N/A. Single-voice highs: H1-H5.
```

#### Section 1: Architecture

```
  ┌──────────────────────────── Flutter app (lib/) ─────────────────────────────┐
  │ app/: router (go_router, route-name consts), theme tokens, ProviderScope     │
  │        (retry: none for UI providers, 1 for DB reads)                        │
  │                                                                              │
  │ features/*/presentation ──watch──▶ features/*/application (Riverpod 3)       │
  │        │ (layer test: no data/ or drift imports)        │                    │
  │        ▼                                                ▼                    │
  │ core/widgets, WarningRow,                PlanService ─Isolate.run─▶ packages/semester_scheduler
  │ ErrorState, MiniSessionBar               SessionService               (pure Dart, civil time,
  │                                          BackupService                 reason codes, no ids)
  │                                          ProposalDiff (id matching)         ▲
  │                                                │                            │ SchedulerInput
  │                                                ▼                            │ (sendable)
  │ features/*/data repositories ──▶ core/database (Drift AppDatabase)          │
  │        │ base query filters deletedAt         │ triggers bump DataVersion   │
  │        ▼                                      ▼ on scheduler-input tables   │
  │  SQLite file (WAL) ◀── DbGuard: user_version + quick_check before Drift ────┘
  │        │                                                                     │
  │        ├── recovery screen (Restore / Start fresh: move db+wal+shm)          │
  │        └── VACUUM INTO .bak before migrations                                │
  │ core/errors (codes) ──▶ ring buffer (code, type, frames only) ──▶ diagnostics│
  └──────────────────────────────────────────────────────────────────────────────┘
       NotificationService (Phase 7, inexact, cap 50/30d) ◀── PlanService events
```

```
  Session timing (H1):
  planned ──start──▶ active{startedAt=now, segmentStartedAt=now}
  active ──pause──▶ paused{accumulatedSeconds += now-segmentStartedAt (clamped ≥0), segmentStartedAt=null}
  paused ──resume─▶ active{segmentStartedAt=now}
  active|paused ──complete/skip──▶ completed|skipped{endedAt=now, actualMinutes=round(accumulated/60) or user-edited}
  elapsed = accumulatedSeconds + (segmentStartedAt != null ? now - segmentStartedAt : 0), never persisted per tick

  Accept (H2/H3):  proposal{generatedAt, dataVersion}
   Accept txn: if DataVersion != proposal.dataVersion → refuse (stale)
               if now > min(first proposed start, first existing planned start in horizon ≥ generatedAt) → refuse (time passed)
               delete unpinned planned with plannedStart ≥ generatedAt in horizon; insert proposed; commit
```

Findings H1-H5 and M1-M6, M9 accepted (see block). Rollback posture unchanged: forward-only builds, `.bak` via VACUUM INTO, recovery screen.

#### Section 2: Code quality

Accepted: centralized `deletedAt` filtering (M1), ProposalDiff as its own unit with a documented matching rule (M5), explicit Riverpod retry policy (M9), workable replacements for the literal-scan and string-scan tests (M10), `PlatformDispatcher.instance.onError` for global errors (low). No shared-code extraction proposals (no existing code; rubric needs two verified callers).

#### Section 3: Test review

Framework: none yet (greenfield); planned `flutter_test`, `test` (scheduler package), `integration_test`. No LLM/prompt code, so no eval suites.

```
CODE PATHS                                               USER FLOWS
[+] packages/semester_scheduler                          [+] Core journey (brief §12)
  ├── scoring (weights, gradeWeight, overdue) [GAP→unit] ├── [GAP] [→E2E] create subject→task→availability→plan
  ├── slot expansion (civil time, DST, exceptions)[GAP]  │        →start→complete/skip→review→restart (simulated
  ├── allocation (limits, breaks, pinned, horizon)[GAP]  │        in integration_test + manual cold restart)
  ├── capacity whole-term + reasons           [GAP→unit] ├── [GAP] Accept after time passes (H2)
  └── determinism (identical input twice)     [GAP→unit] ├── [GAP] Proposal valid after theme change; stale after task edit (H3)
[+] lib/features/planner/application                     ├── [GAP] Travel Manila→New York, deadline intact (H5)
  ├── PlanService.generate (Isolate.run)      [GAP→unit] ├── [GAP] Delete task with active session + undo (M2)
  ├── PlanService.accept (DataVersion, generatedAt)[GAP] ├── [GAP] Study now overlapping a planned session (M3)
  └── ProposalDiff (added/moved/removed)      [GAP→unit] └── [GAP] Welcome back after 3 missed
[+] lib/features/sessions/application                    [+] Backup
  ├── start/pause/resume/complete/skip        [GAP→unit] ├── [GAP] round trip incl. subject deleted "keep tasks" (M1)
  ├── elapsed (restart, clock back, midnight, 20 cycles) │  ├── [GAP] file with 2 active / overlapping sessions (M8)
  └── long-running guard                      [GAP→unit] └── [GAP] diagnostics after malformed import, no titles (M7)
[+] lib/core/database                                    [+] Recovery
  ├── schema snapshot v1 + partial index      [GAP]      ├── [GAP] WAL fixture with uncheckpointed WAL (H4)
  ├── triggers bump DataVersion               [GAP]      └── [GAP] header-valid corrupt file → runtime routing (H4)
  └── DbGuard quick_check / user_version      [GAP]
[+] Perf: 200 tasks × 16 weeks under 500 ms in CI [GAP→benchmark test]

COVERAGE: 0/32 paths tested (greenfield; every path has a planned test below)
QUALITY: planned ★★★ for scheduler, sessions, accept, backup; ★★ for layout widget tests
```

Value cards (critical paths):
- Value: protects=Accept never creates overlapping sessions; fails_when=cutoff uses accept-time now instead of generatedAt; why_new=no prior test covers time passing between generate and accept; seam=none (fake clock already required); no_claim=none beyond protects
- Value: protects=elapsed survives restart and pause/resume without drift; fails_when=accumulation moves to integer minutes or per-tick writes; why_new=no timing columns existed before; seam=none; no_claim=real process kill (simulated restart; manual cold restart per phase)
- Value: protects=deadline civil time survives zone change; fails_when=deadlines stored as UTC instants; why_new=DST tests did not cover travel; seam=none (ZoneConverter injected); no_claim=OS zone detection on device (simulated offset change)
- Value: protects=recovery never mixes a stale WAL with a new database; fails_when=Start fresh renames only the main file; why_new=no WAL fixture existed; seam=none; no_claim=none beyond protects
- Value: protects=proposal stays valid after non-input writes; fails_when=DataVersion bumped by settings/theme writes; why_new=prior design counted every write; seam=none; no_claim=none beyond protects

Test plan artifact written to `docs/reviews/2026-10-12-eng-test-plan.md`. Tests made obsolete by this plan: none (no existing tests).

#### Section 4: Performance

Scale [estimated]: ~500 tasks and ~2,000 sessions per term; 10x = 5,000 tasks over a 6-month term. Findings: scheduler and import JSON parsing must run off the UI isolate (M6); whole-term capacity check is O(days × windows + tasks), bounded by a 200-task/16-week benchmark under 500 ms in CI; indexes from the CEO review stand, with partial index `one_live_session` and composite (taskId, status) for remaining-effort sums; insights aggregate in SQL. No N+1 risk if task lists join subjects in one query (rule recorded in ARCHITECTURE.md).

#### Failure modes (new paths)

```
  CODEPATH              | FAILURE MODE                          | TESTED? | HANDLED? | USER SEES
  PlanService.accept    | time passed since generate            | planned | yes      | "Your plan changed. Regenerate?"
  Session elapsed       | device clock moved back               | planned | clamp ≥0 | correct elapsed
  DbGuard               | uncheckpointed WAL / runtime corrupt  | planned | yes      | recovery screen
  Deadline storage      | zone change                           | planned | civil    | same local deadline
  Task delete           | active session present                | planned | prompt   | finish/skip first
  Study now             | overlaps planned session              | planned | supersede| "plan needs attention"
  Import                | invariant-violating file              | planned | code     | named problem
  Diagnostics           | exception text with content           | planned | sanitize | codes only
  Scheduler             | slow at 10x                           | planned | isolate  | inline progress
```
Critical gaps: 0 (every row has planned handling and a test).

#### Worktree parallelization strategy

| Step | Modules touched | Depends on |
|---|---|---|
| A. Scheduler package | packages/semester_scheduler | — |
| B. Database + repositories | lib/core/database, features/*/data | — |
| C. Theme + shell + docs | lib/app, lib/core/widgets, docs/ | — |
| D. Plan/session services | features/planner, features/sessions application | A, B |
| E. Screens | features/*/presentation | C, D |
| F. Backup/notifications | features/settings, core | B |

Lane A: A (independent). Lane B: B → F. Lane C: C. Launch A + B + C in parallel; merge; then D; then E with F in parallel. Conflict flag: `core/` is touched by B, C and F, so merge B before F and keep C to `core/widgets` only.

**NOT in scope (eng):** sync, desktop/web builds, store submission automation, exact-alarm notifications, recurrence engine, drag-to-move.

**What already exists:** nothing in the repo; reuse is limited to SDK and package features listed in Step 0.

**TODOS.md (collected from all phases):** 9 items already written (Planner .ics export; Capture .ics import and syllabus paste; Onboarding sample semester; Data term entity; Platform home widget, device calendar, web/desktop, on-device model). No new eng TODOs: every eng finding was accepted into v1 scope.

<!-- autoplan-accepted:eng -->
- Session timing (H1): Study sessions add `startedAt`, `endedAt`, `segmentStartedAt` (nullable, UTC epoch) and `accumulatedSeconds` (int, default 0) in schema v1. Elapsed = accumulatedSeconds + (now − segmentStartedAt when active), clamped to ≥ 0 when the device clock moves back; nothing is written per tick. Completing or skipping sets `endedAt` and `actualMinutes` (rounded from seconds, or the user's edited value). The scheduler treats an active session's interval [segmentStartedAt, max(plannedEnd, now + remaining planned minutes)] as busy. Replacement for the weekly-review "Studied" and insights attribution: use `startedAt` when present, else plannedStart. Verify: tests for restart while active and while paused, clock moved back 10 minutes, a session spanning midnight, and 20 pause/resume cycles with zero drift.
- Accept cutoff (H2): a proposal stores `generatedAt`; Accept replaces unpinned planned sessions with plannedStart ≥ generatedAt in the horizon, and refuses with "Your plan changed. Regenerate?" when now has passed the earliest proposed start or the start of any existing planned session in the horizon that began after generatedAt. Verify: test generating at 15:00 with an existing 15:10 session, accepting at 15:12, asserting refusal and no overlap; test accepting at 15:01 succeeds.
- DataVersion scope (H3, replaces the DX "every repository write" wording): the counter is bumped by SQLite AFTER INSERT/UPDATE/DELETE triggers on tasks, study_sessions, availability, availability_exceptions and on updates to the scheduling columns of settings only; theme, notification, backup-nudge, export-time and calibration writes do not bump it. Starting or pausing a session does bump it only when it changes plannedStart/plannedEnd or status of a planned session. Verify: tests that a theme change and a nudge dismissal leave a proposal acceptable, and a task edit makes it stale.
- Database safety (H4): before Drift opens the file, a DbGuard reads `PRAGMA user_version` and runs `PRAGMA quick_check` through raw sqlite3; pre-migration backups use `VACUUM INTO` to `semesteros.db.bak`; "Start fresh" moves the main file and its `-wal`/`-shm` files together; a runtime SqliteException with a corrupt or not-a-database result code routes to the recovery screen. Verify: fixtures for a WAL-mode database with an uncheckpointed WAL, a header-valid corrupted file, and a newer `user_version`.
- Time storage (H5): deadlines, availability and exceptions are stored as civil values (ISO date text plus minutes-of-day integers); only session instants are stored as UTC epoch. The app's ZoneConverter uses Dart local DateTime construction (OS time-zone rules); `package:timezone` is used in scheduler tests and for notification scheduling. Zone changes are detected on resume by comparing `timeZoneOffset` and `timeZoneName`. DST rules: a nonexistent local time moves forward to the first valid minute, an ambiguous local time uses the earlier occurrence, and durations are real elapsed minutes. Verify: travel test (Manila to New York) keeps a 23:59 deadline at 23:59 local; DST tests assert the three rules.
- Notification time zones (taste): Phase 7 adds `flutter_timezone` only if `zonedSchedule` needs the IANA name, after the license/maintenance check, otherwise schedules from computed UTC instants. Verify: Phase 7 spike records the choice and its license.
- Soft-delete consistency (M1): "Keep its tasks without a subject" sets subjectId to null and keeps an in-memory undo token; all reads go through a repository base query (or SQL views) that filters deletedAt. Export runs the import validator before writing. Verify: test that the scheduler input builder excludes deleted rows; export→import round-trip after deleting a subject with "keep tasks".
- Active-session deletion (M2): deleting a task with an active or paused session first asks to finish or skip it; Undo never restores a session as active (restores as paused, or completed if it was completed). Verify: delete + start another + Undo succeeds without violating the single-live-session index.
- Study now (M3): ad-hoc sessions are exempt from the outside-availability conflict; on start, any planned session they overlap is shortened or marked superseded and "plan needs attention" is raised. Verify: test with Study now overlapping a planned session.
- Effort formula clarifications (M4): only pinned sessions with plannedStart ≥ now are subtracted; any planned session after its task's deadline is flagged as a conflict, and a deadline change triggers regeneration of that task's full span in the next proposal. Verify: tests for a missed pinned session and for a deadline moved earlier.
- Proposal diff (M5): the scheduler emits sessions without ids; ProposalDiff matches by same task and nearest start (greedy by time) and labels moved when the start differs; ids are assigned in the app. Verify: ProposalDiff unit tests; scheduler determinism test compares outputs without ids.
- Isolates and performance (M6): generation runs via `Isolate.run` with sendable inputs; import JSON parsing runs off the UI isolate; a benchmark test with 200 tasks over a 16-week term must finish under 500 ms on CI. Verify: benchmark test in the scheduler package.
- Diagnostics sanitizing (M7): the ring buffer and last-error record store failure code, exception type and stack frames only, never `toString()` of foreign exceptions. Verify: malformed-backup and constraint-violation tests built from seeded content show no titles in diagnostics.
- Import invariants (M8): import validation also checks milestone→task references, duplicate ids, availability endTime > startTime, no overlapping sessions, and at most one active/paused session; active sessions are normalized to paused on export; after import, notifications are re-planned and undo tokens cleared. Verify: one rejection test per invariant with its code.
- Riverpod policy (M9): ProviderScope sets retry none for UI providers and one retry for database reads; timer state derives from persisted timestamps, not listener ticks; both documented in ARCHITECTURE.md. Verify: test that a failing provider shows ErrorState without retries and records one diagnostics entry.
- Test replacements (M10, replaces the DX literal-scan and string-scan checks): a test asserts every `SchedulerConfig`/`AppLimits` field is documented and matches the value wired into providers; the scheduler string scan allowlists exception and assert messages. Verify: both tests exist.
- CI budget (M11, replaces the DX "macOS CI job" for goldens): goldens run locally on macOS, and in CI only when the repository is public; README states this. Verify: workflow condition present.
- Low items: partial unique index `one_live_session` created via customStatement on `study_sessions((1)) WHERE status IN ('active','paused') AND deleted_at IS NULL` and included in the schema snapshot; the developer route is gated by `const kDebugMode` (test flag never replaces it) and the clock offset never persists; global errors use `PlatformDispatcher.instance.onError`; Phase 7 handles Android 13+ POST_NOTIFICATIONS, a boot receiver, payload id validation and cold-start routing from a notification; the significant-effort trigger is evaluated when a session completes or is skipped; undo tests compare rows excluding updatedAt and deletedAt; the integration journey simulates restart by disposing the ProviderContainer and reopening the database, with one real cold restart checked manually per phase; README wording says platform backups may send the database to the user's own Google or iCloud account while the app sends nothing. Verify: each item has its test or checklist line.
- Toolchain correction (replaces the CEO PR5 wording): Flutter 3.47.7 enables Swift Package Manager by default (`flutter config --help`), so CocoaPods is needed only for plugins without SwiftPM support; Phase 1 runs `flutter build ios --simulator --no-codesign` with the chosen plugins and records whether CocoaPods is still required; README Known limitations reflects the measured result. Verify: Phase 1 summary records the build result.
<!-- /autoplan-accepted:eng -->

#### Eng Implementation Tasks
- [ ] **G1 (P1, human: ~1d / CC: ~30min)** — data — timing columns, civil-time storage, partial index, triggers, DbGuard
  - Surfaced by: H1, H3, H4, H5, low
  - Files: lib/core/database/
  - Verify: schema snapshot, WAL fixtures, trigger tests
- [ ] **G2 (P1, human: ~1d / CC: ~30min)** — planner — Accept cutoff with generatedAt, ProposalDiff, Isolate.run, benchmark
  - Surfaced by: H2, M5, M6
  - Files: lib/features/planner/application/, packages/semester_scheduler/
  - Verify: 15:00/15:12 timeline test, diff tests, benchmark
- [ ] **G3 (P1, human: ~1d / CC: ~30min)** — sessions — elapsed model, active-delete guard, Study now supersede
  - Surfaced by: H1, M2, M3
  - Files: lib/features/sessions/
  - Verify: restart/clock/midnight/20-cycle tests
- [ ] **G4 (P1, human: ~4h / CC: ~20min)** — backup — invariant validation, active→paused normalization, sanitized diagnostics
  - Surfaced by: M7, M8, M1
  - Files: lib/features/settings/, lib/core/errors/
  - Verify: rejection tests per invariant
- [ ] **G5 (P2, human: ~2h / CC: ~10min)** — config — Riverpod retry policy, config-doc test, CI golden condition, SwiftPM check
  - Surfaced by: M9, M10, M11, toolchain
  - Files: lib/app/, .github/workflows/ci.yml, README.md
  - Verify: tests and Phase 1 iOS build record

**Completion summary (eng):**
- Step 0: Scope Challenge — scope accepted as-is
- Reality rows: 7/7 applicable rows emitted, 0 unverified premises
- Architecture Review: 9 issues found (H1-H5, M1-M3, M6)
- Code Quality Review: 5 issues found (M5, M9, M10, two low)
- Test Review: diagram produced, 32 gaps identified (all greenfield, all with planned tests)
- Performance Review: 2 issues found (isolate, benchmark)
- NOT in scope: written
- What already exists: written
- TODOS.md updates: 0 new items proposed (9 collected from earlier phases)
- Failure modes: 0 critical gaps flagged
- Unresolved decisions: 0 in this review (User Challenges UC1/UC2 wait for the final gate)
- Outside voice: codex unavailable (not installed); native subagent completed
- Parallelization: 3 lanes, 3 parallel / 3 sequential steps
- Lake Score: N/A (no coverage-scored questions asked)
