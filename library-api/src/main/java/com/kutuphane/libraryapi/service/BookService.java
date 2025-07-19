package com.kutuphane.libraryapi.service;

import com.kutuphane.libraryapi.model.Book;
import java.util.List;

public interface BookService {

    List<Book> getAllBooks();

    Book getBookById(Long id);

    Book createBook(Book book);

    Book updateBook(Long id, Book bookDetails);

    void deleteBook(Long id);

    List<Book> findBooksByAuthor(String author);

    List<Book> findBooksByTitle(String title);

    Book findBookByIsbn(String isbn);
}
