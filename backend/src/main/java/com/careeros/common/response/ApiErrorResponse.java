package com.careeros.common.response;

import java.time.LocalDateTime;

public class ApiErrorResponse {

    private boolean success;
    private int status;
    private String message;
    private LocalDateTime timestamp;

    public ApiErrorResponse() {
        this.timestamp = LocalDateTime.now();
    }

    public ApiErrorResponse(boolean success, int status, String message) {
        this.success = success;
        this.status = status;
        this.message = message;
        this.timestamp = LocalDateTime.now();
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }
}