#!/usr/bin/env bash
# Regenerate Drift code (generated files are gitignored).
source "$(dirname "$0")/_common.sh"
"${DART[@]}" run build_runner build --delete-conflicting-outputs
