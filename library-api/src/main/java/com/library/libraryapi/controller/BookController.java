package com.library.libraryapi.controller;

import com.library.libraryapi.dto.book.BookRequest;
import com.library.libraryapi.dto.book.BookResponse;
import com.library.libraryapi.dto.search.AddToCollectionRequest;
import com.library.libraryapi.dto.search.CollectionCheckResponse;
import com.library.libraryapi.dto.search.GoogleBookResult;
import com.library.libraryapi.dto.search.SearchResponse;
import com.library.libraryapi.service.BookService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/books")
public class BookController {

    private final BookService bookService;

    public BookController(BookService bookService) {
        this.bookService = bookService;
    }

    // ----- CRUD -----

    @GetMapping
    public List<BookResponse> getAllBooks() {
        return bookService.getAllBooks();
    }

    @GetMapping("/{id}")
    public BookResponse getBookById(@PathVariable Long id) {
        return bookService.getBookById(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public BookResponse createBook(@Valid @RequestBody BookRequest request) {
        return bookService.createBook(request);
    }

    @PutMapping("/{id}")
    public BookResponse updateBook(@PathVariable Long id, @Valid @RequestBody BookRequest request) {
        return bookService.updateBook(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteBook(@PathVariable Long id) {
        bookService.deleteBook(id);
    }

    // ----- DB Search -----

    @GetMapping("/search/author")
    public List<BookResponse> getBooksByAuthor(@RequestParam String author) {
        return bookService.findBooksByAuthor(author);
    }

    @GetMapping("/search/title")
    public List<BookResponse> getBooksByTitle(@RequestParam String title) {
        return bookService.findBooksByTitle(title);
    }

    @GetMapping("/search/isbn")
    public BookResponse getBookByIsbn(@RequestParam String isbn) {
        return bookService.findBookByIsbn(isbn);
    }

    // ----- Google Books integration -----

    @GetMapping("/google-search")
    public SearchResponse googleSearch(@RequestParam String query,
                                      @RequestParam(defaultValue = "10") int maxResults) {
        return bookService.googleSearch(query, maxResults);
    }

    @GetMapping("/google-suggest")
    public List<GoogleBookResult> googleSuggest(@RequestParam String query,
                                                @RequestParam(defaultValue = "5") int limit) {
        return bookService.googleSuggest(query, limit);
    }

    // ----- User collection -----

    @PostMapping("/collection")
    @ResponseStatus(HttpStatus.CREATED)
    public BookResponse addToCollection(@Valid @RequestBody AddToCollectionRequest request,
                                        Authentication authentication) {
        return bookService.addToUserCollection(authentication.getName(), request.googleBooksId());
    }

    @GetMapping("/collection/check")
    public CollectionCheckResponse checkInCollection(@RequestParam String googleBooksId,
                                                     Authentication authentication) {
        return bookService.checkInUserCollection(authentication.getName(), googleBooksId);
    }
}
