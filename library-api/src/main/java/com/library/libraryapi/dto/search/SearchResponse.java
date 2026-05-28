package com.library.libraryapi.dto.search;

import java.util.List;

public record SearchResponse(
        String query,
        int count,
        List<GoogleBookResult> results
) {
    public static SearchResponse of(String query, List<GoogleBookResult> results) {
        return new SearchResponse(query, results.size(), results);
    }
}
