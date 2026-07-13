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

## Run

Run the app on Android:

```sh
cordova run android
```

Run the app on iOS:

```sh
cordova run ios
```

## Build

Build Android:

```sh
cordova build android
```

Build iOS:

```sh
cordova build ios
```

## Project Structure

- `config.xml` - Cordova app metadata and runtime configuration.
- `www/` - Web application source files packaged into the Cordova app.
- `package.json` - npm dependencies and Cordova platform metadata.
- `platforms/` - Tracked native platform projects containing the splash and login implementations.
- `plugins/` - Generated Cordova plugin installation directory.

## Git Notes

`platforms/` is intentionally committed because it contains native application code. Native build output and local IDE state inside `platforms/` remain ignored. `node_modules/` and `plugins/` are generated dependencies and are ignored.

When changing the Cordova web app, run `cordova prepare` carefully: it refreshes generated web assets in `platforms/` and can overwrite platform-generated files. Review native changes after preparing the project.
