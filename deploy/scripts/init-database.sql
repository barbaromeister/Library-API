-- Library Management System Database Initialization Script
-- This script sets up the initial database structure and sample data

-- Create database (if running manually, uncomment the next lines)
-- CREATE DATABASE kutuphane;
-- \c kutuphane;

-- Create user (if running manually)
-- CREATE USER admin WITH PASSWORD '123456';
-- GRANT ALL PRIVILEGES ON DATABASE kutuphane TO admin;

-- ============================================
-- Table Creation (handled by Hibernate/JPA automatically)
-- This is just for reference
-- ============================================

-- Books table structure (auto-created by JPA)
/*
CREATE TABLE IF NOT EXISTS books (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    isbn VARCHAR(13),
    publish_date DATE,
    page_count INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
*/

-- ============================================
-- Sample Data
-- ============================================

-- Insert sample books (only if table is empty)
INSERT INTO books (title, author, isbn, publish_date, page_count)
SELECT * FROM (VALUES
    ('The Great Gatsby', 'F. Scott Fitzgerald', '9780743273565', '1925-04-10', 180),
    ('To Kill a Mockingbird', 'Harper Lee', '9780061120084', '1960-07-11', 281),
    ('1984', 'George Orwell', '9780451524935', '1949-06-08', 328),
    ('Pride and Prejudice', 'Jane Austen', '9780141439518', '1813-01-28', 432),
    ('The Catcher in the Rye', 'J.D. Salinger', '9780316769174', '1951-07-16', 234),
    ('Lord of the Flies', 'William Golding', '9780571033720', '1954-09-17', 248),
    ('Jane Eyre', 'Charlotte Brontë', '9780141441146', '1847-10-16', 507),
    ('The Hobbit', 'J.R.R. Tolkien', '9780547928227', '1937-09-21', 310),
    ('Fahrenheit 451', 'Ray Bradbury', '9781451673319', '1953-10-19', 256),
    ('Brave New World', 'Aldous Huxley', '9780060850524', '1932-01-01', 288),
    ('The Lord of the Rings', 'J.R.R. Tolkien', '9780544003415', '1954-07-29', 1216),
    ('Of Mice and Men', 'John Steinbeck', '9780140177398', '1937-01-01', 112),
    ('Animal Farm', 'George Orwell', '9780451526342', '1945-08-17', 112),
    ('The Chronicles of Narnia', 'C.S. Lewis', '9780066238501', '1950-10-16', 767),
    ('Wuthering Heights', 'Emily Brontë', '9780141439556', '1847-12-01', 416),
    ('The Picture of Dorian Gray', 'Oscar Wilde', '9780141442464', '1890-06-20', 272),
    ('Moby Dick', 'Herman Melville', '9780142437247', '1851-10-18', 720),
    ('War and Peace', 'Leo Tolstoy', '9780143039990', '1869-01-01', 1392),
    ('Crime and Punishment', 'Fyodor Dostoevsky', '9780486454115', '1866-01-01', 608),
    ('The Odyssey', 'Homer', '9780140268867', '-700-01-01', 432)
) AS sample_data(title, author, isbn, publish_date, page_count)
WHERE NOT EXISTS (SELECT 1 FROM books LIMIT 1);

-- ============================================
-- Indexes for Performance
-- ============================================

-- Create indexes on commonly searched fields
CREATE INDEX IF NOT EXISTS idx_books_title ON books(title);
CREATE INDEX IF NOT EXISTS idx_books_author ON books(author);
CREATE INDEX IF NOT EXISTS idx_books_isbn ON books(isbn);
CREATE INDEX IF NOT EXISTS idx_books_publish_date ON books(publish_date);

-- ============================================
-- Functions and Triggers
-- ============================================

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to automatically update updated_at when a record is modified
-- (This will only work if you add updated_at columns to your entity)
/*
DROP TRIGGER IF EXISTS update_books_updated_at ON books;
CREATE TRIGGER update_books_updated_at
    BEFORE UPDATE ON books
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
*/

-- ============================================
-- Statistics and Views
-- ============================================

-- View for book statistics
CREATE OR REPLACE VIEW book_statistics AS
SELECT 
    COUNT(*) AS total_books,
    COUNT(DISTINCT author) AS total_authors,
    MAX(publish_date) AS latest_publication,
    MIN(publish_date) AS earliest_publication,
    AVG(page_count) AS average_pages,
    SUM(page_count) AS total_pages
FROM books;

-- View for books by decade
CREATE OR REPLACE VIEW books_by_decade AS
SELECT 
    FLOOR(EXTRACT(YEAR FROM publish_date) / 10) * 10 AS decade,
    COUNT(*) AS book_count
FROM books
WHERE publish_date IS NOT NULL
GROUP BY decade
ORDER BY decade DESC;

-- View for prolific authors
CREATE OR REPLACE VIEW prolific_authors AS
SELECT 
    author,
    COUNT(*) AS book_count,
    AVG(page_count) AS avg_pages,
    MIN(publish_date) AS first_publication,
    MAX(publish_date) AS latest_publication
FROM books
GROUP BY author
HAVING COUNT(*) > 1
ORDER BY book_count DESC, author;

-- ============================================
-- Grant Permissions
-- ============================================

-- Grant permissions to the admin user
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO admin;

-- Grant usage on schema
GRANT USAGE ON SCHEMA public TO admin;

-- ============================================
-- Database Configuration
-- ============================================

-- Set timezone
SET timezone = 'UTC';

-- Show completion message
DO $$
BEGIN
    RAISE NOTICE 'Database initialization completed successfully!';
    RAISE NOTICE 'Sample data has been inserted if the books table was empty.';
    RAISE NOTICE 'Indexes and views have been created for better performance.';
END $$;