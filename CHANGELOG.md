# Changelog

## Unreleased

### Phase 1: Foundation
- Flutter app scaffold for Android and iOS (`dev.oliverdg.semester_os`), Flutter pinned to 3.47.7.
- Pure Dart `packages/semester_scheduler` with `SchedulerConfig` defaults checked against the scheduling doc.
- Theme tokens (light/dark, semantic and subject colors) with contrast tests.
- Router with four destinations and adaptive navigation (bottom bar, rail, extended rail).
- Error handling: coded failures, global handlers, provider error logging, diagnostics without personal content.
- Drift database skeleton opened through DbGuard (integrity and version checks).
- Developer scripts (`tool/bootstrap.sh`, `tool/check.sh`, `tool/gen.sh`, `tool/test_integration.sh`) and GitHub Actions CI.

### Phase 0: Planning
- Reviewed implementation plan and design documents in `docs/`.
