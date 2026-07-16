# Native API Contract

## Runtime Configuration

Android and iOS use the same application-wide settings schema:

```json
{
  "isMockMode": true,
  "apiBaseUrl": "https://api.example.com/v1",
  "requestTimeoutSeconds": 15,
  "mockResponseDelayMilliseconds": 650
}
```

- Android: `platforms/android/app/src/main/assets/app-settings.json`
- iOS: `platforms/ios/App/Resources/AppSettings.json`

When `isMockMode` is `true`, the shared native API client does not make a network request. It loads the response file assigned to the API request from the application bundle. When it is `false`, the same request is sent to `apiBaseUrl`.

This behavior belongs to the shared API client and applies to every native API, not only login. Each API request must provide a local mock response filename.

## Login

### Request

```http
POST /login
Accept: application/json
Content-Type: application/json; charset=utf-8
```

```json
{
  "username": "demo",
  "password": "demo"
}
```

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `username` | string | Yes | User login name. |
| `password` | string | Yes | User password. |

### Successful Response

HTTP status: `200`

```json
{
  "success": true,
  "message": "Login successful.",
  "data": {
    "accessToken": "access-token",
    "user": {
      "id": "user-id",
      "displayName": "User Name"
    }
  }
}
```

| Field | Type | Description |
| --- | --- | --- |
| `success` | boolean | Whether authentication succeeded. |
| `message` | string | Human-readable result message. |
| `data.accessToken` | string | Token used by authenticated API requests. |
| `data.user.id` | string | Stable user identifier. |
| `data.user.displayName` | string | User-facing name. |

### Failed Response

Expected HTTP status: `400` or `401`

```json
{
  "success": false,
  "message": "Invalid username or password.",
  "data": null
}
```

The native login screen remains visible and displays `message`. Transport failures and malformed response payloads use a local error message.

### Mock Response

- Android: `platforms/android/app/src/main/assets/mock-responses/login/login-success.json`
- iOS: `platforms/ios/App/Resources/MockResponses/Login/LoginSuccess.json`

Mock mode returns this file directly after `mockResponseDelayMilliseconds`. It does not validate the submitted credentials or contact the configured server.

The native login page can override `isMockMode` for the current screen. Enabling it displays a mock response selector with these cases:

| Scenario | HTTP status | Local payload or behavior |
| --- | --- | --- |
| Success | 200 | Valid authenticated response. |
| Invalid credentials | 401 | Failed response with an authentication message. |
| Validation error | 400 | Failed response with field validation details. |
| Account locked | 423 | Failed response indicating that access is locked. |
| Rate limited | 429 | Failed response asking the user to retry later. |
| Server error | 500 | Failed response indicating temporary service failure. |
| Malformed response | 200 | JSON that does not match the login response schema. |
| Empty response | 200 | Empty response body. |
| Missing payload | 200 | References a deliberately absent bundle file. |
| Network error | N/A | Simulated transport failure; no payload is loaded. |
| Request timeout | N/A | Simulated timeout; no payload is loaded. |

Login payloads are grouped by feature:

- Android: `platforms/android/app/src/main/assets/mock-responses/login/`
- iOS: `platforms/ios/App/Resources/MockResponses/Login/`

The login UI also handles empty username/password input before executing the request. A failed or exceptional response keeps the user on the login page, restores all controls, and displays a specific error message.

## Adding Another API

1. Add the endpoint-specific service and request/response models in the feature folder.
2. Create a feature folder and its response JSON under Android `assets/mock-responses/` and iOS `Resources/MockResponses/`.
3. Build an `ApiRequest`/`APIRequest` with the HTTP method, relative path, body, and mock response filename.
4. Execute it through the shared `ApiClient`/`APIClient`.

Do not add endpoint-specific mock service classes. Mock selection remains centralized in the application settings and shared API client.
