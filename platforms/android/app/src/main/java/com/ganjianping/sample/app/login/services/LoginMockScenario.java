package com.ganjianping.sample.app.login.services;

public enum LoginMockScenario {
    SUCCESS("Success", "mock-responses/login/login-success.json", 200, null),
    INVALID_CREDENTIALS("Invalid credentials", "mock-responses/login/login-invalid-credentials.json", 401, null),
    VALIDATION_ERROR("Validation error", "mock-responses/login/login-validation-error.json", 400, null),
    ACCOUNT_LOCKED("Account locked", "mock-responses/login/login-account-locked.json", 423, null),
    RATE_LIMITED("Rate limited", "mock-responses/login/login-rate-limited.json", 429, null),
    SERVER_ERROR("Server error", "mock-responses/login/login-server-error.json", 500, null),
    MALFORMED_RESPONSE("Malformed response", "mock-responses/login/login-malformed.json", 200, null),
    EMPTY_RESPONSE("Empty response", "mock-responses/login/login-empty.json", 200, null),
    MISSING_PAYLOAD("Missing payload", "mock-responses/login/login-missing.json", 200, null),
    NETWORK_ERROR("Network error", null, 0, "Unable to connect to the login service."),
    TIMEOUT("Request timeout", null, 0, "The login request timed out. Please try again.");

    public static final String MOCK_USERNAME = "mock";

    public final String title;
    public final String responseAsset;
    public final int statusCode;
    public final String errorMessage;

    LoginMockScenario(String title, String responseAsset, int statusCode, String errorMessage) {
        this.title = title;
        this.responseAsset = responseAsset;
        this.statusCode = statusCode;
        this.errorMessage = errorMessage;
    }

    @Override
    public String toString() {
        return title;
    }

    public static LoginMockScenario fromPassword(String password) {
        String normalized = password.trim().toLowerCase().replace('_', '-');
        for (LoginMockScenario scenario : values()) {
            String scenarioName = scenario.name().toLowerCase().replace('_', '-');
            if (scenarioName.equals(normalized)) {
                return scenario;
            }
        }
        return null;
    }
}
