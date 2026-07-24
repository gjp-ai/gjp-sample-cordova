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
LoginActivity + LoginView + LoginService
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
    │       └── LoginService.java
    ├── config/
    │   └── AppSettings.java
    ├── network/
    │   ├── ApiClient.java
    │   ├── ApiRequest.java
    │   └── ApiResponse.java
    ├── session/
    │   ├── SessionStore.java
    │   └── SessionInactivityManager.java
    └── web/
        └── WebViewActivity.java
```

Each feature owns its Android activity and lifecycle. `SplashActivity` and `LoginActivity` are native `AppCompatActivity` implementations. Only `WebViewActivity` extends `CordovaActivity`.

## Launch And Splash

Android displays the system launch screen first. Its background is configured as `#123B72` through `AndroidWindowSplashScreenBackground` in the root `config.xml`, matching the native splash.

`SplashActivity` displays `SplashView` for three seconds, starts `LoginActivity`, and finishes itself. Cordova is not initialized during this phase, so there is no web splash between the native splash and login screen.

## Login

`LoginView` collects the username and password and delegates authentication to the single `LoginService`. The service creates the login request and executes it through the application-wide `ApiClient`.

The project-wide API default is in `app/src/main/assets/app-settings.json`:

```json
{
  "isMockMode": false,
  "apiBaseUrl": "https://api.example.com/v1"
}
```

- `isMockMode: true` makes `ApiClient` return the request's bundled response JSON without making a network call.
- `isMockMode: false` makes `ApiClient` send the request to `apiBaseUrl`.

The setting controls the default for every API executed by `ApiClient`. Login applies a credential-based override without exposing mock controls in the UI: username `mock` uses a local response and the password selects its scenario. For example, `mock` / `success` loads the successful response. Every other username calls the real login endpoint.

On failure, the login screen remains visible and displays an error. On success, `LoginActivity` saves the tokens in the in-memory `SessionStore`, starts `WebViewActivity`, and finishes itself. Authenticated native API requests obtain their bearer header from this store. `WebViewActivity` initializes Cordova with `loadUrl(launchUrl)` and loads the bundled application.

## Session Inactivity

`WebViewActivity` records touch activity and `SessionInactivityManager` uses elapsed realtime so wall-clock changes do not affect the policy. After one minute without interaction it displays a session-expiry warning. Selecting **Stay signed in** resets both timers. At two minutes it clears `SessionStore`, destroys the Cordova activity, and opens a fresh login screen. Time spent in the background counts as inactive and is evaluated when the app resumes.

## Login API Contract

The real service sends the shared request envelope:

```json
{
  "meta": {
    "requestId": "client UUID",
    "sentAt": "UTC timestamp",
    "apiVersion": "1.0",
    "channel": "MOBILE",
    "locale": "en-SG"
  },
  "data": {
    "username": "entered username",
    "password": "entered password"
  }
}
```

Responses contain correlation metadata, `SUCCESS`/`FAILURE`/`PARTIAL` outcome, endpoint data, and a typed `errors` array. The bundled login payloads are under `app/src/main/assets/mock-responses/login/`. See the project root `API.md` for the authoritative contract, scenario list, and process for adding another endpoint.

## Logout

The web application calls `NativeSession.logout()`. The shared JavaScript module invokes Cordova's `exec` API with the `NativeSession` service and `logout` action.

The Android plugin implements `CordovaPlugin` and calls the `LogoutListener` contract exposed by `WebViewActivity`. The web activity clears `SessionStore`, starts a fresh `LoginActivity`, and finishes, allowing `CordovaActivity.onDestroy()` to destroy the current web view and plugin session. A later successful login creates a new native and Cordova session.

The activity transitions finish the previous screen, so Back never returns to splash, an authenticated web session, or a logged-out Cordova instance.

The local plugin source is stored in:

```text
plugins/native-session/
├── plugin.xml
├── www/nativeSession.js
├── src/android/NativeSession.java
└── src/ios/NativeSession.m
```

## Native Project Ownership

`platforms/android` is an authoritative source project. Its Gradle wrapper, native application code, Cordova runtime, and plugin assets are committed so a clean clone can build without preparation.

`npm run native:web-sync` updates only application web files and preserves Cordova runtime/plugin files. Android simulator and package scripts compile directly with `platforms/android/gradlew`; they do not run `cordova prepare`.

Preparation is reserved for plugin, `config.xml`, or platform migrations. Run `npm run cordova:prepare:android` from a clean migration branch. Cordova may relocate the `CordovaActivity` subclass and recreate its default manifest activity; `scripts/after-prepare-android.js` restores the custom web activity package and splash/login/web declarations. Review every generated change before committing.
