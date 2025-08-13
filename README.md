# LibraryOs

LibraryOs is a comprehensive library management backend built with **Java 21** and **Spring Boot 3** for managing books, authors, and categories in a library system.

## Features

- Complete CRUD operations for Books, Authors, and Categories
- Advanced search functionality with multiple filters
- RESTful API with JSON responses
- Database schema management with Flyway migrations
- Swagger/OpenAPI documentation
- Docker support for easy deployment
- PostgreSQL database integration
- Comprehensive error handling and validation

## Technologies Used

- Java 21
- Spring Boot 3.5.3
- Spring Data JPA
- Spring Validation
- PostgreSQL 16
- Flyway for database migrations
- Swagger/OpenAPI 3
- Docker & Docker Compose
- Maven

## Quick Start

### Prerequisites
- Docker & Docker Compose

### Running with Docker Compose
```bash
# Clone the repository
git clone https://github.com/barbaromeister/Library-API.git
cd Library-API

# Start the application
docker compose up --build

# The API will be available at:
# - Main API: http://localhost:8080
# - Swagger UI: http://localhost:8080/swagger-ui.html
# - API Docs: http://localhost:8080/v3/api-docs
```

### Local Development
```bash
# Prerequisites: Java 21, Maven 3+, PostgreSQL 16

# Configure database connection in application.yml or use environment variables:
# LIBRARYOS_DB_URL=jdbc:postgresql://localhost:5432/libraryos
# LIBRARYOS_DB_USER=admin
# LIBRARYOS_DB_PASSWORD=123456

# Build and run
cd library-api
mvn clean package -DskipTests
java -jar target/library-os-0.0.1-SNAPSHOT.jar
```

## API Examples

### Create Author
```bash
curl -X POST http://localhost:8080/api/v1/authors \
  -H "Content-Type: application/json" \
  -d '{"name":"J. K. Rowling","bio":"British author"}'
```

### Create Category
```bash
curl -X POST http://localhost:8080/api/v1/categories \
  -H "Content-Type: application/json" \
  -d '{"name":"Fantasy"}'
```

### Create Book
```bash
curl -X POST http://localhost:8080/api/v1/books \
  -H "Content-Type: application/json" \
  -d '{"title":"Harry Potter and the Philosopher'\''s Stone","isbn":"9780747532699","authorId":1,"categoryIds":[1]}'
```

### Search Books
```bash
# Search by title
curl "http://localhost:8080/api/v1/books?q=harry"

# Search by author and category
curl "http://localhost:8080/api/v1/books?authorId=1&categoryId=1"

# Combined search
curl "http://localhost:8080/api/v1/books?q=potter&authorId=1&categoryId=1"
```

## API Documentation

Visit http://localhost:8080/swagger-ui.html for interactive API documentation.

## Database Schema

The application uses PostgreSQL with the following main entities:
- **Authors**: Manage book authors with biographical information
- **Categories**: Organize books into categories
- **Books**: Main entity with relationships to authors and categories

All schema changes are managed through Flyway migrations.

## Package Structure

```
com.libraryos/
├── domain/          # JPA entities
├── repository/      # Data access layer
├── service/         # Business logic
├── controller/      # REST endpoints
├── dto/             # Data transfer objects
├── mapper/          # Entity-DTO mappers
└── exception/       # Error handling
```

## Migration Notes

- **Old package**: `com.kutuphane.libraryapi` → **New package**: `com.libraryos`
- **Old main class**: `LibraryApiApplication` → **New main class**: `LibraryOsApplication`
- Complete restructuring with proper domain modeling and relationships
