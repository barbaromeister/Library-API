package com.library.libraryapi.dto.auth;

import com.library.libraryapi.model.User;

public record AuthResponse(
        String token,
        String tokenType,
        UserResponse user
) {
    public static AuthResponse of(String token, User user) {
        return new AuthResponse(token, "Bearer", UserResponse.from(user));
    }
}
