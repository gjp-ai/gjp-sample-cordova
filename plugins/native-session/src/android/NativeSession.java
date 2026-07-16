package com.ganjianping.plugins.nativesession;

import android.app.Activity;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;

public final class NativeSession extends CordovaPlugin {
    public interface LogoutListener {
        void onLogoutRequested();
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) {
        if (!"logout".equals(action)) {
            return false;
        }

        Activity activity = cordova.getActivity();
        if (!(activity instanceof LogoutListener)) {
            callbackContext.error("The host activity does not support native logout.");
            return true;
        }

        callbackContext.success();
        activity.runOnUiThread(((LogoutListener) activity)::onLogoutRequested);
        return true;
    }
}
