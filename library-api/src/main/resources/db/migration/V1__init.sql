-- Authors table
CREATE TABLE authors (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    bio TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Categories table
CREATE TABLE categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);

-- Books table
CREATE TABLE books (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(255) UNIQUE,
    published_at DATE,
    author_id BIGINT NOT NULL,
    CONSTRAINT fk_books_author FOREIGN KEY (author_id) REFERENCES authors(id)
);

-- Many-to-many relationship table for books and categories
CREATE TABLE book_categories (
    book_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    PRIMARY KEY (book_id, category_id),
    CONSTRAINT fk_book_categories_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
    CONSTRAINT fk_book_categories_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

-- Indexes for better performance
CREATE INDEX idx_books_author_id ON books(author_id);
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_isbn ON books(isbn);
CREATE INDEX idx_authors_name ON authors(name);
CREATE INDEX idx_categories_name ON categories(name);