package com.ganjianping.sample.app.login.services;

import android.os.Handler;
import android.os.Looper;

public final class MockLoginService implements LoginService {
    private static final long RESPONSE_DELAY_MS = 650L;

    private final Handler handler = new Handler(Looper.getMainLooper());

    @Override
    public void login(String username, String password, Callback callback) {
        handler.removeCallbacksAndMessages(null);
        handler.postDelayed(() -> {
            boolean valid = "demo".equals(username) && "demo".equals(password);
            callback.onComplete(valid ? LoginResult.success() : LoginResult.invalidCredentials());
        }, RESPONSE_DELAY_MS);
    }

    @Override
    public void cancel() {
        handler.removeCallbacksAndMessages(null);
    }
}
