package com.ganjianping.sample.app.network;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public final class ApiEnvelope {
    public enum Outcome {
        SUCCESS,
        FAILURE,
        PARTIAL
    }

    public final Outcome outcome;
    public final JSONObject data;
    public final JSONArray errors;

    private ApiEnvelope(Outcome outcome, JSONObject data, JSONArray errors) {
        this.outcome = outcome;
        this.data = data;
        this.errors = errors;
    }

    public static ApiEnvelope parse(String payload) throws JSONException {
        JSONObject response = new JSONObject(payload);
        JSONObject metadata = response.getJSONObject("meta");
        metadata.getString("requestId");
        metadata.getString("responseId");
        metadata.getString("respondedAt");
        Outcome outcome;
        try {
            outcome = Outcome.valueOf(metadata.getString("outcome"));
        } catch (IllegalArgumentException error) {
            throw new JSONException("Unknown response outcome.");
        }
        JSONArray errors = response.getJSONArray("errors");
        if (outcome == Outcome.SUCCESS && errors.length() != 0) {
            throw new JSONException("Successful response must not contain errors.");
        }
        if (outcome != Outcome.SUCCESS && errors.length() == 0) {
            throw new JSONException("Unsuccessful response must contain an error.");
        }
        for (int index = 0; index < errors.length(); index++) {
            JSONObject error = errors.getJSONObject(index);
            error.getString("code");
            error.getString("message");
            error.getBoolean("retryable");
        }
        return new ApiEnvelope(outcome, response.optJSONObject("data"), errors);
    }

    public String firstErrorMessage(String fallback) throws JSONException {
        if (errors.length() == 0) {
            return fallback;
        }
        return errors.getJSONObject(0).optString("message", fallback);
    }
}
