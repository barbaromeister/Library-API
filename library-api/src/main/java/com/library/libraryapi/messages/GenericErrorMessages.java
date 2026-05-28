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

    public static final String BOOK_NOT_FOUND_BY_ID_EXCEPTION_MESSAGE = "Book not found with id: %d";
    public static final String BOOK_NOT_FOUND_BY_ISBN_EXCEPTION_MESSAGE = "Book not found with ISBN: %s";
    public static final String USERNAME_ALREADY_EXISTS_EXCEPTION_MESSAGE = "Username already exists";
    public static final String EMAIL_ALREADY_EXISTS_EXCEPTION_MESSAGE = "Email already exists";
    public static final String INVALID_CREDENTIALS_EXCEPTION_MESSAGE = "Invalid username or password";
    public static final String USER_NOT_FOUND_EXCEPTION_MESSAGE = "User not found: %s";
    public static final String GOOGLE_BOOK_NOT_FOUND_EXCEPTION_MESSAGE = "Google Book not found with id: %s";
    public static final String ACCESS_DENIED_EXCEPTION_MESSAGE = "Access denied";
    public static final String VALIDATION_FAILED_EXCEPTION_MESSAGE = "Validation failed";
}
