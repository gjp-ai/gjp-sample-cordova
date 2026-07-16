package com.ganjianping.sample.app.login.services;

public interface LoginService {
    interface Callback {
        void onComplete(LoginResult result);
    }

    void login(String username, String password, Callback callback);

    void cancel();
}
