#!/bin/bash

# =============================================================================
# Neovim Development Environment Initialization Script
# Purpose: Configure Neovim development environment without internet access
# Design Principles: Modular, Maintainable, Elegant error handling
# Version: 3.4 - Direct removal of existing config directories
# =============================================================================

set -euo pipefail # Strict security settings

# =============================================================================
# Initialize configuration and constants
# =============================================================================
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"

# Define base variables first to avoid set -u errors
readonly BIN_DIR="$SCRIPT_DIR/bin"
readonly CONFIG_DIR="$SCRIPT_DIR/nvim"
readonly TOOL_DIR="$SCRIPT_DIR/tool"
readonly NVIM_DIR="$SCRIPT_DIR/app"
readonly BASHRC_FILE="$HOME/.bashrc"
readonly CACHE_DIR="$SCRIPT_DIR/.cache"
readonly LOG_FILE="$SCRIPT_DIR/setup.log"

# Required directory structure
readonly REQUIRED_DIRS=("lua" "pack" "plugin" "themes")

# Target directories for symlinks
readonly TARGET_LOCAL_SHARE="$HOME/.local/share"
readonly TARGET_CONFIG="$HOME/.config"
readonly TARGET_NVIM_CONFIG="$TARGET_CONFIG/nvim"
readonly TARGET_NVIM_DATA="$TARGET_LOCAL_SHARE/nvim"
readonly TARGET_COC_CONFIG="$TARGET_CONFIG/coc"

# Source directories in project
readonly SRC_NVIM_CONFIG="$SCRIPT_DIR/nvim"
readonly SRC_NVIM_DATA="$SCRIPT_DIR/.local/share/nvim"
readonly SRC_COC_CONFIG="$SCRIPT_DIR/coc"

# Configuration directories that should be removed if existing (not symlinks)
readonly CONFIG_DIRS_TO_REMOVE=("$TARGET_NVIM_CONFIG" "$TARGET_NVIM_DATA" "$TARGET_COC_CONFIG")

# =============================================================================
# Logging and output system
# =============================================================================
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_PURPLE='\033[0;35m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_RESET='\033[0m'

# Log levels
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARNING=2
readonly LOG_LEVEL_ERROR=3

LOG_LEVEL=${LOG_LEVEL:-$LOG_LEVEL_INFO}

log() {
    local level="$1"
    shift
    local color="$1"
    shift
    local prefix="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    if [[ ${level} -ge ${LOG_LEVEL} ]]; then
        echo -e "${color}[${prefix}]${COLOR_RESET} ${message}" >&2
    fi

    # Write to log file
    echo "[${timestamp}] [${prefix}] ${message}" >> "${LOG_FILE}"
}

log_debug() { log ${LOG_LEVEL_DEBUG} "${COLOR_PURPLE}" "DEBUG" "$@"; }
log_info() { log ${LOG_LEVEL_INFO} "${COLOR_BLUE}" "INFO" "$@"; }
log_success() { log ${LOG_LEVEL_INFO} "${COLOR_GREEN}" "SUCCESS" "$@"; }
log_warning() { log ${LOG_LEVEL_WARNING} "${COLOR_YELLOW}" "WARNING" "$@"; }
log_error() { log ${LOG_LEVEL_ERROR} "${COLOR_RED}" "ERROR" "$@"; }

print_header() {
    echo -e "${COLOR_CYAN}"
    echo "========================================"
    echo "  Neovim Development Environment Setup"
    echo "  Version 3.4 - Direct Config Removal"
    echo "========================================"
    echo -e "${COLOR_RESET}"
}

print_step() {
    echo -e "${COLOR_PURPLE}[STEP]${COLOR_RESET} $1"
    log_info "STEP: $1"
}

print_divider() {
    echo -e "${COLOR_CYAN}----------------------------------------${COLOR_RESET}"
}

# =============================================================================
# Utility functions
# =============================================================================
create_directory() {
    local dir="${1:-}"
    local description="${2:-Unnamed directory}"

    if [[ -z "$dir" ]]; then
        log_error "create_directory: Directory parameter is empty"
        return 1
    fi

    if [[ ! -d "$dir" ]]; then
        if mkdir -p "$dir" 2> /dev/null; then
            log_success "Created directory: $dir ($description)"
        else
            log_error "Failed to create directory: $dir"
            return 1
        fi
    else
        log_debug "Directory already exists: $dir"
    fi
    return 0
}

# =============================================================================
# Configuration directory cleanup
# =============================================================================
cleanup_existing_config_dirs() {
    print_step "Cleaning up existing configuration directories"

    for config_dir in "${CONFIG_DIRS_TO_REMOVE[@]}"; do
        if [[ -e "$config_dir" ]]; then
            if [[ -L "$config_dir" ]]; then
                # It's a symlink, just remove it
                log_info "Removing existing symlink: $config_dir"
                rm -f "$config_dir"
            elif [[ -d "$config_dir" ]]; then
                # It's a directory, remove it (no backup)
                log_info "Removing existing directory: $config_dir"
                rm -rf "$config_dir"
            fi
        fi
    done

    log_success "Existing configuration directories cleaned up"
    return 0
}

# =============================================================================
# Configuration directory setup
# =============================================================================
setup_config_directories() {
    print_step "Setting up configuration directories"

    # Create target directories if they don't exist
    create_directory "$TARGET_LOCAL_SHARE" "Local share directory"
    create_directory "$TARGET_CONFIG" "Config directory"

    # Create source directories in project if they don't exist
    create_directory "$SRC_NVIM_DATA" "Neovim data directory in project"
    create_directory "$SRC_COC_CONFIG" "CoC configuration directory in project"

    # If source nvim config doesn't exist, create it
    if [[ ! -d "$SRC_NVIM_CONFIG" ]]; then
        log_warning "Source nvim config directory not found: $SRC_NVIM_CONFIG"
        log_info "Creating basic nvim config structure..."
        mkdir -p "$SRC_NVIM_CONFIG/lua"
        echo "-- Neovim configuration" > "$SRC_NVIM_CONFIG/init.lua"
        log_success "Created basic nvim config structure"
    fi

    return 0
}

# =============================================================================
# Configuration symlinks management
# =============================================================================
create_config_symlink() {
    local source="${1:-}"
    local target="${2:-}"
    local description="${3:-Unnamed config link}"

    # Validate parameters
    if [[ -z "$source" || -z "$target" ]]; then
        log_error "create_config_symlink: Source or target path is empty"
        return 1
    fi

    # Check if source exists
    if [[ ! -e "$source" ]]; then
        log_warning "Source does not exist: $source"
        log_info "Creating source directory: $source"
        if ! create_directory "$source" "$description source"; then
            log_error "Failed to create source directory: $source"
            return 1
        fi
    fi

    # Handle existing target
    if [[ -e "$target" ]]; then
        if [[ -L "$target" ]]; then
            local current_target=$(readlink "$target" 2> /dev/null || echo "")
            if [[ "$current_target" == "$source" ]]; then
                log_info "Symlink already correctly set: $target -> $source"
                return 0
            else
                log_info "Updating symlink: $target (was -> $current_target)"
                rm -f "$target"
            fi
        else
            # For config directories, just remove them (no backup)
            log_info "Removing existing $description directory: $target"
            rm -rf "$target"
        fi
    fi

    # Ensure parent directory exists
    local target_dir=$(dirname "$target")
    create_directory "$target_dir" "Target parent directory"

    # Create symlink
    if ln -sf "$source" "$target" 2> /dev/null; then
        log_success "Created $description symlink: $target -> $source"
        return 0
    else
        log_error "Failed to create $description symlink: $target"
        return 1
    fi
}

setup_config_symlinks() {
    print_step "Setting up configuration symlinks"

    local success_count=0
    local total_count=0

    # Create symlinks for config directories
    local config_links=(
        "$SRC_NVIM_CONFIG|$TARGET_NVIM_CONFIG|Neovim configuration"
        "$SRC_NVIM_DATA|$TARGET_NVIM_DATA|Neovim data (plugins, cache)"
        "$SRC_COC_CONFIG|$TARGET_COC_CONFIG|CoC extension configuration"
    )

    for link_config in "${config_links[@]}"; do
        IFS='|' read -r source target description <<< "$link_config"
        ((total_count++))

        if create_config_symlink "$source" "$target" "$description"; then
            ((success_count++))
        fi
    done

    # Verify the symlinks
    print_divider
    log_info "Configuration symlinks created: $success_count/$total_count"

    if [[ $success_count -eq $total_count ]]; then
        log_success "All configuration symlinks created successfully"
        log_info "Neovim will now use project-based configuration at: $SCRIPT_DIR"
        return 0
    else
        log_warning "Some configuration symlinks failed to create"
        return 1
    fi
}

# =============================================================================
# Environment validation system
# =============================================================================
validate_environment() {
    print_step "Validating environment requirements"

    local missing_dirs=()
    local missing_tools=()

    # Check base directories
    if [[ ! -d "$CONFIG_DIR" ]]; then
        missing_dirs+=("$CONFIG_DIR (CONFIG_DIR)")
    fi
    if [[ ! -d "$TOOL_DIR" ]]; then
        missing_dirs+=("$TOOL_DIR (TOOL_DIR)")
    fi
    if [[ ! -d "$NVIM_DIR" ]]; then
        missing_dirs+=("$NVIM_DIR (NVIM_DIR)")
    fi

    # Check required tool directories
    local required_tools=("clangd-server" "fzf-0.67.0" "lua-server" "ripgrep-15.1.0" "node-v16.20.2-linux-x64")
    for tool_dir in "${required_tools[@]}"; do
        if [[ ! -d "${TOOL_DIR}/$tool_dir" ]]; then
            missing_tools+=("$tool_dir")
        fi
    done

    # Check Neovim executable
    if [[ ! -f "${NVIM_DIR}/bin/nvim" ]]; then
        log_error "Neovim executable not found: ${NVIM_DIR}/bin/nvim"
        return 1
    fi

    # Report missing items
    if [[ ${#missing_dirs[@]} -gt 0 ]]; then
        log_warning "Missing directories:"
        for dir in "${missing_dirs[@]}"; do
            log_warning "  - $dir"
        done
    fi

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_warning "Missing tool directories:"
        for tool in "${missing_tools[@]}"; do
            log_warning "  - $tool"
        done
    fi

    # Create necessary directories
    create_directory "${BIN_DIR}" "Binary files directory"
    create_directory "${CACHE_DIR}" "Cache directory"

    if [[ ${#missing_dirs[@]} -eq 0 && ${#missing_tools[@]} -eq 0 ]]; then
        log_success "Environment validation passed"
        return 0
    else
        log_warning "Environment validation completed with warnings"
        return 2
    fi
}

# =============================================================================
# Symbolic link management system
# =============================================================================
create_symlink() {
    local source="${1:-}"
    local target="${2:-}"
    local description="${3:-Unnamed link}"

    # Validate parameters
    if [[ -z "$source" || -z "$target" ]]; then
        log_error "create_symlink: Source or target path is empty"
        return 1
    fi

    # Verify source file exists and is executable
    if [[ ! -f "$source" ]]; then
        log_warning "Source file does not exist: $source"
        return 1
    fi

    if [[ ! -x "$source" ]]; then
        if ! chmod +x "$source" 2> /dev/null; then
            log_warning "Cannot make file executable: $source"
            return 1
        fi
    fi

    # Handle existing target
    if [[ -e "$target" ]]; then
        if [[ -L "$target" ]]; then
            local current_target=$(readlink "$target" 2> /dev/null || echo "")
            if [[ "$current_target" == "$source" ]]; then
                log_info "Symlink already correctly set: $target -> $source"
                return 0
            else
                log_info "Updating symlink: $target"
                rm -f "$target"
            fi
        else
            rm -rf "$target"
        fi
    fi

    # Ensure target directory exists
    local target_dir=$(dirname "$target")
    create_directory "$target_dir" "Target directory"

    # Create symbolic link
    if ln -sf "$source" "$target" 2> /dev/null; then
        log_success "Created $description symlink: $target → $source"
        return 0
    else
        log_warning "Symlink creation failed, trying to copy file"
        if cp "$source" "$target" 2> /dev/null && chmod +x "$target"; then
            log_success "Copied $description: $target"
            return 0
        else
            log_error "Failed to create $description: $target"
            return 1
        fi
    fi
}

# Tool mapping configuration
setup_tool_links() {
    print_step "Configuring tool symbolic links"

    chmod -R +x *

    local success_count=0
    local total_count=0
    local failed_tools=()

    # Tool mapping configuration
    local tool_mappings=(
        "clangd-server|bin/clangd|clangd"
        "fzf-0.67.0|fzf|fzf"
        "lua-server|bin/lua-language-server|lua-language-server"
        "ripgrep-15.1.0|rg|rg"
        "node-v16.20.2-linux-x64|bin/node|node"
        "node-v16.20.2-linux-x64|lib/node_modules/npm/bin/npm-cli.js|npm"
        "node-v16.20.2-linux-x64|lib/node_modules/npm/bin/npx-cli.js|npx"
        "node-v16.20.2-linux-x64|lib/node_modules/corepack/dist/corepack.js|corepack"
        "node-v16.20.2-linux-x64|lib/node_modules/bash-language-server/bin/main.js|bash-language-server"
        "node-v16.20.2-linux-x64|lib/node_modules/pyright/index.js|pyright"
        "node-v16.20.2-linux-x64|lib/node_modules/pyright/langserver.index.js|pyright-langserver"
        "yarn-v1.22.22|bin/yarn|yarn"
        "clang-format|clang-format|clang-format"
        "stylua|stylua|stylua"
        "shfmt|shfmt_v3.12.0_linux_amd64|shfmt"
    )

    # First set up Neovim
    if create_symlink \
        "${NVIM_DIR}/bin/nvim" \
        "${BIN_DIR}/nvim" \
        "Neovim"; then
        ((success_count++))
    fi
    ((total_count++))

    # Process all tool mappings
    for mapping in "${tool_mappings[@]}"; do
        IFS='|' read -r tool_dir exec_path link_name <<< "$mapping"
        ((total_count++))

        local tool_path="${TOOL_DIR}/$tool_dir"
        local executable="$tool_path/$exec_path"
        local link_path="${BIN_DIR}/$link_name"

        if [[ ! -d "$tool_path" ]]; then
            log_warning "Tool directory does not exist: $tool_path"
            failed_tools+=("$link_name (directory not found)")
            continue
        fi

        if create_symlink "$executable" "$link_path" "$link_name"; then
            ((success_count++))
        else
            failed_tools+=("$link_name")
            # Try to find alternative executable
            local alternative=$(find "$tool_path" -type f -executable -name "$link_name" 2> /dev/null | head -1)
            if [[ -n "$alternative" ]]; then
                log_info "Trying alternative file: $alternative"
                if create_symlink "$alternative" "$link_path" "$link_name"; then
                    ((success_count++))
                    # Remove from failed list
                    for i in "${!failed_tools[@]}"; do
                        if [[ "${failed_tools[i]}" == "$link_name" ]]; then
                            unset 'failed_tools[i]'
                        fi
                    done
                fi
            fi
        fi
    done

    # Output statistics
    print_divider
    log_info "Tool link statistics: $success_count/$total_count successful"
    if [[ ${#failed_tools[@]} -gt 0 ]]; then
        log_warning "Failed tools:"
        for tool in "${failed_tools[@]}"; do
            [[ -n "$tool" ]] && log_warning "  - $tool"
        done
    fi

    if [[ $success_count -eq $total_count ]]; then
        log_success "All tool links configured"
    else
        log_warning "Tool link configuration completed with failures"
    fi
    return 0
}

# =============================================================================
# Runtime validation system
# =============================================================================
validate_neovim_runtime() {
    print_step "Validating Neovim runtime configuration"

    local valid_count=0

    for dir in "${REQUIRED_DIRS[@]}"; do
        local dir_path="$CONFIG_DIR/$dir"
        if [[ -d "$dir_path" ]]; then
            local file_count=$(find "$dir_path" \( -name "*.lua" -o -name "*.vim" \) -type f 2> /dev/null | wc -l)
            log_success "Directory $dir: contains $file_count config files"
            ((valid_count++))
        else
            log_warning "Directory does not exist: $dir"
        fi
    done

    if [[ $valid_count -eq ${#REQUIRED_DIRS[@]} ]]; then
        log_success "Neovim runtime configuration validation passed"
    else
        log_warning "Neovim runtime configuration validation completed with missing directories"
    fi
    return 0
}

# =============================================================================
# Installation verification system
# =============================================================================
verify_installation() {
    print_step "Verifying installation results"

    local success_count=0
    local total_count=0

    # Test critical tools
    local critical_tools=("nvim" "fzf" "rg" "clangd" "lua-language-server" "node")

    for tool in "${critical_tools[@]}"; do
        ((total_count++))
        local tool_path="${BIN_DIR}/$tool"

        if [[ -e "$tool_path" ]]; then
            if [[ -L "$tool_path" ]]; then
                local target=$(readlink "$tool_path" 2> /dev/null || echo "")
                if [[ -e "$target" ]]; then
                    log_success "$tool: link valid -> $target"
                    ((success_count++))
                else
                    log_warning "$tool: link target does not exist -> $target"
                fi
            elif [[ -x "$tool_path" ]]; then
                log_success "$tool: executable file is valid"
                ((success_count++))
            else
                log_warning "$tool: exists but not executable"
            fi
        else
            log_warning "$tool: not found"
        fi
    done

    # Test Neovim
    if command -v "${BIN_DIR}/nvim" > /dev/null 2>&1; then
        local version=$("${BIN_DIR}/nvim" --version 2> /dev/null | head -1 || echo "Unknown version")
        log_success "Neovim test passed: $version"
        ((success_count++))
    else
        log_error "Neovim test failed"
    fi
    ((total_count++))

    # Verify configuration symlinks
    local config_symlinks=(
        "$TARGET_NVIM_CONFIG"
        "$TARGET_NVIM_DATA"
        "$TARGET_COC_CONFIG"
    )

    for symlink in "${config_symlinks[@]}"; do
        ((total_count++))
        if [[ -L "$symlink" ]]; then
            local target=$(readlink "$symlink" 2> /dev/null || echo "")
            if [[ "$target" == "$SCRIPT_DIR"* ]]; then
                log_success "Config symlink valid: $symlink -> $target"
                ((success_count++))
            else
                log_warning "Config symlink points outside project: $symlink -> $target"
            fi
        else
            log_warning "Config symlink not found: $symlink"
        fi
    done

    print_divider
    log_info "Verification statistics: $success_count/$total_count passed"

    if [[ $success_count -eq $total_count ]]; then
        log_success "Installation verification fully passed"
        return 0
    else
        log_warning "Installation verification completed with warnings"
        return 2
    fi
}

# =============================================================================
# Cleanup system
# =============================================================================
cleanup_old_config() {
    print_step "Cleaning up old configuration"

    local old_markers=("# NEOVIM_DEV_ENV" "# XDG_CONFIG_HOME")
    local marker_end_patterns=("# END_NEOVIM_DEV_ENV" "# END_XDG_CONFIG_HOME")

    for i in "${!old_markers[@]}"; do
        if grep -q "${old_markers[i]}" "$BASHRC_FILE" 2> /dev/null; then
            log_info "Cleaning old config marker: ${old_markers[i]}"
            sed -i "/${old_markers[i]}/,/${marker_end_patterns[i]}/d" "$BASHRC_FILE" 2> /dev/null || true
        fi
    done

    log_success "Old configuration cleanup completed"
    return 0
}

# =============================================================================
# Result display system
# =============================================================================
show_results() {
    print_header
    echo -e "${COLOR_GREEN}Neovim development environment setup completed!${COLOR_RESET}"
    echo ""

    echo -e "${COLOR_CYAN}Configuration summary:${COLOR_RESET}"
    echo -e "  ${COLOR_BLUE}• Configuration files:${COLOR_RESET} ${SCRIPT_DIR}/"
    echo -e "  ${COLOR_BLUE}• Tool directory:${COLOR_RESET} ${BIN_DIR}/"
    echo -e "  ${COLOR_BLUE}• Cache directory:${COLOR_RESET} ${CACHE_DIR}/"
    echo -e "  ${COLOR_BLUE}• Config symlinks:${COLOR_RESET}"
    echo -e "      ~/.config/nvim -> ${SRC_NVIM_CONFIG}"
    echo -e "      ~/.local/share/nvim -> ${SRC_NVIM_DATA}"
    echo -e "      ~/.config/coc -> ${SRC_COC_CONFIG}"
    echo ""

    print_divider
}

# =============================================================================
# Main control system
# =============================================================================
main() {
    local start_time=$(date +%s)

    print_header
    log_info "Starting Neovim development environment setup"
    log_info "Working directory: $SCRIPT_DIR"
    log_info "Start time: $(date)"

    # Create log directory
    mkdir -p "$(dirname "${LOG_FILE}")" 2> /dev/null || true
    echo "=== Neovim configuration log $(date) ===" > "${LOG_FILE}"

    # Execute configuration steps
    local steps=(
        "validate_environment"
        "cleanup_old_config"
        "cleanup_existing_config_dirs"
        "setup_config_directories"
        "setup_config_symlinks"
        "setup_tool_links"
        "validate_neovim_runtime"
        "verify_installation"
    )

    local success_count=0
    for step in "${steps[@]}"; do
        print_divider
        if $step; then
            ((success_count++))
        else
            local exit_code=$?
            log_error "Step failed: $step (exit code: $exit_code)"

            # Decide whether to continue based on step importance
            case "$step" in
                "validate_environment")
                    log_error "Environment validation failed, stopping execution"
                    return 1
                    ;;
                "setup_tool_links"|"setup_config_symlinks")
                    log_error "Critical step failed, stopping execution"
                    return 1
                    ;;
                *)
                    log_warning "Non-critical step failed, continuing with next steps..."
                    ;;
            esac
        fi
    done

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    print_divider
    log_info "Setup completed: $success_count/${#steps[@]} steps successful"
    log_info "Total time: ${duration} seconds"
    log_info "Completion time: $(date)"

    if [[ $success_count -eq ${#steps[@]} ]]; then
        log_success "All setup steps completed successfully"
        show_results
        return 0
    else
        log_warning "Setup completed with warnings, please check log: ${LOG_FILE}"
        show_results
        return 2
    fi
}

# =============================================================================
# Script entry point
# =============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Check if running in correct directory
    if [[ ! -d "${NVIM_DIR}" ]]; then
        echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} Please run this script from project root directory" >&2
        echo -e "Current directory: $(pwd)" >&2
        echo -e "Expected directory containing: ${NVIM_DIR}" >&2
        exit 1
    fi

    # Execute main function
    if main "$@"; then
        exit 0
    else
        exit 1
    fi
fi
