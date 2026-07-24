'use strict';

const express = require('express');
const { apiError, failure, success } = require('../../http/envelopes');
const { requestIdFor } = require('../../http/request-context');
const { validateLoginRequest } = require('../../http/validation');

function createLoginRouter(authService) {
  const router = express.Router();

  router.post('/login', (req, res) => {
    const requestId = requestIdFor(req, res);
    const validationError = validateLoginRequest(req.body);

    if (validationError) {
      res.status(400).json(failure(
        requestId,
        apiError('REQUEST_FIELD_INVALID', validationError.message, {
          field: validationError.field
        })
      ));
      return;
    }

    const loginResult = authService.login(req.body.data.username, req.body.data.password);
    if (!loginResult) {
      res.status(401).json(failure(
        requestId,
        apiError('AUTH_INVALID_CREDENTIALS', 'The username or password is incorrect.')
      ));
      return;
    }

    res.status(200).json(success(requestId, loginResult));
  });

  return router;
}

module.exports = { createLoginRouter };
