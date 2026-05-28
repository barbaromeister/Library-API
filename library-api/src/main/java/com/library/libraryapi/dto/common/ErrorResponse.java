package com.library.libraryapi.dto.common;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.time.Instant;
import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record ErrorResponse(
        Instant timestamp,
        int status,
        String error,
        String message,
        String path,
        List<FieldError> fieldErrors
) {
    public static ErrorResponse of(int status, String error, String message, String path) {
        return new ErrorResponse(Instant.now(), status, error, message, path, null);
    }

    public static ErrorResponse withFieldErrors(int status, String error, String message, String path, List<FieldError> fieldErrors) {
        return new ErrorResponse(Instant.now(), status, error, message, path, fieldErrors);
    }

    public record FieldError(String field, String message) {}
}
