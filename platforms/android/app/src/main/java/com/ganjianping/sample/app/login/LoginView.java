package com.ganjianping.sample.app.login;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.text.InputType;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.ganjianping.sample.R;

public final class LoginView extends FrameLayout {
    public interface Listener {
        void onNotificationsRequested();
        void onMoreRequested();
        void onLoginRequested(String username, String password);
    }

    private static final int ACTION_COLOR = 0xFF092B59;
    private static final int ERROR_COLOR = 0xFFB42318;

    private final EditText usernameInput;
    private final EditText passwordInput;
    private final TextView errorText;
    private final Button loginButton;

    private Listener listener;

    public LoginView(Context context) {
        super(context);
        setBackgroundColor(0xFF06152F);

        PanoramicBackgroundView backgroundView = new PanoramicBackgroundView(context);
        addView(backgroundView, matchParentParams());

        View overlay = new View(context);
        overlay.setBackground(new GradientDrawable(
            GradientDrawable.Orientation.TOP_BOTTOM,
            new int[] { 0x14020B1C, 0x08020B1C, 0x9906152F }
        ));
        addView(overlay, matchParentParams());

        addView(createTopBar(), topBarParams());

        LinearLayout loginPanel = new LinearLayout(context);
        loginPanel.setOrientation(LinearLayout.VERTICAL);
        loginPanel.setPadding(dp(18), dp(18), dp(18), dp(18));
        loginPanel.setBackground(glassPanelBackground());
        loginPanel.setElevation(dp(16));

        usernameInput = input("Username");
        passwordInput = input("Password");
        usernameInput.setImeOptions(EditorInfo.IME_ACTION_NEXT);
        usernameInput.setOnEditorActionListener((view, actionId, event) -> {
            if (actionId == EditorInfo.IME_ACTION_NEXT) {
                passwordInput.requestFocus();
                return true;
            }
            return false;
        });
        loginPanel.addView(usernameInput, fieldParams(0));

        passwordInput.setInputType(
            InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD
        );
        passwordInput.setImeOptions(EditorInfo.IME_ACTION_GO);
        passwordInput.setOnEditorActionListener((view, actionId, event) -> {
            if (actionId == EditorInfo.IME_ACTION_GO) {
                submit();
                return true;
            }
            return false;
        });
        loginPanel.addView(passwordInput, fieldParams(10));

        errorText = label("", 14, ERROR_COLOR);
        errorText.setVisibility(View.GONE);
        loginPanel.addView(errorText, itemParams(10));

        loginButton = new Button(context);
        loginButton.setText("Sign in");
        loginButton.setTextColor(Color.WHITE);
        loginButton.setTextSize(16);
        loginButton.setAllCaps(false);
        loginButton.setBackground(roundedBackground(ACTION_COLOR, 14));
        loginButton.setOnClickListener(view -> submit());
        loginPanel.addView(loginButton, buttonParams(14));

        addView(loginPanel, panelParams());
    }

    public void setListener(Listener listener) {
        this.listener = listener;
    }

    public void setLoading(boolean loading) {
        if (loading) {
            errorText.setVisibility(View.GONE);
        }
        usernameInput.setEnabled(!loading);
        passwordInput.setEnabled(!loading);
        loginButton.setEnabled(!loading);
        loginButton.setText(loading ? "Signing in..." : "Sign in");
        loginButton.setAlpha(loading ? 0.72f : 1.0f);
    }

    public void showError(String message) {
        errorText.setText(message);
        errorText.setVisibility(View.VISIBLE);
    }

    private LinearLayout createTopBar() {
        LinearLayout topBar = new LinearLayout(getContext());
        topBar.setGravity(Gravity.CENTER_VERTICAL);

        ImageButton notifications = iconButton(
            R.drawable.ic_notifications,
            "Notifications"
        );
        notifications.setOnClickListener(view -> {
            if (listener != null) {
                listener.onNotificationsRequested();
            }
        });
        topBar.addView(notifications, iconButtonParams());

        View spacer = new View(getContext());
        topBar.addView(spacer, new LinearLayout.LayoutParams(0, 1, 1));

        ImageButton more = iconButton(R.drawable.ic_more_horiz, "More");
        more.setOnClickListener(view -> {
            if (listener != null) {
                listener.onMoreRequested();
            }
        });
        topBar.addView(more, iconButtonParams());
        return topBar;
    }

    private ImageButton iconButton(int drawable, String description) {
        ImageButton button = new ImageButton(getContext());
        button.setImageResource(drawable);
        button.setColorFilter(Color.WHITE);
        button.setContentDescription(description);
        button.setPadding(dp(12), dp(12), dp(12), dp(12));
        button.setBackground(roundedBackground(0x94062249, 24));
        button.setElevation(dp(6));
        return button;
    }

    private void submit() {
        if (listener == null || !loginButton.isEnabled()) {
            return;
        }
        listener.onLoginRequested(
            usernameInput.getText().toString().trim(),
            passwordInput.getText().toString()
        );
    }

    private EditText input(String hint) {
        EditText input = new EditText(getContext());
        input.setHint(hint);
        input.setHintTextColor(0xFF667085);
        input.setTextColor(0xFF12213A);
        input.setTextSize(16);
        input.setSingleLine(true);
        input.setPadding(dp(16), 0, dp(16), 0);
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
        GradientDrawable background = roundedBackground(0xE6FFFFFF, 14);
        background.setStroke(dp(1), 0xA6FFFFFF);
        return background;
    }

    private GradientDrawable glassPanelBackground() {
        GradientDrawable background = new GradientDrawable(
            GradientDrawable.Orientation.TOP_BOTTOM,
            new int[] { 0xEFFFFFFF, 0xD9F3F7FC }
        );
        background.setCornerRadius(dp(28));
        background.setStroke(dp(1), 0xC7FFFFFF);
        return background;
    }

    private GradientDrawable roundedBackground(int color, int radius) {
        GradientDrawable background = new GradientDrawable();
        background.setColor(color);
        background.setCornerRadius(dp(radius));
        return background;
    }

    private LayoutParams matchParentParams() {
        return new LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        );
    }

    private LayoutParams topBarParams() {
        LayoutParams params = new LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            dp(48),
            Gravity.TOP
        );
        params.setMargins(dp(20), dp(16), dp(20), 0);
        return params;
    }

    private LayoutParams panelParams() {
        LayoutParams params = new LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT,
            Gravity.BOTTOM
        );
        params.setMargins(dp(18), 0, dp(18), dp(18));
        return params;
    }

    private LinearLayout.LayoutParams fieldParams(int topMargin) {
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            dp(50)
        );
        params.topMargin = dp(topMargin);
        return params;
    }

    private LinearLayout.LayoutParams buttonParams(int topMargin) {
        LinearLayout.LayoutParams params = fieldParams(topMargin);
        params.height = dp(50);
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

    private LinearLayout.LayoutParams iconButtonParams() {
        return new LinearLayout.LayoutParams(dp(48), dp(48));
    }

    private int dp(int value) {
        return Math.round(value * getResources().getDisplayMetrics().density);
    }
}
