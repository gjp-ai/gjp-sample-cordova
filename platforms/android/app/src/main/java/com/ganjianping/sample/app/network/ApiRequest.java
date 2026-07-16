package com.ganjianping.sample.app.network;

public final class ApiRequest {
    public final String method;
    public final String path;
    public final String body;
    public final String mockResponseAsset;
    public final int mockStatusCode;
    public final String mockErrorMessage;

    public ApiRequest(
        String method,
        String path,
        String body,
        String mockResponseAsset,
        int mockStatusCode,
        String mockErrorMessage
    ) {
        this.method = method;
        this.path = path;
        this.body = body;
        this.mockResponseAsset = mockResponseAsset;
        this.mockStatusCode = mockStatusCode;
        this.mockErrorMessage = mockErrorMessage;
    }
}
