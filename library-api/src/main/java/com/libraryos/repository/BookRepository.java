package com.libraryos.repository;

import com.libraryos.domain.Book;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BookRepository extends JpaRepository<Book, Long> {

    @Query("SELECT DISTINCT b FROM Book b " +
           "LEFT JOIN FETCH b.author " +
           "LEFT JOIN FETCH b.categories " +
           "WHERE (:q IS NULL OR LOWER(b.title) LIKE LOWER(CONCAT('%', :q, '%'))) " +
           "AND (:authorId IS NULL OR b.author.id = :authorId) " +
           "AND (:categoryId IS NULL OR :categoryId IN (SELECT c.id FROM b.categories c))")
    List<Book> findBooksWithFilters(@Param("q") String q,
                                   @Param("authorId") Long authorId,
                                   @Param("categoryId") Long categoryId);
}