package com.ganjianping.sample.app.splash;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.splashscreen.SplashScreen;

import com.ganjianping.sample.app.login.LoginActivity;

public final class SplashActivity extends AppCompatActivity {
    private static final long SPLASH_DURATION_MS = 3_000L;

    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    private final Runnable openLogin = this::openLogin;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        SplashScreen.installSplashScreen(this);
        super.onCreate(savedInstanceState);

        setContentView(new SplashView(this));
        mainHandler.postDelayed(openLogin, SPLASH_DURATION_MS);
    }

    private void openLogin() {
        startActivity(new Intent(this, LoginActivity.class));
        finish();
    }

    @Override
    protected void onDestroy() {
        mainHandler.removeCallbacksAndMessages(null);
        super.onDestroy();
    }
}
