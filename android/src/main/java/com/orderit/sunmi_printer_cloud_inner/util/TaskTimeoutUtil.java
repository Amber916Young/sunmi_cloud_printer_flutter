package com.orderit.sunmi_printer_cloud_inner.util;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

public class TaskTimeoutUtil {

    /**
     * Executes a task with a timeout. If the task completes within the timeout, it proceeds.
     * If the timeout is reached, an optional timeout action is executed.
     *
     * @param task           The task to execute (usually containing a callback).
     * @param timeoutSeconds The timeout duration in seconds.
     * @param onTimeout      An optional action to execute if the timeout is reached.
     * @return true if the task completes within the timeout, false otherwise.
     */
    public static boolean executeWithTimeout(Runnable task, int timeoutSeconds, Runnable onTimeout) {
        CountDownLatch latch = new CountDownLatch(1);

        // Wrap the task to include latch count down
        Runnable wrappedTask = () -> {
            try {
                task.run();
            } finally {
                latch.countDown(); // Signal task completion
            }
        };

        // Run the task in a separate thread
        new Thread(wrappedTask).start();

        try {
            // Wait for task to complete or timeout
            boolean completed = latch.await(timeoutSeconds, TimeUnit.SECONDS);
            if (!completed && onTimeout != null) {
                onTimeout.run(); // Execute timeout action
            }
            return completed;
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt(); // Restore interrupt status
            return false; // Task did not complete due to interruption
        }
    }
}
