package com.ganjianping.sample.app.login;

import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.ganjianping.sample.R;

public final class NotificationActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setPadding(dp(20), dp(16), dp(20), dp(24));
        root.setBackgroundColor(0xFFF5F7FB);
        root.addView(createHeader(), new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            dp(48)
        ));

        LinearLayout card = new LinearLayout(this);
        card.setOrientation(LinearLayout.VERTICAL);
        card.setGravity(Gravity.CENTER);
        card.setPadding(dp(24), dp(32), dp(24), dp(32));
        card.setBackground(roundedBackground(Color.WHITE, 20));
        card.setElevation(dp(4));

        ImageView icon = new ImageView(this);
        icon.setImageResource(R.drawable.ic_notifications);
        icon.setColorFilter(0xFF1D5FD1);
        card.addView(icon, new LinearLayout.LayoutParams(dp(44), dp(44)));

        TextView title = text("You’re all caught up", 20, 0xFF12213A);
        title.setGravity(Gravity.CENTER);
        LinearLayout.LayoutParams titleParams = wrapParams();
        titleParams.topMargin = dp(18);
        card.addView(title, titleParams);

        TextView detail = text(
            "New account and security notifications will appear here.",
            15,
            0xFF667085
        );
        detail.setGravity(Gravity.CENTER);
        LinearLayout.LayoutParams detailParams = wrapParams();
        detailParams.topMargin = dp(8);
        card.addView(detail, detailParams);

        LinearLayout.LayoutParams cardParams = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        );
        cardParams.topMargin = dp(32);
        root.addView(card, cardParams);
        setContentView(root);
    }

    private LinearLayout createHeader() {
        LinearLayout header = new LinearLayout(this);
        header.setGravity(Gravity.CENTER_VERTICAL);

        ImageButton back = new ImageButton(this);
        back.setImageResource(R.drawable.ic_arrow_back);
        back.setColorFilter(0xFF12213A);
        back.setContentDescription("Back");
        back.setPadding(dp(12), dp(12), dp(12), dp(12));
        back.setBackground(roundedBackground(Color.WHITE, 24));
        back.setOnClickListener(view -> finish());
        header.addView(back, new LinearLayout.LayoutParams(dp(48), dp(48)));

        TextView title = text("Notifications", 24, 0xFF12213A);
        title.setGravity(Gravity.CENTER_VERTICAL);
        LinearLayout.LayoutParams titleParams = wrapParams();
        titleParams.leftMargin = dp(16);
        header.addView(title, titleParams);
        return header;
    }

    private TextView text(String value, float size, int color) {
        TextView view = new TextView(this);
        view.setText(value);
        view.setTextSize(size);
        view.setTextColor(color);
        return view;
    }

    private LinearLayout.LayoutParams wrapParams() {
        return new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        );
    }

    private GradientDrawable roundedBackground(int color, int radius) {
        GradientDrawable background = new GradientDrawable();
        background.setColor(color);
        background.setCornerRadius(dp(radius));
        return background;
    }

    private int dp(int value) {
        return Math.round(value * getResources().getDisplayMetrics().density);
    }
}
