package com.library.libraryapi.dto.book;

import com.library.libraryapi.model.Book;

public record CoverImages(
        String small,
        String thumbnail,
        String medium,
        String large
) {
    public static CoverImages from(Book book) {
        return new CoverImages(
                book.getSmallThumbnail(),
                book.getThumbnail(),
                book.getMediumImage(),
                book.getLargeImage()
        );
    }
}
