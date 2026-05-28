package com.library.libraryapi.dto.book;

import com.library.libraryapi.model.Book;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;

public record BookResponse(
        Long id,
        String title,
        String author,
        String isbn,
        LocalDate publishDate,
        Integer pageCount,
        String googleBooksId,
        String publisher,
        String description,
        String language,
        CoverImages covers,
        Instant createdAt,
        Instant updatedAt
) {
    public static BookResponse from(Book book) {
        return new BookResponse(
                book.getId(),
                book.getTitle(),
                book.getAuthor(),
                book.getIsbn(),
                book.getPublishDate(),
                book.getPageCount(),
                book.getGoogleBooksId(),
                book.getPublisher(),
                book.getDescription(),
                book.getLanguage(),
                CoverImages.from(book),
                book.getCreatedAt() == null ? null : book.getCreatedAt().toInstant(ZoneOffset.UTC),
                book.getUpdatedAt() == null ? null : book.getUpdatedAt().toInstant(ZoneOffset.UTC)
        );
    }
}
