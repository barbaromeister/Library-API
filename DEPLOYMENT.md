# 🚀 Library Management System - Deployment Guide

This guide provides comprehensive instructions for deploying the Library Management System on different computers and environments.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Environment Configurations](#environment-configurations)
- [Production Deployment](#production-deployment)
- [Backup and Restore](#backup-and-restore)
- [Monitoring and Maintenance](#monitoring-and-maintenance)
- [Troubleshooting](#troubleshooting)

## 🔧 Prerequisites

### Required Software
- **Docker Desktop** (version 20.10 or higher)
- **Git** (for cloning the repository)
- **8GB RAM** minimum (16GB recommended for production)
- **10GB free disk space**

### Operating System Support
- ✅ Windows 10/11 (with WSL2)
- ✅ macOS 10.15 or higher
- ✅ Linux (Ubuntu 18.04+, CentOS 7+, RHEL 8+)

## 🚀 Quick Start

### Option 1: Automated Deployment

#### Windows
```batch
# Clone the repository
git clone https://github.com/barbaromeister/Library-API.git
cd Library-API

# Run automated deployment
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

```bash
# Clone and navigate
git clone https://github.com/barbaromeister/Library-API.git
cd Library-API/library-api

# Copy environment configuration
cp ../deploy/env/.env.development .env

# Start services
docker-compose up --build -d

# Access the application
open http://localhost:3000
```

## ⚙️ Environment Configurations

### Development Environment
```bash
# Use development configuration
cp deploy/env/.env.development library-api/.env
cd library-api
docker-compose up -d
```

**Features:**
- Verbose logging for debugging
- Hot reload enabled
- Sample data included
- Development-friendly settings

### Production Environment
```bash
# Run production setup script
./deploy/scripts/setup-production.sh

# Use production configuration
cp deploy/env/.env.production library-api/.env

# Deploy with production settings
cd library-api
docker-compose -f docker-compose.yml -f ../docker-compose.prod.yml up -d
```

**Features:**
- Optimized for performance
- Enhanced security settings
- Resource limits configured
- Health checks enabled

## 🏭 Production Deployment

### Step 1: Initial Setup
```bash
# Clone repository
git clone https://github.com/barbaromeister/Library-API.git
cd Library-API

# Run production setup wizard
./deploy/scripts/setup-production.sh
```

### Step 2: Security Configuration

#### Change Default Passwords
```bash
# The setup script will generate secure passwords
# Or manually edit the environment file:
nano library-api/.env.production
```

#### Configure SSL (Recommended)
```bash
# Place SSL certificates in deploy/ssl/
mkdir -p deploy/ssl
cp your-certificate.crt deploy/ssl/
cp your-private.key deploy/ssl/

# Update environment file
echo "SSL_ENABLED=true" >> library-api/.env.production
```

### Step 3: Deploy
```bash
cd library-api
docker-compose -f docker-compose.yml -f ../docker-compose.prod.yml up -d
```

### Step 4: Verify Deployment
```bash
# Check service status
docker-compose ps

# View logs
docker-compose logs

# Test health endpoints
curl http://localhost:3000/actuator/health
```

## 💾 Backup and Restore

### Automated Backups

#### Create Backup
```bash
# Full database backup
./deploy/scripts/backup-database.sh

# Data-only backup
./deploy/scripts/backup-database.sh -t data

# Custom named backup
./deploy/scripts/backup-database.sh -n "pre-migration-backup"
```

#### Schedule Automated Backups
```bash
# Add to crontab for daily backups at 2 AM
crontab -e

# Add this line:
0 2 * * * /path/to/Library-API/deploy/scripts/backup-database.sh
```

### Restore from Backup

#### Interactive Restore
```bash
# List and select backup interactively
./deploy/scripts/restore-database.sh -i
```

#### Direct Restore
```bash
# Restore specific backup file
./deploy/scripts/restore-database.sh backups/library_backup_20231201_120000.sql.gz
```

#### Force Restore (No Confirmation)
```bash
# Restore without prompts (useful for automation)
./deploy/scripts/restore-database.sh -f backup.sql.gz
```

## 📊 Monitoring and Maintenance

### Health Checks
```bash
# Application health
curl http://localhost:3000/actuator/health

# Database health
docker exec library-postgres pg_isready -U admin -d kutuphane

# Service status
docker-compose ps
```

### Log Management
```bash
# View application logs
docker-compose logs library-api

# Follow logs in real-time
docker-compose logs -f library-api

# Database logs
docker-compose logs postgres

# Export logs
docker-compose logs library-api > app-logs.txt
```

### Performance Monitoring
```bash
# View metrics endpoint
curl http://localhost:8081/actuator/metrics

# Check resource usage
docker stats

# Database statistics
docker exec library-postgres psql -U admin -d kutuphane -c "SELECT * FROM book_statistics;"
```

### Updates and Maintenance
```bash
# Update to latest version
git pull origin main

# Rebuild with updates
docker-compose down
docker-compose up --build -d

# Clean up unused Docker resources
docker system prune -a
```

## 🔧 Advanced Configuration

### Custom Port Configuration
```bash
# Edit docker-compose.yml
nano library-api/docker-compose.yml

# Change port mapping
ports:
  - "YOUR_PORT:8080"
```

### Database Configuration
```bash
# Edit environment file
nano library-api/.env

# Modify database settings
DB_NAME=your_database_name
DB_USERNAME=your_username
DB_PASSWORD=your_secure_password
DB_EXTERNAL_PORT=5433
```

### Resource Limits
```bash
# Edit production compose file
nano docker-compose.prod.yml

# Adjust resource limits
deploy:
  resources:
    limits:
      memory: 2G
      cpus: '2.0'
```

## 🛠️ Troubleshooting

### Common Issues

#### Port Already in Use
```bash
# Check what's using the port
lsof -i :3000                    # macOS/Linux
netstat -ano | findstr :3000     # Windows

# Kill the process or change port in docker-compose.yml
```

#### Database Connection Issues
```bash
# Check database container
docker-compose logs postgres

# Restart database
docker-compose restart postgres

# Reset database volume
docker-compose down -v
docker-compose up -d
```

#### Application Won't Start
```bash
# Check application logs
docker-compose logs library-api

# Verify environment variables
docker-compose config

# Check available resources
docker system df
```

#### Memory Issues
```bash
# Check memory usage
docker stats

# Increase memory limits in docker-compose.prod.yml
# Or increase Docker Desktop memory allocation
```

### Recovery Procedures

#### Complete Reset
```bash
# Stop all services
docker-compose down -v

# Remove all data (WARNING: This deletes everything!)
docker volume rm library-api_postgres_data

# Restart fresh
docker-compose up -d
```

#### Restore from Backup
```bash
# List available backups
./deploy/scripts/restore-database.sh -l

# Restore specific backup
./deploy/scripts/restore-database.sh -i
```

### Performance Tuning

#### Database Optimization
```bash
# Connect to database
docker exec -it library-postgres psql -U admin -d kutuphane

# Run VACUUM and ANALYZE
VACUUM ANALYZE;

# Check index usage
SELECT schemaname, tablename, attname, n_distinct, correlation 
FROM pg_stats 
WHERE tablename = 'books';
```

#### Application Optimization
```bash
# Increase JVM memory (edit docker-compose.yml)
environment:
  - JAVA_OPTS=-Xmx2g -Xms1g

# Enable connection pooling optimization
  - SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE=100
```

## 📞 Support

### Getting Help
1. Check this troubleshooting guide
2. Review application logs: `docker-compose logs`
3. Check system resources: `docker stats`
4. Verify environment configuration: `docker-compose config`

### Reporting Issues
When reporting issues, please include:
- Operating system and version
- Docker version: `docker --version`
- Error messages from logs
- Steps to reproduce the issue
- Environment configuration (without sensitive data)

### Useful Commands Reference
```bash
# Service management
docker-compose ps                 # List services
docker-compose logs               # View all logs
docker-compose restart           # Restart services
docker-compose down              # Stop services
docker-compose up -d             # Start services

# Data management
./deploy/scripts/backup-database.sh     # Create backup
./deploy/scripts/restore-database.sh    # Restore backup
docker volume ls                        # List volumes

# System maintenance
docker system prune -a           # Clean unused resources
docker stats                     # Monitor resource usage
docker exec -it container_name bash     # Access container shell
```

---

For more detailed information, see the main [README.md](README.md) file.