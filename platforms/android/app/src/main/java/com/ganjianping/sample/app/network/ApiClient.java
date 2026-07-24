package com.ganjianping.sample.app.network;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import com.ganjianping.sample.app.config.AppSettings;
import com.ganjianping.sample.app.session.SessionStore;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public final class ApiClient {
    public interface Callback {
        void onComplete(ApiResponse response);
    }

    private final Context context;
    private final AppSettings settings;
    private final ExecutorService executor = Executors.newCachedThreadPool();
    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    private volatile boolean mockMode;
    private volatile boolean closed;

    public ApiClient(Context context) throws Exception {
        this.context = context.getApplicationContext();
        settings = AppSettings.load(context);
        mockMode = settings.isMockMode;
    }

    public boolean isMockMode() {
        return mockMode;
    }

    public void setMockMode(boolean enabled) {
        mockMode = enabled;
    }

    public void execute(ApiRequest request, Callback callback) {
        if (closed) {
            callback.onComplete(ApiResponse.failure("The API client is closed."));
            return;
        }
        executor.submit(() -> {
            boolean shouldUseMock = request.mockModeOverride == null
                ? mockMode
                : request.mockModeOverride;
            ApiResponse response = shouldUseMock
                ? loadMockResponse(request)
                : executeNetworkRequest(request);
            if (!closed && !Thread.currentThread().isInterrupted()) {
                mainHandler.post(() -> callback.onComplete(response));
            }
        });
    }

    private ApiResponse loadMockResponse(ApiRequest request) {
        try {
            if (settings.mockResponseDelayMilliseconds > 0) {
                Thread.sleep(settings.mockResponseDelayMilliseconds);
            }
            if (request.mockErrorMessage != null) {
                return ApiResponse.failure(request.mockErrorMessage);
            }
            return ApiResponse.success(
                request.mockStatusCode,
                AppSettings.readAsset(context, request.mockResponseAsset)
            );
        } catch (InterruptedException error) {
            Thread.currentThread().interrupt();
            return ApiResponse.failure("Request cancelled.");
        } catch (Exception error) {
            return ApiResponse.failure("The local mock response could not be loaded.");
        }
    }

    private ApiResponse executeNetworkRequest(ApiRequest request) {
        HttpURLConnection connection = null;
        try {
            connection = (HttpURLConnection) new URL(settings.apiBaseUrl + request.path).openConnection();
            connection.setRequestMethod(request.method);
            int timeout = settings.requestTimeoutSeconds * 1_000;
            connection.setConnectTimeout(timeout);
            connection.setReadTimeout(timeout);
            connection.setRequestProperty("Accept", "application/json");
            if (request.requiresAuthentication) {
                String authorization = SessionStore.getInstance().getAuthorizationHeader();
                if (authorization == null) {
                    return ApiResponse.failure("Your session has expired. Please sign in again.");
                }
                connection.setRequestProperty("Authorization", authorization);
            }

            if (request.body != null) {
                connection.setRequestProperty("Content-Type", "application/json; charset=utf-8");
                connection.setDoOutput(true);
                try (OutputStream output = connection.getOutputStream()) {
                    output.write(request.body.getBytes(StandardCharsets.UTF_8));
                }
            }

            int statusCode = connection.getResponseCode();
            InputStream stream = statusCode >= 200 && statusCode < 300
                ? connection.getInputStream()
                : connection.getErrorStream();
            return ApiResponse.success(statusCode, stream == null ? "" : read(stream));
        } catch (Exception error) {
            return ApiResponse.failure("Unable to reach the API. Please try again.");
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }

    private String read(InputStream stream) throws Exception {
        try (BufferedReader reader = new BufferedReader(
            new InputStreamReader(stream, StandardCharsets.UTF_8)
        )) {
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                response.append(line);
            }
            return response.toString();
        }
    }

    public void close() {
        closed = true;
        mainHandler.removeCallbacksAndMessages(null);
        executor.shutdownNow();
    }
}
