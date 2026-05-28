package com.library.libraryapi.messages;

public final class GenericErrorMessages {

    private GenericErrorMessages() {
    }

    public static final String USERNAME_REQUIRED_VALIDATION_MESSAGE = "Username is required";
    public static final String USERNAME_SIZE_VALIDATION_MESSAGE = "Username must be between 3 and 30 characters";
    public static final String EMAIL_REQUIRED_VALIDATION_MESSAGE = "Email is required";
    public static final String EMAIL_INVALID_VALIDATION_MESSAGE = "Email must be valid";
    public static final String PASSWORD_REQUIRED_VALIDATION_MESSAGE = "Password is required";
    public static final String PASSWORD_SIZE_VALIDATION_MESSAGE = "Password must be between 8 and 72 characters";

    public static final String TITLE_REQUIRED_VALIDATION_MESSAGE = "Title is required";
    public static final String AUTHOR_REQUIRED_VALIDATION_MESSAGE = "Author is required";
    public static final String ISBN_PATTERN_VALIDATION_MESSAGE = "ISBN must be 10 or 13 digits";
    public static final String PAGE_COUNT_MIN_VALIDATION_MESSAGE = "Page count must be at least 1";

    public static final String GOOGLE_BOOKS_ID_REQUIRED_VALIDATION_MESSAGE = "googleBooksId is required";
}
