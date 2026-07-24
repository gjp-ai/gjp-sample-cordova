'use strict';

function readPositiveInteger(value, fallback, name) {
  if (value === undefined || value === '') {
    return fallback;
  }

  const parsed = Number(value);
  if (!Number.isSafeInteger(parsed) || parsed <= 0) {
    throw new Error(`${name} must be a positive integer.`);
  }

  return parsed;
}

function loadConfig(environment = process.env) {
  return Object.freeze({
    host: environment.API_HOST || '127.0.0.1',
    port: readPositiveInteger(environment.API_PORT, 3000, 'API_PORT'),
    accessTokenTtlSeconds: readPositiveInteger(
      environment.API_ACCESS_TOKEN_TTL_SECONDS,
      900,
      'API_ACCESS_TOKEN_TTL_SECONDS'
    ),
    demoUser: Object.freeze({
      username: environment.API_DEMO_USERNAME || 'demo',
      password: environment.API_DEMO_PASSWORD || 'demo',
      customerId: 'customer-001',
      displayName: 'Demo User'
    })
  });
}

module.exports = { loadConfig };
