#!/usr/bin/env bash
# One-command setup for a fresh clone: version check, packages, codegen, readiness report.
source "$(dirname "$0")/_common.sh"
start=$(date +%s)

check_flutter_version
echo "Flutter $(pinned_version) OK"

"${FLUTTER[@]}" pub get >/dev/null
(cd packages/semester_scheduler && "${DART[@]}" pub get >/dev/null)
echo "Packages OK"

"${DART[@]}" run build_runner build --delete-conflicting-outputs >/dev/null
echo "Generated code OK"

doctor="$("${FLUTTER[@]}" doctor 2>&1 || true)"
if echo "$doctor" | grep -q "Android licenses not accepted"; then
  echo "Android: debug builds and tests work. Release builds need: flutter doctor --android-licenses"
else
  echo "Android: OK"
fi
if [ "$(uname)" = "Darwin" ]; then
  missing_ios="$(echo "$doctor" | sed -n 's/.*! \(iOS [0-9.]*\) Simulator not installed.*/\1/p' | head -1)"
  if [ -n "$missing_ios" ]; then
    echo "iOS: builds fail until the $missing_ios platform is installed: Xcode > Settings > Components (or: xcodebuild -downloadPlatform iOS)"
  elif command -v pod >/dev/null 2>&1; then
    echo "iOS: OK (CocoaPods present)"
  else
    echo "iOS: Swift Package Manager is on by default; if an iOS build asks for CocoaPods, run: brew install cocoapods"
  fi
fi

echo "Ready in $(( $(date +%s) - start ))s. Run: flutter run"
