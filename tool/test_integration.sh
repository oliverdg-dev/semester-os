#!/usr/bin/env bash
# Runs the integration journey on a device or emulator: tool/test_integration.sh <device-id>
source "$(dirname "$0")/_common.sh"
if [ $# -lt 1 ]; then
  echo "Usage: tool/test_integration.sh <device-id>   (list devices with: flutter devices)" >&2
  exit 2
fi
if [ ! -d integration_test ]; then
  echo "No integration_test/ directory yet (the core journey lands in Phase 4)." >&2
  exit 0
fi
"${FLUTTER[@]}" test integration_test -d "$1"
