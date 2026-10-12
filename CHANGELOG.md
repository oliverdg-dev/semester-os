# Changelog

## Unreleased

### Phase 2: Database and core data (in progress)
- Schema v1: all nine tables, CHECK constraints tied to `AppLimits`, the one-live-session index and DataVersion triggers, with a committed Drift schema snapshot and a test that fails on any unrecorded change.
- Adaptive design pass (impeccable critique, BD5/BD6): iOS tab bar, large titles, system font for iOS controls and inset grouped Settings; Android bar, rail or permanent drawer by window size; landscape phones stay compact; Settings opens inside each tab.
- Today leads with the next-action block and the date; empty states sit at the top of the page.
- Color: every Material role mapped and contrast-tested; capacity warnings use an indigo ink, red only for real errors; subject colors kept apart from the accent and warnings.
- Type: tabular numeric, timer and date-line styles.
- Developer workflow: `/harness` (dev, independent QA, ops) and `LEARNING.md`.

### Phase 1: Foundation
- Flutter app scaffold for Android and iOS (`dev.oliverdg.semester_os`), Flutter pinned to 3.47.7.
- Pure Dart `packages/semester_scheduler` with `SchedulerConfig` defaults checked against the scheduling doc.
- Theme tokens (light/dark, semantic and subject colors) with contrast tests.
- Router with four destinations and adaptive navigation (bottom bar, rail, extended rail).
- Error handling: coded failures, global handlers, provider error logging, diagnostics without personal content.
- Drift database skeleton opened through DbGuard (integrity and version checks).
- IBM Plex Sans 1.1.0 bundled (Regular, Medium, SemiBold; SIL OFL) and used by every text style; light/dark goldens of the Today empty state.
- Developer scripts (`tool/bootstrap.sh`, `tool/check.sh`, `tool/gen.sh`, `tool/test_integration.sh`) and GitHub Actions CI.

### Phase 0: Planning
- Reviewed implementation plan and design documents in `docs/`.
