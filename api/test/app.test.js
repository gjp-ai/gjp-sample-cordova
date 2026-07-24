'use strict';

const assert = require('node:assert/strict');
const { randomUUID } = require('node:crypto');
const { once } = require('node:events');
const { after, before, test } = require('node:test');
const { createApp } = require('../src/app');
const { loadConfig } = require('../src/config');

let server;
let baseUrl;

before(async () => {
  const app = createApp({ config: loadConfig({}) });
  server = app.listen(0, '127.0.0.1');
  await once(server, 'listening');
  baseUrl = `http://127.0.0.1:${server.address().port}`;
});

after(async () => {
  await new Promise((resolve, reject) => {
    server.close((error) => error ? reject(error) : resolve());
  });
});

function loginRequest(overrides = {}) {
  return {
    meta: {
      requestId: randomUUID(),
      sentAt: new Date().toISOString(),
      apiVersion: '1.0',
      channel: 'MOBILE',
      locale: 'en-SG',
      ...overrides.meta
    },
    data: {
      username: 'demo',
      password: 'demo',
      ...overrides.data
    }
  };
}

async function postJson(path, body) {
  return fetch(`${baseUrl}${path}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  });
}

test('health reports that the service is available', async () => {
  const response = await fetch(`${baseUrl}/health`);
  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), { status: 'UP' });
  assert.equal(response.headers.get('cache-control'), 'no-store');
});

test('login returns a contract-compliant session for valid credentials', async () => {
  const request = loginRequest();
  const response = await postJson('/v1/login', request);
  const payload = await response.json();

  assert.equal(response.status, 200);
  assert.equal(payload.meta.requestId, request.meta.requestId);
  assert.equal(payload.meta.outcome, 'SUCCESS');
  assert.equal(payload.data.session.tokenType, 'Bearer');
  assert.equal(payload.data.session.expiresInSeconds, 900);
  assert.ok(payload.data.session.accessToken.length >= 40);
  assert.ok(payload.data.session.refreshToken.length >= 60);
  assert.equal(payload.data.customer.customerId, 'customer-001');
  assert.deepEqual(payload.errors, []);
  assert.equal(JSON.stringify(payload).includes('password'), false);
});

test('login uses one customer-safe error for invalid credentials', async () => {
  const request = loginRequest({ data: { password: 'incorrect' } });
  const response = await postJson('/v1/login', request);
  const payload = await response.json();

  assert.equal(response.status, 401);
  assert.equal(payload.meta.requestId, request.meta.requestId);
  assert.equal(payload.meta.outcome, 'FAILURE');
  assert.equal(payload.data, null);
  assert.equal(payload.errors[0].code, 'AUTH_INVALID_CREDENTIALS');
  assert.equal(payload.errors[0].field, null);
});

test('login rejects invalid request fields', async () => {
  const request = loginRequest({ meta: { channel: 'WEB' } });
  const response = await postJson('/v1/login', request);
  const payload = await response.json();

  assert.equal(response.status, 400);
  assert.equal(payload.errors[0].code, 'REQUEST_FIELD_INVALID');
  assert.equal(payload.errors[0].field, 'meta.channel');
});

test('login rejects malformed JSON and unsupported media types', async () => {
  const malformedResponse = await fetch(`${baseUrl}/v1/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: '{invalid'
  });
  assert.equal(malformedResponse.status, 400);
  assert.equal((await malformedResponse.json()).errors[0].code, 'REQUEST_JSON_INVALID');

  const mediaTypeResponse = await fetch(`${baseUrl}/v1/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'text/plain' },
    body: 'invalid'
  });
  assert.equal(mediaTypeResponse.status, 415);
  assert.equal((await mediaTypeResponse.json()).errors[0].code, 'REQUEST_MEDIA_TYPE_UNSUPPORTED');
});

test('unknown routes return the common failure envelope', async () => {
  const response = await fetch(`${baseUrl}/v1/unknown`);
  const payload = await response.json();

  assert.equal(response.status, 404);
  assert.equal(payload.meta.outcome, 'FAILURE');
  assert.equal(payload.errors[0].code, 'RESOURCE_NOT_FOUND');
});
