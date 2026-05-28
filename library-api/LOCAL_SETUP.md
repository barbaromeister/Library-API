# 🏠 Local Environment Setup Guide

This guide shows you how to run the Library API in a local environment using the `.env` file for configuration.

## 📋 Prerequisites

- **Java 21** or higher
- **Docker & Docker Compose** (for PostgreSQL database)
- **Maven** (or use included wrapper)

## 🚀 Quick Start

### 1. Setup Environment File

The `.env` file is already created with sensible defaults. You can modify it if needed:

```bash
# View current configuration
cat .env

# Or edit if you want to change defaults
nano .env
```

### 2. Start Database

```bash
# Start PostgreSQL database in Docker
docker-compose up postgres -d
```

### 3. Start Application

```bash
# Option A: Use the automated startup script (Recommended)
./start-local.sh

# Option B: Manual startup
source ./load-env-simple.sh
./mvnw spring-boot:run -Dspring-boot.run.profiles=local
```

### 4. Access Application

- **Application**: http://localhost:8080
- **Health Check**: http://localhost:8080/actuator/health
- **API Docs**: http://localhost:8080/api/books

## 📁 Environment Configuration

### Current .env Configuration

```bash
# Database Settings (using $ variable references in template)
DB_HOST=localhost
DB_PORT=5433  
DB_NAME=kutuphane
DB_USER=admin
DB_PASSWORD=123456

# Spring Boot uses these directly
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5433/kutuphane
SPRING_DATASOURCE_USERNAME=admin
SPRING_DATASOURCE_PASSWORD=123456

# Server Settings
SERVER_PORT=8080
SPRING_PROFILES_ACTIVE=local
```

### How $ Variables Work

The `.env` file supports variable references with `$` syntax. For example:

```bash
# Base variables
DB_HOST=localhost
DB_PORT=5433

# Reference variables (requires expansion)
SPRING_DATASOURCE_URL=jdbc:postgresql://$DB_HOST:$DB_PORT/kutuphane
```

**Note**: The current setup uses expanded values for reliability, but the template shows how to use `$` references.

## 🛠️ Available Scripts

### Start Scripts

```bash
# Unix/macOS - Full featured startup with checks
./start-local.sh

# Windows - Batch script version
start-local.bat
```

### Environment Management

```bash
# Load environment variables manually
source ./load-env-simple.sh

# Test environment loading
source ./load-env-simple.sh && env | grep SPRING_

# View environment template
cat .env.template
```

### Development Tools

```bash
# Test complete setup
./test-setup.sh

# View application logs (when running)
tail -f logs/application.log
```

## 🐘 Database Management

### Database Connection Details

```bash
Host: localhost
Port: 5433
Database: kutuphane
Username: admin
Password: 123456
```

### Database Commands

```bash
# Start database only
docker-compose up postgres -d

# Connect to database
docker exec -it library-postgres psql -U admin -d kutuphane

# View database logs
docker logs library-postgres -f

# Stop database
docker-compose down
```

## 🔧 Configuration Options

### Environment Variables Reference

| Variable | Description | Default |
|----------|-------------|---------|
| `DB_HOST` | Database host | localhost |
| `DB_PORT` | Database port | 5433 |
| `DB_NAME` | Database name | kutuphane |
| `DB_USER` | Database user | admin |
| `DB_PASSWORD` | Database password | 123456 |
| `SERVER_PORT` | Application port | 8080 |
| `SPRING_PROFILES_ACTIVE` | Spring profile | local |

### Customizing Configuration

1. **Edit .env file**:
   ```bash
   nano .env
   ```

2. **Override specific variables**:
   ```bash
   export SERVER_PORT=9090
   ./start-local.sh
   ```

3. **Use different database**:
   ```bash
   # Edit .env to point to your database
   DB_HOST=your-db-host
   DB_PORT=5432
   DB_NAME=your-database
   ```

## 🐛 Troubleshooting

### Common Issues

#### Database Connection Failed
```bash
# Check if database is running
docker ps | grep postgres

# Start database if not running
docker-compose up postgres -d

# Check database logs
docker logs library-postgres
```

#### Port Already in Use
```bash
# Check what's using port 8080
lsof -i :8080

# Change port in .env file
echo "SERVER_PORT=9090" >> .env
```

#### Maven Issues
```bash
# Make wrapper executable
chmod +x mvnw

# Clean and rebuild
./mvnw clean package

# Use system Maven if wrapper fails
mvn spring-boot:run -Dspring-boot.run.profiles=local
```

#### Environment Variables Not Loading
```bash
# Test environment loading
source ./load-env-simple.sh
echo $SPRING_DATASOURCE_URL

# Manual export if needed
export $(cat .env | grep -v '^#' | xargs)
```

### Debug Mode

Run with debug logging:
```bash
# Enable debug in .env
LOGGING_LEVEL_COM_KUTUPHANE_LIBRARYAPI=DEBUG
LOGGING_LEVEL_ORG_SPRINGFRAMEWORK_SECURITY=DEBUG

# Or set temporarily
export LOGGING_LEVEL_COM_KUTUPHANE_LIBRARYAPI=DEBUG
./start-local.sh
```

## 📊 Health Checks

### Application Health
```bash
# Check application health
curl http://localhost:8080/actuator/health

# Check database connectivity
curl http://localhost:8080/actuator/health/db
```

### Environment Info
```bash
# View loaded environment variables
curl http://localhost:8080/actuator/env | jq '.propertySources'
```

## 🔄 Different Environments

### Switch to Development Profile
```bash
# Edit .env
SPRING_PROFILES_ACTIVE=dev

# Or override temporarily
export SPRING_PROFILES_ACTIVE=dev
./start-local.sh
```

### Use Docker Database
```bash
# For development with docker-compose.dev.yml
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/kutuphane_dev
SPRING_DATASOURCE_USERNAME=dev
SPRING_DATASOURCE_PASSWORD=devpass
```

## 🎯 Next Steps

Once your local environment is running:

1. **Access the application**: http://localhost:8080
2. **Create admin user**: http://localhost:8080/setup
3. **Test API endpoints**: http://localhost:8080/api/books
4. **View documentation**: Check the main README.md

Happy coding! 🎉