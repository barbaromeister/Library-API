package com.libraryos.service;

import com.libraryos.domain.Author;
import com.libraryos.dto.AuthorDto;
import com.libraryos.exception.NotFoundException;
import com.libraryos.mapper.AuthorMapper;
import com.libraryos.repository.AuthorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class AuthorService {

    @Autowired
    private AuthorRepository authorRepository;

    @Autowired
    private AuthorMapper authorMapper;

    @Transactional(readOnly = true)
    public List<AuthorDto> getAllAuthors() {
        return authorRepository.findAll().stream()
                .map(authorMapper::toDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public AuthorDto getAuthorById(Long id) {
        Author author = authorRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Author not found with id: " + id));
        return authorMapper.toDto(author);
    }

    public AuthorDto createAuthor(AuthorDto authorDto) {
        Author author = authorMapper.toEntity(authorDto);
        author = authorRepository.save(author);
        return authorMapper.toDto(author);
    }

    public AuthorDto updateAuthor(Long id, AuthorDto authorDto) {
        Author existingAuthor = authorRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Author not found with id: " + id));
        
        existingAuthor.setName(authorDto.getName());
        existingAuthor.setBio(authorDto.getBio());
        
        Author updatedAuthor = authorRepository.save(existingAuthor);
        return authorMapper.toDto(updatedAuthor);
    }

    public void deleteAuthor(Long id) {
        if (!authorRepository.existsById(id)) {
            throw new NotFoundException("Author not found with id: " + id);
        }
        authorRepository.deleteById(id);
    }
}