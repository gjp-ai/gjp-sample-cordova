#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

[[ "$(uname -s)" == "Darwin" ]] || fail "The iOS simulator requires macOS."
require_command xcodebuild
require_command node

cd "$PROJECT_ROOT"
node "$PROJECT_ROOT/scripts/mobile/sync-web.js"
run_cordova run ios --noprepare --simulator "$@"
