# SemesterOS Architecture

Status: design document written in Phase 0 (2026-10-12). No application code exists yet. Every section describes the target; implementation phases must keep it accurate.

## 1. Principles

1. **Offline and free.** Every core feature works with no network, no account, no API key. The app never sends academic or personal data anywhere.
2. **Pure scheduler.** The scheduling engine is a pure Dart package with no Flutter, Drift or platform imports. Same input, same output.
3. **One way in to the database.** Only repositories touch Drift. Presentation code never imports `data/` or Drift.
4. **Never silently change the plan.** Generated plans are proposals; only an explicit Accept writes them, atomically.
5. **Explicit over clever.** Boring, proven packages; one code generator (Drift); small files with one job.

## 2. Repository layout

```
semester-os/
  lib/
    main.dart                 bootstrap: DbGuard, ProviderScope, error hooks
    app/                      app.dart, router.dart (route-name constants), theme/ (tokens)
    core/
      database/               AppDatabase (Drift), tables, triggers, DbGuard, migrations
      errors/                 Failure hierarchy with SEM-* codes, ring buffer, diagnostics
      time/                   Clock provider, ZoneConverter (device), civil date/time types
      config/                 AppLimits (app-level tunables)
      widgets/                AppScaffold, AdaptiveNavigation, PageHeader, EmptyState, ErrorState,
                              WarningRow/WarningBadge, MiniSessionBar, PrimaryActionButton
    features/
      onboarding/ dashboard/ subjects/ tasks/ planner/ availability/
      sessions/ insights/ settings/
        <feature>/presentation/   screens, widgets (no data/ or drift imports)
        <feature>/application/    Riverpod providers, services (PlanService, SessionService, ...)
        <feature>/domain/         entities, value objects, pure rules
        <feature>/data/           repositories over core/database
  packages/
    semester_scheduler/       pure Dart: inputs, scoring, slot expansion, allocation,
                              capacity check, reason codes, SchedulerConfig
  test/                       unit + widget tests (fixtures/ shared seed data)
  integration_test/           core journey
  drift_schemas/              committed schema snapshots (drift_schema_v1.json from Phase 2)
  tool/                       bootstrap.sh, check.sh, gen.sh, test_integration.sh
  docs/                       this folder
```

## 3. Component diagram

```
  ┌──────────────────────────── Flutter app (lib/) ─────────────────────────────┐
  │ app/: router, theme tokens, ProviderScope (retry policy)                     │
  │                                                                              │
  │ features/*/presentation ──watch──▶ features/*/application (Riverpod 3)       │
  │        │ layer test: no data/ or drift imports            │                  │
  │        ▼                                                  ▼                  │
  │ core/widgets                          PlanService ──Isolate.run──▶ packages/semester_scheduler
  │                                       SessionService                (pure Dart, civil time,
  │                                       BackupService                  reason codes, no ids)
  │                                       ProposalDiff                        ▲
  │                                            │                              │ SchedulerInput
  │                                            ▼                              │ (plain, sendable)
  │ features/*/data repositories ──▶ core/database (Drift AppDatabase) ───────┘
  │        base query filters deletedAt       triggers bump DataVersion
  │                                                                              │
  │ SQLite file (WAL) ◀── DbGuard: user_version + quick_check before Drift opens │
  │        ├── recovery screen (Restore / Start fresh moves db + -wal + -shm)    │
  │        └── VACUUM INTO semesteros.db.bak before any migration                │
  │ core/errors ──▶ ring buffer (code, type, frames only) ──▶ Settings > About   │
  └──────────────────────────────────────────────────────────────────────────────┘
       NotificationService (Phase 7) ◀── PlanService "plan accepted" events
```

Dependency rules (enforced by a unit test that scans imports):
- `presentation/` may import `application/`, `domain/`, `core/widgets`, `app/theme`. Never `data/`, never `package:drift`.
- `application/` may import `domain/`, `data/`, `core/*`, `packages/semester_scheduler`.
- `domain/` imports only Dart core and `packages/semester_scheduler` value types.
- `packages/semester_scheduler` imports only Dart core, `package:clock`/`package:timezone` in tests. No Flutter.

## 4. Stack and versions

Pinned toolchain: **Flutter 3.47.7, Dart 3.13.5** (observed after the 2026-10-12 upgrade). `.fvmrc` pins it; CI reads the same file.

| Package | Use | Resolved (Phase 1, 2026-10-12) | License | Account/service needed |
|---|---|---|---|---|
| drift / drift_dev / build_runner | SQLite ORM, codegen | 2.35.2 / 2.35.1 / 2.16.2 | MIT / MIT / BSD-3 | none |
| sqlite3 | native SQLite (bundled by the package's build hook; `sqlite3_flutter_libs` is end-of-life and not used) | 3.7.0 | MIT | none |
| flutter_riverpod | state | 3.4.3 (stay on ^3; 4.0 may come) | MIT | none |
| go_router | navigation | 18.0.2 | BSD-3 | none |
| path_provider / path | database location | 2.1.6 / 1.9.1 | BSD-3 | none |
| clock | injectable time | 1.1.3 | Apache-2.0 | none |
| timezone (scheduler dev dependency) | IANA rules for tests | 0.11.2 | BSD | none |
| uuid | ids | 4.6.0 | MIT | none |
| intl | dates, numbers | 0.20.3 | BSD-3 | none |
| fl_chart | insights charts | 1.2.0 | MIT | none |
| flutter_lints | lints | 6.0.0 | BSD-3 | none |
| flutter_local_notifications | reminders | added in Phase 7 | BSD-3 (re-check then) | none |
| file save/pick | backup export/import | chosen in Phase 7 spike | to verify | none |

Licenses, pub points and publishers were checked on pub.dev (API `/api/packages/<name>` and `/score`) before adding each package; `timezone` reports no score, so its LICENSE file was read directly (BSD, Dart team). Each later package gets the same check.

Conventions:
- Riverpod 3 **without** code generation. ProviderScope sets `retry: null` for UI providers and at most one retry for database reads. Timer state derives from persisted timestamps, never from ticking listeners.
- GoRouter with route-name constants in `app/router.dart`; no typed-route codegen.
- `flutter_lints` (+ project rules in `analysis_options.yaml`).
- Drift is the only code generator. Generated files are gitignored and rebuilt by `tool/bootstrap.sh`, `tool/gen.sh` and CI (`dart run build_runner build --delete-conflicting-outputs`).

## 5. Database design (schema v1)

Schema v1 holds every column v1 needs, so v1 ships at schema version 1 with no follow-up migration. All ids are UUID v4 text. Timestamps (`createdAt`, `updatedAt`, `deletedAt`, session instants) are UTC epoch milliseconds. **Civil values** (deadlines, availability, exceptions) are stored as ISO date text plus minutes-of-day integers so they mean the same local time after a time-zone change.

| Table | Columns |
|---|---|
| `subjects` | id, name (≤100), courseCode? (≤20), colorIndex (0-9, subject palette), createdAt, updatedAt, deletedAt? |
| `tasks` | id, subjectId? → subjects, title (≤200), description? (≤5000), type (assignment, project, quiz, exam, reading, other), deadlineDate (ISO date), deadlineMinute (0-1439; date-only entry = 1439 = 23:59), estimatedMinutes, priority (low, medium, high; default medium), gradeWeightPct? (0-100), status (incomplete, inProgress, completed), completedAt?, createdAt, updatedAt, deletedAt? |
| `milestones` | id, taskId → tasks, title (≤200), isCompleted, sortOrder, createdAt, updatedAt, deletedAt? |
| `availability` | id, dayOfWeek (1-7, ISO), startMinute, endMinute (> startMinute), isEnabled, createdAt, updatedAt, deletedAt? |
| `availability_exceptions` | id, date (ISO), startMinute, endMinute, note? (≤200), createdAt, updatedAt, deletedAt? |
| `study_sessions` | id, taskId → tasks, plannedStart, plannedEnd (UTC epoch), status (planned, active, paused, completed, skipped), isPinned (default false), isAdHoc (default false), startedAt?, endedAt?, segmentStartedAt?, accumulatedSeconds (default 0), actualMinutes?, createdAt, updatedAt, deletedAt? |
| `settings` | single row (id = 1): preferredSessionMinutes, breakMinutes, dailyLimitMinutes, themeMode, notificationsEnabled, showTaskNamesInNotifications, weekStartDay (default 1 = Monday), defaultEstimate{Assignment 120, Project 360, Quiz 90, Exam 240, Reading 60, Other 60}, significantDiffPct (25), significantDiffMinutes (30), examRevisionDays (7), lastSuccessfulExportAt?, backupNudgeDismissedAt?, onboardingCompletedAt?, updatedAt |
| `estimate_calibration` | taskType (PK), lastAppliedAt?, dismissedAtQualifyingCount? |
| `data_version` | single row (id = 1): value (int), bumped by triggers |

Constraints and indexes:
- Foreign keys on; deletes are soft (see §8), so `ON DELETE` is `RESTRICT` to catch bugs.
- `one_live_session`: `CREATE UNIQUE INDEX one_live_session ON study_sessions((1)) WHERE status IN ('active','paused') AND deleted_at IS NULL` (via `customStatement`).
- Indexes: `study_sessions(plannedStart)`, `study_sessions(taskId, status)`, `tasks(deadlineDate)`, `tasks(subjectId)`, `tasks(status)`.
- `CHECK` constraints for minute ranges, enum values and `endMinute > startMinute`.
- Triggers `AFTER INSERT/UPDATE/DELETE` on `tasks`, `study_sessions`, `availability`, `availability_exceptions`, and `AFTER UPDATE OF <scheduling columns>` on `settings`, increment `data_version.value`. Theme, notification, nudge, export-time and calibration writes do not bump it.
- The schema snapshot `drift_schemas/drift_schema_v1.json` is committed in Phase 2 and tested.

## 6. Time model

- `Clock` comes from `package:clock`, injected everywhere "now" is read. Tests use a fake clock.
- Civil values (dates, minutes-of-day) are converted to instants through a `ZoneConverter`:
  - In the app: Dart local `DateTime` construction (OS time-zone rules).
  - In the scheduler tests: `package:timezone` with explicit zones (America/New_York, Europe/London, Asia/Manila).
- DST rules: a nonexistent local time moves forward to the first valid minute; an ambiguous local time uses the earlier occurrence; durations are real elapsed minutes.
- Time-zone change detection: on app resume, compare `DateTime.now().timeZoneOffset` and `timeZoneName` with the last seen values; on change or local-date change, recompute derived state (missed sessions, Today, nudges).

## 7. Session lifecycle and timing

```
  planned ──start──▶ active{startedAt=now, segmentStartedAt=now}
  active  ──pause──▶ paused{accumulatedSeconds += max(0, now - segmentStartedAt), segmentStartedAt=null}
  paused  ──resume─▶ active{segmentStartedAt=now}
  active|paused ──complete──▶ completed{endedAt=now, actualMinutes = user value (default round(elapsed/60))}
  planned|active|paused ──skip──▶ skipped{endedAt, actualMinutes = "studied some" value or 0}
  planned with plannedEnd < now  ═▶ shown as Missed (derived, still planned in the DB)

  elapsed = accumulatedSeconds + (segmentStartedAt != null ? max(0, now - segmentStartedAt) : 0)
  Nothing is written per tick. Invalid transitions (completed→*, skipped→active, a second live
  session) are rejected by SessionStateMachine in domain, the repository transaction, and the
  one_live_session index.
```

- Long-running guard: if elapsed in the current segment exceeds planned duration + 60 minutes (including after a restart), the app asks the user to confirm the minutes before recording, prefilled with the planned duration.
- Starting a session while another is live asks to pause or finish the current one.
- Deleting a task with a live session first asks to finish or skip it. Undo never restores a session as active.
- "Study now" creates an ad-hoc pinned session (`isAdHoc = true`) starting now; ad-hoc sessions are exempt from the outside-availability conflict, and any planned session they overlap is shortened or marked superseded, raising "plan needs attention".
- Insights and weekly review attribute studied time by `startedAt` when present, otherwise `plannedStart`.

## 8. Soft delete and undo

- Subjects, tasks, milestones, sessions, availability and exceptions carry `deletedAt`. Deleting sets it in one transaction; Undo clears it (undo token held in memory, valid until navigation, snackbar 10 s).
- Every repository read goes through a base query that filters `deletedAt IS NULL`. A test asserts the scheduler input builder never sees deleted rows.
- "Keep its tasks without a subject" nulls `subjectId` on those tasks; the undo token remembers which tasks to restore.
- Tombstones are kept in v1 (no purge). This keeps deletion semantics sync-friendly for a future optional sync.

## 9. Planning flow (generate, review, accept)

```
  repositories ──▶ SchedulerInput (tasks, sessions, availability, exceptions, settings, now, horizon)
                       │  Isolate.run
                       ▼
                 semester_scheduler.plan()  ──▶ ScheduleResult (sessions without ids, unscheduled,
                       │                         warnings, reason codes)
                       ▼
                 ProposalDiff (match by task + nearest start; added / moved / removed)
                       ▼
                 Proposal { generatedAt, dataVersion, horizon, diff }
                       ▼  user taps Accept (button disabled while committing)
  Accept transaction:
    1. if data_version.value != proposal.dataVersion          → refuse "Your plan changed. Regenerate?"
    2. if now > earliest proposed start, or now > start of any existing planned session in the
       horizon that begins after generatedAt                    → refuse (time passed)
    3. soft-delete unpinned sessions with status planned and plannedStart ≥ generatedAt in horizon
    4. insert proposed sessions with new UUIDs
    5. commit; emit "plan accepted" (notifications re-plan)
  Reject / "Not now": nothing is written.
```

Triggers that raise the non-modal "Your plan needs attention" banner (never auto-generate or auto-accept): session skipped or missed, task created/edited/deleted/completed, deadline changed, availability or exception changed, significant effort difference (evaluated when a session completes or is skipped).

## 10. Errors, diagnostics and recovery

- `core/errors/` defines a sealed `Failure` hierarchy; every failure has a stable code `SEM-<AREA>-<NNN>` listed in `docs/ERRORS.md` with user message, cause and fix. A test fails if a failure class has no row.
- Global hooks: `FlutterError.onError` and `PlatformDispatcher.instance.onError` record the failure and show ErrorState (Retry / Go to Today). No silent catch-alls in features.
- Ring buffer of the last 200 error and lifecycle events. Entries hold code, exception type and stack frames only, never `toString()` of foreign exceptions (those can contain backup content or SQL).
- Settings > About: app version, schema version, database size, last error code, "Copy diagnostics".
- **DbGuard** runs before Drift opens the file: reads `PRAGMA user_version` (newer than the app → recovery screen) and `PRAGMA quick_check` (failure → recovery screen). A runtime `SqliteException` with a corrupt or not-a-database result code also routes to recovery.
- Recovery screen: Restore from backup / Start fresh (moves `semesteros.db`, `-wal` and `-shm` together to a timestamped name; nothing is deleted) / Show details.
- Before any future migration: `VACUUM INTO 'semesteros.db.bak'`.

## 11. Backup format

JSON file, `schemaVersion: 1`, containing non-deleted rows of every table plus settings and calibration (never `lastSuccessfulExportAt` or `backupNudgeDismissedAt` on import). Rules:
- Export runs the import validator on the serialized JSON before writing; active sessions are normalized to paused.
- Import: file ≤ 10 MB (checked before parsing); JSON parsed off the UI isolate; whole-file validation (schemaVersion present and supported, enums, ids unique, references resolve, string lengths, `endMinute > startMinute`, no overlapping sessions, at most one live session); confirmation naming what will be replaced (offers export first); replace-all in one transaction; on any failure nothing changes and a coded, plain-language error is shown. After import: notifications re-planned, undo tokens cleared.
- A file without `schemaVersion` is rejected as "not a SemesterOS backup"; a higher version is rejected with "made by a newer SemesterOS".

## 12. Platform notes

- Android: `allowBackup` and `dataExtractionRules` include the database so Android Auto Backup covers it (the OS may copy it to the user's own Google account; the app sends nothing). Inexact alarms only (no `SCHEDULE_EXACT_ALARM`); Android 13+ `POST_NOTIFICATIONS` asked only when reminders are turned on; boot receiver re-registers reminders.
- iOS: database in Application Support (included in device backups). Flutter 3.47.7 enables Swift Package Manager by default; Phase 1 records whether any chosen plugin still needs CocoaPods. Simulator builds need no Apple account; device builds need a signing team (a free personal team gives 7-day provisioning).

## 13. Future sync readiness

UUID ids, `updatedAt` on every row, soft-delete tombstones and a single write path through repositories mean an optional sync layer can be added later as a repository decorator plus a change feed, without rewriting features. Import stays replace-all; merge semantics belong to sync, not backup.

## 14. Developer tooling

- `tool/bootstrap.sh`: checks the pinned Flutter version, runs `pub get` for the app and the scheduler package, runs codegen, prints readiness lines (Android licenses, CocoaPods if needed) with exact fix commands, exits 0 when Android work is possible, prints elapsed time.
- `tool/check.sh`: format check, `flutter analyze`, `flutter test --exclude-tags golden` (goldens run on macOS), scheduler `dart test` with `TZ=America/New_York`.
- `tool/gen.sh`: codegen only. `tool/test_integration.sh <device-id>`: integration journey.
- CI (GitHub Actions): `tool/check.sh` + `flutter build apk --debug`; goldens and the emulator journey only while the repo is public (free minutes). README states CI status honestly.
- Debug-only Settings > Developer (gated by `const kDebugMode`): seed sample semester (same fixture as tests), reset database, clock offset (never persisted), force recovery screen, dump database JSON.

## 15. How to

**Add a column or table**
1. Edit the table in `lib/core/database/tables/`.
2. Bump `schemaVersion`, write the step in `MigrationStrategy.onUpgrade`.
3. `dart run drift_dev make-migrations` (or `schema dump` into `drift_schemas/`) and commit the new snapshot.
4. Add the generated migration test; run `tool/check.sh`.
5. Update §5 above and the backup validator if the column is exported.

**Add a scheduler rule**
1. Add the rule in `packages/semester_scheduler/lib/src/` with a reason code if it affects output.
2. Add tests in `packages/semester_scheduler/test/` (happy, edge, failure).
3. Document it in `docs/SCHEDULING_ALGORITHM.md`; tunables go in `SchedulerConfig`.

**Add a warning type**
1. Add it to the warning enum with its level (info / attention / capacity).
2. Add its row to the taxonomy table in `docs/DESIGN_SYSTEM.md` (a test compares them).
3. Add copy in the presentation layer and a widget test.

**Update goldens** (macOS only): `flutter test --update-goldens --tags golden`, review the diffs, commit.
