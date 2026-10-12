#!/usr/bin/env bash
# Everything CI runs: version pin, format, analyze, app tests, scheduler tests.
source "$(dirname "$0")/_common.sh"

check_flutter_version
"${DART[@]}" format --output=none --set-exit-if-changed lib test packages/semester_scheduler/lib packages/semester_scheduler/test
"${FLUTTER[@]}" analyze
(cd packages/semester_scheduler && "${DART[@]}" analyze)
"${FLUTTER[@]}" test --exclude-tags golden
(cd packages/semester_scheduler && TZ=America/New_York "${DART[@]}" test)
echo "All checks passed."
