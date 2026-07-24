# gjp-sample-cordova

Native-first Android and iOS finance applications with a shared React/Cordova web experience. The committed platform projects own the native splash, login, API, session, and web-container implementations.

## Prerequisites

- Node.js 22 and npm
- Android Studio, Android SDK 36, Android SDK Command-line Tools (latest), and an Android Virtual Device
- macOS and Xcode for iOS builds

The project-local Cordova CLI, Android Gradle wrapper, native projects, Cordova runtime, and local `NativeSession` plugin assets are committed or installed by `npm ci`. A global Cordova installation is not required.

## Setup

```sh
git clone https://github.com/gjp-ai/gjp-sample-cordova.git
cd gjp-sample-cordova
npm ci
npm run api:install
```

Do not run `cordova platform add`, `cordova platform remove`, or `cordova prepare` during normal setup. `platforms/android` and `platforms/ios` are authoritative source projects, not disposable generated output.

## API Development

The standalone Express service is under `api/` and implements the contract in `API.md`.

```sh
npm run api:dev
```

It listens on `http://127.0.0.1:3000` by default. The application endpoint is `POST /v1/login`, and `GET /health` is available for service checks. Sample real-API credentials are `demo` / `demo`; configuration and deployment notes are in `api/README.md`.

Run its tests independently:

```sh
npm run api:test
```

## Web Development

The React source is under `web/`.

```sh
npm run web:dev
```

Open `http://127.0.0.1:5173/`. Browser mode uses its own login/session behavior because Cordova native APIs are unavailable.

Create the browser production bundle:

```sh
npm run web:build
```

Build and synchronize application web files into both committed native projects:

```sh
npm run native:web-sync
```

The synchronizer replaces application files such as `index.html`, hashed Vite assets, and images. It preserves each platform's `cordova.js`, `cordova_plugins.js`, and plugin runtime files.

Do not edit `www/` or the synchronized application files in platform `www` directories directly.

## Android Simulator

```sh
npm run android:simulator
```

Select an Android Virtual Device:

```sh
npm run android:simulator -- --target=Pixel_9_API_35
```

The script:

1. Builds and synchronizes React without Cordova preparation.
2. Builds the debug APK with the committed Gradle wrapper.
3. Cold-boots the selected emulator by default.
4. Installs and launches the APK.

It prioritizes `$ANDROID_HOME/cmdline-tools/latest/bin`, avoiding obsolete Android tools that fail on current JDKs. Set `ANDROID_REUSE_EMULATOR=1` to reuse a running emulator. Emulator logs are written to `build/mobile/android-emulator.log`.

## iOS Simulator

On macOS:

```sh
npm run ios:simulator
```

This synchronizes React and runs the committed Xcode project with Cordova's `--noprepare` option. A target can be passed after `--`:

```sh
npm run ios:simulator -- --target="iPhone-16-Pro"
```

The workspace can also be opened directly:

```text
platforms/ios/App.xcworkspace
```

## Mobile Packages

Build Android release artifacts without Cordova preparation:

```sh
npm run android:apk
npm run android:aab
```

Artifacts are copied to `artifacts/android/`. To sign a package, provide an external Cordova-compatible signing properties file:

```sh
ANDROID_SIGNING_PROPERTIES=/secure/release-signing.properties npm run android:aab
```

Generate an IPA on macOS:

```sh
IOS_TEAM_ID=YOUR_TEAM_ID npm run ios:ipa
```

`IOS_EXPORT_METHOD` supports `debugging`, `release-testing`, `app-store-connect`, and `enterprise`. IPA output is written under `artifacts/ios/`.

## Explicit Cordova Preparation

Preparation is reserved for intentional changes to `config.xml`, Cordova plugins, or platform versions. It is not part of normal build/run commands.

Start from a clean migration branch:

```sh
git switch -c migration/cordova-android
npm run cordova:prepare:android
```

For iOS:

```sh
git switch -c migration/cordova-ios
npm run cordova:prepare:ios
```

The guarded scripts refuse dirty working trees and `main`/`master` by default, show all generated changes, and fail if protected native feature source changes unexpectedly. Review and test every generated change before committing it.

For an intentional main-branch exception:

```sh
CORDOVA_PREPARE_ALLOW_MAIN=1 npm run cordova:prepare:android
```

## Mock And Real APIs

Native login uses the real API for ordinary credentials. Reserved username `mock` uses the password as a local response scenario; `mock` / `success` exercises successful login. Application-wide API defaults are stored in:

```text
platforms/android/app/src/main/assets/app-settings.json
platforms/ios/App/Resources/AppSettings.json
```

Finance API envelopes, error codes, security rules, and mock scenarios are documented in `API.md`.

Successful native login creates an in-memory session used by authenticated native API requests. The web screen warns after one minute without touch activity and forces logout after two minutes. Manual and automatic logout both clear the session.

## Project Structure

- `web/`: React source.
- `api/`: standalone Node.js and Express API.
- `www/`: generated browser production bundle.
- `platforms/android/`: authoritative Android project.
- `platforms/ios/`: authoritative iOS project.
- `plugins/native-session/`: canonical local Cordova bridge plugin.
- `scripts/mobile/sync-web.js`: controlled native web synchronization.
- `scripts/mobile/safe-prepare.js`: guarded Cordova preparation.
- `scripts/mobile/`: native simulator and package scripts.
- `config.xml`: Cordova metadata used only during explicit preparation.

## Verification

```sh
npm test
npm run native:web-sync
./platforms/android/gradlew -p platforms/android :app:assembleDebug
```

CI performs clean-clone Android and iOS builds without Cordova preparation. Build output, IDE state, signing credentials, and local SDK configuration remain ignored by Git.
