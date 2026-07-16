#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

[[ "$(uname -s)" == "Darwin" ]] || fail "IPA generation requires macOS."
require_command xcodebuild
require_command plutil

EXPORT_METHOD="${IOS_EXPORT_METHOD:-debugging}"
case "$EXPORT_METHOD" in
    development) EXPORT_METHOD=debugging ;;
    ad-hoc) EXPORT_METHOD=release-testing ;;
    app-store) EXPORT_METHOD=app-store-connect ;;
esac

case "$EXPORT_METHOD" in
    debugging|release-testing|app-store-connect|enterprise) ;;
    *) fail "IOS_EXPORT_METHOD must be debugging, release-testing, app-store-connect, or enterprise." ;;
esac

cd "$PROJECT_ROOT"
run_cordova prepare ios

WORKSPACE="$PROJECT_ROOT/platforms/ios/App.xcworkspace"
SCHEME="${IOS_SCHEME:-App}"
RUN_ID="$(date '+%Y%m%d-%H%M%S')"
BUILD_DIRECTORY="$PROJECT_ROOT/build/mobile/ios/$RUN_ID"
ARCHIVE_PATH="$BUILD_DIRECTORY/GJPS.xcarchive"
EXPORT_OPTIONS="$BUILD_DIRECTORY/ExportOptions.plist"
EXPORT_DIRECTORY="$PROJECT_ROOT/artifacts/ios/$RUN_ID"

[[ -d "$WORKSPACE" ]] || fail "iOS workspace was not found: $WORKSPACE"
mkdir -p "$BUILD_DIRECTORY" "$EXPORT_DIRECTORY"

plutil -create xml1 "$EXPORT_OPTIONS"
plutil -insert method -string "$EXPORT_METHOD" "$EXPORT_OPTIONS"
plutil -insert signingStyle -string automatic "$EXPORT_OPTIONS"
plutil -insert destination -string export "$EXPORT_OPTIONS"
if [[ -n "${IOS_TEAM_ID:-}" ]]; then
    plutil -insert teamID -string "$IOS_TEAM_ID" "$EXPORT_OPTIONS"
fi

PROVISIONING_ARGS=()
if [[ "${IOS_ALLOW_PROVISIONING_UPDATES:-1}" == "1" ]]; then
    PROVISIONING_ARGS+=(-allowProvisioningUpdates)
fi

SIGNING_ARGS=(CODE_SIGN_STYLE=Automatic)
if [[ -n "${IOS_TEAM_ID:-}" ]]; then
    SIGNING_ARGS+=("DEVELOPMENT_TEAM=$IOS_TEAM_ID")
fi

xcodebuild \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -configuration Release \
    -sdk iphoneos \
    -destination 'generic/platform=iOS' \
    -archivePath "$ARCHIVE_PATH" \
    "${PROVISIONING_ARGS[@]}" \
    "${SIGNING_ARGS[@]}" \
    archive

xcodebuild \
    -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_DIRECTORY" \
    -exportOptionsPlist "$EXPORT_OPTIONS" \
    "${PROVISIONING_ARGS[@]}"

IPA_PATH="$(find "$EXPORT_DIRECTORY" -maxdepth 1 -type f -name '*.ipa' -print | sort | head -n 1)"
[[ -n "$IPA_PATH" ]] || fail "Xcode completed but no IPA was found in $EXPORT_DIRECTORY"
printf 'IPA package: %s\n' "$IPA_PATH"
