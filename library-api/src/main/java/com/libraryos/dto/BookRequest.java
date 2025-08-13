package com.libraryos.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;
import java.util.Set;

@Data
public class BookRequest {

    @NotBlank(message = "Title is required")
    private String title;

    private String isbn;

    private LocalDate publishedAt;

    @NotNull(message = "Author ID is required")
    private Long authorId;

    private Set<Long> categoryIds;
}