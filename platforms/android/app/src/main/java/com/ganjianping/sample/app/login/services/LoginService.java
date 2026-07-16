package com.ganjianping.sample.app.login.services;

import com.ganjianping.sample.app.network.ApiClient;
import com.ganjianping.sample.app.network.ApiRequest;

import org.json.JSONObject;

public final class LoginService {
    public interface Callback {
        void onComplete(LoginResult result);
    }

    private final ApiClient apiClient;

    public LoginService(ApiClient apiClient) {
        this.apiClient = apiClient;
    }

    public void login(
        String username,
        String password,
        LoginMockScenario mockScenario,
        Callback callback
    ) {
        if (username.trim().isEmpty()) {
            callback.onComplete(LoginResult.failure("Enter your username."));
            return;
        }
        if (password.isEmpty()) {
            callback.onComplete(LoginResult.failure("Enter your password."));
            return;
        }
        try {
            JSONObject body = new JSONObject();
            body.put("username", username);
            body.put("password", password);
            ApiRequest request = new ApiRequest(
                "POST",
                "/login",
                body.toString(),
                mockScenario.responseAsset,
                mockScenario.statusCode,
                mockScenario.errorMessage
            );
            apiClient.execute(request, response -> {
                if (response.hasTransportError()) {
                    callback.onComplete(LoginResult.failure(response.errorMessage));
                    return;
                }
                try {
                    LoginResult result = LoginResult.fromJson(response.body);
                    if (response.statusCode < 200 || response.statusCode >= 300) {
                        callback.onComplete(LoginResult.failure(result.getMessage()));
                    } else {
                        callback.onComplete(result);
                    }
                } catch (Exception error) {
                    callback.onComplete(LoginResult.failure("The login response is invalid."));
                }
            });
        } catch (Exception error) {
            callback.onComplete(LoginResult.failure("Unable to create the login request."));
        }
    }

    public void close() {
        apiClient.close();
    }

    public boolean isMockMode() {
        return apiClient.isMockMode();
    }

    public void setMockMode(boolean enabled) {
        apiClient.setMockMode(enabled);
    }
}
