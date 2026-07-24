package com.ganjianping.sample.app.session;

import com.ganjianping.sample.app.login.services.LoginResult;

public final class SessionStore {
    private static final SessionStore INSTANCE = new SessionStore();

    private String accessToken;
    private String refreshToken;
    private String tokenType;
    private long expiresAtEpochMilliseconds;
    private String userId;
    private String displayName;

    private SessionStore() {
    }

    public static SessionStore getInstance() {
        return INSTANCE;
    }

    public synchronized void save(LoginResult result) {
        if (!result.isSuccess()) {
            throw new IllegalArgumentException("Only a successful login can create a session.");
        }
        accessToken = result.getAccessToken();
        refreshToken = result.getRefreshToken();
        tokenType = result.getTokenType();
        expiresAtEpochMilliseconds = result.getExpiresAtEpochMilliseconds();
        userId = result.getUserId();
        displayName = result.getDisplayName();
    }

    public synchronized String getAuthorizationHeader() {
        if (!isAuthenticated()) {
            return null;
        }
        return tokenType + " " + accessToken;
    }

    public synchronized boolean isAuthenticated() {
        return accessToken != null
            && !accessToken.isEmpty()
            && expiresAtEpochMilliseconds > System.currentTimeMillis();
    }

    public synchronized void clear() {
        accessToken = null;
        refreshToken = null;
        tokenType = null;
        expiresAtEpochMilliseconds = 0;
        userId = null;
        displayName = null;
    }
}
