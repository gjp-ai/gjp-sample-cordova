#!/usr/bin/env bash

set -euo pipefail

MOBILE_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$MOBILE_SCRIPT_DIR/../.." && pwd)"

fail() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || fail "$1 is required but was not found."
}

configure_android_tools() {
    local android_sdk="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
    if [[ -z "$android_sdk" && -d "$HOME/Library/Android/sdk" ]]; then
        android_sdk="$HOME/Library/Android/sdk"
    fi

    [[ -n "$android_sdk" ]] || fail "Set ANDROID_HOME or ANDROID_SDK_ROOT to your Android SDK."

    local command_line_tools="$android_sdk/cmdline-tools/latest/bin"
    [[ -x "$command_line_tools/apkanalyzer" ]] || fail \
        "Android SDK Command-line Tools (latest) are required. Install them from Android Studio's SDK Manager."

    export ANDROID_HOME="$android_sdk"
    export ANDROID_SDK_ROOT="$android_sdk"
    export PATH="$command_line_tools:$android_sdk/platform-tools:$android_sdk/emulator:$PATH"
}

resolve_cordova() {
    if [[ -n "${CORDOVA_BIN:-}" ]]; then
        [[ -x "$CORDOVA_BIN" ]] || fail "CORDOVA_BIN is not executable: $CORDOVA_BIN"
        return
    fi

    if [[ -x "$PROJECT_ROOT/node_modules/.bin/cordova" ]]; then
        CORDOVA_BIN="$PROJECT_ROOT/node_modules/.bin/cordova"
        return
    fi

    CORDOVA_BIN="$(command -v cordova || true)"
    [[ -n "$CORDOVA_BIN" ]] || fail "Cordova CLI was not found. Run: npm install -g cordova"
}

run_cordova() {
    resolve_cordova
    "$CORDOVA_BIN" "$@"
}
