# iOS App Workflow

This Cordova iOS app starts with native UIKit screens before showing the bundled Cordova web application.

The app supports iOS 15.0 and later. The minimum version is configured by the iOS `deployment-target` preference in the root `config.xml` and applied to the generated Xcode project.

## Startup Flow

1. iOS launches `AppFlowViewController` from `Main.storyboard`.
2. `AppFlowViewController` displays `SplashViewController` as its first child.
3. After a short delay, it replaces the splash screen with `LoginViewController`.
4. `LoginViewController` authenticates through the injected `LoginServicing` implementation.
5. After a successful login, `AppFlowViewController` creates and displays `WebViewController`.
6. `WebViewController` extends Cordova's `MainViewController`, so Cordova and its web view are initialized only after login succeeds. Its `showInitialSplashScreen` flag is disabled, preventing Cordova from displaying the launch storyboard again.

## Main Files

- `App/Flow/AppFlowViewController.swift` coordinates the splash, login, and web child controllers.
- `App/Splash/SplashViewController.swift` contains the native splash screen.
- `App/Login/LoginViewController.swift` contains the native login form and login state handling.
- `App/Login/Services/MockLoginService.swift` defines the login service contract and mock implementation.
- `App/Web/WebViewController.swift` owns and loads the Cordova web view.
- `www/` contains the prepared web assets that Cordova loads after login.
- `platform_www/` contains Cordova platform runtime assets.
- `App.xcodeproj` and `App.xcworkspace` are the generated iOS project files.

## Native Splash Screen

Before UIKit starts the app flow, iOS displays `App/Base.lproj/CDVLaunchScreen.storyboard`. Its static background, title, subtitle, spacing, and spinner match the initial state of `SplashViewController` so the transition is visually continuous. The storyboard spinner is static because launch screens cannot run animations.

The splash screen is built in code by `SplashViewController`.

It shows:

- App title: `GJPS`
- Status text: `Preparing your workspace`
- Native loading spinner

After the splash delay, `onFinished` asks `AppFlowViewController` to show the login screen.

## Native Login Screen

The login form is built in code by `LoginViewController`.

It contains:

- Username field
- Password field
- Error message label
- Sign in button
- Demo credential hint

The login button calls `submitLogin()`, which delegates authentication through `LoginServicing`.

## Mock Login Service

`MockLoginService` is implemented in `App/Login/Services/MockLoginService.swift` and injected into `LoginViewController` by `AppFlowViewController`.

Current demo credentials:

```text
username: demo
password: demo
```

The mock service simulates network latency with a short `DispatchQueue.main.asyncAfter` delay. It returns success only when both the username and password match `demo`.

When the real login service is ready, create another `LoginServicing` implementation and inject it instead of `MockLoginService`. Keep the result contract simple:

- `success == true`: remove the native overlay and show the Cordova web view.
- `success == false`: keep the user on the native login form and show the error message.

## Web App Handoff

Cordova is not initialized during the splash or login screens. A `WebViewController` is created only after login succeeds, and Cordova's additional initial splash display is disabled.

On successful login:

1. `AppFlowViewController` removes the native login child.
2. It creates and displays `WebViewController`.
3. `WebViewController` runs Cordova's normal `MainViewController` lifecycle and loads the bundled web application.

This keeps authentication in native code while leaving the post-login application experience in Cordova web code. `CDVLaunchScreen.storyboard` is still the required static iOS system launch screen, but it is not displayed again during the native-to-web handoff.

## Logout Flow

The web app displays an iOS-only `Log out` button after Cordova's `deviceready` event. The button calls `NativeSession.logout()`, which is provided by the local Cordova plugin in `plugins/native-session`.

The plugin uses Cordova's `exec` API to invoke the iOS `NativeSession` class. The native plugin posts a logout notification, `WebViewController` calls its `onLogout` callback, and `AppFlowViewController` replaces the web controller with a new `LoginViewController`.

Keeping the JavaScript API in a Cordova plugin prevents the web application from depending directly on WebKit APIs. The plugin is installed as a local package through the `file:plugins/native-session` dependency in `package.json`.

## Cordova Prepare Notes

The `platforms/ios` directory is intentionally tracked because it contains custom native code.

Be careful when running:

```sh
cordova prepare ios
```

Cordova can refresh generated platform files and web assets. After running prepare, review the native Swift files, `Main.storyboard`, and the Xcode project changes before committing.
