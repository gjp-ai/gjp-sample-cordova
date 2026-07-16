package com.ganjianping.sample.app.login;

import android.content.Intent;
import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;

import com.ganjianping.sample.app.login.services.LoginResult;
import com.ganjianping.sample.app.login.services.LoginMockScenario;
import com.ganjianping.sample.app.login.services.LoginService;
import com.ganjianping.sample.app.network.ApiClient;
import com.ganjianping.sample.app.web.WebViewActivity;

public final class LoginActivity extends AppCompatActivity {
    private LoginService loginService;
    private LoginView loginView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        loginView = new LoginView(this);
        try {
            loginService = new LoginService(new ApiClient(this));
            loginView.setMockMode(loginService.isMockMode());
        } catch (Exception error) {
            loginView.showError("The application settings are invalid.");
        }
        loginView.setListener(new LoginView.Listener() {
            @Override
            public void onLoginRequested(
                String username,
                String password,
                LoginMockScenario scenario
            ) {
                submitLogin(username, password, scenario);
            }

            @Override
            public void onMockModeChanged(boolean enabled) {
                if (loginService != null) {
                    loginService.setMockMode(enabled);
                }
            }
        });
        setContentView(loginView);
    }

    private void submitLogin(String username, String password, LoginMockScenario scenario) {
        LoginView currentLoginView = loginView;
        if (currentLoginView == null) {
            return;
        }

        currentLoginView.setLoading(true);
        if (loginService == null) {
            currentLoginView.showError("The login service is unavailable.");
            currentLoginView.setLoading(false);
            return;
        }
        loginService.login(
            username,
            password,
            scenario,
            result -> handleLoginResult(currentLoginView, result)
        );
    }

    private void handleLoginResult(LoginView sourceView, LoginResult result) {
        if (sourceView != loginView || isFinishing() || isDestroyed()) {
            return;
        }

        if (result.isSuccess()) {
            startActivity(new Intent(this, WebViewActivity.class));
            finish();
            return;
        }

        sourceView.showError(result.getMessage());
        sourceView.setLoading(false);
    }

    @Override
    protected void onDestroy() {
        loginView = null;
        if (loginService != null) {
            loginService.close();
            loginService = null;
        }
        super.onDestroy();
    }
}
