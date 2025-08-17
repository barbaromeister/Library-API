#!/bin/bash

# Library Management System - Database Restore Script
# This script restores PostgreSQL database from backup files

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
    fi
}

# Function to list available backups
list_backups() {
    print_info "Available backups in $BACKUP_DIR:"
    echo
    
    if [ -d "$BACKUP_DIR" ] && [ "$(ls -A $BACKUP_DIR/*.sql.gz 2>/dev/null)" ]; then
        local counter=1
        printf "%-5s %-40s %-15s %-20s\n" "No." "Backup File" "Size" "Date Created"
        printf "%-5s %-40s %-15s %-20s\n" "-----" "----------------------------------------" "---------------" "--------------------"
        
        for backup in "$BACKUP_DIR"/*.sql.gz; do
            if [ -f "$backup" ]; then
                local filename=$(basename "$backup")
                local size=$(du -h "$backup" | cut -f1)
                local date=$(stat -c %y "$backup" 2>/dev/null || stat -f %Sm "$backup" 2>/dev/null | head -1)
                printf "%-5s %-40s %-15s %-20s\n" "$counter" "$filename" "$size" "${date:0:19}"
                counter=$((counter + 1))
            fi
        done
    else
        print_warning "No backups found in $BACKUP_DIR"
        return 1
    fi
    echo
    return 0
}

# Function to select backup interactively
select_backup() {
    if ! list_backups; then
        return 1
    fi
    
    local backup_files=("$BACKUP_DIR"/*.sql.gz)
    local backup_count=${#backup_files[@]}
    
    if [ $backup_count -eq 0 ]; then
        return 1
    fi
    
    echo "Please select a backup to restore:"
    read -p "Enter backup number (1-$backup_count): " selection
    
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le $backup_count ]; then
        local selected_backup="${backup_files[$((selection-1))]}"
        echo "$selected_backup"
        return 0
    else
        print_error "Invalid selection"
        return 1
    fi
}

# Function to create pre-restore backup
create_pre_restore_backup() {
    local container_name="$1"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="${BACKUP_DIR}/pre_restore_backup_${timestamp}.sql"
    
    print_info "Creating pre-restore backup for safety..."
    
    docker exec "$container_name" pg_dump \
        -U "$DB_USERNAME" \
        -d "$DB_NAME" \
        --clean \
        --if-exists \
        --create \
        > "$backup_file" 2>/dev/null
    
    if [ $? -eq 0 ] && [ -s "$backup_file" ]; then
        gzip "$backup_file"
        print_success "Pre-restore backup created: ${backup_file}.gz"
        return 0
    else
        print_warning "Failed to create pre-restore backup (continuing anyway)"
        rm -f "$backup_file"
        return 1
    fi
}

# Function to restore database
restore_database() {
    local backup_file="$1"
    local container_name="$2"
    local skip_backup="$3"
    
    # Verify backup file exists
    if [ ! -f "$backup_file" ]; then
        print_error "Backup file not found: $backup_file"
        return 1
    fi
    
    # Create pre-restore backup unless skipped
    if [ "$skip_backup" != "true" ]; then
        create_pre_restore_backup "$container_name"
    fi
    
    print_info "Preparing to restore database..."
    print_info "Source file: $backup_file"
    print_info "Target database: $DB_NAME"
    print_info "Container: $container_name"
    
    # Stop the application to prevent connections during restore
    print_info "Stopping application temporarily..."
    docker-compose stop library-api >/dev/null 2>&1
    
    # Determine if file is compressed
    local restore_command=""
    if [[ "$backup_file" == *.gz ]]; then
        print_info "Decompressing and restoring from compressed backup..."
        restore_command="gunzip -c \"$backup_file\" | docker exec -i \"$container_name\" psql -U \"$DB_USERNAME\" -d \"$DB_NAME\""
    else
        print_info "Restoring from uncompressed backup..."
        restore_command="docker exec -i \"$container_name\" psql -U \"$DB_USERNAME\" -d \"$DB_NAME\" < \"$backup_file\""
    fi
    
    # Perform the restore
    print_info "Restoring database (this may take a while)..."
    
    if [[ "$backup_file" == *.gz ]]; then
        gunzip -c "$backup_file" | docker exec -i "$container_name" psql -U "$DB_USERNAME" -d "$DB_NAME" >/dev/null 2>&1
    else
        docker exec -i "$container_name" psql -U "$DB_USERNAME" -d "$DB_NAME" < "$backup_file" >/dev/null 2>&1
    fi
    
    local restore_exit_code=$?
    
    # Restart the application
    print_info "Restarting application..."
    docker-compose start library-api >/dev/null 2>&1
    
    if [ $restore_exit_code -eq 0 ]; then
        print_success "Database restored successfully!"
        
        # Verify the restore
        print_info "Verifying restore..."
        local book_count=$(docker exec "$container_name" psql -U "$DB_USERNAME" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM books;" 2>/dev/null | tr -d ' \n')
        
        if [[ "$book_count" =~ ^[0-9]+$ ]]; then
            print_success "Verification successful: Found $book_count books in database"
        else
            print_warning "Could not verify restore (this may be normal)"
        fi
        
        return 0
    else
        print_error "Database restore failed!"
        return 1
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS] [BACKUP_FILE]"
    echo
    echo "Options:"
    echo "  -c, --container NAME    Container name (default: library-postgres)"
    echo "  -e, --env FILE          Environment file (default: .env)"
    echo "  -i, --interactive       Select backup file interactively"
    echo "  -l, --list              List available backups only"
    echo "  -s, --skip-backup       Skip creating pre-restore backup"
    echo "  -f, --force             Force restore without confirmation"
    echo "  -h, --help              Show this help message"
    echo
    echo "Arguments:"
    echo "  BACKUP_FILE             Path to backup file to restore"
    echo
    echo "Examples:"
    echo "  $0 backups/library_backup_20231201_120000.sql.gz"
    echo "  $0 -i                   Interactive backup selection"
    echo "  $0 -l                   List available backups"
    echo "  $0 -f backup.sql        Force restore without confirmation"
    echo
    echo "Note: If no backup file is specified, interactive mode is used."
    echo
}

# Function to confirm restore operation
confirm_restore() {
    local backup_file="$1"
    local force="$2"
    
    if [ "$force" = "true" ]; then
        return 0
    fi
    
    echo
    print_warning "WARNING: This operation will replace the current database!"
    echo "Backup file: $(basename "$backup_file")"
    echo "Database: $DB_NAME"
    echo "A pre-restore backup will be created automatically."
    echo
    read -p "Are you sure you want to continue? (yes/no): " confirmation
    
    case "$confirmation" in
        yes|YES|y|Y)
            return 0
            ;;
        *)
            echo "Restore cancelled."
            return 1
            ;;
    esac
}

# Main function
main() {
    local backup_file=""
    local container_name="library-postgres"
    local env_file=".env"
    local interactive=false
    local list_only=false
    local skip_backup=false
    local force=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--container)
                container_name="$2"
                shift 2
                ;;
            -e|--env)
                env_file="$2"
                shift 2
                ;;
            -i|--interactive)
                interactive=true
                shift
                ;;
            -l|--list)
                list_only=true
                shift
                ;;
            -s|--skip-backup)
                skip_backup=true
                shift
                ;;
            -f|--force)
                force=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            -*)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                backup_file="$1"
                shift
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
    
    # Show header
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}   Database Restore Utility${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo
    
    # Check prerequisites
    check_docker
    check_container "$container_name"
    
    # Handle backup file selection
    if [ -z "$backup_file" ] || [ "$interactive" = true ]; then
        backup_file=$(select_backup)
        if [ $? -ne 0 ] || [ -z "$backup_file" ]; then
            print_error "No backup file selected"
            exit 1
        fi
    fi
    
    # Make backup file path absolute if it's relative
    if [[ "$backup_file" != /* ]]; then
        backup_file="$(pwd)/$backup_file"
    fi
    
    # Confirm the restore operation
    if ! confirm_restore "$backup_file" "$force"; then
        exit 0
    fi
    
    # Perform the restore
    if restore_database "$backup_file" "$container_name" "$skip_backup"; then
        echo
        print_success "Database restore completed successfully!"
        echo
        print_info "Your application should now be running with the restored data."
        print_info "You can access it at: http://localhost:3000"
    else
        echo
        print_error "Database restore failed!"
        echo
        print_info "You may need to restore manually or from a pre-restore backup."
        exit 1
    fi
}

# Check if script is being executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi