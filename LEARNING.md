# Learning log

Lessons from earlier work on SemesterOS. Agents read this before starting and add to it after a run (newest last under each heading). Lessons, not a diary: each bullet should save the next run time or prevent a mistake.

## Toolchain

- 2026-10-12: Flutter is not on the default PATH. Prefix commands with `PATH="$HOME/development/flutter/bin:$PATH"`.
- 2026-10-12: `build_runner` ignores `--delete-conflicting-outputs` now. Use `dart run build_runner build`.
- 2026-10-12: iOS simulator builds need the iOS platform that matches Xcode (26.5 for Xcode 26.6). `tool/bootstrap.sh` reports it when missing.
- 2026-10-12: The Pixel Fold emulator has two displays. `adb exec-out screencap` needs `-d <display id>` from `adb shell dumpsys SurfaceFlinger --display-id`.

## Database

- 2026-10-12: Drift only records CHECK constraints in the schema snapshot when they are literal strings. `test/core/database/schema_test.dart` checks the literals against `AppLimits`; update both together.
- 2026-10-12: The schema snapshot test must open a fresh `AppDatabase.memory()`. Opening the verifier's own snapshot connection compares the snapshot with itself and always passes. Prove a schema test can fail with a planted change before trusting it.

## UI and design

- 2026-10-12: Platform is decided by `Theme.of(context).platform` (`isCupertinoPlatform`). Test UI with `TargetPlatformVariant.only(TargetPlatform.iOS)` and `.android`; the default test platform is Android.
- 2026-10-12: Goldens need real fonts: `setUpAll(loadAppFonts)` from `test/support/load_fonts.dart`. iOS goldens are not useful because the SF font cannot load in tests; verify iOS on the simulator.
- 2026-10-12: Text-scale tests must include landscape heights (852×393, 667×375); `setWindowSize` takes a height. Width-only checks missed real overflows.
- 2026-10-12: Subject swatches must stay apart from the accent and capacity colors (RGB distance > 50) and from each other (> 40); the contrast test enforces it.

## Process

- 2026-10-12: Bulk `sed` across `docs/` also rewrites dated review records in `docs/reviews/`. Exclude that folder; those files are history.
- 2026-10-12: Another Claude session may be working in this repo. Check `git status` and file timestamps before editing shared docs, and coordinate through SendMessage.
- 2026-10-12: The impeccable `detect` command only understands web CSS and HTML. On Flutter code it returns a meaningless clean result; check Flutter by hand and on devices.
- 2026-10-13: graphify's Dart extractor records files, classes and inheritance, not calls or widget usage. Use it as a map (`graphify-out/graph.html`, `graphify explain`), not to trace call paths. Rebuild with `graphify update . --no-cluster && graphify cluster-only . --no-label` (no LLM).
