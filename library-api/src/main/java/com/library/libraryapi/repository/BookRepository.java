package com.library.libraryapi.repository;

import com.library.libraryapi.model.Book;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BookRepository extends JpaRepository<Book, Long> {

    List<Book> findByAuthorContainingIgnoreCase(String author);

    List<Book> findByTitleContainingIgnoreCase(String title);

    Book findByIsbn(String isbn);

    Optional<Book> findByGoogleBooksId(String googleBooksId);

    Optional<Book> findByTitleAndAuthor(String title, String author);
}
