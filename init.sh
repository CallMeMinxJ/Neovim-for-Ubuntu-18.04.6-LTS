#!/bin/bash

# =============================================================================
# Neovim 开发环境初始化脚本
# 功能：配置无外网环境的 Neovim 开发环境
# 设计原则：模块化、可维护、优雅的错误处理
# 版本：3.2 - 修复语法错误版本
# =============================================================================

set -euo pipefail  # 严格的安全设置

# =============================================================================
# 初始化配置和常量
# =============================================================================
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"

# 首先定义基础变量，避免 set -u 错误
readonly BIN_DIR="$SCRIPT_DIR/bin"
readonly CONFIG_DIR="$SCRIPT_DIR/nvim"
readonly TOOL_DIR="$SCRIPT_DIR/tool"
readonly NVIM_DIR="$SCRIPT_DIR/app"
readonly CONFIG_FILE="$SCRIPT_DIR/nvim.conf"
readonly BASHRC_FILE="$HOME/.bashrc"
readonly CACHE_DIR="$SCRIPT_DIR/.cache"
readonly LOG_FILE="$SCRIPT_DIR/setup.log"

# 必需的目录结构
readonly REQUIRED_DIRS=("lua" "pack" "plugin" "themes")

# =============================================================================
# 日志和输出系统
# =============================================================================
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_PURPLE='\033[0;35m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_RESET='\033[0m'

# 日志级别
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARNING=2
readonly LOG_LEVEL_ERROR=3

LOG_LEVEL=${LOG_LEVEL:-$LOG_LEVEL_INFO}

log() {
    local level="$1"; shift
    local color="$1"; shift
    local prefix="$1"; shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [[ ${level} -ge ${LOG_LEVEL} ]]; then
        echo -e "${color}[${prefix}]${COLOR_RESET} ${message}" >&2
    fi
    
    # 写入日志文件
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
    echo "  Neovim 开发环境配置系统"
    echo "  版本 3.2 - 修复语法错误版本"
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
# 工具函数
# =============================================================================
create_directory() {
    local dir="${1:-}"
    local description="${2:-未命名目录}"
    
    if [[ -z "$dir" ]]; then
        log_error "create_directory: 目录参数为空"
        return 1
    fi
    
    if [[ ! -d "$dir" ]]; then
        if mkdir -p "$dir" 2>/dev/null; then
            log_success "创建目录: $dir ($description)"
        else
            log_error "无法创建目录: $dir"
            return 1
        fi
    else
        log_debug "目录已存在: $dir"
    fi
    return 0
}

# =============================================================================
# 环境验证系统
# =============================================================================
validate_environment() {
    print_step "验证环境要求"
    
    local missing_dirs=()
    local missing_tools=()
    
    # 检查基础目录
    if [[ ! -d "$CONFIG_DIR" ]]; then
        missing_dirs+=("$CONFIG_DIR (CONFIG_DIR)")
    fi
    if [[ ! -d "$TOOL_DIR" ]]; then
        missing_dirs+=("$TOOL_DIR (TOOL_DIR)")
    fi
    if [[ ! -d "$NVIM_DIR" ]]; then
        missing_dirs+=("$NVIM_DIR (NVIM_DIR)")
    fi
    
    # 检查必要的工具目录
    local required_tools=("clangd-server" "fzf-0.67.0" "lua-server" "ripgrep-15.1.0" "node-v16.20.2-linux-x64")
    for tool_dir in "${required_tools[@]}"; do
        if [[ ! -d "${TOOL_DIR}/$tool_dir" ]]; then
            missing_tools+=("$tool_dir")
        fi
    done
    
    # 检查 Neovim 可执行文件
    if [[ ! -f "${NVIM_DIR}/bin/nvim" ]]; then
        log_error "未找到 Neovim 可执行文件: ${NVIM_DIR}/bin/nvim"
        return 1
    fi
    
    # 报告缺失项
    if [[ ${#missing_dirs[@]} -gt 0 ]]; then
        log_warning "缺失目录:"
        for dir in "${missing_dirs[@]}"; do
            log_warning "  - $dir"
        done
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_warning "缺失工具目录:"
        for tool in "${missing_tools[@]}"; do
            log_warning "  - $tool"
        done
    fi
    
    # 创建必要的目录
    create_directory "${BIN_DIR}" "二进制文件目录"
    create_directory "${CACHE_DIR}" "缓存目录"
    
    if [[ ${#missing_dirs[@]} -eq 0 && ${#missing_tools[@]} -eq 0 ]]; then
        log_success "环境验证通过"
        return 0
    else
        log_warning "环境验证完成，但存在警告"
        return 2
    fi
}

# =============================================================================
# 符号链接管理系统
# =============================================================================
create_symlink() {
    local source="${1:-}"
    local target="${2:-}"
    local description="${3:-未命名链接}"
    
    # 验证参数
    if [[ -z "$source" || -z "$target" ]]; then
        log_error "create_symlink: 源或目标路径为空"
        return 1
    fi
    
    # 验证源文件是否存在且可执行
    if [[ ! -f "$source" ]]; then
        log_warning "源文件不存在: $source"
        return 1
    fi
    
    if [[ ! -x "$source" ]]; then
        if ! chmod +x "$source" 2>/dev/null; then
            log_warning "无法使文件可执行: $source"
            return 1
        fi
    fi
    
    # 处理已存在的目标
    if [[ -e "$target" ]]; then
        if [[ -L "$target" ]]; then
            local current_target=$(readlink "$target" 2>/dev/null || echo "")
            if [[ "$current_target" == "$source" ]]; then
                log_info "符号链接已正确设置: $target -> $source"
                return 0
            else
                log_info "更新符号链接: $target"
                rm -f "$target"
            fi
        else
            rm -rf "$target"
        fi
    fi
    
    # 确保目标目录存在
    local target_dir=$(dirname "$target")
    create_directory "$target_dir" "目标目录"
    
    # 创建符号链接
    if ln -sf "$source" "$target" 2>/dev/null; then
        log_success "创建 $description 符号链接: $target → $source"
        return 0
    else
        log_warning "符号链接创建失败，尝试复制文件"
        if cp "$source" "$target" 2>/dev/null && chmod +x "$target"; then
            log_success "复制 $description: $target"
            return 0
        else
            log_error "无法创建 $description: $target"
            return 1
        fi
    fi
}

# 工具映射配置 - 使用数组而不是关联数组
setup_tool_links() {
    print_step "配置工具符号链接"

    chmod -R +x *
    
    local success_count=0
    local total_count=0
    local failed_tools=()
    
    # 工具映射配置
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
    )
    
    # 首先设置 Neovim
    if create_symlink \
        "${NVIM_DIR}/bin/nvim" \
        "${BIN_DIR}/nvim" \
        "Neovim"; then
        ((success_count++))
    fi
    ((total_count++))
    
    # 处理所有工具映射
    for mapping in "${tool_mappings[@]}"; do
        IFS='|' read -r tool_dir exec_path link_name <<< "$mapping"
        ((total_count++))
        
        local tool_path="${TOOL_DIR}/$tool_dir"
        local executable="$tool_path/$exec_path"
        local link_path="${BIN_DIR}/$link_name"
        
        if [[ ! -d "$tool_path" ]]; then
            log_warning "工具目录不存在: $tool_path"
            failed_tools+=("$link_name (目录不存在)")
            continue
        fi
        
        if create_symlink "$executable" "$link_path" "$link_name"; then
            ((success_count++))
        else
            failed_tools+=("$link_name")
            # 尝试查找替代的可执行文件
            local alternative=$(find "$tool_path" -type f -executable -name "$link_name" 2>/dev/null | head -1)
            if [[ -n "$alternative" ]]; then
                log_info "尝试替代文件: $alternative"
                if create_symlink "$alternative" "$link_path" "$link_name"; then
                    ((success_count++))
                    # 从失败列表中移除
                    for i in "${!failed_tools[@]}"; do
                        if [[ "${failed_tools[i]}" == "$link_name" ]]; then
                            unset 'failed_tools[i]'
                        fi
                    done
                fi
            fi
        fi
    done
    
    # 输出统计信息
    print_divider
    log_info "工具链接统计: $success_count/$total_count 成功"
    if [[ ${#failed_tools[@]} -gt 0 ]]; then
        log_warning "失败的工具:"
        for tool in "${failed_tools[@]}"; do
            [[ -n "$tool" ]] && log_warning "  - $tool"
        done
    fi
    
    if [[ $success_count -eq $total_count ]]; then
        log_success "所有工具链接配置完成"
    else
        log_warning "工具链接配置完成，但存在失败项"
    fi
    return 0
}

# =============================================================================
# 配置文件生成系统
# =============================================================================
generate_module_config() {
    print_step "生成模块化配置文件"
    
    # 备份现有配置文件
    backup_file "$CONFIG_FILE"
    
    # 生成新的配置文件
    cat > "$CONFIG_FILE" << 'EOF'
#!/bin/bash
# =============================================================================
# Neovim 开发环境配置模块
# 此文件由初始化脚本自动生成，请勿手动修改
# =============================================================================

# 检查配置是否已加载
if [[ -n "${NVIM_DEV_CONFIG_LOADED:-}" ]]; then
    return 0
fi

export NVIM_DEV_CONFIG_LOADED=1

# =============================================================================
# 基础路径配置
# =============================================================================
export NVIM_DEV_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="${NVIM_DEV_ROOT}/bin:${PATH}"

# =============================================================================
# XDG 基础目录规范配置
# =============================================================================
export XDG_CONFIG_HOME="${NVIM_DEV_ROOT}"
export XDG_DATA_HOME="${NVIM_DEV_ROOT}/.local/share"
export XDG_CACHE_HOME="${NVIM_DEV_ROOT}/.cache"

# 确保目录存在
mkdir -p "${XDG_DATA_HOME}" "${XDG_CACHE_HOME}" 2>/dev/null || true

# =============================================================================
# 工具路径配置
# =============================================================================
export CLANGD_PATH="${NVIM_DEV_ROOT}/tool/clangd-server/bin/clangd"
export LUA_LANGUAGE_SERVER_PATH="${NVIM_DEV_ROOT}/tool/lua-server/bin/lua-language-server"

# =============================================================================
# 别名定义
# =============================================================================
alias nvim="${NVIM_DEV_ROOT}/bin/nvim"
alias nvim-dev="nvim"
alias nvim-cfg="nvim \"${NVIM_DEV_ROOT}/nvim\""

# 插件管理命令
alias nvim-pack-sync="nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'"
alias nvim-pack-install="nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerInstall'"

# =============================================================================
# 工具函数
# =============================================================================
nvim-dev-info() {
    echo "=== Neovim 开发环境信息 ==="
    echo "根目录: ${NVIM_DEV_ROOT}"
    echo "配置目录: ${XDG_CONFIG_HOME}"
    echo "数据目录: ${XDG_DATA_HOME}"
    echo "缓存目录: ${XDG_CACHE_HOME}"
    echo "Neovim 路径: $(command -v nvim)"
    echo "Neovim 版本: $(nvim --version 2>/dev/null | head -1 || echo '不可用')"
}

nvim-dev-clean() {
    echo "清理 Neovim 开发环境缓存..."
    rm -rf "${XDG_CACHE_HOME}/nvim" "${XDG_DATA_HOME}/nvim" 2>/dev/null
    echo "缓存清理完成"
}

nvim-dev-reload() {
    unset NVIM_DEV_CONFIG_LOADED
    # shellcheck source=/dev/null
    source "${NVIM_DEV_ROOT}/nvim.conf"
    echo "Neovim 开发环境配置已重新加载"
}

# =============================================================================
# 自动完成函数
# =============================================================================
if command -v complete >/dev/null 2>&1; then
    _nvim_dev_commands() {
        local cur prev words cword
        _get_comp_words_by_ref -n : cur prev words cword
        
        local commands="info clean reload"
        case "${cword}" in
            1)
                COMPREPLY=($(compgen -W "${commands}" -- "${cur}"))
                ;;
        esac
    }
    complete -F _nvim_dev_commands nvim-dev- 2>/dev/null || true
fi

EOF
    
    if [[ $? -eq 0 ]]; then
        chmod +x "$CONFIG_FILE"
        log_success "配置文件生成完成: $CONFIG_FILE"
        return 0
    else
        log_error "配置文件生成失败"
        return 1
    fi
}

# =============================================================================
# Shell 集成系统
# =============================================================================
setup_shell_integration() {
    print_step "配置 Shell 集成"
    
    local marker="# NVIM_DEV_CONFIG"
    local marker_end="# END_NVIM_DEV_CONFIG"
    
    # 检查是否已存在配置
    if grep -q "$marker" "$BASHRC_FILE" 2>/dev/null; then
        log_info "发现现有配置，进行更新..."
        
        # 使用临时文件来确保操作原子性
        local temp_file
        temp_file=$(mktemp)
        if sed "/$marker/,/$marker_end/d" "$BASHRC_FILE" > "$temp_file" 2>/dev/null; then
            mv "$temp_file" "$BASHRC_FILE"
            log_success "已移除旧配置"
        else
            log_warning "使用备用方案更新配置"
            grep -v "$marker" "$BASHRC_FILE" > "$temp_file" && mv "$temp_file" "$BASHRC_FILE"
            rm -f "$temp_file"
        fi
    fi
    
    # 添加新配置
    cat >> "$BASHRC_FILE" << EOF

${marker}
# Neovim 开发环境配置
# 此配置由初始化脚本自动生成
if [[ -f "${CONFIG_FILE}" ]]; then
    # shellcheck source=/dev/null
    source "${CONFIG_FILE}"
else
    echo "警告: Neovim 开发环境配置文件不存在: ${CONFIG_FILE}"
    echo "请运行初始化脚本重新配置"
fi
${marker_end}
EOF
    
    if [[ $? -eq 0 ]]; then
        log_success "Shell 集成配置完成"
        return 0
    else
        log_error "Shell 集成配置失败"
        return 1
    fi
}

# =============================================================================
# 运行时验证系统
# =============================================================================
validate_neovim_runtime() {
    print_step "验证 Neovim 运行时配置"
    
    local valid_count=0
    
    for dir in "${REQUIRED_DIRS[@]}"; do
        local dir_path="$CONFIG_DIR/$dir"
        if [[ -d "$dir_path" ]]; then
            local file_count=$(find "$dir_path" \( -name "*.lua" -o -name "*.vim" \) -type f 2>/dev/null | wc -l)
            log_success "目录 $dir: 包含 $file_count 个配置文件"
            ((valid_count++))
        else
            log_warning "目录不存在: $dir"
        fi
    done
    
    if [[ $valid_count -eq ${#REQUIRED_DIRS[@]} ]]; then
        log_success "Neovim 运行时配置验证通过"
    else
        log_warning "Neovim 运行时配置验证完成，但存在缺失目录"
    fi
    return 0
}

# =============================================================================
# 安装验证系统
# =============================================================================
verify_installation() {
    print_step "验证安装结果"
    
    local success_count=0
    local total_count=0
    
    # 测试关键工具
    local critical_tools=("nvim" "fzf" "rg" "clangd" "lua-language-server" "node")
    
    for tool in "${critical_tools[@]}"; do
        ((total_count++))
        local tool_path="${BIN_DIR}/$tool"
        
        if [[ -e "$tool_path" ]]; then
            if [[ -L "$tool_path" ]]; then
                local target=$(readlink "$tool_path" 2>/dev/null || echo "")
                if [[ -e "$target" ]]; then
                    log_success "$tool: 链接有效 -> $target"
                    ((success_count++))
                else
                    log_warning "$tool: 链接目标不存在 -> $target"
                fi
            elif [[ -x "$tool_path" ]]; then
                log_success "$tool: 可执行文件正常"
                ((success_count++))
            else
                log_warning "$tool: 存在但不可执行"
            fi
        else
            log_warning "$tool: 未找到"
        fi
    done
    
    # 测试 Neovim
    if command -v "${BIN_DIR}/nvim" >/dev/null 2>&1; then
        local version=$("${BIN_DIR}/nvim" --version 2>/dev/null | head -1 || echo "未知版本")
        log_success "Neovim 测试通过: $version"
        ((success_count++))
    else
        log_error "Neovim 测试失败"
    fi
    ((total_count++))
    
    # 验证配置文件语法
    if bash -n "${CONFIG_FILE}" 2>/dev/null; then
        log_success "配置文件语法正确"
        ((success_count++))
    else
        log_error "配置文件语法错误"
    fi
    ((total_count++))
    
    print_divider
    log_info "验证统计: $success_count/$total_count 项通过"
    
    if [[ $success_count -eq $total_count ]]; then
        log_success "安装验证完全通过"
        return 0
    else
        log_warning "安装验证完成，但存在警告"
        return 2
    fi
}

# =============================================================================
# 清理系统
# =============================================================================
cleanup_old_config() {
    print_step "清理旧配置"
    
    local old_markers=("# NEOVIM_DEV_ENV" "# XDG_CONFIG_HOME")
    local marker_end_patterns=("# END_NEOVIM_DEV_ENV" "# END_XDG_CONFIG_HOME")
    
    for i in "${!old_markers[@]}"; do
        if grep -q "${old_markers[i]}" "$BASHRC_FILE" 2>/dev/null; then
            log_info "清理旧配置标记: ${old_markers[i]}"
            sed -i "/${old_markers[i]}/,/${marker_end_patterns[i]}/d" "$BASHRC_FILE" 2>/dev/null || true
        fi
    done
    
    log_success "旧配置清理完成"
    return 0
}

# =============================================================================
# 结果展示系统
# =============================================================================
show_results() {
    print_header
    echo -e "${COLOR_GREEN}Neovim 开发环境配置完成！${COLOR_RESET}"
    echo ""
    
    echo -e "${COLOR_CYAN}配置摘要:${COLOR_RESET}"
    echo -e "  ${COLOR_BLUE}• 配置文件:${COLOR_RESET} ${CONFIG_FILE}"
    echo -e "  ${COLOR_BLUE}• 工具目录:${COLOR_RESET} ${BIN_DIR}/"
    echo -e "  ${COLOR_BLUE}• 缓存目录:${COLOR_RESET} ${CACHE_DIR}/"
    echo ""
    
    echo -e "${COLOR_CYAN}使用方法:${COLOR_RESET}"
    echo -e "  ${COLOR_YELLOW}source ~/.bashrc${COLOR_RESET}          # 立即生效"
    echo -e "  或 ${COLOR_YELLOW}source \"${CONFIG_FILE}\"${COLOR_RESET}  # 直接加载配置"
    echo ""
    
    echo -e "${COLOR_CYAN}可用命令:${COLOR_RESET}"
    echo -e "  ${COLOR_GREEN}nvim-dev-info${COLOR_RESET}    # 显示环境信息"
    echo -e "  ${COLOR_GREEN}nvim-dev-clean${COLOR_RESET}   # 清理缓存"
    echo -e "  ${COLOR_GREEN}nvim-dev-reload${COLOR_RESET}  # 重载配置"
    echo -e "  ${COLOR_GREEN}nvim${COLOR_RESET}             # 启动 Neovim"
    echo -e "  ${COLOR_GREEN}nvim-cfg${COLOR_RESET}         # 编辑配置"
    echo ""
    
    echo -e "${COLOR_YELLOW}下一步:${COLOR_RESET}"
    echo -e "  1. 运行 ${COLOR_YELLOW}source ~/.bashrc${COLOR_RESET} 使配置生效"
    echo -e "  2. 运行 ${COLOR_YELLOW}nvim-dev-info${COLOR_RESET} 验证安装"
    echo -e "  3. 运行 ${COLOR_YELLOW}nvim${COLOR_RESET} 启动编辑器测试"
    echo ""
    
    print_divider
}

# =============================================================================
# 主控制系统
# =============================================================================
main() {
    local start_time=$(date +%s)
    
    print_header
    log_info "启动 Neovim 开发环境配置"
    log_info "工作目录: $SCRIPT_DIR"
    log_info "开始时间: $(date)"
    
    # 创建日志目录
    mkdir -p "$(dirname "${LOG_FILE}")" 2>/dev/null || true
    echo "=== Neovim 配置日志 $(date) ===" > "${LOG_FILE}"
    
    # 执行配置步骤
    local steps=(
        "validate_environment"
        "cleanup_old_config" 
        "setup_tool_links"
        "generate_module_config"
        "setup_shell_integration"
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
            log_error "步骤失败: $step (退出码: $exit_code)"
            
            # 根据步骤的重要性决定是否继续
            case "$step" in
                "validate_environment")
                    log_error "环境验证失败，终止执行"
                    return 1
                    ;;
                "setup_tool_links"|"generate_module_config"|"setup_shell_integration")
                    log_error "关键步骤失败，终止执行"
                    return 1
                    ;;
                *)
                    log_warning "非关键步骤失败，继续执行后续步骤..."
                    ;;
            esac
        fi
    done
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    print_divider
    log_info "配置完成: $success_count/${#steps[@]} 个步骤成功"
    log_info "总耗时: ${duration} 秒"
    log_info "完成时间: $(date)"
    
    if [[ $success_count -eq ${#steps[@]} ]]; then
        log_success "所有配置步骤顺利完成"
        show_results
        return 0
    else
        log_warning "配置完成，但存在警告，请检查日志: ${LOG_FILE}"
        show_results
        return 2
    fi
}

# =============================================================================
# 脚本入口点
# =============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # 检查是否在正确目录运行
    if [[ ! -d "${BIN_DIR}" ]]; then
        echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} 请在项目根目录运行此脚本" >&2
        echo -e "当前目录: $(pwd)" >&2
        echo -e "期望包含的目录: ${BIN_DIR}" >&2
        exit 1
    fi
    
    # 执行主函数
    if main "$@"; then
        exit 0
    else
        exit 1
    fi
fi
