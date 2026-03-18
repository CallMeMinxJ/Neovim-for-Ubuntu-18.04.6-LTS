#!/bin/bash
# fix_mason_links.sh - Recreate all Mason symlinks

# set -euo pipefail

readonly MASON_DIR="${HOME}/.local/share/nvim/mason"
readonly BIN_DIR="${MASON_DIR}/bin"
readonly PKG_DIR="${MASON_DIR}/packages"

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log_info() { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
log_ok() { printf "${GREEN}[OK]${NC} %s\n" "$1"; }
log_warn() { printf "${YELLOW}[WARN]${NC} %s\n" "$1" >&2; }
log_error() { printf "${RED}[ERR]${NC} %s\n" "$1" >&2; }

echo "=========================================="
echo "Mason Symlink Repair Tool"
echo "=========================================="

# Ensure directories exist
mkdir -p "${BIN_DIR}"

# Clear existing symlinks (but keep the directory)
log_info "Cleaning bin directory..."
find "${BIN_DIR}" -maxdepth 1 -type l -delete
log_ok "Bin directory cleaned"

# Define tools with corrected paths based on your directory structure
declare -A TOOLS=(
    # Tool name: package|relative_path_in_package|rename_if_needed
    ["stylua"]="stylua|stylua"
    ["lua-language-server"]="lua-language-server|libexec/bin/lua-language-server"
    ["clangd"]="clangd|clangd_21.1.8/bin/clangd"
    ["clang-format"]="clang-format|clang-format"
    ["clang-format-diff.py"]="clang-format|clang-format-diff.py"
    ["git-clang-format"]="clang-format|git-clang-format"
    ["shfmt"]="shfmt|shfmt_v3.13.0_linux_amd64|shfmt"
    ["taplo"]="taplo|taplo-linux-x86_64|taplo"
    ["prettier"]="prettier|node_modules/.bin/prettier"
    ["black"]="black|black"
    ["bash-language-server"]="bash-language-server|node_modules/.bin/bash-language-server"
    ["pyright"]="pyright|node_modules/.bin/pyright"
    ["pyright-langserver"]="pyright|node_modules/.bin/pyright-langserver"
    ["vscode-json-language-server"]="json-lsp|node_modules/.bin/vscode-json-language-server"
    # Note: clang-format-diff.py and git-clang-format are scripts, not binaries
)

create_symlink() {
    local bin_name=$1
    local package=$2
    local rel_path=$3
    local rename=${4:-}

    local pkg_dir="${PKG_DIR}/${package}"
    local target_path="${pkg_dir}/${rel_path}"
    local link_path="${BIN_DIR}/${bin_name}"

    # Check if package exists
    if [[ ! -d "${pkg_dir}" ]]; then
        log_error "Package not found: ${package}"
        return 1
    fi

    # If rename specified, we need to create a copy
    if [[ -n "${rename}" ]]; then
        local simple_path="${pkg_dir}/${rename}"

        # If the renamed file doesn't exist, copy it
        if [[ ! -f "${simple_path}" ]]; then
            if [[ -f "${target_path}" ]]; then
                log_info "Creating copy: ${target_path} -> ${simple_path}"
                cp -f "${target_path}" "${simple_path}"
                chmod +x "${simple_path}" 2>/dev/null || true
            else
                # If target doesn't exist, find the actual binary
                log_warn "Target not found: ${target_path}"
                local found=$(find "${pkg_dir}" -type f -executable 2>/dev/null | head -1)
                if [[ -n "${found}" ]]; then
                    log_info "Found alternative: ${found}"
                    cp -f "${found}" "${simple_path}"
                    chmod +x "${simple_path}" 2>/dev/null || true
                else
                    log_error "No executable found in ${package}"
                    return 1
                fi
            fi
        fi
        target_path="${simple_path}"
    fi

    # If target doesn't exist at all, try to find it
    if [[ ! -f "${target_path}" ]]; then
        log_warn "Target not found: ${target_path}"
        local found=$(find "${pkg_dir}" -type f -executable 2>/dev/null | head -1)
        if [[ -n "${found}" ]]; then
            log_info "Using alternative: ${found}"
            target_path="${found}"
        else
            log_error "No executable found for ${bin_name}"
            return 1
        fi
    fi

    # Check if it's a Python script (needs different handling)
    if [[ "${bin_name}" == *".py" ]] || [[ "${target_path}" == *".py" ]]; then
        # For Python scripts, ensure they're executable
        chmod +x "${target_path}" 2>/dev/null || true
    fi

    # Create symlink
    ln -sf "${target_path}" "${link_path}" 2>/dev/null
    if [[ $? -eq 0 ]] && [[ -L "${link_path}" ]]; then
        log_ok "Created: ${bin_name} -> $(readlink -f "${link_path}")"
        return 0
    else
        log_error "Failed to create symlink for ${bin_name}"
        return 1
    fi
}

echo ""
echo "Creating symlinks..."
echo "=========================================="

total=0
success=0
failed=0
failed_tools=()

for tool in "${!TOOLS[@]}"; do
    ((total++))

    IFS='|' read -r package rel_path rename <<<"${TOOLS[$tool]}"

    log_info "Processing: ${tool}"
    if create_symlink "${tool}" "${package}" "${rel_path}" "${rename:-}"; then
        ((success++))
    else
        ((failed++))
        failed_tools+=("${tool} (package: ${package})")
    fi
    echo ""
done

echo "=========================================="
printf "Results: %d total, %d success, %d failed\n" ${total} ${success} ${failed}
echo "=========================================="

# Show bin directory contents
echo ""
log_info "Bin directory contents:"
ls -la "${BIN_DIR}/"

# Test a few tools
echo ""
log_info "Testing tools:"
test_tools=("stylua" "lua-language-server" "prettier")
for tool in "${test_tools[@]}"; do
    tool_path="${BIN_DIR}/${tool}"
    if [[ -L "${tool_path}" ]] && [[ -f "$(readlink -f "${tool_path}")" ]]; then
        if [[ -x "$(readlink -f "${tool_path}")" ]]; then
            log_ok "${tool}: OK"
        else
            log_warn "${tool}: Found but not executable"
        fi
    else
        log_error "${tool}: Not found"
    fi
done

# Show failed tools
if [[ ${failed} -gt 0 ]]; then
    echo ""
    log_warn "Failed tools (need reinstallation):"
    for failed_tool in "${failed_tools[@]}"; do
        echo "  ${failed_tool}"
    done
    echo ""
    log_info "Run in Neovim:"
    echo "  :MasonUninstall <package>"
    echo "  :MasonInstall <package>"
fi

echo ""
# Final test
log_info "Testing stylua version:"
if "${BIN_DIR}/stylua" --version 2>/dev/null; then
    log_ok "All symlinks created successfully!"
else
    log_warn "stylua test failed, but symlinks may still work"
fi
