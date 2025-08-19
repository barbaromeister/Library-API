package com.kutuphane.libraryapi.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.util.UriComponentsBuilder;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;
import java.util.ArrayList;
import java.time.Duration;

@Service
public class GoogleBooksService {
    
    private final WebClient webClient;
    private static final String GOOGLE_BOOKS_API_URL = "https://www.googleapis.com/books/v1/volumes";
    
    @Value("${google.books.api.key:}")
    private String apiKey;
    
    public GoogleBooksService() {
        this.webClient = WebClient.builder()
            .codecs(configurer -> configurer.defaultCodecs().maxInMemorySize(2 * 1024 * 1024))
            .build();
    }
    
    public List<BookSuggestion> searchBooks(String query, int maxResults) {
        if (query == null || query.trim().length() < 3) {
            return new ArrayList<>();
        }
        
        try {
            String url = buildSearchUrl(query.trim(), maxResults);
            
            GoogleBooksResponse response = webClient.get()
                .uri(url)
                .retrieve()
                .bodyToMono(GoogleBooksResponse.class)
                .timeout(Duration.ofSeconds(10))
                .block();
                
            return convertToBookSuggestions(response);
            
        } catch (Exception e) {
            System.err.println("Error searching Google Books API: " + e.getMessage());
            return new ArrayList<>();
        }
    }
    
    private String buildSearchUrl(String query, int maxResults) {
        UriComponentsBuilder builder = UriComponentsBuilder.fromUriString(GOOGLE_BOOKS_API_URL)
            .queryParam("q", query)
            .queryParam("maxResults", Math.min(maxResults, 40))
            .queryParam("printType", "books")
            .queryParam("projection", "lite");
            
        if (apiKey != null && !apiKey.isEmpty()) {
            builder.queryParam("key", apiKey);
        }
        
        return builder.toUriString();
    }
    
    private List<BookSuggestion> convertToBookSuggestions(GoogleBooksResponse response) {
        List<BookSuggestion> suggestions = new ArrayList<>();
        
        if (response == null || response.items == null) {
            return suggestions;
        }
        
        for (GoogleBookItem item : response.items) {
            if (item.volumeInfo != null) {
                BookSuggestion suggestion = new BookSuggestion();
                suggestion.setGoogleId(item.id);
                suggestion.setTitle(item.volumeInfo.title);
                suggestion.setSubtitle(item.volumeInfo.subtitle);
                
                // Authors
                if (item.volumeInfo.authors != null && !item.volumeInfo.authors.isEmpty()) {
                    suggestion.setAuthors(String.join(", ", item.volumeInfo.authors));
                }
                
                // Publisher
                suggestion.setPublisher(item.volumeInfo.publisher);
                
                // Published Date
                suggestion.setPublishedDate(item.volumeInfo.publishedDate);
                
                // ISBN
                if (item.volumeInfo.industryIdentifiers != null) {
                    for (IndustryIdentifier identifier : item.volumeInfo.industryIdentifiers) {
                        if ("ISBN_13".equals(identifier.type)) {
                            suggestion.setIsbn13(identifier.identifier);
                        } else if ("ISBN_10".equals(identifier.type)) {
                            suggestion.setIsbn10(identifier.identifier);
                        }
                    }
                }
                
                // Description
                suggestion.setDescription(item.volumeInfo.description);
                
                // Page Count
                suggestion.setPageCount(item.volumeInfo.pageCount);
                
                // Cover Images
                if (item.volumeInfo.imageLinks != null) {
                    suggestion.setSmallThumbnail(item.volumeInfo.imageLinks.smallThumbnail);
                    suggestion.setThumbnail(item.volumeInfo.imageLinks.thumbnail);
                    suggestion.setSmallImage(item.volumeInfo.imageLinks.small);
                    suggestion.setMediumImage(item.volumeInfo.imageLinks.medium);
                    suggestion.setLargeImage(item.volumeInfo.imageLinks.large);
                }
                
                // Categories
                if (item.volumeInfo.categories != null && !item.volumeInfo.categories.isEmpty()) {
                    suggestion.setCategories(String.join(", ", item.volumeInfo.categories));
                }
                
                suggestion.setLanguage(item.volumeInfo.language);
                suggestion.setPreviewLink(item.volumeInfo.previewLink);
                suggestion.setInfoLink(item.volumeInfo.infoLink);
                
                suggestions.add(suggestion);
            }
        }
        
        return suggestions;
    }
    
    // Google Books API Response DTOs
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class GoogleBooksResponse {
        public List<GoogleBookItem> items;
        public int totalItems;
    }
    
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class GoogleBookItem {
        public String id;
        public VolumeInfo volumeInfo;
    }
    
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class VolumeInfo {
        public String title;
        public String subtitle;
        public List<String> authors;
        public String publisher;
        public String publishedDate;
        public String description;
        public List<IndustryIdentifier> industryIdentifiers;
        public Integer pageCount;
        public List<String> categories;
        public ImageLinks imageLinks;
        public String language;
        public String previewLink;
        public String infoLink;
    }
    
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class IndustryIdentifier {
        public String type;
        public String identifier;
    }
    
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class ImageLinks {
        public String smallThumbnail;
        public String thumbnail;
        public String small;
        public String medium;
        public String large;
        public String extraLarge;
    }
    
    // Book Suggestion DTO for frontend
    public static class BookSuggestion {
        private String googleId;
        private String title;
        private String subtitle;
        private String authors;
        private String publisher;
        private String publishedDate;
        private String description;
        private String isbn10;
        private String isbn13;
        private Integer pageCount;
        private String categories;
        private String language;
        
        // Cover images
        private String smallThumbnail;
        private String thumbnail;
        private String smallImage;
        private String mediumImage;
        private String largeImage;
        
        // Links
        private String previewLink;
        private String infoLink;
        
        // Getters and Setters
        public String getGoogleId() { return googleId; }
        public void setGoogleId(String googleId) { this.googleId = googleId; }
        
        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }
        
        public String getSubtitle() { return subtitle; }
        public void setSubtitle(String subtitle) { this.subtitle = subtitle; }
        
        public String getAuthors() { return authors; }
        public void setAuthors(String authors) { this.authors = authors; }
        
        public String getPublisher() { return publisher; }
        public void setPublisher(String publisher) { this.publisher = publisher; }
        
        public String getPublishedDate() { return publishedDate; }
        public void setPublishedDate(String publishedDate) { this.publishedDate = publishedDate; }
        
        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }
        
        public String getIsbn10() { return isbn10; }
        public void setIsbn10(String isbn10) { this.isbn10 = isbn10; }
        
        public String getIsbn13() { return isbn13; }
        public void setIsbn13(String isbn13) { this.isbn13 = isbn13; }
        
        public Integer getPageCount() { return pageCount; }
        public void setPageCount(Integer pageCount) { this.pageCount = pageCount; }
        
        public String getCategories() { return categories; }
        public void setCategories(String categories) { this.categories = categories; }
        
        public String getLanguage() { return language; }
        public void setLanguage(String language) { this.language = language; }
        
        public String getSmallThumbnail() { return smallThumbnail; }
        public void setSmallThumbnail(String smallThumbnail) { this.smallThumbnail = smallThumbnail; }
        
        public String getThumbnail() { return thumbnail; }
        public void setThumbnail(String thumbnail) { this.thumbnail = thumbnail; }
        
        public String getSmallImage() { return smallImage; }
        public void setSmallImage(String smallImage) { this.smallImage = smallImage; }
        
        public String getMediumImage() { return mediumImage; }
        public void setMediumImage(String mediumImage) { this.mediumImage = mediumImage; }
        
        public String getLargeImage() { return largeImage; }
        public void setLargeImage(String largeImage) { this.largeImage = largeImage; }
        
        public String getPreviewLink() { return previewLink; }
        public void setPreviewLink(String previewLink) { this.previewLink = previewLink; }
        
        public String getInfoLink() { return infoLink; }
        public void setInfoLink(String infoLink) { this.infoLink = infoLink; }
    }
}