'use strict';

const { apiError, failure } = require('./envelopes');

function notFound(req, res) {
  res.status(404).json(failure(
    res.locals.requestId,
    apiError('RESOURCE_NOT_FOUND', 'The requested API resource does not exist.')
  ));
}

function errorHandler(error, req, res, next) {
  if (res.headersSent) {
    next(error);
    return;
  }

  if (error?.type === 'entity.parse.failed') {
    res.status(400).json(failure(
      res.locals.requestId,
      apiError('REQUEST_JSON_INVALID', 'The request body contains invalid JSON.')
    ));
    return;
  }

  // Log only request metadata. Request bodies may contain credentials or personal data.
  console.error('Unhandled API error', {
    requestId: res.locals.requestId,
    method: req.method,
    path: req.path,
    error: error?.message || 'Unknown error'
  });

  res.status(500).json(failure(
    res.locals.requestId,
    apiError(
      'SERVICE_TEMPORARILY_UNAVAILABLE',
      'The service is temporarily unavailable. Please try again later.',
      { retryable: true, retryAfterSeconds: 30 }
    )
  ));
}

module.exports = { errorHandler, notFound };
