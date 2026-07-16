# Android App Workflow

## Overview

The Android application uses native views for startup and authentication, then initializes Cordova only after a successful login.

```text
Android system launch screen
        |
        v
SplashActivity + SplashView (3 seconds)
        |
        v
LoginActivity + LoginView + MockLoginService
        |
        v
WebViewActivity + Cordova web application
        |
        v
NativeSession.logout()
        |
        v
Fresh LoginActivity
```

## Source Structure

```text
app/src/main/java/com/ganjianping/sample/
└── app/
    ├── splash/
    │   ├── SplashActivity.java
    │   └── SplashView.java
    ├── login/
    │   ├── LoginActivity.java
    │   ├── LoginView.java
    │   └── services/
    │       ├── LoginResult.java
    │       ├── LoginService.java
    │       └── MockLoginService.java
    └── web/
        └── WebViewActivity.java
```

Each feature owns its Android activity and lifecycle. `SplashActivity` and `LoginActivity` are native `AppCompatActivity` implementations. Only `WebViewActivity` extends `CordovaActivity`.

## Launch And Splash

Android displays the system launch screen first. Its background is configured as `#123B72` through `AndroidWindowSplashScreenBackground` in the root `config.xml`, matching the native splash.

`SplashActivity` displays `SplashView` for three seconds, starts `LoginActivity`, and finishes itself. Cordova is not initialized during this phase, so there is no web splash between the native splash and login screen.

## Login

`LoginView` collects the username and password and delegates authentication to `LoginService`. `MockLoginService` responds after 650 milliseconds.

The mock credentials are:

```text
Username: demo
Password: demo
```

On failure, the login screen remains visible and displays an error. On success, `LoginActivity` starts `WebViewActivity` and finishes itself. `WebViewActivity` initializes Cordova with `loadUrl(launchUrl)` and loads the bundled application.

## Logout

The web application calls `NativeSession.logout()`. The shared JavaScript module invokes Cordova's `exec` API with the `NativeSession` service and `logout` action.

The Android plugin implements `CordovaPlugin` and calls the `LogoutListener` contract exposed by `WebViewActivity`. The web activity starts a fresh `LoginActivity` and finishes, allowing `CordovaActivity.onDestroy()` to destroy the current web view and plugin session. A later successful login creates a new `WebViewActivity` and Cordova session.

The activity transitions finish the previous screen, so Back never returns to splash, an authenticated web session, or a logged-out Cordova instance.

The local plugin source is stored in:

```text
plugins/native-session/
├── plugin.xml
├── www/nativeSession.js
├── src/android/NativeSession.java
└── src/ios/NativeSession.m
```

## Cordova Prepare Notes

The `platforms/android` directory is intentionally tracked because it contains custom native code.

Running `cordova prepare android` refreshes generated configuration, plugin registrations, and bundled web assets. Cordova also relocates the `CordovaActivity` subclass to the application package and recreates its default `MainActivity` manifest entry. The `scripts/after-prepare-android.js` hook restores `WebViewActivity` to `App/Web`, removes generated or stale application activity entries, and writes one canonical manifest declaration for each of the splash, login, and web activities.

Review changes to `AndroidManifest.xml`, `res/xml/config.xml`, `android.json`, `app/src/main/assets/www`, and generated plugin sources before committing.
