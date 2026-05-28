# 📚 Library API - Spring Boot Backend

A robust Spring Boot REST API for library management with authentication, admin dashboard, and comprehensive CRUD operations.

[![Java](https://img.shields.io/badge/Java-21-orange)](https://openjdk.org/projects/jdk/21/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5.3-brightgreen)](https://spring.io/projects/spring-boot)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue)](https://www.docker.com/)
[![Maven](https://img.shields.io/badge/Maven-3.9.9-red)](https://maven.apache.org/)

## 🏗️ Architecture

- **Framework**: Spring Boot 3.5.3
- **Java Version**: 21 (LTS)
- **Database**: PostgreSQL 15
- **Build Tool**: Maven with wrapper
- **Security**: Spring Security with session-based auth
- **ORM**: Hibernate/JPA
- **API**: RESTful endpoints with CORS support

## 🚀 Quick Start

### Prerequisites

- **Java 21** or higher
- **Docker & Docker Compose** (for database)
- **Maven 3.9+** (or use included wrapper)

### Option 1: Run with Docker (Recommended)

```bash
# Start PostgreSQL database
docker-compose up postgres -d

# Run the application
./mvnw spring-boot:run
```

The application will be available at `http://localhost:8080`

### Option 2: Full Docker Setup

```bash
# Build and run everything with Docker
docker-compose up --build -d
```

The application will be available at `http://localhost:8080`

### Option 3: Development Mode

```bash
# Start PostgreSQL
docker-compose up postgres -d

# Install dependencies
./mvnw dependency:resolve

# Run with development profile
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

## 📊 Database Configuration

The application connects to PostgreSQL with these default settings:

- **Host**: localhost:5433
- **Database**: kutuphane
- **Username**: admin  
- **Password**: 123456

### Environment Variables

You can override database configuration:

```bash
export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5433/kutuphane
export SPRING_DATASOURCE_USERNAME=admin
export SPRING_DATASOURCE_PASSWORD=123456
```

## 🔐 Authentication & Security

### Default Admin Account
When no admin exists, create one at: `http://localhost:8080/setup`

### API Authentication
- **Session-based authentication** for web interface
- **Protected endpoints** require authentication
- **CORS enabled** for frontend integration

### Security Features
- Password encryption with BCrypt
- Session management with timeout
- CSRF protection
- Secure headers

## 🛠️ API Endpoints

### Public Endpoints
```
GET  /api/books          # Get all books (paginated)
GET  /api/books/{id}     # Get book by ID
GET  /api/books/search   # Search books
GET  /actuator/health    # Health check
```

### Protected Endpoints (Authentication Required)
```
POST   /api/books        # Create new book
PUT    /api/books/{id}   # Update book
DELETE /api/books/{id}   # Delete book
GET    /admin/**         # Admin dashboard
```

### Sample API Calls

#### Get All Books
```bash
curl http://localhost:8080/api/books
```

#### Add New Book
```bash
curl -X POST http://localhost:8080/api/books \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Clean Code",
    "author": "Robert C. Martin",
    "isbn": "9780132350884",
    "publishedDate": "2008-08-01",
    "pageCount": 464,
    "description": "A Handbook of Agile Software Craftsmanship"
  }'
```

#### Search Books
```bash
# Search by title
curl "http://localhost:8080/api/books/search/title?title=Clean"

# Search by author  
curl "http://localhost:8080/api/books/search/author?author=Martin"
```

## 🏃‍♂️ Development

### Project Structure
```
src/
├── main/
│   ├── java/com/kutuphane/libraryapi/
│   │   ├── LibraryApiApplication.java    # Main application class
│   │   ├── config/                       # Configuration classes
│   │   ├── controller/                   # REST controllers
│   │   ├── service/                      # Business logic
│   │   ├── repository/                   # Data access layer
│   │   ├── model/                        # Entity classes
│   │   └── exception/                    # Exception handling
│   └── resources/
│       ├── application.properties        # Configuration
│       └── static/                       # Web assets
└── test/                                 # Test classes
```

### Running Tests
```bash
# Run all tests
./mvnw test

# Run with coverage
./mvnw test jacoco:report
```

### Building
```bash
# Build JAR file
./mvnw clean package

# Skip tests during build
./mvnw clean package -DskipTests

# Build Docker image
docker build -t library-api .
```

### Development Tools
```bash
# Format code
./mvnw spring-javaformat:apply

# Check code style
./mvnw spring-javaformat:validate

# Generate API docs
./mvnw spring-boot:run
# Visit http://localhost:8080/swagger-ui.html
```

## 🐛 Troubleshooting

### Common Issues

#### Maven Wrapper Permission Error
```bash
chmod +x mvnw
```

#### Database Connection Issues
```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# View database logs
docker logs library-postgres

# Reset database
docker-compose down -v
docker-compose up postgres -d
```

#### Port Already in Use
```bash
# Kill process on port 8080
lsof -ti:8080 | xargs kill -9

# Or change port
./mvnw spring-boot:run -Dserver.port=8081
```

#### Memory Issues
```bash
# Increase JVM heap size
export MAVEN_OPTS="-Xmx2g"
./mvnw spring-boot:run
```

### Logging

#### Enable Debug Logging
```bash
./mvnw spring-boot:run -Dlogging.level.com.kutuphane.libraryapi=DEBUG
```

#### View Application Logs
```bash
# In Docker
docker logs library-api -f

# Local development logs are in console
```

## 📈 Production Deployment

### Environment Configuration
Create `application-prod.properties`:
```properties
# Database
spring.datasource.url=${DB_URL}
spring.datasource.username=${DB_USER}
spring.datasource.password=${DB_PASSWORD}

# Security
server.servlet.session.cookie.secure=true
server.servlet.session.cookie.same-site=strict

# Logging
logging.level.root=WARN
logging.level.com.kutuphane.libraryapi=INFO
```

### Health Monitoring
- **Health check**: `GET /actuator/health`
- **Metrics**: `GET /actuator/metrics` (if enabled)
- **Custom health indicators** for database connectivity

### Performance Tuning
```bash
# Production JVM settings
java -XX:+UseContainerSupport \
     -XX:MaxRAMPercentage=75.0 \
     -XX:+UseG1GC \
     -jar app.jar
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/my-feature`
3. Run tests: `./mvnw test`
4. Commit changes: `git commit -m 'Add my feature'`
5. Push to branch: `git push origin feature/my-feature`
6. Submit Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/barbaromeister/Library-API/issues)
- **Discussions**: [GitHub Discussions](https://github.com/barbaromeister/Library-API/discussions)
- **Documentation**: See `/docs` folder for detailed documentation