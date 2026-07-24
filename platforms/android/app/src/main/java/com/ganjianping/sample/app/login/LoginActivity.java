package com.ganjianping.sample.app.login;

import android.content.Intent;
import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;

import com.ganjianping.sample.app.login.services.LoginResult;
import com.ganjianping.sample.app.login.services.LoginService;
import com.ganjianping.sample.app.network.ApiClient;
import com.ganjianping.sample.app.session.SessionStore;
import com.ganjianping.sample.app.web.WebViewActivity;

public final class LoginActivity extends AppCompatActivity {
    public static final String EXTRA_SESSION_EXPIRED = "sessionExpired";

    private LoginService loginService;
    private LoginView loginView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        loginView = new LoginView(this);
        try {
            loginService = new LoginService(new ApiClient(this));
        } catch (Exception error) {
            loginView.showError("The application settings are invalid.");
        }
        loginView.setListener(new LoginView.Listener() {
            @Override
            public void onNotificationsRequested() {
                startActivity(new Intent(LoginActivity.this, NotificationActivity.class));
            }

            @Override
            public void onMoreRequested() {
                startActivity(new Intent(LoginActivity.this, MoreActivity.class));
            }

            @Override
            public void onLoginRequested(
                String username,
                String password
            ) {
                submitLogin(username, password);
            }
        });
        setContentView(loginView);
        if (getIntent().getBooleanExtra(EXTRA_SESSION_EXPIRED, false)) {
            loginView.showError("Your session expired due to inactivity. Sign in again.");
        }
    }

    private void submitLogin(String username, String password) {
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
            result -> handleLoginResult(currentLoginView, result)
        );
    }

    private void handleLoginResult(LoginView sourceView, LoginResult result) {
        if (sourceView != loginView || isFinishing() || isDestroyed()) {
            return;
        }

        if (result.isSuccess()) {
            SessionStore.getInstance().save(result);
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
