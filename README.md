# SemesterOS

> Know what matters. Know what to do next. Stay in control of your semester.

SemesterOS is an offline-first study planner for Android phones and tablets, iPhones and iPads. You add your deadlines and when you can study; it builds a realistic plan, tells you what to work on next, and warns you early when the work does not fit.

**Status: early development (Phase 1 of 9, foundation).** The app runs and shows its navigation and empty screens; subjects, tasks, the scheduler and sessions arrive in the next phases. See [docs/IMPLEMENTATION_PLAN.md](docs/IMPLEMENTATION_PLAN.md).

## Why SemesterOS

- **Explained scheduling that never silently moves your plan.** Every plan is a proposal you accept; every session says why it is there.
- **Fully private, no account.** Everything stays on your device. The app makes no network requests for its features and sends no data anywhere.
- **Estimates that learn your real pace.** Once you have studied a few tasks of a type, it suggests better default estimates.

There is **no cloud sync** in v1. Your data lives in a SQLite database on the device; you keep a copy with the built-in JSON backup (Phase 7).

## Prerequisites

- Flutter **3.47.7** (Dart 3.13.5). The version is pinned in `.fvmrc` and `pubspec.yaml`. Use [fvm](https://fvm.app) (`fvm use 3.47.7`) or put that SDK's `bin` on your PATH.
- Android: Android SDK and JDK 17+. The first build installs the SDK platform and CMake it needs if they are missing.
- iOS (macOS only): Xcode 26 with the matching iOS simulator platform installed (Xcode > Settings > Components). CocoaPods is not needed.
- No accounts, API keys or paid services are needed to build, run or test.

## Setup

```bash
./tool/bootstrap.sh
```

It checks the Flutter version, gets packages for the app and the scheduler package, generates Drift code (generated files are not committed), and prints what is still missing on your machine with the exact fix.

## Run

```bash
flutter run
```

## Test

```bash
./tool/check.sh
```

Runs exactly what CI runs: version pin check, `dart format` check, `flutter analyze`, the app tests and the scheduler package tests (with `TZ=America/New_York`). Other scripts: `tool/gen.sh` (codegen only) and `tool/test_integration.sh <device-id>` (integration journey, from Phase 4).

## Build

```bash
flutter build apk --debug                       # Android debug build
flutter build ios --simulator --no-codesign     # iOS simulator build (macOS)
```

Release builds and store publishing are covered in Phase 9.

## Project layout

```
lib/                         Flutter app (app/, core/, features/<feature>/{presentation,application,domain,data})
packages/semester_scheduler  pure Dart scheduling engine (no Flutter, no database)
test/                        unit and widget tests
tool/                        bootstrap, check, gen, test_integration scripts
docs/                        plan, architecture, scheduling, design system, UX flows, responsive, errors
```

Architecture: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md). Scheduling: [docs/SCHEDULING_ALGORITHM.md](docs/SCHEDULING_ALGORITHM.md). Design: [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md).

## Continuous integration

GitHub Actions (`.github/workflows/ci.yml`) runs `tool/check.sh` and a debug APK build on every push to `main` and on pull requests.

## Known limitations

- Early development: only the app shell exists. Features land phase by phase.
- Build status (measured 2026-10-12 on macOS, Flutter 3.47.7): the Android debug APK and the iOS simulator build both succeed. Xcode 26.6 needs the iOS 26.5 platform installed first (Xcode > Settings > Components, or `xcodebuild -downloadPlatform iOS`); `tool/bootstrap.sh` tells you when it is missing. CocoaPods is not required; plugins resolve through Swift Package Manager.
- Golden tests (`flutter test --tags golden`) are compared on macOS only and are not part of `tool/check.sh`.

## Costs

Building, running and testing SemesterOS costs nothing: no backend, no paid APIs, no subscriptions. Publishing is optional and separate: the Google Play developer registration (one-time fee) and the Apple Developer Program (annual fee) are needed only to distribute through the stores.

## Roadmap

See [docs/IMPLEMENTATION_PLAN.md](docs/IMPLEMENTATION_PLAN.md) for the phases and [TODOS.md](TODOS.md) for ideas deferred beyond v1 (calendar import, a semester archive, home-screen widget, optional desktop/web).
