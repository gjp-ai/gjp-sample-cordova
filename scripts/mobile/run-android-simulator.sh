#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

configure_android_tools

AVD_NAME="${ANDROID_AVD:-}"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --target=*)
            AVD_NAME="${1#*=}"
            ;;
        --target)
            shift
            [[ $# -gt 0 ]] || fail "--target requires an Android Virtual Device name."
            AVD_NAME="$1"
            ;;
        *)
            fail "Unsupported option: $1. Use --target=<avd-name> or set ANDROID_AVD."
            ;;
    esac
    shift
done

require_command adb
require_command emulator
require_command apkanalyzer

find_online_emulator() {
    local serial
    local current_avd

    while read -r serial; do
        [[ -n "$serial" ]] || continue
        if [[ -z "$AVD_NAME" ]]; then
            printf '%s\n' "$serial"
            return
        fi

        current_avd="$(adb -s "$serial" emu avd name 2>/dev/null | head -n 1 | tr -d '\r')"
        if [[ "$current_avd" == "$AVD_NAME" ]]; then
            printf '%s\n' "$serial"
            return
        fi
    done < <(adb devices | awk '/^emulator-[0-9]+[[:space:]]+device$/ { print $1 }')
}

read_avd_name() {
    adb -s "$1" emu avd name 2>/dev/null | head -n 1 | tr -d '\r'
}

stop_emulator() {
    local serial="$1"
    adb -s "$serial" emu kill >/dev/null 2>&1 || true

    for ((attempt = 0; attempt < 30; attempt += 1)); do
        if ! adb devices | awk '{ print $1 }' | grep -qx "$serial"; then
            return
        fi
        sleep 1
    done

    fail "Emulator $serial did not stop. Close it from Android Studio and try again."
}

cd "$PROJECT_ROOT"
run_cordova build android --debug

APK_PATH="$PROJECT_ROOT/platforms/android/app/build/outputs/apk/debug/app-debug.apk"
[[ -f "$APK_PATH" ]] || fail "Debug APK was not found: $APK_PATH"

EMULATOR_SERIAL="$(find_online_emulator)"
if [[ -n "$EMULATOR_SERIAL" && "${ANDROID_REUSE_EMULATOR:-0}" != "1" ]]; then
    if [[ -z "$AVD_NAME" ]]; then
        AVD_NAME="$(read_avd_name "$EMULATOR_SERIAL")"
    fi
    printf 'Restarting %s with a cold boot\n' "$EMULATOR_SERIAL"
    stop_emulator "$EMULATOR_SERIAL"
    EMULATOR_SERIAL=""
fi

if [[ -z "$EMULATOR_SERIAL" ]]; then
    if [[ -z "$AVD_NAME" ]]; then
        AVD_NAME="$(emulator -list-avds | head -n 1)"
    fi
    [[ -n "$AVD_NAME" ]] || fail "No Android Virtual Device is available. Create one in Android Studio."

    LOG_DIRECTORY="$PROJECT_ROOT/build/mobile"
    mkdir -p "$LOG_DIRECTORY"
    printf 'Starting Android Virtual Device: %s\n' "$AVD_NAME"
    nohup emulator \
        -avd "$AVD_NAME" \
        -no-snapshot-load \
        -no-snapshot-save \
        -no-boot-anim \
        -cores "${ANDROID_EMULATOR_CORES:-2}" \
        -gpu "${ANDROID_EMULATOR_GPU:-host}" \
        >"$LOG_DIRECTORY/android-emulator.log" 2>&1 &

    for ((attempt = 0; attempt < 180; attempt += 1)); do
        EMULATOR_SERIAL="$(find_online_emulator)"
        if [[ -n "$EMULATOR_SERIAL" ]] && \
            [[ "$(adb -s "$EMULATOR_SERIAL" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]; then
            break
        fi
        sleep 1
    done
fi

[[ -n "$EMULATOR_SERIAL" ]] || fail \
    "The Android emulator did not become ready. See build/mobile/android-emulator.log."

printf 'Installing APK on %s\n' "$EMULATOR_SERIAL"
adb -s "$EMULATOR_SERIAL" install -r "$APK_PATH"

PACKAGE_NAME="$(apkanalyzer manifest application-id "$APK_PATH")"
[[ -n "$PACKAGE_NAME" ]] || fail "Unable to read the application ID from $APK_PATH"

adb -s "$EMULATOR_SERIAL" shell monkey \
    -p "$PACKAGE_NAME" \
    -c android.intent.category.LAUNCHER \
    1 >/dev/null

printf 'LAUNCH SUCCESS: %s on %s\n' "$PACKAGE_NAME" "$EMULATOR_SERIAL"
