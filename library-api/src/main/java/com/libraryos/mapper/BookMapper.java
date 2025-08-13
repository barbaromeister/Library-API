package com.libraryos.mapper;

import com.libraryos.domain.Book;
import com.libraryos.dto.BookResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.stream.Collectors;

@Component
public class BookMapper {

    @Autowired
    private AuthorMapper authorMapper;

    @Autowired
    private CategoryMapper categoryMapper;

    public BookResponse toResponse(Book book) {
        if (book == null) {
            return null;
        }
        
        BookResponse response = new BookResponse();
        response.setId(book.getId());
        response.setTitle(book.getTitle());
        response.setIsbn(book.getIsbn());
        response.setPublishedAt(book.getPublishedAt());
        response.setAuthor(authorMapper.toDto(book.getAuthor()));
        
        if (book.getCategories() != null) {
            response.setCategories(
                book.getCategories().stream()
                    .map(categoryMapper::toDto)
                    .collect(Collectors.toSet())
            );
        }
        
        return response;
    }
}