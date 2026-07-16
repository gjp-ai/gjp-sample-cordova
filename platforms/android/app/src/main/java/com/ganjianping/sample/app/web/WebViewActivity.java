package com.ganjianping.sample.app.web;

import android.content.Intent;
import android.os.Bundle;

import com.ganjianping.plugins.nativesession.NativeSession;
import com.ganjianping.sample.app.login.LoginActivity;

import org.apache.cordova.CordovaActivity;

public final class WebViewActivity extends CordovaActivity implements NativeSession.LogoutListener {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Bundle extras = getIntent().getExtras();
        if (extras != null && extras.getBoolean("cdvStartInBackground", false)) {
            moveTaskToBack(true);
        }

        loadUrl(launchUrl);
    }

    @Override
    protected boolean showInitialSplashScreen() {
        return false;
    }

    @Override
    public void onLogoutRequested() {
        Intent loginIntent = new Intent(this, LoginActivity.class);
        loginIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        startActivity(loginIntent);
        finish();
    }
}
