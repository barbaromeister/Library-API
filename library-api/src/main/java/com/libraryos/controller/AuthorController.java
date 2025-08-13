package com.libraryos.controller;

import com.libraryos.dto.AuthorDto;
import com.libraryos.service.AuthorService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/authors")
@Tag(name = "Authors", description = "Author management API")
public class AuthorController {

    @Autowired
    private AuthorService authorService;

    @GetMapping
    @Operation(summary = "Get all authors", description = "Retrieve a list of all authors")
    public ResponseEntity<List<AuthorDto>> getAllAuthors() {
        List<AuthorDto> authors = authorService.getAllAuthors();
        return ResponseEntity.ok(authors);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get author by ID", description = "Retrieve a specific author by their ID")
    public ResponseEntity<AuthorDto> getAuthorById(@PathVariable Long id) {
        AuthorDto author = authorService.getAuthorById(id);
        return ResponseEntity.ok(author);
    }

    @PostMapping
    @Operation(summary = "Create new author", description = "Create a new author")
    public ResponseEntity<AuthorDto> createAuthor(@Valid @RequestBody AuthorDto authorDto) {
        AuthorDto createdAuthor = authorService.createAuthor(authorDto);
        return new ResponseEntity<>(createdAuthor, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update author", description = "Update an existing author")
    public ResponseEntity<AuthorDto> updateAuthor(@PathVariable Long id, @Valid @RequestBody AuthorDto authorDto) {
        AuthorDto updatedAuthor = authorService.updateAuthor(id, authorDto);
        return ResponseEntity.ok(updatedAuthor);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete author", description = "Delete an author by ID")
    public ResponseEntity<Void> deleteAuthor(@PathVariable Long id) {
        authorService.deleteAuthor(id);
        return ResponseEntity.noContent().build();
    }
}