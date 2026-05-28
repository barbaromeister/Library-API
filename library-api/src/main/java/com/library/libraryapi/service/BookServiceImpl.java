package com.library.libraryapi.service;

import com.library.libraryapi.dto.book.BookRequest;
import com.library.libraryapi.dto.book.BookResponse;
import com.library.libraryapi.dto.search.CollectionCheckResponse;
import com.library.libraryapi.dto.search.GoogleBookResult;
import com.library.libraryapi.dto.search.SearchResponse;
import com.library.libraryapi.exception.ResourceNotFoundException;
import com.library.libraryapi.messages.GenericErrorMessages;
import com.library.libraryapi.model.Book;
import com.library.libraryapi.repository.BookRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class BookServiceImpl implements BookService {

    private final BookRepository bookRepository;
    private final GoogleBooksService googleBooksService;
    private final UserBookService userBookService;

    public BookServiceImpl(BookRepository bookRepository,
                           GoogleBooksService googleBooksService,
                           UserBookService userBookService) {
        this.bookRepository = bookRepository;
        this.googleBooksService = googleBooksService;
        this.userBookService = userBookService;
    }

    @Override
    @Transactional(readOnly = true)
    public List<BookResponse> getAllBooks() {
        return bookRepository.findAll().stream()
                .map(BookResponse::from)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public BookResponse getBookById(Long id) {
        return BookResponse.from(findBookEntityById(id));
    }

    @Override
    @Transactional
    public BookResponse createBook(BookRequest request) {
        Book book = new Book();
        applyRequest(book, request);
        Book saved = bookRepository.saveAndFlush(book);
        return BookResponse.from(saved);
    }

    @Override
    @Transactional
    public BookResponse updateBook(Long id, BookRequest request) {
        Book book = findBookEntityById(id);
        applyRequest(book, request);
        Book saved = bookRepository.saveAndFlush(book);
        return BookResponse.from(saved);
    }

    @Override
    @Transactional
    public void deleteBook(Long id) {
        Book book = findBookEntityById(id);
        bookRepository.delete(book);
    }

    @Override
    @Transactional(readOnly = true)
    public List<BookResponse> findBooksByAuthor(String author) {
        return bookRepository.findByAuthorContainingIgnoreCase(author).stream()
                .map(BookResponse::from)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<BookResponse> findBooksByTitle(String title) {
        return bookRepository.findByTitleContainingIgnoreCase(title).stream()
                .map(BookResponse::from)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public BookResponse findBookByIsbn(String isbn) {
        Book book = bookRepository.findByIsbn(isbn);
        if (book == null) {
            throw new ResourceNotFoundException(
                    String.format(GenericErrorMessages.BOOK_NOT_FOUND_BY_ISBN_EXCEPTION_MESSAGE, isbn));
        }
        return BookResponse.from(book);
    }

    @Override
    public SearchResponse googleSearch(String query, int maxResults) {
        List<GoogleBookResult> results = googleBooksService.searchBooks(query, maxResults);
        return SearchResponse.of(query == null ? "" : query.trim(), results);
    }

    @Override
    public List<GoogleBookResult> googleSuggest(String query, int limit) {
        if (query == null || query.trim().length() < 3) {
            return List.of();
        }
        return googleBooksService.searchBooks(query, limit);
    }

    @Override
    public BookResponse addToUserCollection(String username, String googleBooksId) {
        return BookResponse.from(userBookService.addToUserCollection(username, googleBooksId));
    }

    @Override
    public CollectionCheckResponse checkInUserCollection(String username, String googleBooksId) {
        return new CollectionCheckResponse(userBookService.isInUserCollection(username, googleBooksId));
    }

    private Book findBookEntityById(Long id) {
        return bookRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException(
                        String.format(GenericErrorMessages.BOOK_NOT_FOUND_BY_ID_EXCEPTION_MESSAGE, id)));
    }

    private void applyRequest(Book book, BookRequest request) {
        book.setTitle(request.title());
        book.setAuthor(request.author());
        book.setIsbn(request.isbn());
        book.setPublishDate(request.publishDate());
        book.setPageCount(request.pageCount());
        book.setPublisher(request.publisher());
        book.setDescription(request.description());
        book.setLanguage(request.language());
        book.setGoogleBooksId(request.googleBooksId());
        if (request.covers() != null) {
            book.setSmallThumbnail(request.covers().small());
            book.setThumbnail(request.covers().thumbnail());
            book.setMediumImage(request.covers().medium());
            book.setLargeImage(request.covers().large());
        }
    }
}
