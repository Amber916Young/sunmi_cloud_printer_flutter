package com.orderit.sunmi_printer_cloud_inner.util;
import com.sunmi.externalprinterlibrary2.exceptions.PrinterException;

import java.util.concurrent.Callable;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;
public class TaskHandleUtil {
    private static final int DEFAULT_TIMEOUT = 10;

    /**
     * For synchronous calls with exception handling (no Optional).
     */
    public static <T> T runSyncWithException(Callable<T> task) throws PrinterException {
        return TaskTimeoutUtil.runWithTimeout(task, DEFAULT_TIMEOUT).getOrThrow();
    }

    /**
     * For async (callback-style) calls with timeout and error handling (no Optional).
     */
    public static <T> T runAsyncWithCallback(CallbackRegistrar<T> registrar) throws PrinterException {
        Callable<T> blockingTask = new Callable<T>() {
            @Override
            public T call() throws Exception {
                CountDownLatch latch = new CountDownLatch(1);
                final AtomicReference<T> result = new AtomicReference<>();
                final AtomicReference<Exception> error = new AtomicReference<>();

                registrar.register(new Callback<T>() {
                    @Override
                    public void onSuccess(T value) {
                        result.set(value);
                        latch.countDown();
                    }

                    @Override
                    public void onError(Exception e) {
                        error.set(e);
                        latch.countDown();
                    }
                });

                boolean completed = latch.await(DEFAULT_TIMEOUT, TimeUnit.SECONDS);
                if (!completed) throw new PrinterException("Callback timed out after " + DEFAULT_TIMEOUT + " seconds.");
                if (error.get() != null) throw error.get();

                return result.get();
            }
        };

        return TaskTimeoutUtil.runWithTimeout(blockingTask, DEFAULT_TIMEOUT).getOrThrow();
    }

    // === Callback Interfaces ===

    public interface Callback<T> {
        void onSuccess(T value);
        void onError(Exception e);
    }

    public interface CallbackRegistrar<T> {
        void register(Callback<T> callback);
    }
}