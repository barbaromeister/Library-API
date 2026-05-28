package com.library.libraryapi.dto.search;

import com.library.libraryapi.messages.GenericErrorMessages;
import jakarta.validation.constraints.NotBlank;

public record AddToCollectionRequest(
        @NotBlank(message = GenericErrorMessages.GOOGLE_BOOKS_ID_REQUIRED_VALIDATION_MESSAGE)
        String googleBooksId
) {}
