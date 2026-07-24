'use strict';

const { createApp } = require('./app');
const { loadConfig } = require('./config');

const config = loadConfig();
const app = createApp({ config });
const server = app.listen(config.port, config.host, () => {
  console.log(`GJP sample API listening on http://${config.host}:${config.port}`);
});

function shutdown(signal) {
  console.log(`${signal} received; closing HTTP server.`);
  server.close((error) => {
    if (error) {
      console.error('Failed to close HTTP server', error);
      process.exitCode = 1;
    }
  });
}

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));
