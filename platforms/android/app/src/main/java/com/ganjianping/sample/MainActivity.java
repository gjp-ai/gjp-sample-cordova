/**
    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.
*/

package com.ganjianping.sample;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.graphics.Color;
import android.graphics.Typeface;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import org.apache.cordova.*;

public class MainActivity extends CordovaActivity
{
    private final MockLoginService loginService = new MockLoginService();
    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    private EditText usernameInput;
    private EditText passwordInput;
    private Button loginButton;
    private TextView errorText;

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

        // enable Cordova apps to be started in the background
        Bundle extras = getIntent().getExtras();
        if (extras != null && extras.getBoolean("cdvStartInBackground", false)) {
            moveTaskToBack(true);
        }

        showSplashScreen();
    }

    private void showSplashScreen() {
        LinearLayout splash = baseLayout();
        TextView title = label("GJPS", 34, Color.WHITE);
        title.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        splash.addView(title, centeredParams());
        TextView subtitle = label("Preparing your workspace", 15, 0xFFD6E4FF);
        splash.addView(subtitle, centeredParams());
        ProgressBar progress = new ProgressBar(this);
        LinearLayout.LayoutParams progressParams = centeredParams();
        progressParams.topMargin = 32;
        splash.addView(progress, progressParams);
        setContentView(splash);

        mainHandler.postDelayed(this::showLoginScreen, 900);
    }

    private void showLoginScreen() {
        LinearLayout screen = baseLayout();
        screen.setBackgroundColor(0xFFF5F7FB);

        TextView title = label("Welcome back", 30, 0xFF12213A);
        title.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        screen.addView(title, centeredParams());
        TextView subtitle = label("Sign in to continue", 16, 0xFF5E6C84);
        screen.addView(subtitle, centeredParams());

        LinearLayout form = new LinearLayout(this);
        form.setOrientation(LinearLayout.VERTICAL);
        form.setPadding(32, 36, 32, 0);
        screen.addView(form, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        usernameInput = input("Username");
        passwordInput = input("Password");
        passwordInput.setInputType(0x81);
        form.addView(usernameInput, fieldParams());
        form.addView(passwordInput, fieldParams());

        errorText = label("", 14, 0xFFB42318);
        errorText.setVisibility(View.GONE);
        form.addView(errorText, fieldParams());

        loginButton = new Button(this);
        loginButton.setText("Sign in");
        loginButton.setTextColor(Color.WHITE);
        loginButton.setBackgroundColor(0xFF1D5FD1);
        loginButton.setOnClickListener(view -> submitLogin());
        form.addView(loginButton, fieldParams());

        TextView hint = label("Demo credentials: demo / demo", 13, 0xFF6B778C);
        LinearLayout.LayoutParams hintParams = centeredParams();
        hintParams.topMargin = 24;
        screen.addView(hint, hintParams);
        setContentView(screen);
    }

    private void submitLogin() {
        String username = usernameInput.getText().toString().trim();
        String password = passwordInput.getText().toString();
        errorText.setVisibility(View.GONE);
        loginButton.setEnabled(false);
        loginButton.setText("Signing in...");
        loginService.login(username, password, result -> runOnUiThread(() -> {
            if (result.success) {
                Toast.makeText(this, "Signed in", Toast.LENGTH_SHORT).show();
                loadUrl(launchUrl);
            } else {
                errorText.setText(result.message);
                errorText.setVisibility(View.VISIBLE);
                loginButton.setEnabled(true);
                loginButton.setText("Sign in");
            }
        }));
    }

    private LinearLayout baseLayout() {
        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setGravity(Gravity.CENTER);
        layout.setPadding(24, 24, 24, 24);
        layout.setBackgroundColor(0xFF123B72);
        return layout;
    }

    private TextView label(String text, int size, int color) {
        TextView label = new TextView(this);
        label.setText(text);
        label.setTextSize(size);
        label.setTextColor(color);
        label.setGravity(Gravity.CENTER);
        return label;
    }

    private EditText input(String hint) {
        EditText input = new EditText(this);
        input.setHint(hint);
        input.setTextSize(16);
        input.setSingleLine(true);
        input.setPadding(16, 12, 16, 12);
        return input;
    }

    private LinearLayout.LayoutParams centeredParams() {
        return new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
    }

    private LinearLayout.LayoutParams fieldParams() {
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.bottomMargin = 14;
        return params;
    }

    private static final class MockLoginService {
        void login(String username, String password, Callback callback) {
            new Handler(Looper.getMainLooper()).postDelayed(() -> {
                boolean valid = "demo".equals(username) && "demo".equals(password);
                callback.complete(new LoginResult(valid, valid ? "" : "Use the demo credentials shown below."));
            }, 650);
        }
    }

    private interface Callback {
        void complete(LoginResult result);
    }

    private static final class LoginResult {
        final boolean success;
        final String message;

        LoginResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }
    }
}
