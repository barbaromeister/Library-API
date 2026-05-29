package com.library.libraryapi.service;

import com.library.libraryapi.dto.search.GoogleBookResult;
import com.library.libraryapi.exception.ResourceNotFoundException;
import com.library.libraryapi.messages.GenericErrorMessages;
import com.library.libraryapi.model.Book;
import com.library.libraryapi.model.User;
import com.library.libraryapi.repository.BookRepository;
import com.library.libraryapi.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;

@Service
public class  UserBookService {

    private final BookRepository bookRepository;
    private final UserRepository userRepository;
    private final GoogleBooksService googleBooksService;

    public UserBookService(BookRepository bookRepository,
                           UserRepository userRepository,
                           GoogleBooksService googleBooksService) {
        this.bookRepository = bookRepository;
        this.userRepository = userRepository;
        this.googleBooksService = googleBooksService;
    }

    @Transactional
    public Book addToUserCollection(String username, String googleBooksId) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException(
                        String.format(GenericErrorMessages.USER_NOT_FOUND_EXCEPTION_MESSAGE, username)));

        Book book = bookRepository.findByGoogleBooksId(googleBooksId)
                .orElseGet(() -> persistFromGoogle(googleBooksId));

        if (!user.getBooks().contains(book)) {
            user.addBook(book);
            userRepository.save(user);
        }
        return book;
    }

    private Book persistFromGoogle(String googleBooksId) {
        GoogleBookResult result = googleBooksService.getByGoogleId(googleBooksId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        String.format(GenericErrorMessages.GOOGLE_BOOK_NOT_FOUND_EXCEPTION_MESSAGE, googleBooksId)));

        Book book = new Book();
        book.setTitle(result.title());
        book.setAuthor(result.authors());
        book.setGoogleBooksId(result.googleId());
        book.setPublisher(result.publisher());
        book.setDescription(result.description());
        book.setLanguage(result.language());
        book.setIsbn(result.isbn13() != null ? result.isbn13() : result.isbn10());
        book.setSmallThumbnail(result.smallThumbnail());
        book.setThumbnail(result.thumbnail());
        book.setMediumImage(result.mediumImage());
        book.setLargeImage(result.largeImage());

        if (result.publishedDate() != null && !result.publishedDate().isEmpty()) {
            try {
                String dateStr = result.publishedDate();
                LocalDate publishDate;
                if (dateStr.length() == 4) {
                    publishDate = LocalDate.of(Integer.parseInt(dateStr), 1, 1);
                } else if (dateStr.length() == 7) {
                    publishDate = LocalDate.parse(dateStr + "-01");
                } else {
                    publishDate = LocalDate.parse(dateStr);
                }
                book.setPublishDate(publishDate);
            } catch (DateTimeParseException | NumberFormatException ignored) {
            }
        }
        if (result.pageCount() != null && result.pageCount() > 0) {
            book.setPageCount(result.pageCount());
        }

        return bookRepository.save(book);
    }

    @Transactional(readOnly = true)
    public boolean isInUserCollection(String username, String googleBooksId) {
        return userRepository.findByUsername(username)
                .map(u -> u.getBooks().stream().anyMatch(b -> googleBooksId.equals(b.getGoogleBooksId())))
                .orElse(false);
    }
}
