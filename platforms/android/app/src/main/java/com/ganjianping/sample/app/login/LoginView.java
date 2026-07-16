package com.ganjianping.sample.app.login;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.text.InputType;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ArrayAdapter;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.Spinner;
import android.widget.TextView;

import androidx.appcompat.widget.SwitchCompat;

import com.ganjianping.sample.app.login.services.LoginMockScenario;

public final class LoginView extends ScrollView {
    public interface Listener {
        void onLoginRequested(String username, String password, LoginMockScenario scenario);

        void onMockModeChanged(boolean enabled);
    }

    private static final int BACKGROUND_COLOR = 0xFFF5F7FB;
    private static final int TITLE_COLOR = 0xFF12213A;
    private static final int SECONDARY_COLOR = 0xFF5E6C84;
    private static final int ACTION_COLOR = 0xFF1D5FD1;
    private static final int ERROR_COLOR = 0xFFB42318;

    private final EditText usernameInput;
    private final EditText passwordInput;
    private final TextView errorText;
    private final TextView demoCredentialsHint;
    private final Button loginButton;
    private final SwitchCompat mockModeSwitch;
    private final Spinner mockScenarioSpinner;

    private Listener listener;

    public LoginView(Context context) {
        super(context);
        setFillViewport(true);
        setBackgroundColor(BACKGROUND_COLOR);

        LinearLayout content = new LinearLayout(context);
        content.setOrientation(LinearLayout.VERTICAL);
        content.setGravity(Gravity.CENTER);
        content.setPadding(dp(28), dp(32), dp(28), dp(32));
        addView(content, new LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        ));

        TextView title = label("Welcome back", 30, TITLE_COLOR);
        title.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        content.addView(title, itemParams(0));
        content.addView(label("Sign in to continue", 16, SECONDARY_COLOR), itemParams(8));

        usernameInput = input("Username");
        passwordInput = input("Password");
        passwordInput.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
        passwordInput.setImeOptions(EditorInfo.IME_ACTION_GO);

        usernameInput.setImeOptions(EditorInfo.IME_ACTION_NEXT);
        usernameInput.setOnEditorActionListener((view, actionId, event) -> {
            if (actionId == EditorInfo.IME_ACTION_NEXT) {
                passwordInput.requestFocus();
                return true;
            }
            return false;
        });
        content.addView(usernameInput, fieldParams(24));

        passwordInput.setOnEditorActionListener((view, actionId, event) -> {
            if (actionId == EditorInfo.IME_ACTION_GO) {
                submit();
                return true;
            }
            return false;
        });
        content.addView(passwordInput, fieldParams(14));

        LinearLayout mockModeRow = new LinearLayout(context);
        mockModeRow.setOrientation(LinearLayout.HORIZONTAL);
        mockModeRow.setGravity(Gravity.CENTER_VERTICAL);
        TextView mockModeLabel = label("Mock mode", 15, TITLE_COLOR);
        mockModeLabel.setGravity(Gravity.START | Gravity.CENTER_VERTICAL);
        mockModeRow.addView(mockModeLabel, new LinearLayout.LayoutParams(
            0,
            ViewGroup.LayoutParams.WRAP_CONTENT,
            1
        ));
        mockModeSwitch = new SwitchCompat(context);
        mockModeSwitch.setContentDescription("Enable mock mode");
        mockModeSwitch.setOnCheckedChangeListener((button, checked) -> {
            updateMockControls(checked);
            if (listener != null) {
                listener.onMockModeChanged(checked);
            }
        });
        mockModeRow.addView(mockModeSwitch);
        content.addView(mockModeRow, itemParams(16));

        mockScenarioSpinner = new Spinner(context);
        ArrayAdapter<LoginMockScenario> scenarioAdapter = new ArrayAdapter<>(
            context,
            android.R.layout.simple_spinner_item,
            LoginMockScenario.values()
        );
        scenarioAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        mockScenarioSpinner.setAdapter(scenarioAdapter);
        mockScenarioSpinner.setContentDescription("Mock login response");
        content.addView(mockScenarioSpinner, fieldParams(8));

        errorText = label("", 14, ERROR_COLOR);
        errorText.setVisibility(View.GONE);
        content.addView(errorText, itemParams(0));

        loginButton = new Button(context);
        loginButton.setText("Sign in");
        loginButton.setTextColor(Color.WHITE);
        loginButton.setTextSize(16);
        loginButton.setAllCaps(false);
        loginButton.setBackground(roundedBackground(ACTION_COLOR, 8));
        loginButton.setOnClickListener(view -> submit());
        content.addView(loginButton, buttonParams(14));

        demoCredentialsHint = label("Mock mode: using a local response", 13, SECONDARY_COLOR);
        content.addView(demoCredentialsHint, itemParams(14));
        updateMockControls(false);
    }

    public void setListener(Listener listener) {
        this.listener = listener;
    }

    public void setMockMode(boolean enabled) {
        mockModeSwitch.setChecked(enabled);
        updateMockControls(enabled);
    }

    public void setLoading(boolean loading) {
        if (loading) {
            errorText.setVisibility(View.GONE);
        }
        usernameInput.setEnabled(!loading);
        passwordInput.setEnabled(!loading);
        loginButton.setEnabled(!loading);
        mockModeSwitch.setEnabled(!loading);
        mockScenarioSpinner.setEnabled(!loading);
        loginButton.setText(loading ? "Signing in..." : "Sign in");
        loginButton.setAlpha(loading ? 0.72f : 1.0f);
    }

    public void showError(String message) {
        errorText.setText(message);
        errorText.setVisibility(View.VISIBLE);
    }

    private void submit() {
        if (listener == null || !loginButton.isEnabled()) {
            return;
        }
        listener.onLoginRequested(
            usernameInput.getText().toString().trim(),
            passwordInput.getText().toString(),
            (LoginMockScenario) mockScenarioSpinner.getSelectedItem()
        );
    }

    private void updateMockControls(boolean enabled) {
        mockScenarioSpinner.setVisibility(enabled ? View.VISIBLE : View.GONE);
        demoCredentialsHint.setVisibility(enabled ? View.VISIBLE : View.GONE);
    }

    private EditText input(String hint) {
        EditText input = new EditText(getContext());
        input.setHint(hint);
        input.setTextSize(16);
        input.setSingleLine(true);
        input.setPadding(dp(14), 0, dp(14), 0);
        input.setBackground(roundedFieldBackground());
        return input;
    }

    private TextView label(String text, float size, int color) {
        TextView label = new TextView(getContext());
        label.setText(text);
        label.setTextSize(size);
        label.setTextColor(color);
        label.setGravity(Gravity.CENTER);
        return label;
    }

    private GradientDrawable roundedFieldBackground() {
        GradientDrawable background = roundedBackground(Color.WHITE, 8);
        background.setStroke(dp(1), 0xFFD0D5DD);
        return background;
    }

    private GradientDrawable roundedBackground(int color, int radius) {
        GradientDrawable background = new GradientDrawable();
        background.setColor(color);
        background.setCornerRadius(dp(radius));
        return background;
    }

    private LinearLayout.LayoutParams fieldParams(int topMargin) {
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            dp(48)
        );
        params.topMargin = dp(topMargin);
        return params;
    }

    private LinearLayout.LayoutParams buttonParams(int topMargin) {
        LinearLayout.LayoutParams params = fieldParams(topMargin);
        params.height = dp(48);
        return params;
    }

    private LinearLayout.LayoutParams itemParams(int topMargin) {
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        );
        params.topMargin = dp(topMargin);
        return params;
    }

    private int dp(int value) {
        return Math.round(value * getResources().getDisplayMetrics().density);
    }
}
