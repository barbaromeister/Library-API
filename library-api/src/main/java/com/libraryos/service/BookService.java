package com.libraryos.service;

import com.libraryos.domain.Author;
import com.libraryos.domain.Book;
import com.libraryos.domain.Category;
import com.libraryos.dto.BookRequest;
import com.libraryos.dto.BookResponse;
import com.libraryos.exception.NotFoundException;
import com.libraryos.mapper.BookMapper;
import com.libraryos.repository.AuthorRepository;
import com.libraryos.repository.BookRepository;
import com.libraryos.repository.CategoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@Transactional
public class BookService {

    @Autowired
    private BookRepository bookRepository;

    @Autowired
    private AuthorRepository authorRepository;

    @Autowired
    private CategoryRepository categoryRepository;

    @Autowired
    private BookMapper bookMapper;

    @Transactional(readOnly = true)
    public List<BookResponse> searchBooks(String q, Long authorId, Long categoryId) {
        List<Book> books = bookRepository.findBooksWithFilters(q, authorId, categoryId);
        return books.stream()
                .map(bookMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public BookResponse getBookById(Long id) {
        Book book = bookRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Book not found with id: " + id));
        return bookMapper.toResponse(book);
    }

    public BookResponse createBook(BookRequest bookRequest) {
        Author author = authorRepository.findById(bookRequest.getAuthorId())
                .orElseThrow(() -> new NotFoundException("Author not found with id: " + bookRequest.getAuthorId()));

        Set<Category> categories = new HashSet<>();
        if (bookRequest.getCategoryIds() != null && !bookRequest.getCategoryIds().isEmpty()) {
            for (Long categoryId : bookRequest.getCategoryIds()) {
                Category category = categoryRepository.findById(categoryId)
                        .orElseThrow(() -> new NotFoundException("Category not found with id: " + categoryId));
                categories.add(category);
            }
        }

        Book book = new Book();
        book.setTitle(bookRequest.getTitle());
        book.setIsbn(bookRequest.getIsbn());
        book.setPublishedAt(bookRequest.getPublishedAt());
        book.setAuthor(author);
        book.setCategories(categories);

        book = bookRepository.save(book);
        return bookMapper.toResponse(book);
    }

    public BookResponse updateBook(Long id, BookRequest bookRequest) {
        Book existingBook = bookRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Book not found with id: " + id));

        Author author = authorRepository.findById(bookRequest.getAuthorId())
                .orElseThrow(() -> new NotFoundException("Author not found with id: " + bookRequest.getAuthorId()));

        Set<Category> categories = new HashSet<>();
        if (bookRequest.getCategoryIds() != null && !bookRequest.getCategoryIds().isEmpty()) {
            for (Long categoryId : bookRequest.getCategoryIds()) {
                Category category = categoryRepository.findById(categoryId)
                        .orElseThrow(() -> new NotFoundException("Category not found with id: " + categoryId));
                categories.add(category);
            }
        }

        existingBook.setTitle(bookRequest.getTitle());
        existingBook.setIsbn(bookRequest.getIsbn());
        existingBook.setPublishedAt(bookRequest.getPublishedAt());
        existingBook.setAuthor(author);
        existingBook.setCategories(categories);

        Book updatedBook = bookRepository.save(existingBook);
        return bookMapper.toResponse(updatedBook);
    }

    public void deleteBook(Long id) {
        if (!bookRepository.existsById(id)) {
            throw new NotFoundException("Book not found with id: " + id);
        }
        bookRepository.deleteById(id);
    }
}