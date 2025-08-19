package com.kutuphane.libraryapi.controller;

import com.kutuphane.libraryapi.service.GoogleBooksService;
import com.kutuphane.libraryapi.service.GoogleBooksService.BookSuggestion;
import com.kutuphane.libraryapi.service.UserBookService;
import com.kutuphane.libraryapi.model.Book;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.Authentication;

import java.util.List;
import java.util.Map;
import java.util.HashMap;

@RestController
@RequestMapping("/api/books")
public class BookSearchController {
    
    @Autowired
    private GoogleBooksService googleBooksService;
    
    @Autowired
    private UserBookService userBookService;
    
    @GetMapping("/search")
    public ResponseEntity<Map<String, Object>> searchBooks(
            @RequestParam String query,
            @RequestParam(defaultValue = "10") int maxResults) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Validate query length
            if (query == null || query.trim().length() < 3) {
                response.put("success", false);
                response.put("message", "Query must be at least 3 characters long");
                response.put("suggestions", List.of());
                return ResponseEntity.badRequest().body(response);
            }
            
            // Search books
            List<BookSuggestion> suggestions = googleBooksService.searchBooks(query, maxResults);
            
            response.put("success", true);
            response.put("query", query.trim());
            response.put("count", suggestions.size());
            response.put("suggestions", suggestions);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error searching books: " + e.getMessage());
            response.put("suggestions", List.of());
            return ResponseEntity.status(500).body(response);
        }
    }
    
    @GetMapping("/suggest")
    public ResponseEntity<List<BookSuggestion>> getSuggestions(
            @RequestParam String query,
            @RequestParam(defaultValue = "5") int limit) {
        
        try {
            if (query == null || query.trim().length() < 3) {
                return ResponseEntity.ok(List.of());
            }
            
            List<BookSuggestion> suggestions = googleBooksService.searchBooks(query, limit);
            return ResponseEntity.ok(suggestions);
            
        } catch (Exception e) {
            System.err.println("Error getting suggestions: " + e.getMessage());
            return ResponseEntity.ok(List.of());
        }
    }
    
    @GetMapping("/test-search")
    public ResponseEntity<Map<String, Object>> testSearch() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Test search with "Harry Potter"
            List<BookSuggestion> suggestions = googleBooksService.searchBooks("Harry Potter", 3);
            
            response.put("success", true);
            response.put("message", "Test search completed");
            response.put("testQuery", "Harry Potter");
            response.put("resultsCount", suggestions.size());
            response.put("results", suggestions);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Test search failed: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }
    
    @PostMapping("/add-to-collection")
    public ResponseEntity<Map<String, Object>> addBookToCollection(
            @RequestBody BookSuggestion bookSuggestion,
            Authentication authentication) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (authentication == null || !authentication.isAuthenticated()) {
                response.put("success", false);
                response.put("message", "User not authenticated");
                return ResponseEntity.status(401).body(response);
            }
            
            String username = authentication.getName();
            Book addedBook = userBookService.addBookToUserCollection(username, bookSuggestion);
            
            response.put("success", true);
            response.put("message", "Book added to your collection successfully");
            response.put("book", Map.of(
                "id", addedBook.getId(),
                "title", addedBook.getTitle(),
                "author", addedBook.getAuthor(),
                "publisher", addedBook.getPublisher() != null ? addedBook.getPublisher() : ""
            ));
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Failed to add book to collection: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }
    
    @GetMapping("/check-collection")
    public ResponseEntity<Map<String, Object>> checkBookInCollection(
            @RequestParam String googleBooksId,
            Authentication authentication) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (authentication == null || !authentication.isAuthenticated()) {
                response.put("success", false);
                response.put("inCollection", false);
                return ResponseEntity.ok(response);
            }
            
            String username = authentication.getName();
            boolean inCollection = userBookService.isBookInUserCollection(username, googleBooksId);
            
            response.put("success", true);
            response.put("inCollection", inCollection);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("inCollection", false);
            response.put("message", "Error checking collection: " + e.getMessage());
            return ResponseEntity.ok(response);
        }
    }
}