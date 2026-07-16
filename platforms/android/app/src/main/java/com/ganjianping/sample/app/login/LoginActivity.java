package com.ganjianping.sample.app.login;

import android.content.Intent;
import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;

import com.ganjianping.sample.app.login.services.LoginResult;
import com.ganjianping.sample.app.login.services.LoginService;
import com.ganjianping.sample.app.login.services.MockLoginService;
import com.ganjianping.sample.app.web.WebViewActivity;

public final class LoginActivity extends AppCompatActivity {
    private final LoginService loginService = new MockLoginService();

    private LoginView loginView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        loginView = new LoginView(this);
        loginView.setListener(this::submitLogin);
        setContentView(loginView);
    }

    private void submitLogin(String username, String password) {
        LoginView currentLoginView = loginView;
        if (currentLoginView == null) {
            return;
        }

        currentLoginView.setLoading(true);
        loginService.login(username, password, result -> handleLoginResult(currentLoginView, result));
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
        loginService.cancel();
        super.onDestroy();
    }
}
