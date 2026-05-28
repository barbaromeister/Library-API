package com.library.libraryapi.dto.auth;

import com.library.libraryapi.messages.GenericErrorMessages;
import jakarta.validation.constraints.NotBlank;

public record LoginRequest(
        @NotBlank(message = GenericErrorMessages.USERNAME_REQUIRED_VALIDATION_MESSAGE)
        String username,

        @NotBlank(message = GenericErrorMessages.PASSWORD_REQUIRED_VALIDATION_MESSAGE)
        String password
) {}
