package com.kutuphane.libraryapi.repository;

import com.kutuphane.libraryapi.model.Book;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BookRepository extends JpaRepository<Book, Long> {

    // Yazara göre kitapları bul
    List<Book> findByAuthorContainingIgnoreCase(String author);

    // Başlığa göre kitapları bul
    List<Book> findByTitleContainingIgnoreCase(String title);

    // ISBN'e göre kitap bul
    Book findByIsbn(String isbn);

    // Google Books ID'ye göre kitap bul
    Optional<Book> findByGoogleBooksId(String googleBooksId);

    // Başlık ve yazara göre kitap bul
    Optional<Book> findByTitleAndAuthor(String title, String author);
}
