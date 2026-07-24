'use strict';

const { randomUUID } = require('node:crypto');
const { isUuid } = require('./validation');

function requestContext(req, res, next) {
  const suppliedRequestId = req.get('X-Request-ID');
  res.locals.requestId = isUuid(suppliedRequestId) ? suppliedRequestId : randomUUID();
  res.set('X-Request-ID', res.locals.requestId);
  next();
}

function requestIdFor(req, res) {
  return isUuid(req.body?.meta?.requestId)
    ? req.body.meta.requestId
    : res.locals.requestId;
}

module.exports = { requestContext, requestIdFor };
