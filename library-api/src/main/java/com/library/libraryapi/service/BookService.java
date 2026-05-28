package com.library.libraryapi.service;

import com.library.libraryapi.dto.book.BookRequest;
import com.library.libraryapi.dto.book.BookResponse;
import com.library.libraryapi.dto.search.CollectionCheckResponse;
import com.library.libraryapi.dto.search.GoogleBookResult;
import com.library.libraryapi.dto.search.SearchResponse;

import java.util.List;

public interface BookService {

    List<BookResponse> getAllBooks();

    BookResponse getBookById(Long id);

    BookResponse createBook(BookRequest request);

    BookResponse updateBook(Long id, BookRequest request);

    void deleteBook(Long id);

    List<BookResponse> findBooksByAuthor(String author);

    List<BookResponse> findBooksByTitle(String title);

    BookResponse findBookByIsbn(String isbn);

    SearchResponse googleSearch(String query, int maxResults);

    List<GoogleBookResult> googleSuggest(String query, int limit);

    BookResponse addToUserCollection(String username, String googleBooksId);

    CollectionCheckResponse checkInUserCollection(String username, String googleBooksId);
}
