package com.ganjianping.sample.app.splash;

import android.content.Context;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.ganjianping.sample.R;

public final class SplashView extends LinearLayout {
    private static final int BACKGROUND_COLOR = 0xFF123B72;
    private static final int SUBTITLE_COLOR = 0xFFD9D9D9;

    public SplashView(Context context) {
        super(context);
        setOrientation(VERTICAL);
        setGravity(Gravity.CENTER);
        setPadding(dp(28), dp(28), dp(28), dp(28));
        setBackgroundColor(BACKGROUND_COLOR);

        ImageView appIcon = new ImageView(context);
        appIcon.setImageResource(R.drawable.splash_icon);
        appIcon.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
        appIcon.setImportantForAccessibility(IMPORTANT_FOR_ACCESSIBILITY_NO);
        addView(appIcon, centeredParams(0, 180, 160));

        addView(label("Preparing your workspace", 16, SUBTITLE_COLOR), centeredParams(12));

        ProgressBar progress = new ProgressBar(context);
        progress.setIndeterminateTintList(ColorStateList.valueOf(Color.WHITE));
        addView(progress, centeredParams(20));
    }

    private TextView label(String text, float size, int color) {
        TextView label = new TextView(getContext());
        label.setText(text);
        label.setTextSize(size);
        label.setTextColor(color);
        label.setGravity(Gravity.CENTER);
        return label;
    }

    private LayoutParams centeredParams(int topMargin) {
        return centeredParams(
            topMargin,
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        );
    }

    private LayoutParams centeredParams(int topMargin, int width, int height) {
        LayoutParams params = new LayoutParams(
            width == ViewGroup.LayoutParams.WRAP_CONTENT ? width : dp(width),
            height == ViewGroup.LayoutParams.WRAP_CONTENT ? height : dp(height)
        );
        params.topMargin = dp(topMargin);
        params.gravity = Gravity.CENTER_HORIZONTAL;
        return params;
    }

    private int dp(int value) {
        return Math.round(value * getResources().getDisplayMetrics().density);
    }
}
