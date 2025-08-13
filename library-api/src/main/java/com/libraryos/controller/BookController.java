package com.libraryos.controller;

import com.libraryos.dto.BookRequest;
import com.libraryos.dto.BookResponse;
import com.libraryos.service.BookService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/books")
@Tag(name = "Books", description = "Book management API")
public class BookController {

    @Autowired
    private BookService bookService;

    @GetMapping
    @Operation(summary = "Search books", description = "Search books with optional filters")
    public ResponseEntity<List<BookResponse>> searchBooks(
            @Parameter(description = "Search term for book title") @RequestParam(required = false) String q,
            @Parameter(description = "Filter by author ID") @RequestParam(required = false) Long authorId,
            @Parameter(description = "Filter by category ID") @RequestParam(required = false) Long categoryId) {
        List<BookResponse> books = bookService.searchBooks(q, authorId, categoryId);
        return ResponseEntity.ok(books);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get book by ID", description = "Retrieve a specific book by its ID")
    public ResponseEntity<BookResponse> getBookById(@PathVariable Long id) {
        BookResponse book = bookService.getBookById(id);
        return ResponseEntity.ok(book);
    }

    @PostMapping
    @Operation(summary = "Create new book", description = "Create a new book")
    public ResponseEntity<BookResponse> createBook(@Valid @RequestBody BookRequest bookRequest) {
        BookResponse createdBook = bookService.createBook(bookRequest);
        return new ResponseEntity<>(createdBook, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update book", description = "Update an existing book")
    public ResponseEntity<BookResponse> updateBook(@PathVariable Long id, @Valid @RequestBody BookRequest bookRequest) {
        BookResponse updatedBook = bookService.updateBook(id, bookRequest);
        return ResponseEntity.ok(updatedBook);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete book", description = "Delete a book by ID")
    public ResponseEntity<Void> deleteBook(@PathVariable Long id) {
        bookService.deleteBook(id);
        return ResponseEntity.noContent().build();
    }
}