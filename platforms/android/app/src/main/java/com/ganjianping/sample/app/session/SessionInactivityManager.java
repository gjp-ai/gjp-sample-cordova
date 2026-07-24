package com.ganjianping.sample.app.session;

import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;

public final class SessionInactivityManager {
    public interface Listener {
        void onWarning();
        void onSessionExtended();
        void onTimeout();
    }

    private static final long WARNING_AFTER_MILLISECONDS = 60_000L;
    private static final long TIMEOUT_AFTER_MILLISECONDS = 120_000L;

    private final Handler handler = new Handler(Looper.getMainLooper());
    private final Listener listener;
    private final Runnable evaluator = this::evaluate;
    private long lastInteractionAt;
    private boolean started;
    private boolean resumed;
    private boolean warningShown;

    public SessionInactivityManager(Listener listener) {
        this.listener = listener;
    }

    public void start() {
        started = true;
        resumed = true;
        lastInteractionAt = SystemClock.elapsedRealtime();
        warningShown = false;
        scheduleNextEvaluation();
    }

    public void pause() {
        resumed = false;
        handler.removeCallbacks(evaluator);
    }

    public void resume() {
        if (!started) {
            start();
            return;
        }
        resumed = true;
        evaluate();
    }

    public void recordInteraction() {
        if (!started) {
            return;
        }
        lastInteractionAt = SystemClock.elapsedRealtime();
        warningShown = false;
        listener.onSessionExtended();
        scheduleNextEvaluation();
    }

    public void stop() {
        started = false;
        resumed = false;
        handler.removeCallbacks(evaluator);
    }

    private void evaluate() {
        if (!started || !resumed) {
            return;
        }
        long elapsed = SystemClock.elapsedRealtime() - lastInteractionAt;
        if (elapsed >= TIMEOUT_AFTER_MILLISECONDS) {
            stop();
            listener.onTimeout();
            return;
        }
        if (elapsed >= WARNING_AFTER_MILLISECONDS && !warningShown) {
            warningShown = true;
            listener.onWarning();
        }
        scheduleNextEvaluation();
    }

    private void scheduleNextEvaluation() {
        handler.removeCallbacks(evaluator);
        if (!started || !resumed) {
            return;
        }
        long elapsed = SystemClock.elapsedRealtime() - lastInteractionAt;
        long nextThreshold = elapsed < WARNING_AFTER_MILLISECONDS
            ? WARNING_AFTER_MILLISECONDS
            : TIMEOUT_AFTER_MILLISECONDS;
        handler.postDelayed(evaluator, Math.max(nextThreshold - elapsed, 1L));
    }
}
