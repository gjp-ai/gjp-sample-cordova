package com.ganjianping.sample.app.network;

import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;
import java.util.UUID;

public final class ApiRequest {
    public final String method;
    public final String path;
    public final String body;
    public final String mockResponseAsset;
    public final int mockStatusCode;
    public final String mockErrorMessage;
    public final Boolean mockModeOverride;
    public final boolean requiresAuthentication;

    public ApiRequest(
        String method,
        String path,
        String body,
        String mockResponseAsset,
        int mockStatusCode,
        String mockErrorMessage,
        Boolean mockModeOverride,
        boolean requiresAuthentication
    ) {
        this.method = method;
        this.path = path;
        this.body = body;
        this.mockResponseAsset = mockResponseAsset;
        this.mockStatusCode = mockStatusCode;
        this.mockErrorMessage = mockErrorMessage;
        this.mockModeOverride = mockModeOverride;
        this.requiresAuthentication = requiresAuthentication;
    }

    public static JSONObject createMetadata() throws JSONException {
        SimpleDateFormat formatter = new SimpleDateFormat(
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            Locale.US
        );
        formatter.setTimeZone(TimeZone.getTimeZone("UTC"));

        JSONObject metadata = new JSONObject();
        metadata.put("requestId", UUID.randomUUID().toString());
        metadata.put("sentAt", formatter.format(new Date()));
        metadata.put("apiVersion", "1.0");
        metadata.put("channel", "MOBILE");
        metadata.put("locale", Locale.getDefault().toLanguageTag());
        return metadata;
    }
}
