package com.hims.core.authz;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.OffsetDateTime;
import java.util.Map;

/**
 * Global exception handler for authorization errors.
 * 
 * Converts AccessDeniedException (thrown by Permit.io checks)
 * into proper HTTP 403 responses.
 */
@RestControllerAdvice
public class AccessDeniedExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(AccessDeniedExceptionHandler.class);

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<Map<String, Object>> handleAccessDenied(AccessDeniedException ex) {
        log.warn("Access denied: {}", ex.getMessage());

        Map<String, Object> body = Map.of(
            "timestamp", OffsetDateTime.now().toString(),
            "status", 403,
            "error", "Forbidden",
            "message", ex.getMessage(),
            "path", "" // Will be populated by filter if needed
        );

        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(body);
    }
}

