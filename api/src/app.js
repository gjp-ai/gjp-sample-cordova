'use strict';

const express = require('express');
const { loadConfig } = require('./config');
const { AuthService } = require('./features/auth/auth-service');
const { createLoginRouter } = require('./features/auth/login-router');
const { errorHandler, notFound } = require('./http/error-handler');
const { apiError, failure } = require('./http/envelopes');
const { requestContext } = require('./http/request-context');

function createApp(options = {}) {
  const config = options.config || loadConfig();
  const authService = options.authService || new AuthService(config);
  const app = express();

  app.disable('x-powered-by');
  app.use(requestContext);
  app.use((req, res, next) => {
    res.set({
      'Cache-Control': 'no-store',
      'Content-Security-Policy': "default-src 'none'; frame-ancestors 'none'",
      'Referrer-Policy': 'no-referrer',
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY'
    });
    next();
  });

  app.get('/health', (req, res) => {
    res.status(200).json({ status: 'UP' });
  });

  app.use('/v1', (req, res, next) => {
    if (['POST', 'PUT', 'PATCH'].includes(req.method) && !req.is('application/json')) {
      res.status(415).json(failure(
        res.locals.requestId,
        apiError('REQUEST_MEDIA_TYPE_UNSUPPORTED', 'Content-Type must be application/json.')
      ));
      return;
    }
    next();
  });
  app.use(express.json({ limit: '32kb', strict: true }));
  app.use('/v1', createLoginRouter(authService));

  app.use(notFound);
  app.use(errorHandler);

  return app;
}

module.exports = { createApp };
