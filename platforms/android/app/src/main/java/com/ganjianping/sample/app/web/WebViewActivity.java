package com.ganjianping.sample.app.web;

import android.content.Intent;
import android.os.Bundle;
import android.view.MotionEvent;

import androidx.appcompat.app.AlertDialog;

import com.ganjianping.plugins.nativesession.NativeSession;
import com.ganjianping.sample.app.login.LoginActivity;
import com.ganjianping.sample.app.session.SessionInactivityManager;
import com.ganjianping.sample.app.session.SessionStore;

import org.apache.cordova.CordovaActivity;

public final class WebViewActivity extends CordovaActivity implements NativeSession.LogoutListener {
    private SessionInactivityManager inactivityManager;
    private AlertDialog inactivityWarning;
    private boolean loggingOut;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (!SessionStore.getInstance().isAuthenticated()) {
            navigateToLogin(false);
            return;
        }

        inactivityManager = new SessionInactivityManager(new SessionInactivityManager.Listener() {
            @Override
            public void onWarning() {
                showInactivityWarning();
            }

            @Override
            public void onSessionExtended() {
                dismissInactivityWarning();
            }

            @Override
            public void onTimeout() {
                navigateToLogin(true);
            }
        });
        inactivityManager.start();

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
        navigateToLogin(false);
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent event) {
        if (event.getActionMasked() == MotionEvent.ACTION_DOWN && inactivityManager != null) {
            inactivityManager.recordInteraction();
        }
        return super.dispatchTouchEvent(event);
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (inactivityManager != null) {
            inactivityManager.resume();
        }
    }

    @Override
    protected void onPause() {
        if (inactivityManager != null) {
            inactivityManager.pause();
        }
        super.onPause();
    }

    @Override
    public void onDestroy() {
        if (inactivityManager != null) {
            inactivityManager.stop();
            inactivityManager = null;
        }
        dismissInactivityWarning();
        super.onDestroy();
    }

    private void showInactivityWarning() {
        if (isFinishing() || isDestroyed() || inactivityWarning != null) {
            return;
        }
        inactivityWarning = new AlertDialog.Builder(this)
            .setTitle("Session expiring")
            .setMessage("You will be signed out in one minute due to inactivity.")
            .setCancelable(false)
            .setPositiveButton("Stay signed in", (dialog, which) -> {
                inactivityWarning = null;
                if (inactivityManager != null) {
                    inactivityManager.recordInteraction();
                }
            })
            .create();
        inactivityWarning.show();
    }

    private void dismissInactivityWarning() {
        if (inactivityWarning != null) {
            inactivityWarning.dismiss();
            inactivityWarning = null;
        }
    }

    private void navigateToLogin(boolean sessionExpired) {
        if (loggingOut) {
            return;
        }
        loggingOut = true;
        SessionStore.getInstance().clear();
        dismissInactivityWarning();
        if (inactivityManager != null) {
            inactivityManager.stop();
        }
        Intent loginIntent = new Intent(this, LoginActivity.class);
        loginIntent.putExtra(LoginActivity.EXTRA_SESSION_EXPIRED, sessionExpired);
        loginIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(loginIntent);
        finish();
    }
}
