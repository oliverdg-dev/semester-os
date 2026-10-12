# SemesterOS Implementation Plan

> Know what matters. Know what to do next. Stay in control of your semester.

SemesterOS is a premium, offline-first study planner for Android phones and tablets, iPhones and iPads, built by a solo developer on a zero-dollar budget. This plan is the working checklist; each item has a **Verify** step that must pass, with its actual result recorded, before the phase is called done.

Companion docs: [ARCHITECTURE](ARCHITECTURE.md) · [SCHEDULING_ALGORITHM](SCHEDULING_ALGORITHM.md) · [DESIGN_SYSTEM](DESIGN_SYSTEM.md) · [UX_FLOWS](UX_FLOWS.md) · [RESPONSIVE_DESIGN](RESPONSIVE_DESIGN.md) · [ERRORS](ERRORS.md) · [TODOS](../TODOS.md) · review record: [reviews/2026-10-12-autoplan-review.md](reviews/2026-10-12-autoplan-review.md)

## Status

| Phase | State |
|---|---|
| 0. Audit and planning | **Done** (2026-10-12): repo audited, plan reviewed (CEO, design, DX, eng), all planning docs written |
| 1. Foundation | In progress |
| 2-9 | Not started |

## 0. Repository audit (2026-10-12)

| Item | Observed state |
|---|---|
| Repository | Empty at start. Local git initialized on `main`; remote `github.com/oliverdg-dev/semester-os` (public, empty before the first push). |
| Flutter SDK | Upgraded from 3.24.0 to **Flutter 3.47.7 / Dart 3.13.5** (stable, framework 2026-10-08) at `~/development/flutter` (not on the default PATH). |
| Xcode | 26.6. iOS 17.5 simulators present (iPhone SE 3, iPhone 15 family, iPad mini 6, iPad Air/Pro M2/M4, iPad 10th gen). `flutter doctor` notes the iOS 26.5 simulator runtime is not installed. |
| CocoaPods | Not installed. Flutter 3.47.7 enables Swift Package Manager by default, so CocoaPods is needed only for plugins without SwiftPM support. Phase 1 measures this with a real simulator build. |
| Android | SDK platforms 33/34/35, build-tools 35.0.0, JDK 21. Some SDK licenses are not accepted: the owner must run `flutter doctor --android-licenses` (debug builds and tests work without it). |
| Existing features | None. |

## Product framing [assumed, confirm with the owner]

- **Persona:** undergraduate with 4-6 courses, phone-first, plans on Sunday evenings, checks the phone between classes.
- **Success metric:** 5 real students use it for 3 consecutive weeks.
- **Differentiators:** (1) explained scheduling that never silently moves the plan, (2) fully private with no account, (3) estimates that learn the student's real pace.

## Binding decisions

| ID | Decision | Source |
|---|---|---|
| BD1 | Git on `main`; remote `oliverdg-dev/semester-os` | Owner, 2026-10-12 |
| BD2 | Flutter upgraded to current stable before Phase 1 | Owner, 2026-10-12 |
| BD3 | No /office-hours; the brief is the design input | Owner, 2026-10-12 |
| BD4 | Commits never list Claude as co-author; `CLAUDE.md` is local and gitignored | Owner, 2026-10-12 |

## Pending owner decisions

These came out of the review and change the brief's phase order. Until the owner decides, the original order below stands.

- **UC1:** after Phase 4, put a phone build in front of 5-10 students for about two weeks before Phase 6 polish, holding estimate calibration, weekly review and tablet master-detail until after.
- **UC2:** move a minimal "session starts in 10 minutes" reminder from Phase 7 to Phase 4 (permission edge cases stay in Phase 7).

## Non-negotiable requirements (from the brief)

- No OpenAI/Claude/Gemini cloud APIs, no paid inference, no Supabase/Firebase, no paid hosting, auth or notification services, no external APIs for core features, no dependencies needing paid accounts. Every dependency is checked for license, platform support, maintenance and account requirements before it is added.
- Offline-first: all core features work offline; data stays on the device; scheduling, analysis and rescheduling run locally in Dart; data persists across restarts; no accounts, keys or secrets; nothing transmitted externally by the app; local JSON export/import; shared Android/iOS logic; architecture ready for optional future sync.
- Publishing fees are separate from development costs and never block building or testing.
- Never claim tests passed, builds succeeded or platforms were verified without running them; record exact commands and limitations.

## Glossary

| Term | Meaning |
|---|---|
| Proposal | A generated plan shown for review; nothing is written until Accept |
| Pinned session | A session the scheduler never moves (user-pinned or edited by hand) |
| Ad-hoc session | A "Study now" session started outside the plan |
| Missed session | A planned session whose end time has passed without being started (derived, not stored) |
| Civil time | A calendar date plus minutes-of-day, independent of time zone |
| DataVersion | Counter bumped by database triggers whenever a scheduler input changes |
| Effort to schedule | Remaining effort minus time already planned in pinned or out-of-horizon sessions |
| Review labels | E1 quick add, E2 estimate calibration, E7 weekly review, E10 pinned sessions, E11 backup nudge, UC1/UC2 pending owner decisions |

## Phase checklists

### Phase 0 — Audit and planning (done)

- [x] Audit repo and toolchain; record facts in §0. Verify: §0 table.
- [x] Plan reviewed by /autoplan (CEO, design, DX, eng). Verify: review record committed.
- [x] Planning docs: ARCHITECTURE, SCHEDULING_ALGORITHM, DESIGN_SYSTEM (with measured contrast), UX_FLOWS (state table, copy), RESPONSIVE_DESIGN, ERRORS. Verify: files in `docs/`.
- [x] Every accepted review obligation folded into the phase checklists below; glossary added. Verify: no phase-less obligation remains in this file.
- [x] Deferred ideas recorded in TODOS.md.
- [x] `.gitignore` excludes `CLAUDE.md`; `CLAUDE.md` holds the no-co-author rule.

### Phase 1 — Foundation (in progress, 2026-10-12)

- [x] `flutter create --org dev.oliverdg --project-name semester_os --platforms android,ios` in the repo root; docs and `.gitignore` untouched. App id `dev.oliverdg.semester_os`.
- [x] Toolchain pin: `.fvmrc` = 3.47.7 and `environment.flutter: 3.47.7` in pubspec; README explains fvm or PATH. Verified: with `.fvmrc` set to 3.99.0, `tool/check.sh` exits 1 with "Flutter 3.47.7 is active but this repo pins 3.99.0" and the fix command.
- [x] Dependencies added with `flutter pub add` after checking each on pub.dev (license, points, publisher); ARCHITECTURE §4 updated with resolved versions. `sqlite3_flutter_libs` is end-of-life, so `sqlite3` 3.x (bundled SQLite) is used directly; `drift_flutter` not needed. `flutter pub outdated`: all direct and dev dependencies up to date.
- [x] `packages/semester_scheduler` pure Dart package with `SchedulerConfig`/`ScoringWeights`/`TaskType`/`TaskPriority`. Verified: `dart test` 8/8 (purity test: no Flutter/Drift imports, no Flutter dependency; config defaults parsed from SCHEDULING_ALGORITHM §7).
- [x] Scripts `tool/bootstrap.sh`, `tool/check.sh`, `tool/gen.sh`, `tool/test_integration.sh`.
- [ ] Clean-clone verification: fresh clone → `tool/bootstrap.sh` → `flutter analyze` with no missing generated symbols; measured time recorded in README.
- [x] Codegen policy: `*.g.dart` gitignored; bootstrap, gen and CI run build_runner.
- [x] Theme tokens in `lib/app/theme/` (light/dark palettes, semantic colors extension, subject palette, type scale, spacing, radii, motion with reduced-motion helper, width classes). Verified: `test/theme/contrast_test.dart` (every text/background pair ≥ 4.5:1, outlines and subject colors ≥ 3:1, both themes).
- [ ] Bundle IBM Plex Sans (OFL) in `assets/fonts/` and set `kAppFontFamily`; until then the platform font is used. Light/dark goldens wait for the bundled font.
- [x] App shell: GoRouter (`StatefulShellRoute`, route-name constants), AdaptiveShell (NavigationBar < 600, rail 600-839, extended rail ≥ 840), Settings in the header, quick-add and mini session bar slots that stay hidden until their features exist. Verified: widget tests at 360/700/1024 dp; no overflow at text scale 2.0 at all three widths.
- [x] ProviderScope retry policy `noRetry` (DB reads opt in to `databaseReadRetry`, used from Phase 2). Verified: failing provider evaluated once, ErrorState shown, one log entry.
- [x] Global error handling: `FlutterError.onError` + `PlatformDispatcher.instance.onError` + `ErrorLogObserver` → ring buffer (code, type, stack frames only, 200 entries); `AsyncValueView` renders ErrorState with code. Verified: tests incl. a message containing a task title that never reaches diagnostics.
- [x] Layer rule test. Verified: passes on `lib/` and catches a planted violation.
- [x] `analysis_options.yaml` (flutter_lints + strict casts/raw types + extra rules); `dart format` clean.
- [x] Drift `AppDatabase` skeleton (schema v1, no tables yet) opened through DbGuard (`quick_check`, `user_version`); minimal recovery screen with the error code. Verified: DbGuard tests (missing, healthy, not-a-database, newer version, corruption codes, Drift opens a real file).
- [x] Error catalogue test: every Failure class has a docs/ERRORS.md row.
- [x] Smoke tests: boots to Today empty state; each destination shows its documented empty state; Settings > About & diagnostics works.
- [ ] CI (GitHub Actions): workflow written (`tool/check.sh` + debug APK); verified only after its first run on GitHub.
- [x] Android debug build (`flutter build apk --debug`) result recorded. 2026-10-12: exit 0, `build/app/outputs/flutter-apk/app-debug.apk` (first run 193 s; Gradle auto-installed SDK Platform 36 and CMake 3.22.1).
- [ ] iOS simulator build (`flutter build ios --simulator --no-codesign`) result recorded; CocoaPods requirement noted. 2026-10-12: **failed (exit 1)** on this machine: Xcode 26.6 reports "iOS 26.5 is not installed" (only the iOS 17.5 simulator runtime is present). Not a project error. Fix: Xcode > Settings > Components, or `xcodebuild -downloadPlatform iOS`, then re-run. CocoaPods: not needed (the project resolves plugins through Swift Package Manager).
- [x] README stub and CHANGELOG.md.

### Phase 2 — Database and core data

- [ ] Schema v1 exactly as ARCHITECTURE §5 (all tables, columns, checks, indexes, `one_live_session` partial index, DataVersion triggers on scheduler-input tables and scheduling settings columns only). Verify: schema snapshot test lists every column; fresh DB has exactly one Settings row; trigger tests: a task edit bumps DataVersion, a theme change and a nudge dismissal do not.
- [ ] `drift_schemas/drift_schema_v1.json` committed with generated migration-test scaffolding.
- [ ] DbGuard: `user_version` and `quick_check` before Drift opens; `VACUUM INTO` backup helper; recovery screen (Restore / Start fresh moving db + -wal + -shm / Show details); runtime corrupt-code routing. Verify: fixtures for an uncheckpointed-WAL database, a header-valid corrupt file and a newer `user_version`.
- [ ] Civil-time storage for deadlines, availability and exceptions; UTC epoch for instants. Verify: travel test (Manila → New York) keeps a 23:59 deadline at 23:59 local.
- [ ] Repositories with a base query filtering `deletedAt`; soft delete + in-memory undo tokens. Verify: deleted rows disappear from every list and insight query; Undo restores them (comparison excludes updatedAt/deletedAt).
- [ ] Subjects: create, edit, delete with "Keep its tasks without a subject" (nulls subjectId, undo restores links) or "Delete its tasks too"; 0-task subjects skip the choice; color from the 10-color palette; task counts and next deadline. Verify: repository tests for both options + undo; widget test for the 0-task case.
- [ ] Tasks: create, edit, complete (sets completedAt), reopen (clears it), delete with minutes-count confirmation and Undo; live-session guard (finish or skip first). Verify: repository and widget tests incl. delete + start another + Undo without violating the live-session index.
- [ ] E1 quick add: title, deadline (date-only → 23:59 local, shown "Due {day}, end of day"), type; estimate from the type default, priority Medium, status incomplete. Verify: widget test asserts 120 min for an Assignment, Medium, incomplete.
- [ ] Planning defaults in Settings: six type defaults (15-480), weekStartDay, significantDiffPct (5-100), significantDiffMinutes (5-240). Verify: editing a default changes the next quick add; out-of-range values show field errors.
- [ ] Full task form: subject, priority, grade weight (0-100), description, milestones checklist, weekly repeat (max 26 independent tasks, live preview). Verify: 10-week repeat across a DST change has correct local deadlines; cap at 26.
- [ ] Progress = tracked minutes / estimate; milestones counted separately; status becomes in-progress on first session start.
- [ ] Unsaved-changes prompt on every form. Verify: back with edits shows "Discard changes?" and Keep editing preserves values.
- [ ] Validation inline next to fields; entered data kept on failure.
- [ ] Error hierarchy with codes per docs/ERRORS.md. Verify: test that every Failure class has an ERRORS.md row.
- [ ] Shared deterministic seed fixture in `test/fixtures/` (also used by the debug Developer menu).

### Phase 3 — Scheduling engine

All rules from SCHEDULING_ALGORITHM.md, in `packages/semester_scheduler`.

- [ ] Inputs/outputs, no ids, structured reason codes only (no user-facing English strings; string scan allowlists exception/assert messages).
- [ ] ZoneConverter + civil-time slot expansion; DST rules (forward, earlier occurrence, real durations). Verify: DST tests (America/New_York, Europe/London) pass with `TZ=UTC` and `TZ=Asia/Manila`.
- [ ] Effort to schedule (pinned with plannedStart ≥ now and out-of-horizon planned sessions subtracted). Verify: one-week run over an existing 8-week plan schedules only unallocated minutes; missed pinned session not subtracted.
- [ ] Horizon defaults (latest deadline or today+6, cap today+55), no session before now (rounded to 5 min), all-overdue case. Verify: tests for each.
- [ ] Scoring with configurable weights (urgency, priority, importance from grade weight or type, pressure) and deterministic tie-breaks. Verify: weight set/unset, two tasks differing only by weight, equal-priority tie order; config defaults match SCHEDULING_ALGORITHM §7 (doc-parse test).
- [ ] Allocation: availability minus exceptions minus busy time (pinned, ad-hoc, completed, skipped, active interval) with break padding; daily limit; session splitting; max sessions per task per day; never after the deadline; exam revision window with extension.
- [ ] E10 pinned sessions: never moved, deleted or overlapped; break spacing; count against daily limit; conflicts (availability changed, limit lowered, deadline moved before it, inside a busy time, task already complete) reported with Unpin action.
- [ ] Capacity: whole-term check without the cap; unscheduled reasons (beyondPlanningWindow / planned later, notEnoughTime, noAvailability); deadlineAtRisk; overloadedDay; termOverload; sessionAfterDeadline.
- [ ] Required scheduler tests from SCHEDULING_ALGORITHM §11, including determinism (two runs byte-equal) and no overlaps.
- [ ] `SchedulerConfig`/`AppLimits` hold every tunable. Verify: test that every field is documented and matches the value wired into providers.
- [ ] Benchmark: 200 tasks over a 16-week term under 500 ms on CI.

### Phase 4 — Dashboard, planner, sessions

- [ ] PlanService: SchedulerInput builder (excludes deleted rows), `Isolate.run` generation, ProposalDiff (match by task + nearest start; added/moved/removed). Verify: diff unit tests; generation keeps navigation usable.
- [ ] Accept transaction with DataVersion check and `generatedAt` cutoff + time-passed refusal; Reject writes nothing; Accept button disabled while committing. Verify: generate 15:00 with an existing 15:10 session, accept 15:12 → refused, no overlap; accept 15:01 → succeeds; simulated mid-accept failure leaves prior sessions intact; Reject leaves a row-identical dump; double tap commits once.
- [ ] Proposal review screen: summary line, doesn't-fit and conflict sections above Accept, week groups with "Why here?", full-screen (compact) / side panel (expanded), "Not now" on a first plan. Verify: 50-session proposal renders collapsed groups; goldens at compact and expanded.
- [ ] "Your plan needs attention" banner and triggers (skip, missed, task create/edit/delete/complete, deadline, availability/exception changes, significant effort difference at session completion/skip); "Schedule it now?" after saving a task; "Update plan" primary action. Verify: skip shows the banner and no sessions change until Accept.
- [ ] Today: hierarchy and single banner/secondary slots; the eight next-action states (UX_FLOWS §3); welcome back for 2+ missed; progress; deadlines. Verify: one widget test per state; all notices true → exactly one banner and one card; 3 missed → one summary.
- [ ] Planner layouts: compact day strip + agenda, medium 3-day, expanded 7-day grid + unscheduled tray; agenda at text scale ≥ 1.3; missed history group; no drag. Verify: widget tests at 360/700/1024 and text scale 2.0 without overflow.
- [ ] Sessions: state machine, timing columns (startedAt, endedAt, segmentStartedAt, accumulatedSeconds), elapsed model with clamping, live-session index, switch prompt, long-running guard, Complete/Skip sheets, Session timer, mini session bar. Verify: restart while active and paused, clock moved back 10 min, session spanning midnight, 20 pause/resume cycles with zero drift, +59/+61 min guard incl. after restart, bar visible after navigation and restart.
- [ ] Session detail: Pin/Unpin, Edit time (pins; blocks overlap and outside availability; warns over limit). Verify: widget tests.
- [ ] Study now: ad-hoc pinned session, exempt from availability conflict, shortens/supersedes overlapped planned session, raises banner. Verify: overlap test.
- [ ] Missed sessions derived from the clock. Verify: ±1 minute test.
- [ ] Resume recompute on resume, local date change and time-zone change (offset/name comparison). Verify: fake clock crossing midnight and an offset change.
- [ ] Availability editor: day rows with chips, Copy to weekdays, one-off busy times; onboarding presets, onboarding ending in quick add, skip default Mon-Fri 18:00-21:00 with "Edit study times". Verify: widget tests.
- [ ] Empty/loading/error/success states per DESIGN_SYSTEM §11 and UX_FLOWS §13. Verify: empty-state copy tests.
- [ ] Integration journey (simulated restart by disposing the ProviderContainer and reopening the DB) + one manual cold restart, result recorded.

### Phase 5 — Rescheduling and insights

- [ ] Significant-difference rule (≥ significantDiffPct % and ≥ significantDiffMinutes). Verify: 24/25 % and 29/30 min boundaries.
- [ ] Deadline moved earlier: sessions after the deadline flagged; task's full span regenerated in the next proposal.
- [ ] Insights: planned vs studied (attributed by startedAt, else plannedStart), workload by subject, deadline concentration, estimate vs actual, unscheduled work, work beyond available time; pinned future sessions of completed tasks excluded from planned workload; text summary per chart as semantics label; ≥ 1 studied session to show charts. Verify: widget tests with seeded literal numbers.
- [ ] E2 estimate calibration: qualifying tasks (completed after lastAppliedAt by completedAt, ≥ 1 tracked minute), ratio over completed+skipped minutes, ≥ 3 tasks, round to 5, clamp 15-480, apply sets lastAppliedAt and clears dismissal, dismissal re-offers at +3, existing tasks untouched; copy suggests a default. Verify: 0/2/3/10 tasks, exclusions, rounding, clamps, re-offer.
- [ ] E7 weekly review: Planner action + Today card on weekStartDay (hidden on dismiss or after Plan this week is accepted); last 7 days planned vs studied, coming-up deadlines with overdue listed separately, Plan this week (horizon today..today+6). Verify: literal numbers from the fixture; empty state.

### Phase 6 — Responsive design and polish

- [ ] Layouts per RESPONSIVE_DESIGN §2; master-detail rules; resize keeps selection. Verify: 1024 → 700 → 1024 test.
- [ ] Accessibility: 48 dp targets, contrast test, semantics labels on sessions/charts/icon buttons, focus order and visible focus, text scale 1.0/1.5/2.0, status never color-only, timer announcements on state change only, reduced motion. Verify: `meetsGuideline` tests on Today, Plan, Tasks, proposal.
- [ ] Undo snackbar 10 s announced to screen readers; Undo does not survive navigation; undoing a task delete with planned sessions raises the banner.
- [ ] Copy and confirmations from UX_FLOWS (delete, import, recovery, calibration).
- [ ] Simulator/emulator pass: iPhone SE 3, iPhone 15 Pro Max, iPad mini, iPad Pro 13, Android phone + tablet emulators; split screen on iPad and Android tablet; results recorded.
- [ ] Run /design-review on the running app (replaces mockups, which were skipped because the designer uses a paid API).
- [ ] Goldens run on macOS locally; in CI only while the repo is public.

### Phase 7 — Notifications and backups

- [ ] Spike first: platform save-file dialog behavior (Android SAF, iOS document picker) and notification setup (manifest, AppDelegate, inexact alarms, Android 13+ POST_NOTIFICATIONS, boot receiver, cold-start routing, payload id validation); whether `flutter_timezone` is needed for `zonedSchedule`. Record choices, licenses and limitations.
- [ ] Backup export: validated JSON (schemaVersion 1, non-deleted rows, settings, calibration, completedAt, isPinned; live sessions normalized to paused); success only when the dialog reports a saved location (+ read-back where possible); no share-sheet path. Verify: export refuses to write when validation fails.
- [ ] Import: 10 MB limit before parsing; parse off the UI isolate; validation per ARCHITECTURE §11 with codes; replace-all confirmation with "Back up current data first"; one transaction; device's lastSuccessfulExportAt/backupNudgeDismissedAt survive; notifications re-planned and undo tokens cleared afterwards. Verify: round trip (incl. subject deleted with "keep tasks"), v1 fixture with missing optional fields, higher version, missing schemaVersion, malformed JSON, each invariant, mid-import failure leaving data intact.
- [ ] E11 backup nudge: shown with ≥ 1 task and no successful export in ≥ 30 whole days (or never), not dismissed in the last 30 days. Verify: 0/29/30 days, never, zero tasks, dismissed 10 days ago.
- [ ] OS backups: Android `allowBackup` + `dataExtractionRules` include the DB; iOS DB in Application Support; README wording says the OS may copy the database to the user's own Google or iCloud account while the app sends nothing. Verify: manifest check; manual restore test on an Android emulator, result recorded.
- [ ] Reminders: optional, asked only when enabled with a pre-prompt; ≤ 50 pending, ≤ 30 days ahead, re-planned on app open and plan changes; "Show task names in notifications" (default on). Verify: cap test with 200 candidates; generic text when names are off; first launch requests no permission.
- [ ] Diagnostics sanitizing. Verify: malformed-backup and constraint-violation tests built from seeded titles leave no titles in diagnostics.
- [ ] Debug Developer menu (seed, reset, clock offset not persisted, force recovery, dump JSON) gated by `const kDebugMode`. Verify: unreachable in non-debug configuration.

### Phase 8 — Quality assurance

- [ ] `dart format`, `flutter analyze`, unit, widget, integration, migration (schema snapshot), restart persistence, offline (airplane mode manual check), responsive matrix; defects fixed. Results recorded with commands and dates.
- [ ] Docs-match checks: warning types vs DESIGN_SYSTEM §8, ScoringWeights vs SCHEDULING_ALGORITHM §7, README tool commands exist.
- [ ] Test plan in [reviews/2026-10-12-eng-test-plan.md](reviews/2026-10-12-eng-test-plan.md) walked end to end.

### Phase 9 — Release preparation

- [ ] README complete (features, genuine screenshots from the running app, architecture, database, scheduling, offline behavior, privacy, backup/restore, prerequisites, setup, run, test, Android/iOS build, known limitations, roadmap from TODOS.md); states clearly there is no cloud sync and data lives on the device.
- [ ] Costs section: development costs $0; publishing costs separate (Google Play one-time developer fee, Apple Developer Program annual fee) and optional for local builds.
- [ ] App icon and launch assets; Android release config (signing documented, keys never committed); iOS release config verified on this Mac.
- [ ] LICENSE and CONTRIBUTING.md (points to bootstrap/check) decided.
- [ ] Store listing notes; /devex-review after release to compare measured setup time with the target.

## Testing summary

Unit (scheduler, services, repositories), widget (every screen state, width matrix, accessibility), integration (core journey with simulated restart plus a manual cold restart), migration (schema snapshot), benchmark (scheduler). Time-dependent tests use a fake clock; DST tests are host-zone independent. Goldens run on macOS. The detailed test plan with value cards is in [reviews/2026-10-12-eng-test-plan.md](reviews/2026-10-12-eng-test-plan.md).

## Parallel work

Lane A: scheduler package (Phase 3) is independent of lanes B and C. Lane B: database and repositories (Phase 2) then backup (Phase 7). Lane C: theme, shell, docs. Then PlanService/SessionService (needs A + B), then screens (needs C + services). `core/` is shared by B, C and backup; merge B before backup work.

## Git and change management

Small, reviewable commits per checklist group. After each phase: format, analyze, test, fix regressions, update docs, and write a phase summary (files changed, commands run, actual results, known limitations). Never leave `main` knowingly broken. Commits are authored by the owner only, with no co-author trailers.
