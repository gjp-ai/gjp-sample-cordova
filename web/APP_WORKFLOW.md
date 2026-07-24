# Web Application Workflow

## Overview

The React application has two runtime modes:

- **Browser mode** runs directly in a desktop or mobile browser. React owns login, session state, and logout.
- **Cordova mode** runs inside the Android or iOS web view. Native code owns splash, login, and logout, while React provides the authenticated application UI.

Both modes render the same post-login React views from `web/src`. The difference is which layer authenticates the user and controls the session.

## Source And Build Flow

The editable web source is under `web/`:

```text
web/
├── index.html
├── public/
│   └── cordova.js
└── src/
    ├── App.jsx
    ├── main.jsx
    ├── components/
    ├── features/
    │   ├── auth/
    │   ├── home/
    │   ├── accounts/
    │   ├── pay/
    │   └── more/
    ├── hooks/
    │   └── useNativeSession.js
    └── navigation/
```

Vite builds this source into the root `www/` directory:

```text
web/ source -> Vite build -> www/ -> native:web-sync -> platform web assets
```

The platform destinations are:

- Android: `platforms/android/app/src/main/assets/www/`
- iOS: `platforms/ios/www/`

The React application files in `www/` and the platform web asset directories are generated output. Make React changes in `web/`, not in those generated directories. The Cordova runtime and `NativeSession` plugin files inside the platform directories are committed native-project dependencies and are preserved by the sync script.

Run `npm run native:web-sync` to build React and synchronize it to both native projects. Normal builds do not run `cordova prepare`; that command is reserved for intentional Cordova dependency migrations through the guarded prepare scripts documented in the root `README.md`.

## Browser Mode

Start browser development with:

```sh
npm run web:dev
```

The browser loads `web/index.html`, then `web/src/main.jsx` mounts `App` into the `#root` element.

```text
Browser opens Vite URL
        |
        v
main.jsx mounts App
        |
        v
useWebSession reads sessionStorage
        |
        +-- no session --> React LoginPage
        |                     |
        |                     v
        |              mockAuthService
        |                     |
        |                     v
        +-------------- authenticated app
                              |
                              v
                     Home / Accounts /
                     Pay & Transfer / More
                              |
                              v
                     React logout clears session
                              |
                              v
                         LoginPage
```

### Browser Login

`useWebSession` checks the `sample-finance.web-authenticated` value in browser `sessionStorage`. If it is absent, `App` renders `LoginPage`.

`LoginPage` sends the entered credentials to `authenticateWithMock`. The current mock credentials are:

```text
Username: demo
Password: demo
```

After a successful login, the hook stores the session flag and React renders the application. The session lasts for the current browser tab session. Closing the tab or logging out removes access to the authenticated UI.

### Browser Logout

The logout button in the More view calls `useWebSession.logout()`. This removes the session flag and updates React state, causing `App` to render `LoginPage` again.

No Cordova API is available or required in browser mode. `web/public/cordova.js` is a browser placeholder so the shared HTML can reference `/cordova.js` without producing a missing-file error during browser development and Vite builds.

## Android Mode

Android owns the initial authentication flow:

```text
Android system launch screen
        |
        v
SplashActivity
        |
        v
LoginActivity + LoginService
        |
        v
WebViewActivity (CordovaActivity)
        |
        v
React App detects window.cordova
        |
        v
Authenticated React views
        |
        v
NativeSession.logout()
        |
        v
WebViewActivity finishes -> LoginActivity
```

`SplashActivity` is the launcher activity. It shows the native splash, then opens `LoginActivity`. Reserved `mock` credentials load a local response; ordinary credentials call the real API. A successful login creates the native session and `WebViewActivity`; only this activity extends `CordovaActivity` and loads the bundled `www/index.html`.

When React starts inside the web view, Cordova provides `window.cordova`. `useWebSession` treats that as an authenticated native host and skips `LoginPage`, because native login has already succeeded.

For logout, the More view calls `window.NativeSession.logout()`. The plugin invokes the Android `NativeSession` implementation through Cordova `exec`. `WebViewActivity` receives the request, opens a fresh `LoginActivity`, and finishes the current Cordova activity.

Native touch monitoring warns after one inactive minute and forces the same logout flow after two inactive minutes.

See `platforms/android/APP_WORKFLOW.md` for the complete Android activity lifecycle.

## iOS Mode

iOS also owns the initial authentication flow:

```text
iOS launch storyboard
        |
        v
AppFlowViewController
        |
        v
SplashViewController
        |
        v
LoginViewController + LoginService
        |
        v
WebViewController (Cordova MainViewController)
        |
        v
React App detects window.cordova
        |
        v
Authenticated React views
        |
        v
NativeSession.logout()
        |
        v
AppFlowViewController replaces web with login
```

`Main.storyboard` creates `AppFlowViewController`. It coordinates the native splash, native login, and Cordova web controllers. Cordova is initialized only after native login succeeds and `WebViewController` is created.

As on Android, `useWebSession` detects `window.cordova` and skips the React login. After Cordova fires `deviceready`, the `NativeSession` JavaScript API is available to the More view.

For logout, `window.NativeSession.logout()` invokes the iOS plugin through Cordova `exec`. The plugin posts `NativeSessionDidRequestLogout`; `WebViewController` observes it and asks `AppFlowViewController` to replace the web controller with a new `LoginViewController`.

Native touch monitoring warns after one inactive minute and forces the same logout flow after two inactive minutes.

See `platforms/ios/APP_WORKFLOW.md` for the complete iOS controller lifecycle.

## Runtime Detection And Session Ownership

The runtime split is implemented by two hooks:

- `features/auth/hooks/useWebSession.js` detects the Cordova host and owns browser authentication state.
- `hooks/useNativeSession.js` waits for the Cordova plugin and exposes native logout to React.

| Behavior | Browser | Android | iOS |
| --- | --- | --- | --- |
| Splash | None | Native | Native |
| Login UI | React `LoginPage` | Native `LoginActivity` | Native `LoginViewController` |
| Login service | Web mock | Native mock or real API | Native mock or real API |
| Session owner | React + `sessionStorage` | Native `SessionStore` | Native `SessionStore` |
| Application UI | React | React in Cordova | React in Cordova |
| Logout handler | React | `NativeSession` plugin | `NativeSession` plugin |

## Cordova Plugin Handoff

The local plugin source is in `plugins/native-session/` and exposes one JavaScript function:

```js
window.NativeSession.logout(successCallback, errorCallback);
```

The plugin source and each platform implementation are committed to the repository. The guarded prepare command refreshes them only during an intentional Cordova migration:

```text
React More view
      |
      v
useNativeSession
      |
      v
window.NativeSession.logout
      |
      v
cordova.exec("NativeSession", "logout")
      |
      +-- Android: WebViewActivity.onLogoutRequested()
      |
      +-- iOS: NativeSessionDidRequestLogout notification
```

The web application does not call Android or iOS APIs directly. This keeps React platform-independent and puts native navigation in the layer that owns it.

## Where To Make Changes

| Change | Source location |
| --- | --- |
| Browser login screen | `web/src/features/auth/LoginPage.jsx` and `login.css` |
| Browser login behavior | `web/src/features/auth/hooks/useWebSession.js` |
| Browser mock credentials/service | `web/src/features/auth/services/mockAuthService.js` |
| Main authenticated UI | `web/src/features/` and `web/src/components/` |
| Logout button | `web/src/features/more/MoreView.jsx` |
| Cordova logout hook | `web/src/hooks/useNativeSession.js` |
| Shared plugin contract | `plugins/native-session/` |
| Android native flow | `platforms/android/app/src/main/java/com/ganjianping/sample/app/` |
| iOS native flow | `platforms/ios/App/` |

After changing web source, validate both modes:

```sh
npm run web:build
npm run native:web-sync
npm run android:simulator
npm run ios:simulator
```

Use `npm run web:dev` for browser testing, then run the native applications to verify Cordova detection and plugin logout behavior.
