# gjp-sample-cordova

GJP Sample Cordova project for iOS and Android.

The app starts with native splash and login screens on Android and iOS. After a successful native login, the existing Cordova web application is revealed.

The login service is currently a platform-local mock. Use `demo` as the username and `demo` as the password. Replace `MockLoginService` in the Android and iOS native entry points when the real service is ready.

## Prerequisites

- Node.js and npm
- Apache Cordova CLI: `npm install -g cordova`
- Android Studio and Android SDK for Android builds
- Xcode and CocoaPods for iOS builds

## Setup

Install project dependencies:

```sh
npm install
```

Restore Cordova platforms from `package.json`:

```sh
cordova prepare
```

If a platform needs to be added manually:

```sh
cordova platform add android
cordova platform add ios
```

## Web Development

The React source code is in `web/`. Install dependencies before running or building it:

```sh
npm install
```

Start the Vite development server:

```sh
npm run web:dev
```

Open the local URL printed by Vite, normally `http://127.0.0.1:5173/`. Vite automatically reloads the page when files under `web/` change.

Sign in to the standalone web app with the mock username `demo` and password `demo`.

The browser development server does not provide Cordova native APIs. It uses its own session and returns to the React login page after logout. Android and iOS continue to use the native login and native logout flow.

## Build Web

Create the production React bundle:

```sh
npm run web:build
```

The build reads `web/` and replaces the generated contents of `www/`. Do not edit files in `www/` directly because the next web build will overwrite them.

The following command is an alias for the same production build:

```sh
npm run build
```

Preview the generated production bundle locally:

```sh
npm run web:preview
```

`cordova prepare`, `cordova run`, and `cordova build` automatically run the web production build through `scripts/build-web.js`. The resulting `www/` bundle is then copied into the selected native platform project.

## Run

Run the app in an Android emulator:

```sh
npm run android:simulator
```

Run the app in an iOS Simulator:

```sh
npm run ios:simulator
```

Pass Cordova target options after `--` when a specific simulator is required:

```sh
npm run android:simulator -- --target=Pixel_9_API_35
npm run ios:simulator -- --target="iPhone-16-Pro"
```

The Android simulator script prioritizes `$ANDROID_HOME/cmdline-tools/latest/bin`. This avoids the obsolete `$ANDROID_HOME/tools/bin/apkanalyzer`, which is incompatible with current JDK versions. Install **Android SDK Command-line Tools (latest)** from Android Studio's SDK Manager if the script reports that the current analyzer is missing.

The wrapper uses Cordova to prepare and build the debug APK, then uses `adb` to install it and launch the manifest's launcher activity. This supports the native `SplashActivity` package structure without relying on Cordova's default root-package activity launcher.

By default, the script cold-boots the emulator without loading or saving Quick Boot snapshots, uses two virtual CPU cores, and requests host GPU rendering. These defaults avoid stale `system_server` state and reduce Android system ANRs. Set `ANDROID_REUSE_EMULATOR=1` to reuse an already-running emulator, or override `ANDROID_EMULATOR_CORES` and `ANDROID_EMULATOR_GPU` when needed.

If the emulator still reports **Process system isn't responding**, create an API 35 Google APIs AVD without the Play Store and close memory-intensive host applications. API 36.1 Play Store images require more host resources and may fall back to slow software graphics under memory pressure.

## Mobile Packages

Generate Android release packages:

```sh
npm run android:apk
npm run android:aab
```

The copied artifacts are written to `artifacts/android/`. To sign either package, set `ANDROID_SIGNING_PROPERTIES` to an absolute Cordova release-signing properties file:

```sh
ANDROID_SIGNING_PROPERTIES=/secure/release-signing.properties npm run android:aab
```

The properties file uses Cordova's standard `storeFile`, `storePassword`, `keyAlias`, and `keyPassword` keys. Keep signing files and passwords outside the repository.

Generate a signed development IPA on macOS:

```sh
IOS_TEAM_ID=YOUR_TEAM_ID npm run ios:ipa
```

`IOS_EXPORT_METHOD` defaults to `debugging`. Set it to `release-testing`, `app-store-connect`, or `enterprise` for another distribution type:

```sh
IOS_TEAM_ID=YOUR_TEAM_ID IOS_EXPORT_METHOD=app-store-connect npm run ios:ipa
```

The IPA is written to a timestamped directory under `artifacts/ios/`. Xcode must have a matching Apple Developer account, certificate, and provisioning access. Set `IOS_ALLOW_PROVISIONING_UPDATES=0` when builds must not contact Apple's provisioning service.

## Project Structure

- `config.xml` - Cordova app metadata and runtime configuration.
- `web/` - React source, styles, and public assets.
- `web/APP_WORKFLOW.md` - Browser, Android, and iOS web runtime and session flow.
- `www/` - Generated Vite production bundle packaged into the Cordova app.
- `scripts/build-web.js` - Cordova hook that builds React before platform preparation.
- `vite.config.js` - Vite configuration that builds `web/` into `www/`.
- `package.json` - npm dependencies and Cordova platform metadata.
- `platforms/` - Tracked native platform projects containing the splash and login implementations.
- `plugins/` - Generated Cordova plugin installation directory.

## Git Notes

`platforms/` is intentionally committed because it contains native application code. Native build output and local IDE state inside `platforms/` remain ignored. `node_modules/` and `plugins/` are generated dependencies and are ignored.

When changing the React app, edit `web/` and run `npm run web:build` or a Cordova command. Run `cordova prepare` carefully: it refreshes generated web assets in `platforms/` and can overwrite platform-generated files. Review native changes after preparing the project.
