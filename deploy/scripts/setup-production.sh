#!/bin/bash

# Library Management System - Production Setup Script
# This script helps configure the application for production deployment

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Function to generate random password
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
}

# Function to prompt for input with default
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local result
    
    read -p "$prompt [$default]: " result
    echo "${result:-$default}"
}

# Function to prompt for password
prompt_password() {
    local prompt="$1"
    local password
    
    echo -n "$prompt: "
    read -s password
    echo
    echo "$password"
}

# Main setup function
setup_production() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}   Production Environment Setup${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo

    # Navigate to project root
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    cd "$PROJECT_ROOT"

    print_info "Setting up production environment configuration..."
    echo

    # Check if production env already exists
    if [ -f "library-api/.env.production" ]; then
        print_warning "Production environment file already exists"
        read -p "Do you want to overwrite it? (y/N): " overwrite
        if [[ ! $overwrite =~ ^[Yy]$ ]]; then
            echo "Keeping existing configuration"
            exit 0
        fi
    fi

    # Collect configuration parameters
    echo "Please provide the following configuration parameters:"
    echo "(Press Enter to use default values)"
    echo

    # Application settings
    APP_PORT=$(prompt_with_default "Application port" "3000")
    APP_NAME=$(prompt_with_default "Application name" "Library Management System")

    # Database settings
    echo
    print_info "Database Configuration"
    DB_NAME=$(prompt_with_default "Database name" "kutuphane")
    DB_USERNAME=$(prompt_with_default "Database username" "library_admin")
    
    # Generate or prompt for database password
    echo
    print_info "Database password options:"
    echo "1. Generate a secure random password (recommended)"
    echo "2. Enter a custom password"
    read -p "Choose option (1/2): " pwd_option
    
    if [ "$pwd_option" = "2" ]; then
        DB_PASSWORD=$(prompt_password "Enter database password")
        if [ -z "$DB_PASSWORD" ]; then
            print_error "Password cannot be empty"
            exit 1
        fi
    else
        DB_PASSWORD=$(generate_password)
        print_success "Generated secure password"
    fi

    DB_EXTERNAL_PORT=$(prompt_with_default "Database external port" "5433")

    # CORS settings
    echo
    print_info "CORS Configuration"
    echo "Enter allowed origins (comma-separated, e.g., https://yourdomain.com,https://www.yourdomain.com)"
    CORS_ORIGINS=$(prompt_with_default "Allowed origins" "https://localhost:3000")

    # SSL settings
    echo
    read -p "Will you be using SSL/HTTPS? (y/N): " use_ssl
    if [[ $use_ssl =~ ^[Yy]$ ]]; then
        SSL_ENABLED="true"
    else
        SSL_ENABLED="false"
    fi

    # Performance settings
    echo
    print_info "Performance Configuration"
    JAVA_MEMORY=$(prompt_with_default "Java heap size (e.g., 1g, 512m)" "1g")
    DB_POOL_SIZE=$(prompt_with_default "Database connection pool size" "50")

    # Create production environment file
    print_info "Creating production environment file..."

    cat > "library-api/.env.production" << EOF
# Production Environment Configuration
# Generated on $(date)
# IMPORTANT: Keep this file secure and do not commit to version control!

# Application settings
APP_PORT=$APP_PORT
SPRING_PROFILES_ACTIVE=production
APP_NAME=$APP_NAME

# Database settings
DB_HOST=postgres
DB_PORT=5432
DB_NAME=$DB_NAME
DB_USERNAME=$DB_USERNAME
DB_PASSWORD=$DB_PASSWORD
DB_EXTERNAL_PORT=$DB_EXTERNAL_PORT

# URLs
SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/$DB_NAME
SPRING_DATASOURCE_USERNAME=$DB_USERNAME
SPRING_DATASOURCE_PASSWORD=$DB_PASSWORD

# Postgres settings
POSTGRES_DB=$DB_NAME
POSTGRES_USER=$DB_USERNAME
POSTGRES_PASSWORD=$DB_PASSWORD

# JPA settings for production
SPRING_JPA_HIBERNATE_DDL_AUTO=validate
SPRING_JPA_SHOW_SQL=false

# Logging (minimal for production)
LOGGING_LEVEL_ROOT=WARN
LOGGING_LEVEL_COM_KUTUPHANE=INFO

# Docker settings
COMPOSE_PROJECT_NAME=library-prod
NETWORK_NAME=library-prod-network
POSTGRES_VOLUME=postgres_prod_data

# Backup settings
BACKUP_DIR=./backups
BACKUP_RETENTION_DAYS=90

# Monitoring (restricted for production)
MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=health,info
MANAGEMENT_SERVER_PORT=8081

# CORS (restrictive for production)
CORS_ALLOWED_ORIGINS=$CORS_ORIGINS

# Performance settings
JAVA_OPTS=-Xmx$JAVA_MEMORY -Xms$(echo $JAVA_MEMORY | sed 's/g/512m/g' | sed 's/m/m/g') -XX:+UseG1GC -XX:MaxGCPauseMillis=200
SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE=$DB_POOL_SIZE
SPRING_DATASOURCE_HIKARI_MINIMUM_IDLE=10

# Security settings
SPRING_SECURITY_REQUIRE_SSL=$SSL_ENABLED
SERVER_SSL_ENABLED=$SSL_ENABLED

# Production optimizations
SPRING_JPA_PROPERTIES_HIBERNATE_JDBC_BATCH_SIZE=25
SPRING_JPA_PROPERTIES_HIBERNATE_ORDER_INSERTS=true
SPRING_JPA_PROPERTIES_HIBERNATE_ORDER_UPDATES=true
SPRING_JPA_PROPERTIES_HIBERNATE_JDBC_BATCH_VERSIONED_DATA=true

# Logging configuration
LOGGING_FILE_NAME=./logs/library-management.log
LOGGING_PATTERN_FILE=%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n
LOGGING_PATTERN_CONSOLE=%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n
EOF

    print_success "Production environment file created"

    # Create production docker-compose override
    print_info "Creating production Docker Compose override..."

    cat > "library-api/docker-compose.prod.yml" << EOF
# Production Docker Compose Configuration
# Use this file for production deployments
# Command: docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

version: '3.8'

services:
  postgres:
    restart: always
    environment:
      - POSTGRES_DB=$DB_NAME
      - POSTGRES_USER=$DB_USERNAME
      - POSTGRES_PASSWORD=$DB_PASSWORD
    volumes:
      - postgres_prod_data:/var/lib/postgresql/data
      - ./backups:/backups
    ports:
      - "$DB_EXTERNAL_PORT:5432"
    networks:
      - library-prod-network

  library-api:
    restart: always
    environment:
      - SPRING_PROFILES_ACTIVE=production
      - SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/$DB_NAME
      - SPRING_DATASOURCE_USERNAME=$DB_USERNAME
      - SPRING_DATASOURCE_PASSWORD=$DB_PASSWORD
      - JAVA_OPTS=-Xmx$JAVA_MEMORY -Xms$(echo $JAVA_MEMORY | sed 's/g/512m/g') -XX:+UseG1GC
    ports:
      - "$APP_PORT:8080"
    volumes:
      - ./logs:/app/logs
    networks:
      - library-prod-network
    depends_on:
      - postgres

volumes:
  postgres_prod_data:
    driver: local

networks:
  library-prod-network:
    driver: bridge
EOF

    print_success "Production Docker Compose override created"

    # Create logs directory
    mkdir -p "library-api/logs"
    print_success "Logs directory created"

    # Create backups directory
    mkdir -p "library-api/backups"
    print_success "Backups directory created"

    # Set proper permissions
    chmod 600 "library-api/.env.production"
    print_success "Set secure permissions on environment file"

    # Display summary
    echo
    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN}   Production Setup Complete!${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo
    echo "Configuration Summary:"
    echo "• Application Port: $APP_PORT"
    echo "• Database: $DB_NAME"
    echo "• Database User: $DB_USERNAME"
    echo "• Database Port: $DB_EXTERNAL_PORT"
    echo "• SSL Enabled: $SSL_ENABLED"
    echo "• Java Memory: $JAVA_MEMORY"
    echo
    print_warning "IMPORTANT SECURITY NOTES:"
    echo "• Database password has been generated/set"
    echo "• Keep the .env.production file secure"
    echo "• Do not commit .env.production to version control"
    echo "• Consider using Docker secrets for sensitive data"
    echo "• Enable firewall rules for production"
    echo
    echo "To deploy with production settings:"
    echo "1. Copy .env.production to .env in library-api directory"
    echo "2. Run: docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d"
    echo
    echo "Database Password: $DB_PASSWORD"
    print_warning "Save this password securely!"
    echo
}

# Check if script is being executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_production "$@"
fi