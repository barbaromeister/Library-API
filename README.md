# 📚 Library Management System

A modern, full-stack library management application built with Spring Boot and a responsive frontend. This application provides complete CRUD operations for managing books with a beautiful, user-friendly interface.

![Library Management System](https://img.shields.io/badge/Status-Production%20Ready-green)
![Java](https://img.shields.io/badge/Java-21-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5.3-brightgreen)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue)
![Docker](https://img.shields.io/badge/Docker-Enabled-blue)

## ✨ Features

### 🎨 Modern Frontend
- **Responsive Design**: Works perfectly on desktop, tablet, and mobile devices
- **Beautiful UI**: Modern gradient design with smooth animations
- **Grid/List Views**: Toggle between different view modes
- **Real-time Search**: Search by title, author, or ISBN with live filtering
- **Statistics Dashboard**: View total books, authors, and publication data

### 📚 Complete CRUD Operations
- **Create**: Add new books with detailed information
- **Read**: Browse and search through your book collection
- **Update**: Edit existing book details with inline forms
- **Delete**: Remove books with confirmation dialogs

### 🔧 Technical Features
- **RESTful API**: Well-structured API endpoints for all operations
- **Database Integration**: PostgreSQL database with JPA/Hibernate
- **Containerized**: Fully containerized with Docker and Docker Compose
- **CORS Enabled**: Frontend and backend properly configured
- **Error Handling**: Comprehensive error handling with user feedback

## 🚀 Quick Start

### Prerequisites
- **Docker Desktop** installed and running
- **Git** for cloning the repository
- **8GB RAM** minimum recommended

### Option 1: One-Click Deployment (Recommended)

#### Windows
```bash
# Clone the repository
git clone https://github.com/barbaromeister/Library-API.git
cd Library-API

# Run the deployment script
.\deploy\windows\deploy.bat
```

#### macOS/Linux
```bash
# Clone the repository
git clone https://github.com/barbaromeister/Library-API.git
cd Library-API

# Make script executable and run
chmod +x deploy/unix/deploy.sh
./deploy/unix/deploy.sh
```

### Option 2: Manual Deployment

1. **Clone the Repository**
   ```bash
   git clone https://github.com/barbaromeister/Library-API.git
   cd Library-API/library-api
   ```

2. **Start the Application**
   ```bash
   docker-compose up --build -d
   ```

3. **Access the Application**
   - **Frontend**: http://localhost:3000
   - **API**: http://localhost:3000/api/books
   - **Database**: localhost:5433 (PostgreSQL)

## 📱 Using the Application

### Accessing the Frontend
Open your web browser and navigate to:
```
http://localhost:3000
```

### API Endpoints
Base URL: `http://localhost:3000/api/books`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/books` | Get all books |
| GET | `/api/books/{id}` | Get book by ID |
| POST | `/api/books` | Create new book |
| PUT | `/api/books/{id}` | Update existing book |
| DELETE | `/api/books/{id}` | Delete book |
| GET | `/api/books/search/author?author={name}` | Search by author |
| GET | `/api/books/search/title?title={name}` | Search by title |
| GET | `/api/books/search/isbn?isbn={number}` | Search by ISBN |

### Sample API Usage

#### Add a New Book
```bash
curl -X POST http://localhost:3000/api/books \
  -H "Content-Type: application/json" \
  -d '{
    "title": "The Great Gatsby",
    "author": "F. Scott Fitzgerald",
    "isbn": "9780743273565",
    "publishDate": "1925-04-10",
    "pageCount": 180
  }'
```

#### Get All Books
```bash
curl http://localhost:3000/api/books
