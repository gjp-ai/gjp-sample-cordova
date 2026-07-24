package com.ganjianping.sample.app.login;

import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.os.Build;
import android.os.Bundle;
import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.GridLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import com.ganjianping.sample.BuildConfig;
import com.ganjianping.sample.R;

public final class MoreActivity extends AppCompatActivity {
    private static final MenuItem[] ITEMS = {
        new MenuItem("Device info", R.drawable.ic_device_info),
        new MenuItem("About app", R.drawable.ic_info),
        new MenuItem("Security", R.drawable.ic_security),
        new MenuItem("Privacy", R.drawable.ic_privacy),
        new MenuItem("Help", R.drawable.ic_help),
        new MenuItem("Contact", R.drawable.ic_contact)
    };

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

        GridLayout grid = new GridLayout(this);
        grid.setColumnCount(3);
        grid.setUseDefaultMargins(false);
        for (MenuItem item : ITEMS) {
            grid.addView(createTile(item), tileParams());
        }

        LinearLayout.LayoutParams gridParams = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        );
        gridParams.topMargin = dp(24);
        root.addView(grid, gridParams);
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

        TextView title = text("More", 24, 0xFF12213A);
        title.setGravity(Gravity.CENTER_VERTICAL);
        LinearLayout.LayoutParams titleParams = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        );
        titleParams.leftMargin = dp(16);
        header.addView(title, titleParams);
        return header;
    }

    private LinearLayout createTile(MenuItem item) {
        LinearLayout tile = new LinearLayout(this);
        tile.setOrientation(LinearLayout.VERTICAL);
        tile.setGravity(Gravity.CENTER);
        tile.setPadding(dp(8), dp(18), dp(8), dp(14));
        tile.setBackground(roundedBackground(Color.WHITE, 18));
        tile.setElevation(dp(3));
        tile.setContentDescription(item.title);
        tile.setClickable(true);
        tile.setFocusable(true);
        tile.setOnClickListener(view -> showItem(item.title));

        ImageView icon = new ImageView(this);
        icon.setImageResource(item.drawable);
        icon.setColorFilter(0xFF1D5FD1);
        tile.addView(icon, new LinearLayout.LayoutParams(dp(34), dp(34)));

        TextView label = text(item.title, 13, 0xFF344054);
        label.setGravity(Gravity.CENTER);
        LinearLayout.LayoutParams labelParams = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        );
        labelParams.topMargin = dp(10);
        tile.addView(label, labelParams);
        return tile;
    }

    private GridLayout.LayoutParams tileParams() {
        GridLayout.LayoutParams params = new GridLayout.LayoutParams();
        params.width = 0;
        params.height = dp(112);
        params.columnSpec = GridLayout.spec(GridLayout.UNDEFINED, 1f);
        params.setMargins(dp(5), dp(6), dp(5), dp(6));
        return params;
    }

    private void showItem(String title) {
        String message;
        if ("Device info".equals(title)) {
            message = Build.MANUFACTURER + " " + Build.MODEL
                + "\nAndroid " + Build.VERSION.RELEASE;
        } else if ("About app".equals(title)) {
            message = getString(R.string.app_name) + "\nVersion " + BuildConfig.VERSION_NAME;
        } else {
            message = title + " options will be available here.";
        }
        new AlertDialog.Builder(this)
            .setTitle(title)
            .setMessage(message)
            .setPositiveButton("Done", null)
            .show();
    }

    private TextView text(String value, float size, int color) {
        TextView view = new TextView(this);
        view.setText(value);
        view.setTextSize(size);
        view.setTextColor(color);
        return view;
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

    private static final class MenuItem {
        private final String title;
        private final int drawable;

        private MenuItem(String title, int drawable) {
            this.title = title;
            this.drawable = drawable;
        }
    }
}
