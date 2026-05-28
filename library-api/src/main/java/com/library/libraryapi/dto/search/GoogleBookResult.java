package com.library.libraryapi.dto.search;

public record GoogleBookResult(
        String googleId,
        String title,
        String subtitle,
        String authors,
        String publisher,
        String publishedDate,
        String description,
        String isbn10,
        String isbn13,
        Integer pageCount,
        String categories,
        String language,
        String smallThumbnail,
        String thumbnail,
        String smallImage,
        String mediumImage,
        String largeImage,
        String previewLink,
        String infoLink
) {}
