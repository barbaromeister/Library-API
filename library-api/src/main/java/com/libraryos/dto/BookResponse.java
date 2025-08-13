package com.libraryos.dto;

import lombok.Data;

import java.time.LocalDate;
import java.util.Set;

@Data
public class BookResponse {
    private Long id;
    private String title;
    private String isbn;
    private LocalDate publishedAt;
    private AuthorDto author;
    private Set<CategoryDto> categories;
}