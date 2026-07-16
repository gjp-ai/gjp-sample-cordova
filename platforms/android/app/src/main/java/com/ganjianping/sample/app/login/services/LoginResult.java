package com.ganjianping.sample.app.login.services;

public final class LoginResult {
    private final boolean success;
    private final String message;

    private LoginResult(boolean success, String message) {
        this.success = success;
        this.message = message;
    }

    public static LoginResult success() {
        return new LoginResult(true, "");
    }

    public static LoginResult invalidCredentials() {
        return new LoginResult(false, "Use the demo credentials shown below.");
    }

    public boolean isSuccess() {
        return success;
    }

    public String getMessage() {
        return message;
    }
}
