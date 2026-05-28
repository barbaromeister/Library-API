package com.library.libraryapi.dto.book;

import com.library.libraryapi.messages.GenericErrorMessages;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

public record BookRequest(
        @NotBlank(message = GenericErrorMessages.TITLE_REQUIRED_VALIDATION_MESSAGE)
        @Size(max = 255)
        String title,

        @NotBlank(message = GenericErrorMessages.AUTHOR_REQUIRED_VALIDATION_MESSAGE)
        @Size(max = 255)
        String author,

        @Pattern(regexp = "^(\\d{10}|\\d{13})?$", message = GenericErrorMessages.ISBN_PATTERN_VALIDATION_MESSAGE)
        String isbn,

        LocalDate publishDate,

        @Min(value = 1, message = GenericErrorMessages.PAGE_COUNT_MIN_VALIDATION_MESSAGE)
        Integer pageCount,

        String publisher,
        String description,
        String language,
        String googleBooksId,
        CoverImages covers
) {}
