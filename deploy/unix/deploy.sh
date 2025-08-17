#!/bin/bash

# Library Management System - Unix/Linux/macOS Deployment Script
# This script will set up and deploy the Library Management System

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

print_header() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}   Library Management System Deployment${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if port is in use
port_in_use() {
    if command_exists lsof; then
        lsof -i:$1 >/dev/null 2>&1
    elif command_exists netstat; then
        netstat -an | grep ":$1" >/dev/null 2>&1
    else
        return 1
    fi
}

# Main deployment function
deploy() {
    print_header

    # Step 1: Check Docker installation
    echo "[1/8] Checking Docker installation..."
    if ! command_exists docker; then
        print_error "Docker is not installed"
        echo "Please install Docker from: https://www.docker.com/products/docker-desktop"
        echo "For Ubuntu/Debian: sudo apt-get install docker.io docker-compose"
        echo "For macOS: Install Docker Desktop"
        echo "For other systems, see: https://docs.docker.com/get-docker/"
        exit 1
    fi

    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running"
        echo "Please start Docker and try again"
        echo "On Linux: sudo systemctl start docker"
        echo "On macOS: Start Docker Desktop application"
        exit 1
    fi
    print_success "Docker is installed and running"

    # Step 2: Check Docker Compose
    echo "[2/8] Checking Docker Compose..."
    if ! command_exists docker-compose && ! docker compose version >/dev/null 2>&1; then
        print_error "Docker Compose is not installed"
        echo "Please install Docker Compose"
        exit 1
    fi
    print_success "Docker Compose is available"

    # Step 3: Check Git installation
    echo "[3/8] Checking Git installation..."
    if ! command_exists git; then
        print_error "Git is not installed"
        echo "Please install Git from: https://git-scm.com/downloads"
        echo "On Ubuntu/Debian: sudo apt-get install git"
        echo "On macOS: Install from App Store or use Homebrew"
        exit 1
    fi
    print_success "Git is installed"

    # Step 4: Navigate to project directory
    echo "[4/8] Setting up project directory..."
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    cd "$PROJECT_ROOT"
    print_success "Project root: $PROJECT_ROOT"

    # Step 5: Set up environment configuration
    echo "[5/8] Setting up environment configuration..."
    if [ ! -f "library-api/.env" ]; then
        cp "deploy/env/.env.development" "library-api/.env"
        print_success "Environment configuration copied"
    else
        print_success "Environment configuration already exists"
    fi

    # Step 6: Check for port conflicts
    echo "[6/8] Checking for port conflicts..."
    if port_in_use 3000; then
        print_warning "Port 3000 is already in use"
        echo "The application will try to start anyway, but may fail"
        echo "You can change the port in docker-compose.yml if needed"
    fi

    if port_in_use 5433; then
        print_warning "Port 5433 is already in use"
        echo "The database may fail to start"
        echo "You can change the port in docker-compose.yml if needed"
    fi
    print_success "Port check completed"

    # Step 7: Stop any existing containers
    echo "[7/8] Stopping any existing containers..."
    cd library-api
    docker-compose down >/dev/null 2>&1 || true
    print_success "Existing containers stopped"

    # Step 8: Build and start the application
    echo "[8/8] Building and starting the application..."
    echo "This may take a few minutes for the first run..."
    
    # Use docker compose or docker-compose based on availability
    if docker compose version >/dev/null 2>&1; then
        COMPOSE_CMD="docker compose"
    else
        COMPOSE_CMD="docker-compose"
    fi

    if ! $COMPOSE_CMD up --build -d; then
        print_error "Failed to start the application"
        echo "Please check the logs with: $COMPOSE_CMD logs"
        exit 1
    fi
    print_success "Application built and started successfully"

    # Wait for application to be ready
    echo "Waiting for application to be ready..."
    sleep 30
    print_success "Application should be ready now"

    # Display success message
    echo
    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN}   🎉 DEPLOYMENT SUCCESSFUL! 🎉${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo
    echo "Your Library Management System is now running!"
    echo
    echo -e "${BLUE}📱 Frontend Application:${NC}  http://localhost:3000"
    echo -e "${BLUE}🔧 API Endpoints:${NC}         http://localhost:3000/api/books"
    echo -e "${BLUE}🗄️  Database:${NC}              localhost:5433 (PostgreSQL)"
    echo
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}   Useful Commands${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo
    echo "View logs:           $COMPOSE_CMD logs"
    echo "Stop application:    $COMPOSE_CMD down"
    echo "Restart:            $COMPOSE_CMD restart"
    echo "View status:        $COMPOSE_CMD ps"
    echo
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}   Troubleshooting${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo
    echo "If you see any errors:"
    echo "1. Check logs: $COMPOSE_CMD logs"
    echo "2. Restart: $COMPOSE_CMD down && $COMPOSE_CMD up -d"
    echo "3. Check ports: lsof -i :3000"
    echo
    echo "For more help, see the README.md file"
    echo
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    deploy "$@"
fi