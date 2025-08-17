#!/bin/bash

# Library Management System - Database Backup Script
# This script creates backups of the PostgreSQL database

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

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running"
        echo "Please start Docker and try again"
        exit 1
    fi
}

# Function to check if container is running
check_container() {
    local container_name="$1"
    if ! docker ps --format "table {{.Names}}" | grep -q "^${container_name}$"; then
        print_error "Container '${container_name}' is not running"
        echo "Please start the application first with: docker-compose up -d"
        exit 1
    fi
}

# Function to load environment variables
load_env() {
    local env_file="$1"
    if [ -f "$env_file" ]; then
        # Load environment variables, excluding comments and empty lines
        export $(grep -v '^#' "$env_file" | grep -v '^$' | xargs)
        print_success "Loaded environment from $env_file"
    else
        print_warning "Environment file $env_file not found, using defaults"
        # Set defaults
        export DB_NAME="kutuphane"
        export DB_USERNAME="admin"
        export DB_PASSWORD="123456"
        export BACKUP_RETENTION_DAYS="30"
    fi
}

# Function to create backup
create_backup() {
    local backup_type="$1"
    local backup_name="$2"
    local container_name="${3:-library-postgres}"
    
    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"
    
    # Generate timestamp if no custom name provided
    if [ -z "$backup_name" ]; then
        local timestamp=$(date +"%Y%m%d_%H%M%S")
        backup_name="library_backup_${timestamp}"
    fi
    
    local backup_file="${BACKUP_DIR}/${backup_name}.sql"
    
    print_info "Creating ${backup_type} backup..."
    print_info "Database: $DB_NAME"
    print_info "Output file: $backup_file"
    
    # Create the backup
    if [ "$backup_type" = "full" ]; then
        # Full database backup
        docker exec "$container_name" pg_dump \
            -U "$DB_USERNAME" \
            -d "$DB_NAME" \
            --clean \
            --if-exists \
            --create \
            --verbose \
            > "$backup_file" 2>/dev/null
    else
        # Data-only backup
        docker exec "$container_name" pg_dump \
            -U "$DB_USERNAME" \
            -d "$DB_NAME" \
            --data-only \
            --verbose \
            > "$backup_file" 2>/dev/null
    fi
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ] && [ -s "$backup_file" ]; then
        local file_size=$(du -h "$backup_file" | cut -f1)
        print_success "Backup created successfully: $backup_file ($file_size)"
        
        # Compress the backup
        print_info "Compressing backup..."
        gzip "$backup_file"
        local compressed_file="${backup_file}.gz"
        local compressed_size=$(du -h "$compressed_file" | cut -f1)
        print_success "Backup compressed: $compressed_file ($compressed_size)"
        
        return 0
    else
        print_error "Backup failed"
        if [ -f "$backup_file" ]; then
            rm -f "$backup_file"
        fi
        return 1
    fi
}

# Function to clean old backups
clean_old_backups() {
    local retention_days="${BACKUP_RETENTION_DAYS:-30}"
    
    print_info "Cleaning backups older than $retention_days days..."
    
    if [ -d "$BACKUP_DIR" ]; then
        local deleted_count=$(find "$BACKUP_DIR" -name "*.sql.gz" -type f -mtime +$retention_days -delete -print | wc -l)
        if [ "$deleted_count" -gt 0 ]; then
            print_success "Deleted $deleted_count old backup(s)"
        else
            print_info "No old backups to delete"
        fi
    fi
}

# Function to list existing backups
list_backups() {
    print_info "Existing backups in $BACKUP_DIR:"
    echo
    
    if [ -d "$BACKUP_DIR" ] && [ "$(ls -A $BACKUP_DIR/*.sql.gz 2>/dev/null)" ]; then
        printf "%-40s %-15s %-20s\n" "Backup File" "Size" "Date Created"
        printf "%-40s %-15s %-20s\n" "----------------------------------------" "---------------" "--------------------"
        
        for backup in "$BACKUP_DIR"/*.sql.gz; do
            if [ -f "$backup" ]; then
                local filename=$(basename "$backup")
                local size=$(du -h "$backup" | cut -f1)
                local date=$(stat -c %y "$backup" 2>/dev/null || stat -f %Sm "$backup" 2>/dev/null | head -1)
                printf "%-40s %-15s %-20s\n" "$filename" "$size" "${date:0:19}"
            fi
        done
    else
        print_warning "No backups found"
    fi
    echo
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -t, --type TYPE         Backup type: 'full' (default) or 'data'"
    echo "  -n, --name NAME         Custom backup name (optional)"
    echo "  -c, --container NAME    Container name (default: library-postgres)"
    echo "  -e, --env FILE          Environment file (default: .env)"
    echo "  -l, --list              List existing backups"
    echo "  -C, --clean             Clean old backups only"
    echo "  -h, --help              Show this help message"
    echo
    echo "Examples:"
    echo "  $0                      Create full backup with timestamp"
    echo "  $0 -t data              Create data-only backup"
    echo "  $0 -n my_backup        Create backup with custom name"
    echo "  $0 -l                   List all existing backups"
    echo "  $0 -C                   Clean old backups"
    echo
}

# Main function
main() {
    local backup_type="full"
    local backup_name=""
    local container_name="library-postgres"
    local env_file=".env"
    local list_only=false
    local clean_only=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--type)
                backup_type="$2"
                if [[ ! "$backup_type" =~ ^(full|data)$ ]]; then
                    print_error "Invalid backup type: $backup_type"
                    echo "Valid types: full, data"
                    exit 1
                fi
                shift 2
                ;;
            -n|--name)
                backup_name="$2"
                shift 2
                ;;
            -c|--container)
                container_name="$2"
                shift 2
                ;;
            -e|--env)
                env_file="$2"
                shift 2
                ;;
            -l|--list)
                list_only=true
                shift
                ;;
            -C|--clean)
                clean_only=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Navigate to project root
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    cd "$PROJECT_ROOT/library-api"
    
    # Set backup directory
    BACKUP_DIR="$(pwd)/backups"
    
    # Load environment variables
    load_env "$env_file"
    
    # Handle list-only request
    if [ "$list_only" = true ]; then
        list_backups
        exit 0
    fi
    
    # Handle clean-only request
    if [ "$clean_only" = true ]; then
        clean_old_backups
        exit 0
    fi
    
    # Check prerequisites
    check_docker
    check_container "$container_name"
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Show current status
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}   Database Backup Utility${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo
    
    # Create backup
    if create_backup "$backup_type" "$backup_name" "$container_name"; then
        # Clean old backups
        clean_old_backups
        
        echo
        print_success "Backup operation completed successfully!"
        
        # Show backup summary
        echo
        list_backups
    else
        print_error "Backup operation failed!"
        exit 1
    fi
}

# Check if script is being executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi