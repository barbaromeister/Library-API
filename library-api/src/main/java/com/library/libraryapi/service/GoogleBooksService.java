package com.library.libraryapi.service;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.library.libraryapi.dto.search.GoogleBookResult;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.util.UriComponentsBuilder;

import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class GoogleBooksService {

    private static final String GOOGLE_BOOKS_API_URL = "https://www.googleapis.com/books/v1/volumes";

    private final WebClient webClient;
    private final String apiKey;

    public GoogleBooksService(@Value("${google.books.api.key:}") String apiKey) {
        this.apiKey = apiKey;
        this.webClient = WebClient.builder()
                .codecs(c -> c.defaultCodecs().maxInMemorySize(2 * 1024 * 1024))
                .build();
    }

    public List<GoogleBookResult> searchBooks(String query, int maxResults) {
        if (query == null || query.trim().length() < 3) {
            return new ArrayList<>();
        }
        try {
            GoogleBooksResponse response = webClient.get()
                    .uri(buildSearchUrl(query.trim(), maxResults))
                    .retrieve()
                    .bodyToMono(GoogleBooksResponse.class)
                    .timeout(Duration.ofSeconds(10))
                    .block();
            return toResults(response);
        } catch (Exception e) {
            System.err.println("Error searching Google Books API: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    public Optional<GoogleBookResult> getByGoogleId(String googleId) {
        if (googleId == null || googleId.isBlank()) {
            return Optional.empty();
        }
        try {
            String url = GOOGLE_BOOKS_API_URL + "/" + googleId
                    + (apiKey != null && !apiKey.isEmpty() ? "?key=" + apiKey : "");

            GoogleBookItem item = webClient.get()
                    .uri(url)
                    .retrieve()
                    .bodyToMono(GoogleBookItem.class)
                    .timeout(Duration.ofSeconds(10))
                    .block();

            return Optional.ofNullable(item)
                    .filter(i -> i.volumeInfo != null)
                    .map(this::toResult);
        } catch (Exception e) {
            return Optional.empty();
        }
    }

    private String buildSearchUrl(String query, int maxResults) {
        UriComponentsBuilder b = UriComponentsBuilder.fromUriString(GOOGLE_BOOKS_API_URL)
                .queryParam("q", query)
                .queryParam("maxResults", Math.min(maxResults, 40))
                .queryParam("printType", "books")
                .queryParam("projection", "lite");
        if (apiKey != null && !apiKey.isEmpty()) {
            b.queryParam("key", apiKey);
        }
        return b.toUriString();
    }

    private List<GoogleBookResult> toResults(GoogleBooksResponse response) {
        List<GoogleBookResult> results = new ArrayList<>();
        if (response == null || response.items == null) {
            return results;
        }
        for (GoogleBookItem item : response.items) {
            if (item.volumeInfo != null) {
                results.add(toResult(item));
            }
        }
        return results;
    }

    private GoogleBookResult toResult(GoogleBookItem item) {
        VolumeInfo vi = item.volumeInfo;
        String authors = (vi.authors != null && !vi.authors.isEmpty()) ? String.join(", ", vi.authors) : null;
        String categories = (vi.categories != null && !vi.categories.isEmpty()) ? String.join(", ", vi.categories) : null;

        String isbn10 = null;
        String isbn13 = null;
        if (vi.industryIdentifiers != null) {
            for (IndustryIdentifier id : vi.industryIdentifiers) {
                if ("ISBN_13".equals(id.type)) {
                    isbn13 = id.identifier;
                } else if ("ISBN_10".equals(id.type)) {
                    isbn10 = id.identifier;
                }
            }
        }

        ImageLinks il = vi.imageLinks;
        return new GoogleBookResult(
                item.id, vi.title, vi.subtitle, authors,
                vi.publisher, vi.publishedDate, vi.description,
                isbn10, isbn13, vi.pageCount, categories, vi.language,
                il == null ? null : il.smallThumbnail,
                il == null ? null : il.thumbnail,
                il == null ? null : il.small,
                il == null ? null : il.medium,
                il == null ? null : il.large,
                vi.previewLink, vi.infoLink);
    }

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
}
