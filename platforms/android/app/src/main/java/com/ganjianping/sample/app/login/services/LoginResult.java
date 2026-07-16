package com.ganjianping.sample.app.login.services;

import org.json.JSONException;
import org.json.JSONObject;

public final class LoginResult {
    private final boolean success;
    private final String message;
    private final String accessToken;
    private final String userId;
    private final String displayName;

    private LoginResult(
        boolean success,
        String message,
        String accessToken,
        String userId,
        String displayName
    ) {
        this.success = success;
        this.message = message;
        this.accessToken = accessToken;
        this.userId = userId;
        this.displayName = displayName;
    }

    public static LoginResult fromJson(String payload) throws JSONException {
        JSONObject response = new JSONObject(payload);
        if (!response.has("success")) {
            throw new JSONException("Missing success field.");
        }
        boolean success = response.getBoolean("success");
        String message = response.optString(
            "message",
            success ? "" : "Unable to sign in. Please try again."
        );
        JSONObject data = response.optJSONObject("data");
        JSONObject user = data == null ? null : data.optJSONObject("user");

        if (success && (data == null || data.optString("accessToken").isEmpty() || user == null)) {
            throw new JSONException("Successful login response is missing session data.");
        }

        return new LoginResult(
            success,
            message,
            data == null ? "" : data.optString("accessToken", ""),
            user == null ? "" : user.optString("id", ""),
            user == null ? "" : user.optString("displayName", "")
        );
    }

    public static LoginResult failure(String message) {
        return new LoginResult(false, message, "", "", "");
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

    public String getUserId() {
        return userId;
    }

    public String getDisplayName() {
        return displayName;
    }
}
