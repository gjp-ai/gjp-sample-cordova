'use strict';

const { randomBytes, timingSafeEqual } = require('node:crypto');

function secureEquals(left, right) {
  const leftBuffer = Buffer.from(String(left));
  const rightBuffer = Buffer.from(String(right));
  const maximumLength = Math.max(leftBuffer.length, rightBuffer.length, 1);
  const paddedLeft = Buffer.alloc(maximumLength);
  const paddedRight = Buffer.alloc(maximumLength);

  leftBuffer.copy(paddedLeft);
  rightBuffer.copy(paddedRight);

  return timingSafeEqual(paddedLeft, paddedRight) && leftBuffer.length === rightBuffer.length;
}

class AuthService {
  constructor(config) {
    this.config = config;
  }

  login(username, password) {
    const user = this.config.demoUser;
    if (!secureEquals(username, user.username) || !secureEquals(password, user.password)) {
      return null;
    }

    return {
      session: {
        accessToken: randomBytes(32).toString('base64url'),
        refreshToken: randomBytes(48).toString('base64url'),
        tokenType: 'Bearer',
        expiresInSeconds: this.config.accessTokenTtlSeconds
      },
      customer: {
        customerId: user.customerId,
        displayName: user.displayName,
        lastLoginAt: new Date().toISOString()
      }
    };
  }
}

module.exports = { AuthService };
