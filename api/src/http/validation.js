'use strict';

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const LOCALE_PATTERN = /^[A-Za-z]{2,3}(?:-[A-Za-z0-9]{2,8})*$/;

function isPlainObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function isUuid(value) {
  return typeof value === 'string' && UUID_PATTERN.test(value);
}

function isUtcTimestamp(value) {
  return typeof value === 'string'
    && value.endsWith('Z')
    && !Number.isNaN(Date.parse(value));
}

function requiredString(value, field, maximumLength) {
  if (typeof value !== 'string' || value.trim().length === 0) {
    return { field, message: `${field} is required.` };
  }

  if (value.length > maximumLength) {
    return { field, message: `${field} must not exceed ${maximumLength} characters.` };
  }

  return null;
}

function validateLoginRequest(body) {
  if (!isPlainObject(body)) {
    return { field: null, message: 'The request body must be a JSON object.' };
  }

  if (!isPlainObject(body.meta)) {
    return { field: 'meta', message: 'meta is required.' };
  }

  if (!isUuid(body.meta.requestId)) {
    return { field: 'meta.requestId', message: 'meta.requestId must be a UUID.' };
  }

  if (!isUtcTimestamp(body.meta.sentAt)) {
    return { field: 'meta.sentAt', message: 'meta.sentAt must be an ISO 8601 UTC timestamp.' };
  }

  if (body.meta.apiVersion !== '1.0') {
    return { field: 'meta.apiVersion', message: 'meta.apiVersion must be 1.0.' };
  }

  if (body.meta.channel !== 'MOBILE') {
    return { field: 'meta.channel', message: 'meta.channel must be MOBILE.' };
  }

  if (typeof body.meta.locale !== 'string' || !LOCALE_PATTERN.test(body.meta.locale)) {
    return { field: 'meta.locale', message: 'meta.locale must be a valid locale.' };
  }

  if (!isPlainObject(body.data)) {
    return { field: 'data', message: 'data is required.' };
  }

  return requiredString(body.data.username, 'data.username', 128)
    || requiredString(body.data.password, 'data.password', 256);
}

module.exports = { isUuid, validateLoginRequest };
