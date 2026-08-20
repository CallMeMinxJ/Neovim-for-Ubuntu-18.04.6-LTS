#!/bin/bash
set -euo pipefail

# =============================================================================
# Neovim Development Environment Setup Script
# Purpose: Configure Neovim with offline tools and dotfiles via symlinks
# Version: 5.1 - Idempotent, self-contained, no external deps
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
# Logging Functions
# -----------------------------------------------------------------------------
log_info()    { echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $*" >&2;    echo "[INFO] $(date '+%H:%M:%S') $*" >>"$LOG_FILE"; }
log_success() { echo -e "${COLOR_GREEN}[OK]${COLOR_RESET} $*" >&2;      echo "[OK]    $(date '+%H:%M:%S') $*" >>"$LOG_FILE"; }
log_warning() { echo -e "${COLOR_YELLOW}[WARN]${COLOR_RESET} $*" >&2;   echo "[WARN]  $(date '+%H:%M:%S') $*" >>"$LOG_FILE"; }
log_error()   { echo -e "${COLOR_RED}[ERR]${COLOR_RESET} $*" >&2;       echo "[ERR]   $(date '+%H:%M:%S') $*" >>"$LOG_FILE"; }
log_skip()    { echo -e "${COLOR_CYAN}[SKIP]${COLOR_RESET} $*" >&2;     echo "[SKIP]  $(date '+%H:%M:%S') $*" >>"$LOG_FILE"; }

print_header() {
    echo -e "${COLOR_CYAN}"
    echo "========================================="
    echo "  Neovim Dev Environment Setup (v5.1)"
    echo "  Fully self-contained, idempotent"
    echo "========================================="
    echo -e "${COLOR_RESET}"
}

# -----------------------------------------------------------------------------
# Utility Functions
# -----------------------------------------------------------------------------
create_directory() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" && log_success "Created directory: $dir"
    fi
}

# Idempotent symlink creation.
# If dst already points to the correct src, skip.
# If dst is a symlink pointing elsewhere, replace it.
# If dst is a regular file/directory, abort.
create_symlink() {
    local src="$1"
    local dst="$2"
    local desc="$3"

    # Already correct — skip
    if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
        log_skip "Already linked: $dst ($desc)"
        return 0
    fi

    # Exists as a regular file/directory — abort
    if [[ -e "$dst" ]] && [[ ! -L "$dst" ]]; then
        log_error "Cannot create symlink: $dst exists and is not a symlink. Remove it manually."
        return 1
    fi

    # Exists as wrong symlink — remove and recreate
    if [[ -L "$dst" ]]; then
        rm -f "$dst"
    fi

    mkdir -p "$(dirname "$dst")"
    if ln -sf "$src" "$dst"; then
        log_success "Linked: $dst ($desc)"
    else
        log_error "Failed to link: $dst"
        return 1
    fi
}

# Wrapper for tool symlinks that can fail gracefully (non-fatal)
link_tool() {
    local src="$1"
    local dst="$2"
    local desc="$3"
    if [[ -e "$src" ]]; then
        [[ ! -x "$src" ]] && chmod +x "$src" 2>/dev/null || true
        create_symlink "$src" "$dst" "$desc"
    else
        log_warning "$desc not found: $src"
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
            ((missing++))
        fi
    done
    if [[ $missing -gt 0 ]]; then
        log_error "Missing $missing required directories. Aborting."
        return 1
    fi
    log_success "Environment OK"
}

# -----------------------------------------------------------------------------
# Step 2: Prepare config symlinks
# -----------------------------------------------------------------------------
setup_config_symlinks() {
    log_info "Setting up config symlinks..."

    # Ensure data dir exists
    create_directory "$SRC_NVIM_DATA"

    # If the target exists but is NOT a symlink to our config, warn and ask
    for target in "$TARGET_NVIM_CONFIG" "$TARGET_NVIM_DATA"; do
        if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
            log_warning "$target exists as a regular file/directory, not a symlink."
            log_warning "This script needs to replace it with a symlink."
            log_warning "Please back up and remove it manually, then re-run."
            return 1
        fi
    done

    create_symlink "$SRC_NVIM_CONFIG" "$TARGET_NVIM_CONFIG" "nvim config"
    create_symlink "$SRC_NVIM_DATA" "$TARGET_NVIM_DATA" "nvim data"
}

# -----------------------------------------------------------------------------
# Step 3: Treesitter Parser Symlink
# -----------------------------------------------------------------------------
setup_parser_symlink() {
    log_info "Setting up treesitter parser symlink..."
    if [[ ! -d "$PARSER_SOURCE" ]]; then
        log_warning "Parser source not found, creating empty: $PARSER_SOURCE"
        mkdir -p "$PARSER_SOURCE"
    fi
    create_symlink "$PARSER_SOURCE" "$PARSER_TARGET" "treesitter parsers"
}

# -----------------------------------------------------------------------------
# Step 4: Tool Symlinks (Neovim, core tools, LSP, formatters, npm)
# -----------------------------------------------------------------------------
setup_tool_links() {
    log_info "Setting up tool symlinks in $BIN_DIR"
    create_directory "$BIN_DIR"

    # --- Core tools ---
    local core_tools=(
        "fzf:tool/fzf-0.67.0/fzf"
        "rg:tool/ripgrep-15.1.0/rg"
        "node:tool/node-v16.20.2-linux-x64/bin/node"
        "npm:tool/node-v16.20.2-linux-x64/lib/node_modules/npm/bin/npm-cli.js"
        "npx:tool/node-v16.20.2-linux-x64/lib/node_modules/npm/bin/npx-cli.js"
        "corepack:tool/node-v16.20.2-linux-x64/lib/node_modules/corepack/dist/corepack.js"
    )
    for entry in "${core_tools[@]}"; do
        local name="${entry%%:*}"
        local path="${entry#*:}"
        link_tool "$SCRIPT_DIR/$path" "$BIN_DIR/$name" "$name"
    done

    # --- Neovim ---
    if [[ -x "$NVIM_DIR/bin/nvim" ]]; then
        create_symlink "$NVIM_DIR/bin/nvim" "$BIN_DIR/nvim" "Neovim"
    else
        log_error "Neovim not found: $NVIM_DIR/bin/nvim"
        return 1
    fi

    # --- LSP servers (native) ---
    log_info "LSP servers..."
    local lsp_tools=(
        "clangd:tool/lsp/clangd"
        "lua-language-server:tool/lsp/lua-language-server/bin/lua-language-server"
        "taplo:tool/lsp/taplo"
    )
    for entry in "${lsp_tools[@]}"; do
        local name="${entry%%:*}"
        local path="${entry#*:}"
        link_tool "$SCRIPT_DIR/$path" "$BIN_DIR/$name" "$name"
    done

    # --- Formatters (native) ---
    log_info "Formatters..."
    local fmt_tools=(
        "stylua:tool/fmt/stylua"
        "shfmt:tool/fmt/shfmt"
        "clang-format:tool/fmt/clang-format"
    )
    for entry in "${fmt_tools[@]}"; do
        local name="${entry%%:*}"
        local path="${entry#*:}"
        link_tool "$SCRIPT_DIR/$path" "$BIN_DIR/$name" "$name"
    done

    # --- npm-based tools (wrapper scripts) ---
    log_info "npm-based tools..."
    local npm_tools=(
        "bash-language-server:bash-language-server/node_modules/bash-language-server/out/cli.js:node --experimental-wasm-reftypes"
        "pyright-langserver:pyright/node_modules/pyright/langserver.index.js:node"
        "vscode-json-language-server:json-lsp/node_modules/vscode-langservers-extracted/bin/vscode-json-language-server:node"
        "prettier:prettier/node_modules/prettier/bin/prettier.cjs:node"
    )
    for entry in "${npm_tools[@]}"; do
        IFS=':' read -r name script_path runner <<<"$entry"
        local full_path="$TOOL_DIR/npm-packages/$script_path"
        local dst="$BIN_DIR/$name"
        if [[ -f "$full_path" ]]; then
            cat > "$dst" << EOF
#!/bin/bash
exec $runner "$full_path" "\$@"
EOF
            chmod +x "$dst"
            log_success "Created wrapper: $name"
        else
            log_warning "npm tool $name: script not found ($full_path)"
        fi
    done
}

# -----------------------------------------------------------------------------
# Step 5: Python tools (portable Python + black + isort)
# -----------------------------------------------------------------------------
setup_python_tools() {
    log_info "Setting up Python tools..."

    local python_dir="$TOOL_DIR/python-3.10"
    local python_bin="$python_dir/bin/python3"

    if [[ ! -x "$python_bin" ]]; then
        log_warning "Portable Python not found at $python_bin"
        log_warning "  Run tool/download.sh on a machine with internet to download it"
        return 0
    fi

    # Python symlinks
    create_symlink "$python_bin" "$BIN_DIR/python" "Python 3.10"
    create_symlink "$python_bin" "$BIN_DIR/python3" "Python 3.10"
    if [[ -x "$python_dir/bin/pip3" ]]; then
        create_symlink "$python_dir/bin/pip3" "$BIN_DIR/pip" "pip3"
    fi

    # black wrapper
    if "$python_bin" -c "import black" 2>/dev/null; then
        cat > "$BIN_DIR/black" << 'EOF'
#!/bin/bash
exec python -m black "$@"
EOF
        chmod +x "$BIN_DIR/black"
        log_success "Created wrapper: black"
    else
        log_warning "black not installed. Run: tool/install.sh"
    fi

    # isort wrapper
    if "$python_bin" -c "import isort" 2>/dev/null; then
        cat > "$BIN_DIR/isort" << 'EOF'
#!/bin/bash
exec python -m isort "$@"
EOF
        chmod +x "$BIN_DIR/isort"
        log_success "Created wrapper: isort"
    else
        log_warning "isort not installed. Run: tool/install.sh"
    fi
}

# -----------------------------------------------------------------------------
# Step 6: Add BIN_DIR to PATH in .bashrc
# -----------------------------------------------------------------------------
add_bin_to_path() {
    log_info "Updating PATH in ~/.bashrc..."

    local bashrc="$HOME/.bashrc"
    local marker_start="# >>> NEOVIM_DEV_ENV_PATH >>>"
    local marker_end="# <<< NEOVIM_DEV_ENV_PATH <<<"
    local path_export="export PATH=\"$BIN_DIR:\$PATH\""

    # Remove existing block if present
    if [[ -f "$bashrc" ]] && grep -qF "$marker_start" "$bashrc" 2>/dev/null; then
        sed -i "/$marker_start/,/$marker_end/d" "$bashrc"
        log_info "Removed previous PATH entry"
    fi

    # Append new block
    {
        echo ""
        echo "$marker_start"
        echo "$path_export"
        echo "$marker_end"
    } >>"$bashrc"

    log_success "PATH updated: $BIN_DIR"
    log_info "Run 'source ~/.bashrc' or restart your shell to apply."
}

# -----------------------------------------------------------------------------
# Step 7: Verification
# -----------------------------------------------------------------------------
verify_installation() {
    log_info "Verifying installation..."
    local ok=0 total=0

    # Config symlinks
    for link in "$TARGET_NVIM_CONFIG" "$TARGET_NVIM_DATA"; do
        ((total++))
        if [[ -L "$link" ]] && [[ -e "$(readlink "$link")" ]]; then
            log_success "Config: $link"
            ((ok++))
        else
            log_warning "Config: $link is invalid"
        fi
    done

    # Tools
    local tools=(
        "nvim" "fzf" "rg" "node" "npm"
        "clangd" "lua-language-server" "taplo"
        "shfmt" "clang-format" "stylua"
        "bash-language-server" "pyright-langserver" "prettier"
        "vscode-json-language-server"
    )
    for tool in "${tools[@]}"; do
        ((total++))
        if [[ -x "$BIN_DIR/$tool" ]]; then
            log_success "Tool: $tool"
            ((ok++))
        else
            log_warning "Tool: $tool missing"
        fi
    done

    # Python
    if [[ -x "$BIN_DIR/python" ]]; then
        ((total++))
        if "$BIN_DIR/python" -c "import black" 2>/dev/null; then
            log_success "Python: black"
            ((ok++))
        else
            log_warning "Python: black not installed"
        fi
        ((total++))
        if "$BIN_DIR/python" -c "import isort" 2>/dev/null; then
            log_success "Python: isort"
            ((ok++))
        else
            log_warning "Python: isort not installed"
        fi
    fi

    echo ""
    log_info "Passed: $ok / $total"
    if [[ $ok -eq $total ]]; then
        log_success "All checks passed!"
    elif [[ $ok -gt $((total / 2)) ]]; then
        log_warning "Some tools are missing. Run tool/download.sh on a machine with internet."
    else
        log_error "Many tools are missing. Please check the project structure."
    fi
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    print_header

    # Prepare log file
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "" >>"$LOG_FILE"
    echo "=== Setup started $(date) ===" >>"$LOG_FILE"

    local steps=(
        validate_environment
        setup_config_symlinks
        setup_parser_symlink
        setup_tool_links
        setup_python_tools
        add_bin_to_path
        verify_installation
    )

    local failed=0
    for step in "${steps[@]}"; do
        echo ""
        if $step; then
            :
        else
            log_error "Step '$step' failed."
            ((failed++))
        fi
    done

    echo ""
    echo "========================================="
    if [[ $failed -eq 0 ]]; then
        log_success "Setup complete!"
        echo ""
        log_info "Run 'source ~/.bashrc' to update PATH, then run 'nvim'."
    else
        log_error "Setup completed with $failed error(s). Check $LOG_FILE for details."
    fi
    echo "========================================="
}

# -----------------------------------------------------------------------------
# Entry Point
# -----------------------------------------------------------------------------
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ ! -d "$NVIM_DIR" ]]; then
        echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} Please run this script from the project root (containing app/ directory)." >&2
        exit 1
    fi

    # Check if this is a re-run (config already linked)
    already_setup=false
    if [[ -L "$TARGET_NVIM_CONFIG" ]] && [[ "$(readlink "$TARGET_NVIM_CONFIG")" == "$SRC_NVIM_CONFIG" ]]; then
        already_setup=true
    fi

    if $already_setup; then
        echo -e "${COLOR_CYAN}Already configured. Re-running to refresh symlinks and tools...${COLOR_RESET}"
        echo ""
    else
        echo -e "${COLOR_YELLOW}First-time setup: this will create symlinks for:~${COLOR_RESET}"
        echo "  ~/.config/nvim  -> $SRC_NVIM_CONFIG"
        echo "  ~/.local/share/nvim -> $SRC_NVIM_DATA"
        echo ""
        echo -e "${COLOR_YELLOW}Existing nvim config at these paths will be replaced.${COLOR_RESET}"
        read -p "Continue? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi

    main
fi