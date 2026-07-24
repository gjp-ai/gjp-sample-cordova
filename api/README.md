# GJP Sample API

Standalone Node.js and Express implementation of the native mobile API contract in [`../API.md`](../API.md).

## Run Locally

From the repository root:

```sh
npm run api:install
npm run api:dev
```

The default listener is `http://127.0.0.1:3000`. Check it with:

```sh
curl http://127.0.0.1:3000/health
```

The implemented application endpoint is `POST /v1/login`. Local sample credentials are `demo` / `demo`. Override them and other settings with environment variables listed in `.env.example`; do not commit a real `.env` file.

The server reads environment variables from its process. For example:

```sh
API_DEMO_USERNAME=local-user API_DEMO_PASSWORD='local-password' npm run api:start
```

Run automated tests with:

```sh
npm run api:test
```

## Mobile Configuration

Set each native `apiBaseUrl` to the deployed HTTPS server plus `/v1`. Android emulators reach a service on the development machine through `10.0.2.2`; iOS simulators use the Mac host. Keep cleartext HTTP limited to local debug configuration and use HTTPS for shared environments and production.

This sample authentication implementation issues cryptographically random opaque tokens but does not persist accounts or sessions. Replace the demo credential provider and add a durable, encrypted session store before production use.
