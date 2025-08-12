# Library API

Library API is a RESTful web service built with **Java 21** and **Spring Boot 3** for managing books, authors, and categories in a library system.

## Features
- Add, update, and delete books
- Manage authors and categories
- Search books by title, author, or category
- RESTful API with JSON responses

## Technologies Used
- Java 21
- Spring Boot 3
- Spring Data JPA
- PostgreSQL
- Maven

## Installation

### Prerequisites
- Java 21
- Maven 3+
- PostgreSQL (running locally or in Docker)

### Steps
```bash
# Clone the repository
git clone https://github.com/barbaromeister/Library-API.git
cd Library-API

# Configure database connection in application.properties
# Example:
# spring.datasource.url=jdbc:postgresql://localhost:5432/library
# spring.datasource.username=postgres
# spring.datasource.password=yourpassword

# Run the application
mvn spring-boot:run
