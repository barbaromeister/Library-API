package com.libraryos.mapper;

import com.libraryos.domain.Author;
import com.libraryos.dto.AuthorDto;
import org.springframework.stereotype.Component;

@Component
public class AuthorMapper {

    public AuthorDto toDto(Author author) {
        if (author == null) {
            return null;
        }
        
        AuthorDto dto = new AuthorDto();
        dto.setId(author.getId());
        dto.setName(author.getName());
        dto.setBio(author.getBio());
        dto.setCreatedAt(author.getCreatedAt());
        return dto;
    }

    public Author toEntity(AuthorDto dto) {
        if (dto == null) {
            return null;
        }
        
        Author author = new Author();
        author.setId(dto.getId());
        author.setName(dto.getName());
        author.setBio(dto.getBio());
        author.setCreatedAt(dto.getCreatedAt());
        return author;
    }
}