package com.ganjianping.sample.app.login.services;

import org.json.JSONException;
import org.json.JSONObject;

import com.ganjianping.sample.app.network.ApiEnvelope;

public final class LoginResult {
    private final boolean success;
    private final String message;
    private final String accessToken;
    private final String refreshToken;
    private final String tokenType;
    private final long expiresAtEpochMilliseconds;
    private final String userId;
    private final String displayName;

    private LoginResult(
        boolean success,
        String message,
        String accessToken,
        String refreshToken,
        String tokenType,
        long expiresAtEpochMilliseconds,
        String userId,
        String displayName
    ) {
        this.success = success;
        this.message = message;
        this.accessToken = accessToken;
        this.refreshToken = refreshToken;
        this.tokenType = tokenType;
        this.expiresAtEpochMilliseconds = expiresAtEpochMilliseconds;
        this.userId = userId;
        this.displayName = displayName;
    }

    public static LoginResult fromJson(String payload) throws JSONException {
        ApiEnvelope envelope = ApiEnvelope.parse(payload);
        boolean success = envelope.outcome == ApiEnvelope.Outcome.SUCCESS;

        String message = success
            ? ""
            : envelope.firstErrorMessage("Unable to sign in. Please try again.");
        JSONObject data = envelope.data;
        JSONObject session = data == null ? null : data.optJSONObject("session");
        JSONObject customer = data == null ? null : data.optJSONObject("customer");

        if (success && (
            session == null
                || session.optString("accessToken").isEmpty()
                || session.optString("refreshToken").isEmpty()
                || customer == null
                || customer.optString("customerId").isEmpty()
                || !"Bearer".equals(session.optString("tokenType"))
                || session.optInt("expiresInSeconds", 0) <= 0
        )) {
            throw new JSONException("Successful login response is missing session data.");
        }

        int expiresInSeconds = session == null ? 0 : session.optInt("expiresInSeconds", 0);
        return new LoginResult(
            success,
            message,
            session == null ? "" : session.optString("accessToken", ""),
            session == null ? "" : session.optString("refreshToken", ""),
            session == null ? "" : session.optString("tokenType", ""),
            success ? System.currentTimeMillis() + expiresInSeconds * 1_000L : 0,
            customer == null ? "" : customer.optString("customerId", ""),
            customer == null ? "" : customer.optString("displayName", "")
        );
    }

    public static LoginResult failure(String message) {
        return new LoginResult(false, message, "", "", "", 0, "", "");
    }

    public boolean isSuccess() {
        return success;
    }

    public String getMessage() {
        return message;
    }

    public String getAccessToken() {
        return accessToken;
    }

    public String getRefreshToken() {
        return refreshToken;
    }

    public String getTokenType() {
        return tokenType;
    }

    public long getExpiresAtEpochMilliseconds() {
        return expiresAtEpochMilliseconds;
    }

    public String getUserId() {
        return userId;
    }

    public String getDisplayName() {
        return displayName;
    }
}
