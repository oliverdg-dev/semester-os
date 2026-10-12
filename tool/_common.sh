# Shared helpers for tool/*.sh. Source this file; do not run it.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

pinned_version() {
  sed -n 's/.*"flutter": *"\([^"]*\)".*/\1/p' "$ROOT/.fvmrc"
}

check_flutter_version() {
  local want have
  want="$(pinned_version)"
  have="$("${FLUTTER[@]}" --version 2>/dev/null | sed -n 's/^Flutter \([0-9.]*\).*/\1/p' | head -1)"
  if [ "$want" != "$have" ]; then
    echo "Flutter $have is active but this repo pins $want (.fvmrc, pubspec.yaml)." >&2
    echo "Fix: run 'fvm use $want' or switch your Flutter SDK to $want." >&2
    exit 1
  fi
}

# Use fvm when present, otherwise flutter on PATH, otherwise the default install.
if command -v fvm >/dev/null 2>&1 && [ -f .fvmrc ]; then
  FLUTTER=(fvm flutter); DART=(fvm dart)
elif command -v flutter >/dev/null 2>&1; then
  FLUTTER=(flutter); DART=(dart)
elif [ -x "$HOME/development/flutter/bin/flutter" ]; then
  FLUTTER=("$HOME/development/flutter/bin/flutter"); DART=("$HOME/development/flutter/bin/dart")
else
  echo "Flutter not found. Install Flutter $(pinned_version) or fvm, then rerun." >&2
  exit 1
fi
