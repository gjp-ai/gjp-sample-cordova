'use strict';

const { randomUUID } = require('node:crypto');

function responseMeta(requestId, outcome) {
  return {
    requestId,
    responseId: randomUUID(),
    respondedAt: new Date().toISOString(),
    outcome
  };
}

function success(requestId, data) {
  return {
    meta: responseMeta(requestId, 'SUCCESS'),
    data,
    errors: []
  };
}

function failure(requestId, error) {
  return {
    meta: responseMeta(requestId, 'FAILURE'),
    data: null,
    errors: [error]
  };
}

function apiError(code, message, options = {}) {
  const error = {
    code,
    message,
    field: options.field ?? null,
    retryable: options.retryable ?? false
  };

  if (options.retryAfterSeconds !== undefined) {
    error.retryAfterSeconds = options.retryAfterSeconds;
  }

  return error;
}

module.exports = { apiError, failure, success };
