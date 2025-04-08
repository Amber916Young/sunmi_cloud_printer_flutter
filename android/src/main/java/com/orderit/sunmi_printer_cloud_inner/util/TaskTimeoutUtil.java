package com.orderit.sunmi_printer_cloud_inner.util;
import com.sunmi.externalprinterlibrary2.exceptions.PrinterException;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.*;

public class TaskTimeoutUtil {

    public static <T> TaskResult<T> runWithTimeout(Callable<T> task, int timeoutSeconds) {
        ExecutorService executor = Executors.newSingleThreadExecutor();
        Future<T> future = executor.submit(task);

        try {
            T result = future.get(timeoutSeconds, TimeUnit.SECONDS);
            return TaskResult.success(result);
        } catch (TimeoutException e) {
            future.cancel(true);
            return TaskResult.error(new RuntimeException("Timeout after " + timeoutSeconds + "s", e));
        } catch (Exception e) {
            return TaskResult.error(e);
        } finally {
            executor.shutdownNow();
        }
    }

    public static class TaskResult<T> {
        private final T data;
        private final Exception error;

        private TaskResult(T data, Exception error) {
            this.data = data;
            this.error = error;
        }

        public static <T> TaskResult<T> success(T data) {
            return new TaskResult<>(data, null);
        }

        public static <T> TaskResult<T> error(Exception error) {
            return new TaskResult<>(null, error);
        }

        public boolean isSuccess() {
            return error == null;
        }

        public T getOrThrow() throws PrinterException {
            if (error != null) {
                throw new PrinterException(error.getMessage());
            }
            return data;
        }
    }
}
