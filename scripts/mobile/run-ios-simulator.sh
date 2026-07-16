#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

[[ "$(uname -s)" == "Darwin" ]] || fail "The iOS simulator requires macOS."
require_command xcodebuild

cd "$PROJECT_ROOT"
run_cordova run ios --simulator "$@"
