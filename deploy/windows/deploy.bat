@echo off
REM Library Management System - Windows Deployment Script
REM This script will set up and deploy the Library Management System on Windows

echo ============================================
echo   Library Management System Deployment
echo ============================================
echo.

REM Set color to green for success messages
color 0A

REM Check if Docker is installed and running
echo [1/8] Checking Docker installation...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not installed or not in PATH
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not running
    echo Please start Docker Desktop and try again
    pause
    exit /b 1
)
echo ✓ Docker is installed and running

REM Check if Git is installed
echo [2/8] Checking Git installation...
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Git is not installed or not in PATH
    echo Please install Git from: https://git-scm.com/downloads
    pause
    exit /b 1
)
echo ✓ Git is installed

REM Navigate to project directory
echo [3/8] Setting up project directory...
cd /d "%~dp0"
cd ..\..
set PROJECT_ROOT=%cd%
echo ✓ Project root: %PROJECT_ROOT%

REM Copy environment configuration
echo [4/8] Setting up environment configuration...
if not exist "library-api\.env" (
    copy "deploy\env\.env.development" "library-api\.env"
    echo ✓ Environment configuration copied
) else (
    echo ✓ Environment configuration already exists
)

REM Check for port conflicts
echo [5/8] Checking for port conflicts...
netstat -an | findstr ":3000" >nul 2>&1
if %errorlevel% equ 0 (
    echo WARNING: Port 3000 is already in use
    echo The application will try to start anyway, but may fail
    echo You can change the port in docker-compose.yml if needed
)

netstat -an | findstr ":5433" >nul 2>&1
if %errorlevel% equ 0 (
    echo WARNING: Port 5433 is already in use
    echo The database may fail to start
    echo You can change the port in docker-compose.yml if needed
)
echo ✓ Port check completed

REM Stop any existing containers
echo [6/8] Stopping any existing containers...
cd library-api
docker-compose down >nul 2>&1
echo ✓ Existing containers stopped

REM Build and start the application
echo [7/8] Building and starting the application...
echo This may take a few minutes for the first run...
docker-compose up --build -d
if %errorlevel% neq 0 (
    echo ERROR: Failed to start the application
    echo Please check the logs with: docker-compose logs
    pause
    exit /b 1
)
echo ✓ Application built and started successfully

REM Wait for application to be ready
echo [8/8] Waiting for application to be ready...
timeout /t 30 /nobreak >nul
echo ✓ Application should be ready now

REM Display success message and URLs
echo.
echo ============================================
echo   🎉 DEPLOYMENT SUCCESSFUL! 🎉
echo ============================================
echo.
echo Your Library Management System is now running!
echo.
echo 📱 Frontend Application:  http://localhost:3000
echo 🔧 API Endpoints:         http://localhost:3000/api/books
echo 🗄️  Database:              localhost:5433 (PostgreSQL)
echo.
echo ============================================
echo   Useful Commands
echo ============================================
echo.
echo View logs:           docker-compose logs
echo Stop application:    docker-compose down
echo Restart:            docker-compose restart
echo View status:        docker-compose ps
echo.
echo ============================================
echo   Troubleshooting
echo ============================================
echo.
echo If you see any errors:
echo 1. Check logs: docker-compose logs
echo 2. Restart: docker-compose down && docker-compose up -d
echo 3. Check ports: netstat -an | findstr ":3000"
echo.
echo For more help, see the README.md file
echo.
pause