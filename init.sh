#!/bin/bash
set -euo pipefail

# =============================================================================
# Neovim Development Environment Setup Script
# Purpose: Configure Neovim with offline tools and dotfiles via symlinks
# Version: 4.0 - Clean, maintainable, and focused
# =============================================================================

# -----------------------------------------------------------------------------
# Constants and Paths
# -----------------------------------------------------------------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"

readonly BIN_DIR="$SCRIPT_DIR/bin"
readonly CONFIG_DIR="$SCRIPT_DIR/nvim"
readonly TOOL_DIR="$SCRIPT_DIR/tool"
readonly NVIM_DIR="$SCRIPT_DIR/app"
readonly CACHE_DIR="$SCRIPT_DIR/.cache"
readonly LOG_FILE="$SCRIPT_DIR/setup.log"

# Target symlink locations (in user's home)
readonly TARGET_CONFIG="$HOME/.config"
readonly TARGET_NVIM_CONFIG="$TARGET_CONFIG/nvim"
readonly TARGET_NVIM_DATA="$HOME/.local/share/nvim"

# Source directories inside the project
readonly SRC_NVIM_CONFIG="$CONFIG_DIR"
readonly SRC_NVIM_DATA="$SCRIPT_DIR/.local/share/nvim"

# Treesitter parser symlink
readonly PARSER_SOURCE="$NVIM_DIR/lib/nvim/parser"
readonly PARSER_TARGET="$SRC_NVIM_CONFIG/addons/nvim-treesitter/parser"

# -----------------------------------------------------------------------------
# Colorful Output
# -----------------------------------------------------------------------------
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_RESET='\033[0m'

# -----------------------------------------------------------------------------
# Logging Functions (write to both terminal and log file)
# -----------------------------------------------------------------------------
log_info() {
    echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $*" >&2
    echo "[INFO] $*" >>"$LOG_FILE"
}
log_success() {
    echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $*" >&2
    echo "[SUCCESS] $*" >>"$LOG_FILE"
}
log_warning() {
    echo -e "${COLOR_YELLOW}[WARNING]${COLOR_RESET} $*" >&2
    echo "[WARNING] $*" >>"$LOG_FILE"
}
log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*" >&2
    echo "[ERROR] $*" >>"$LOG_FILE"
}

print_header() {
    echo -e "${COLOR_CYAN}"
    echo "========================================="
    echo "  Neovim Dev Environment Setup (v4.0)"
    echo "========================================="
    echo -e "${COLOR_RESET}"
}

# -----------------------------------------------------------------------------
# Utility Functions
# -----------------------------------------------------------------------------
create_directory() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" && log_success "Created directory: $dir" || log_error "Failed to create: $dir"
    fi
}

# Safely create a symbolic link.
# If destination exists and is a symlink, it is removed.
# If it exists as a regular file/directory, the script aborts to avoid data loss.
create_symlink() {
    local src="$1"
    local dst="$2"
    local desc="$3"

    if [[ -e "$dst" ]]; then
        if [[ -L "$dst" ]]; then
            rm -f "$dst"
            log_info "Removed existing symlink: $dst"
        else
            log_error "Destination $dst exists and is not a symlink. Please remove it manually."
            return 1
        fi
    fi

    mkdir -p "$(dirname "$dst")"
    if ln -sf "$src" "$dst"; then
        log_success "Created symlink: $dst -> $src ($desc)"
    else
        log_error "Failed to create symlink: $dst"
        return 1
    fi
}

# Remove all symlinks inside BIN_DIR that point to anything under SCRIPT_DIR.
# This cleans up previously created tool links without touching user files.
cleanup_bin_links() {
    log_info "Cleaning up old tool symlinks in $BIN_DIR"
    if [[ -d "$BIN_DIR" ]]; then
        find "$BIN_DIR" -type l -lname "$SCRIPT_DIR/*" -delete
    fi
}

# -----------------------------------------------------------------------------
# Step 1: Environment Validation
# -----------------------------------------------------------------------------
validate_environment() {
    log_info "Validating environment..."
    local missing=0
    for d in "$NVIM_DIR" "$TOOL_DIR" "$CONFIG_DIR"; do
        if [[ ! -d "$d" ]]; then
            log_error "Required directory missing: $d"
            missing=1
        fi
    done
    if [[ $missing -eq 1 ]]; then
        return 1
    fi
    log_success "Environment validation passed"
}

# -----------------------------------------------------------------------------
# Step 2: Remove Existing Configuration (clean slate)
# -----------------------------------------------------------------------------
cleanup_old_config() {
    log_info "Cleaning up old configuration symlinks/directories"
    for target in "$TARGET_NVIM_CONFIG" "$TARGET_NVIM_DATA"; do
        if [[ -e "$target" ]]; then
            rm -rf "$target"
            log_info "Removed: $target"
        fi
    done
}

# -----------------------------------------------------------------------------
# Step 3: Create Configuration Symlinks (nvim config & data)
# -----------------------------------------------------------------------------
setup_config_symlinks() {
    log_info "Setting up configuration symlinks"
    create_directory "$SRC_NVIM_DATA" # ensure source data directory exists
    create_symlink "$SRC_NVIM_CONFIG" "$TARGET_NVIM_CONFIG" "Neovim config"
    create_symlink "$SRC_NVIM_DATA" "$TARGET_NVIM_DATA" "Neovim data"
}

# -----------------------------------------------------------------------------
# Step 4: Treesitter Parser Symlink
# -----------------------------------------------------------------------------
setup_parser_symlink() {
    log_info "Setting up treesitter parser symlink"
    if [[ ! -d "$PARSER_SOURCE" ]]; then
        log_warning "Parser source not found, creating empty directory: $PARSER_SOURCE"
        mkdir -p "$PARSER_SOURCE"
    fi
    create_symlink "$PARSER_SOURCE" "$PARSER_TARGET" "Treesitter parsers"
}

# -----------------------------------------------------------------------------
# Step 5: Tool Symlinks (only the ones you requested)
# -----------------------------------------------------------------------------
setup_tool_links() {
    log_info "Setting up tool symlinks in $BIN_DIR"
    create_directory "$BIN_DIR"

    # Remove any previously created tool links
    cleanup_bin_links

    # Define tool mappings: link_name -> relative path inside TOOL_DIR
    declare -A tool_map=(
        ["fzf"]="fzf-0.67.0/fzf"
        ["rg"]="ripgrep-15.1.0/rg"
        ["node"]="node-v16.20.2-linux-x64/bin/node"
        ["npm"]="node-v16.20.2-linux-x64/lib/node_modules/npm/bin/npm-cli.js"
        ["npx"]="node-v16.20.2-linux-x64/lib/node_modules/npm/bin/npx-cli.js"
        ["corepack"]="node-v16.20.2-linux-x64/lib/node_modules/corepack/dist/corepack.js"
    )

    for link_name in "${!tool_map[@]}"; do
        src="$TOOL_DIR/${tool_map[$link_name]}"
        dst="$BIN_DIR/$link_name"

        if [[ -e "$src" ]]; then
            # Ensure source is executable (harmless if already set)
            [[ ! -x "$src" ]] && chmod +x "$src" 2>/dev/null || true
            create_symlink "$src" "$dst" "Tool $link_name"
        else
            log_warning "Source not found: $src, skipping $link_name"
        fi
    done

    # Add Neovim itself
    nvim_src="$NVIM_DIR/bin/nvim"
    if [[ -f "$nvim_src" ]] && [[ -x "$nvim_src" ]]; then
        create_symlink "$nvim_src" "$BIN_DIR/nvim" "Neovim"
    else
        log_error "Neovim executable not found or not executable: $nvim_src"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Step 6: Add BIN_DIR to PATH in .bashrc (with marker block for clean updates)
# -----------------------------------------------------------------------------
add_bin_to_path() {
    log_info "Adding $BIN_DIR to PATH in ~/.bashrc"
    local bashrc="$HOME/.bashrc"
    local marker_start="# >>> NEOVIM_DEV_ENV_PATH >>>"
    local marker_end="# <<< NEOVIM_DEV_ENV_PATH <<<"
    local path_export="export PATH=\"$BIN_DIR:\$PATH\""

    # Remove existing block if present
    if [[ -f "$bashrc" ]] && grep -q "$marker_start" "$bashrc" 2>/dev/null; then
        sed -i "/$marker_start/,/$marker_end/d" "$bashrc"
        log_info "Removed old PATH block from .bashrc"
    fi

    # Append new block
    {
        echo "$marker_start"
        echo "$path_export"
        echo "$marker_end"
    } >>"$bashrc"

    log_success "PATH updated in .bashrc. Please run 'source ~/.bashrc' or restart your shell to apply."
}

# -----------------------------------------------------------------------------
# Step 7: Verify Installation
# -----------------------------------------------------------------------------
verify_installation() {
    log_info "Verifying installation..."
    local ok=0 total=0

    # Check config symlinks
    for link in "$TARGET_NVIM_CONFIG" "$TARGET_NVIM_DATA"; do
        ((total++))
        if [[ -L "$link" ]] && [[ -e "$(readlink "$link")" ]]; then
            log_success "Symlink $link is valid"
            ((ok++))
        else
            log_warning "Symlink $link is not valid"
        fi
    done

    # Check critical tools
    local tools=("nvim" "fzf" "rg" "node" "npm" "pyright")
    for tool in "${tools[@]}"; do
        ((total++))
        if [[ -x "$BIN_DIR/$tool" ]]; then
            log_success "Tool $tool is executable"
            ((ok++))
        else
            log_warning "Tool $tool not found or not executable in $BIN_DIR"
        fi
    done

    log_info "Verification completed: $ok/$total checks passed."
}

# -----------------------------------------------------------------------------
# Main Orchestration
# -----------------------------------------------------------------------------
main() {
    print_header

    # Prepare log file
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "=== Neovim setup log $(date) ===" >"$LOG_FILE"

    # Define steps in order
    local steps=(
        validate_environment
        cleanup_old_config
        setup_config_symlinks
        setup_parser_symlink
        setup_tool_links
        add_bin_to_path
        verify_installation
    )

    for step in "${steps[@]}"; do
        echo "----------------------------------------"
        if $step; then
            log_success "Step '$step' completed"
        else
            log_error "Step '$step' failed. Aborting."
            return 1
        fi
    done

    echo "----------------------------------------"
    log_success "All steps completed successfully!"
}

# -----------------------------------------------------------------------------
# Entry Point
# -----------------------------------------------------------------------------
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Ensure we are in the project root (where app/ directory lives)
    if [[ ! -d "$NVIM_DIR" ]]; then
        echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} Please run this script from the project root (containing app/ directory)." >&2
        exit 1
    fi

    # Warn about potential data removal
    echo -e "${COLOR_YELLOW}This script will remove existing directories:"
    echo "  $TARGET_NVIM_CONFIG"
    echo "  $TARGET_NVIM_DATA"
    echo "Make sure you have backups if needed.${COLOR_RESET}"
    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi

    main
fi
