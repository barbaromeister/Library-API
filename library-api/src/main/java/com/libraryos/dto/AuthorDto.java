package com.libraryos.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.time.OffsetDateTime;

@Data
public class AuthorDto {
    private Long id;

    @NotBlank(message = "Name is required")
    private String name;

    private String bio;

    private OffsetDateTime createdAt;
}