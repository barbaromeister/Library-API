package com.library.libraryapi.dto.auth;

import com.library.libraryapi.messages.GenericErrorMessages;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
        @NotBlank(message = GenericErrorMessages.USERNAME_REQUIRED_VALIDATION_MESSAGE)
        @Size(min = 3, max = 30, message = GenericErrorMessages.USERNAME_SIZE_VALIDATION_MESSAGE)
        String username,

        @NotBlank(message = GenericErrorMessages.EMAIL_REQUIRED_VALIDATION_MESSAGE)
        @Email(message = GenericErrorMessages.EMAIL_INVALID_VALIDATION_MESSAGE)
        String email,

        @NotBlank(message = GenericErrorMessages.PASSWORD_REQUIRED_VALIDATION_MESSAGE)
        @Size(min = 8, max = 72, message = GenericErrorMessages.PASSWORD_SIZE_VALIDATION_MESSAGE)
        String password
) {}
