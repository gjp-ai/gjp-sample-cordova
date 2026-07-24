package com.ganjianping.sample.app.login;

import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.view.View;
import android.view.animation.LinearInterpolator;

import com.ganjianping.sample.R;

public final class PanoramicBackgroundView extends View {
    private static final long PAN_DURATION_MILLISECONDS = 36_000L;

    private final Bitmap bitmap;
    private final Matrix imageMatrix = new Matrix();
    private final Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG | Paint.FILTER_BITMAP_FLAG);
    private final ValueAnimator animator = ValueAnimator.ofFloat(0f, 1f);
    private float progress;

    public PanoramicBackgroundView(Context context) {
        super(context);
        bitmap = BitmapFactory.decodeResource(getResources(), R.drawable.login_background);
        animator.setDuration(PAN_DURATION_MILLISECONDS);
        animator.setInterpolator(new LinearInterpolator());
        animator.setRepeatCount(ValueAnimator.INFINITE);
        animator.addUpdateListener(animation -> {
            progress = (float) animation.getAnimatedValue();
            invalidate();
        });
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        if (!animator.isStarted()) {
            animator.start();
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        animator.cancel();
        super.onDetachedFromWindow();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        if (bitmap == null || getWidth() == 0 || getHeight() == 0) {
            return;
        }

        float scale = Math.max(
            (float) getWidth() / bitmap.getWidth(),
            (float) getHeight() / bitmap.getHeight()
        );
        float scaledWidth = bitmap.getWidth() * scale;
        float scaledHeight = bitmap.getHeight() * scale;
        float horizontalTravel = Math.max(scaledWidth - getWidth(), 0f);

        imageMatrix.reset();
        imageMatrix.postScale(scale, scale);
        imageMatrix.postTranslate(
            -horizontalTravel * progress,
            (getHeight() - scaledHeight) / 2f
        );
        canvas.drawBitmap(bitmap, imageMatrix, paint);
    }
}
