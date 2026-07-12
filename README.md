# gjp-sample-cordova

GJP Sample Cordova project for iOS and Android.

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
- `platforms/` - Generated native platform projects. Recreate with `cordova prepare`.
- `plugins/` - Generated Cordova plugin installation directory.

## Git Notes

Generated directories such as `node_modules/`, `platforms/`, and `plugins/` are ignored. Commit the source files, `config.xml`, `package.json`, and `package-lock.json`.
