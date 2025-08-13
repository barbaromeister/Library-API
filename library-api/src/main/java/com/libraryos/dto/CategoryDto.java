package com.libraryos.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CategoryDto {
    private Long id;

    @NotBlank(message = "Name is required")
    private String name;
}