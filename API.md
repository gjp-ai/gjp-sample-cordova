# Native Finance API Contract

The local reference implementation is under `api/`. It exposes the versioned login route at `POST /v1/login`; the endpoint paths below are relative to the configured `/v1` base URL.

## Design Rules

All native APIs use a consistent JSON envelope. Endpoint-specific fields belong under `data`; transport and correlation fields belong under `meta`.

- Use HTTPS only outside mock mode.
- Use UUID request and response identifiers for tracing. Never use them as business identifiers.
- Use ISO 8601 UTC timestamps with milliseconds, such as `2026-07-17T08:30:00.000Z`.
- Represent monetary values as decimal strings plus ISO 4217 currency codes. Never use JSON floating-point numbers for money.
- Use opaque identifiers for customers, accounts, payments, and transactions.
- Return masked account and card labels for display. Do not expose full account or card numbers.
- Keep access tokens in the `Authorization: Bearer <token>` header after login, not in later request bodies.
- Require an `Idempotency-Key` header for money-moving commands such as payments and transfers.
- Never log passwords, tokens, personal data, or complete request/response bodies in production.

## Runtime Configuration

Android and iOS use the same application-wide settings schema:

```json
{
  "isMockMode": false,
  "apiBaseUrl": "https://api.example.com/v1",
  "requestTimeoutSeconds": 15,
  "mockResponseDelayMilliseconds": 650
}
```

- Android: `platforms/android/app/src/main/assets/app-settings.json`
- iOS: `platforms/ios/App/Resources/AppSettings.json`

When `isMockMode` is enabled, the shared API client loads the response file assigned to a request by default. Otherwise, it sends requests to `apiBaseUrl`. Login has a credential-based per-request override: username `mock` selects a local response, while every other username uses the real endpoint. There is no mock control in the login UI.

## Request Envelope

Every JSON request uses this shape:

```json
{
  "meta": {
    "requestId": "89feea61-aadc-4fc8-9610-9d6dc57403fc",
    "sentAt": "2026-07-17T08:30:00.000Z",
    "apiVersion": "1.0",
    "channel": "MOBILE",
    "locale": "en-SG"
  },
  "data": {}
}
```

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `meta.requestId` | UUID string | Yes | Client-generated correlation identifier. |
| `meta.sentAt` | UTC timestamp | Yes | Time the client created the request. |
| `meta.apiVersion` | string | Yes | Contract version, independent of the app version. |
| `meta.channel` | string | Yes | Calling channel; native apps send `MOBILE`. |
| `meta.locale` | BCP 47 string | Yes | Locale used for customer-facing messages. |
| `data` | object | Yes | Endpoint-specific request payload. |

## Response Envelope

Every JSON response uses this shape:

```json
{
  "meta": {
    "requestId": "89feea61-aadc-4fc8-9610-9d6dc57403fc",
    "responseId": "fa6c6202-ec11-4ca9-91d9-fb9e4bc5619d",
    "respondedAt": "2026-07-17T08:30:00.250Z",
    "outcome": "SUCCESS"
  },
  "data": {},
  "errors": []
}
```

`outcome` is `SUCCESS`, `FAILURE`, or `PARTIAL`. A successful response has endpoint data and an empty `errors` array. A failed response normally has `data: null` and at least one error. `PARTIAL` is reserved for operations where some independently actionable items succeeded.

Each error uses this shape:

```json
{
  "code": "AUTH_RATE_LIMITED",
  "message": "Too many sign-in attempts. Please try again later.",
  "field": null,
  "retryable": true,
  "retryAfterSeconds": 60
}
```

`code` is stable and machine-readable. `message` is safe to show to the customer and must not reveal internal systems or security decisions. `field` is an optional request path. `retryAfterSeconds` is present only when the server can provide useful retry guidance.

## HTTP Statuses

| Status | Usage |
| --- | --- |
| `200` | Successful query or command. |
| `201` | Resource created. |
| `202` | Command accepted for asynchronous processing. |
| `400` | Invalid request fields or envelope. |
| `401` | Authentication failed or token is invalid. |
| `403` | Authenticated customer is not permitted. |
| `404` | Requested business resource does not exist. |
| `409` | Business conflict or duplicate command. |
| `423` | Account or security access is locked. |
| `429` | Rate limit exceeded. |
| `500` | Unexpected server failure. |
| `503` | Service temporarily unavailable. |

The client evaluates both the HTTP status and response envelope. It must not treat `200` as success when `meta.outcome` is `FAILURE`, or accept `SUCCESS` from a non-2xx response.

## Login API

### Request

```http
POST /login
Accept: application/json
Content-Type: application/json; charset=utf-8
```

```json
{
  "meta": {
    "requestId": "89feea61-aadc-4fc8-9610-9d6dc57403fc",
    "sentAt": "2026-07-17T08:30:00.000Z",
    "apiVersion": "1.0",
    "channel": "MOBILE",
    "locale": "en-SG"
  },
  "data": {
    "username": "demo",
    "password": "demo"
  }
}
```

Both credential fields are required strings. The server must return the same customer-safe error for an unknown username and an incorrect password to avoid account enumeration.

### Success

```json
{
  "meta": {
    "requestId": "89feea61-aadc-4fc8-9610-9d6dc57403fc",
    "responseId": "fa6c6202-ec11-4ca9-91d9-fb9e4bc5619d",
    "respondedAt": "2026-07-17T08:30:00.250Z",
    "outcome": "SUCCESS"
  },
  "data": {
    "session": {
      "accessToken": "access-token",
      "refreshToken": "refresh-token",
      "tokenType": "Bearer",
      "expiresInSeconds": 900
    },
    "customer": {
      "customerId": "customer-001",
      "displayName": "Demo User",
      "lastLoginAt": "2026-07-16T08:30:00.000Z"
    }
  },
  "errors": []
}
```

Tokens are returned only by authentication/refresh endpoints. The sample retains them only in native process memory, adds the access token to authenticated native API requests, and clears the session on logout or inactivity timeout. A production app that needs session restoration must use Keychain or Android Keystore-backed storage. `lastLoginAt` supports customer security awareness and is not used for authorization decisions.

### Failure

```json
{
  "meta": {
    "requestId": "89feea61-aadc-4fc8-9610-9d6dc57403fc",
    "responseId": "fa6c6202-ec11-4ca9-91d9-fb9e4bc5619d",
    "respondedAt": "2026-07-17T08:30:00.250Z",
    "outcome": "FAILURE"
  },
  "data": null,
  "errors": [
    {
      "code": "AUTH_INVALID_CREDENTIALS",
      "message": "The username or password is incorrect.",
      "field": null,
      "retryable": false
    }
  ]
}
```

## Login Mock Scenarios

Enter username `mock` and use the scenario name as the password. For example, `mock` / `success` loads the successful response. Hyphenated passwords select the remaining scenarios.

| Password | HTTP status | Code or behavior |
| --- | --- | --- |
| `success` | 200 | Valid session and customer data. |
| `invalid-credentials` | 401 | `AUTH_INVALID_CREDENTIALS`. |
| `validation-error` | 400 | `REQUEST_FIELD_INVALID`. |
| `account-locked` | 423 | `AUTH_ACCOUNT_LOCKED`. |
| `rate-limited` | 429 | `AUTH_RATE_LIMITED`, retry after 60 seconds. |
| `server-error` | 500 | `SERVICE_TEMPORARILY_UNAVAILABLE`, retry after 30 seconds. |
| `malformed-response` | 200 | JSON outside the response contract. |
| `empty-response` | 200 | Empty response body. |
| `missing-payload` | 200 | Valid envelope with missing endpoint data. |
| `network-error` | N/A | Simulated transport failure. |
| `timeout` | N/A | Simulated timeout. |

- Android: `platforms/android/app/src/main/assets/mock-responses/login/`
- iOS: `platforms/ios/App/Resources/MockResponses/Login/`

## Adding Another API

1. Define endpoint-specific request and response `data` models while reusing the common envelopes.
2. Use decimal strings and ISO currency codes for every monetary field.
3. Assign documented stable error codes and HTTP statuses.
4. Add payloads under a feature folder in Android `assets/mock-responses/` and iOS `Resources/MockResponses/`.
5. Execute the request through the shared API client; do not add endpoint-specific mock service classes.
6. For payment or transfer commands, send an `Idempotency-Key` and return the same result for retries with that key.
