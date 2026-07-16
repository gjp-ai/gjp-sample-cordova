package com.ganjianping.sample.app.network;

public final class ApiResponse {
    public final int statusCode;
    public final String body;
    public final String errorMessage;

    private ApiResponse(int statusCode, String body, String errorMessage) {
        this.statusCode = statusCode;
        this.body = body;
        this.errorMessage = errorMessage;
    }

    public static ApiResponse success(int statusCode, String body) {
        return new ApiResponse(statusCode, body, null);
    }

    public static ApiResponse failure(String errorMessage) {
        return new ApiResponse(0, "", errorMessage);
    }

    public boolean hasTransportError() {
        return errorMessage != null;
    }
}
