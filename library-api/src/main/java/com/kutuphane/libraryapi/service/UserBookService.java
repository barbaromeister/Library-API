package com.kutuphane.libraryapi.service;

import com.kutuphane.libraryapi.service.GoogleBooksService.BookSuggestion;
import com.kutuphane.libraryapi.model.Book;
import com.kutuphane.libraryapi.model.User;
import com.kutuphane.libraryapi.repository.BookRepository;
import com.kutuphane.libraryapi.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Optional;

@Service
public class UserBookService {

    @Autowired
    private BookRepository bookRepository;

    @Autowired
    private UserRepository userRepository;

    @Transactional
    public Book addBookToUserCollection(String username, BookSuggestion bookSuggestion) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found: " + username));

        // Check if book already exists by Google Books ID or title+author
        Book existingBook = null;
        if (bookSuggestion.getGoogleId() != null) {
            existingBook = bookRepository.findByGoogleBooksId(bookSuggestion.getGoogleId()).orElse(null);
        }
        
        if (existingBook == null) {
            existingBook = bookRepository.findByTitleAndAuthor(
                bookSuggestion.getTitle(), bookSuggestion.getAuthors()).orElse(null);
        }

        Book book;
        if (existingBook != null) {
            book = existingBook;
        } else {
            // Create new book from BookSuggestion
            book = createBookFromSuggestion(bookSuggestion);
            book = bookRepository.save(book);
        }

        // Check if user already has this book
        if (!user.getBooks().contains(book)) {
            user.addBook(book);
            userRepository.save(user);
        }

        return book;
    }

    private Book createBookFromSuggestion(BookSuggestion suggestion) {
        Book book = new Book();
        book.setTitle(suggestion.getTitle());
        book.setAuthor(suggestion.getAuthors());
        book.setGoogleBooksId(suggestion.getGoogleId());
        book.setPublisher(suggestion.getPublisher());
        book.setDescription(suggestion.getDescription());
        book.setLanguage(suggestion.getLanguage());

        // Set cover images
        book.setSmallThumbnail(suggestion.getSmallThumbnail());
        book.setThumbnail(suggestion.getThumbnail());
        book.setMediumImage(suggestion.getMediumImage());

        // Parse publish date
        if (suggestion.getPublishedDate() != null && !suggestion.getPublishedDate().isEmpty()) {
            try {
                // Try different date formats
                LocalDate publishDate = null;
                String dateStr = suggestion.getPublishedDate();
                
                if (dateStr.length() == 4) { // Year only
                    publishDate = LocalDate.of(Integer.parseInt(dateStr), 1, 1);
                } else if (dateStr.length() == 7) { // YYYY-MM
                    publishDate = LocalDate.parse(dateStr + "-01");
                } else { // Full date
                    publishDate = LocalDate.parse(dateStr);
                }
                
                book.setPublishDate(publishDate);
            } catch (DateTimeParseException | NumberFormatException e) {
                // Ignore invalid dates
            }
        }

        // Set page count
        if (suggestion.getPageCount() != null && suggestion.getPageCount() > 0) {
            book.setPageCount(suggestion.getPageCount());
        }

        return book;
    }

    @Transactional(readOnly = true)
    public boolean isBookInUserCollection(String username, String googleBooksId) {
        Optional<User> userOpt = userRepository.findByUsername(username);
        if (!userOpt.isPresent()) {
            return false;
        }

        User user = userOpt.get();
        return user.getBooks().stream()
                .anyMatch(book -> googleBooksId.equals(book.getGoogleBooksId()));
    }

    @Transactional
    public void removeBookFromUserCollection(String username, Long bookId) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found: " + username));

        Book book = bookRepository.findById(bookId)
                .orElseThrow(() -> new RuntimeException("Book not found: " + bookId));

        user.removeBook(book);
        userRepository.save(user);
    }
}