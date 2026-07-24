#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

PACKAGE_TYPE="${1:-}"
case "$PACKAGE_TYPE" in
    apk)
        PACKAGE_LABEL=APK
        GRADLE_TASK=assembleRelease
        OUTPUT_DIRECTORY="$PROJECT_ROOT/platforms/android/app/build/outputs/apk/release"
        FILE_PATTERN='*.apk'
        DESTINATION_NAME='gjp-sample-release.apk'
        ;;
    aab)
        PACKAGE_LABEL=AAB
        GRADLE_TASK=bundleRelease
        OUTPUT_DIRECTORY="$PROJECT_ROOT/platforms/android/app/build/outputs/bundle/release"
        FILE_PATTERN='*.aab'
        DESTINATION_NAME='gjp-sample-release.aab'
        ;;
    *)
        fail "Usage: $0 <apk|aab>"
        ;;
esac

cd "$PROJECT_ROOT"
require_command node
node "$PROJECT_ROOT/scripts/mobile/sync-web.js"

GRADLEW="$PROJECT_ROOT/platforms/android/gradlew"
[[ -x "$GRADLEW" ]] || fail "Android Gradle wrapper was not found: $GRADLEW"

GRADLE_ARGS=("$GRADLE_TASK")
if [[ -n "${ANDROID_SIGNING_PROPERTIES:-}" ]]; then
    [[ -f "$ANDROID_SIGNING_PROPERTIES" ]] || fail "Signing properties file not found: $ANDROID_SIGNING_PROPERTIES"
    SIGNING_PROPERTIES="$(cd "$(dirname "$ANDROID_SIGNING_PROPERTIES")" && pwd)/$(basename "$ANDROID_SIGNING_PROPERTIES")"
    GRADLE_ARGS+=("-PcdvReleaseSigningPropertiesFile=$SIGNING_PROPERTIES")
fi

"$GRADLEW" -p "$PROJECT_ROOT/platforms/android" "${GRADLE_ARGS[@]}"

ARTIFACT="$(find "$OUTPUT_DIRECTORY" -maxdepth 1 -type f -name "$FILE_PATTERN" -print | sort | tail -n 1)"
[[ -n "$ARTIFACT" ]] || fail "Gradle completed but no $PACKAGE_TYPE artifact was found in $OUTPUT_DIRECTORY"

DESTINATION_DIRECTORY="$PROJECT_ROOT/artifacts/android"
mkdir -p "$DESTINATION_DIRECTORY"
cp "$ARTIFACT" "$DESTINATION_DIRECTORY/$DESTINATION_NAME"

printf '%s package: %s\n' "$PACKAGE_LABEL" "$DESTINATION_DIRECTORY/$DESTINATION_NAME"
if [[ -z "${ANDROID_SIGNING_PROPERTIES:-}" ]]; then
    printf 'Note: no ANDROID_SIGNING_PROPERTIES file was supplied; verify signing before distribution.\n'
fi
