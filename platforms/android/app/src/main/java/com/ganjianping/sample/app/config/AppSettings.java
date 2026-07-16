package com.ganjianping.sample.app.config;

import android.content.Context;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;

public final class AppSettings {
    private static final String SETTINGS_ASSET = "app-settings.json";

    public final boolean isMockMode;
    public final String apiBaseUrl;
    public final int requestTimeoutSeconds;
    public final long mockResponseDelayMilliseconds;

    private AppSettings(
        boolean isMockMode,
        String apiBaseUrl,
        int requestTimeoutSeconds,
        long mockResponseDelayMilliseconds
    ) {
        this.isMockMode = isMockMode;
        this.apiBaseUrl = apiBaseUrl;
        this.requestTimeoutSeconds = requestTimeoutSeconds;
        this.mockResponseDelayMilliseconds = mockResponseDelayMilliseconds;
    }

    public static AppSettings load(Context context) throws Exception {
        JSONObject json = new JSONObject(readAsset(context, SETTINGS_ASSET));
        String apiBaseUrl = json.getString("apiBaseUrl");
        if (apiBaseUrl.isEmpty()) {
            throw new IllegalArgumentException("apiBaseUrl must not be empty.");
        }
        return new AppSettings(
            json.getBoolean("isMockMode"),
            apiBaseUrl.replaceAll("/+$", ""),
            Math.max(json.optInt("requestTimeoutSeconds", 15), 1),
            Math.max(json.optLong("mockResponseDelayMilliseconds", 0), 0)
        );
    }

    public static String readAsset(Context context, String path) throws Exception {
        try (InputStream stream = context.getAssets().open(path);
             BufferedReader reader = new BufferedReader(
                 new InputStreamReader(stream, StandardCharsets.UTF_8)
             )) {
            StringBuilder contents = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                contents.append(line);
            }
            return contents.toString();
        }
    }
}
