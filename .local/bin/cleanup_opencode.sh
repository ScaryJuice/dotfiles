#!/usr/bin/zsh

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Parse --dry-run flag
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
fi

# Function to print colored messages
print_info() {
    echo -e "${CYAN}$1${NC}"
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}$1${NC}"
}

print_error() {
    echo -e "${RED}$1${NC}"
}

# Target directories array
DIRECTORIES=(
    "$HOME/.config/opencode"
    "$HOME/.local/share/opencode"
    "$HOME/.local/state/opencode"
)

# Function to check and display existing directories
check_directories() {
    local existing_dirs=()
    for dir in "${DIRECTORIES[@]}"; do
        if [[ -d "$dir" ]]; then
            existing_dirs+=("$dir")
        fi
    done
    echo "${existing_dirs[@]}"
}

# Function to display what will be deleted
show_deletion_preview() {
    local existing_dirs=("$@")
    
    if [[ ${#existing_dirs[@]} -eq 0 ]]; then
        print_warning "No OpenCode directories found to remove."
        return 1
    fi
    
    print_info "The following OpenCode directories and files will be removed:"
    echo
    
    for dir in "${existing_dirs[@]}"; do
        print_info "Directory: $dir"
        if [[ -d "$dir" ]]; then
            while IFS= read -r file; do
                if [[ -n "$file" ]]; then
                    echo "    - $file"
                fi
            done < <(find "$dir" -type f 2>/dev/null | head -20)
            local file_count=$(find "$dir" -type f 2>/dev/null | wc -l)
            if [[ $file_count -gt 20 ]]; then
                echo "    ... and $((file_count - 20)) more files"
            fi
        fi
        echo
    done
    return 0
}

# Function to perform dry-run
dry_run() {
    local existing_dirs=("$@")
    
    print_info "DRY RUN: Previewing removal operations..."
    echo
    
    for dir in "${existing_dirs[@]}"; do
        print_info "Would remove directory: $dir"
        local file_count=$(find "$dir" -type f 2>/dev/null | wc -l)
        echo "    (contains $file_count files)"
    done
    
    echo
    print_success "Dry run completed. No files were actually removed."
}

# Function to remove directories
remove_directories() {
    local existing_dirs=("$@")
    local removed_count=0
    local failed_count=0
    
    print_info "Removing OpenCode directories..."
    echo
    
    for dir in "${existing_dirs[@]}"; do
        if rm -rf "$dir" 2>/dev/null; then
            print_success "✓ Removed: $dir"
            ((removed_count++))
        else
            print_error "✗ Failed to remove: $dir"
            ((failed_count++))
        fi
    done
    
    echo
    if [[ $failed_count -eq 0 ]]; then
        print_success "All $removed_count OpenCode directories removed successfully!"
    else
        print_warning "$removed_count directories removed, $failed_count failed."
    fi
}

# Function to get confirmation
get_confirmation() {
    while true; do
        print_warning "Are you sure you want to remove these directories? (y/N): "
        read -r response
        case "$response" in
            [yY]|[yY][eE][sS])
                return 0
                ;;
            [nN]|[nN][oO]|"")
                return 1
                ;;
            *)
                print_error "Please enter 'y' or 'n'."
                ;;
        esac
    done
}

# Main execution
main() {
    if [[ "$DRY_RUN" == true ]]; then
        print_info "OpenCode Cleanup Script (DRY RUN MODE)"
    else
        print_info "OpenCode Cleanup Script"
    fi
    echo
    
    # Check what directories exist
    existing_dirs=($(check_directories))
    
    # Show what will be deleted
    if ! show_deletion_preview "${existing_dirs[@]}"; then
        exit 0
    fi
    
    # If dry-run, show preview and exit
    if [[ "$DRY_RUN" == true ]]; then
        dry_run "${existing_dirs[@]}"
        exit 0
    fi
    
    # Get confirmation for actual deletion
    if ! get_confirmation; then
        print_info "Operation cancelled by user."
        exit 0
    fi
    
    echo
    # Perform the removal
    remove_directories "${existing_dirs[@]}"
}

# Run main function
main "$@"
