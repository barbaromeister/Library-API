package com.library.libraryapi.dto.auth;

import com.library.libraryapi.model.User;

import java.time.Instant;
import java.time.ZoneOffset;

public record UserResponse(
        Long id,
        String username,
        String email,
        User.Role role,
        Instant createdAt
) {
    public static UserResponse from(User user) {
        return new UserResponse(
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getRole(),
                user.getCreatedAt() == null ? null : user.getCreatedAt().toInstant(ZoneOffset.UTC)
        );
    }
}
