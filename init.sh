#!/bin/bash

# =============================================================================
# Neovim 开发环境初始化脚本
# 功能：配置无外网环境的 Neovim 开发环境（模块化版本）
# 作者：AI Assistant  
# 版本：2.0 - 模块化配置管理
# =============================================================================

set -e  # 遇到错误立即退出

# =============================================================================
# 颜色定义和输出函数
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_step() { echo -e "${PURPLE}[STEP]${NC} $1"; }
print_divider() { echo -e "${CYAN}========================================${NC}"; }

# =============================================================================
# 配置变量
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$SCRIPT_DIR/bin"
CONFIG_DIR="$SCRIPT_DIR/nvim"
TOOL_DIR="$SCRIPT_DIR/tool"
NVIM_DIR="$SCRIPT_DIR/app"
CONFIG_FILE="$SCRIPT_DIR/nvim.conf"  # 模块化配置文件
BASHRC_FILE="$HOME/.bashrc"

# =============================================================================
# 检查函数
# =============================================================================
check_requirements() {
    print_step "检查环境要求..."

    local missing_requirements=()

    for dir in "$BIN_DIR" "$CONFIG_DIR" "$TOOL_DIR" "$NVIM_DIR"; do
        [[ ! -d "$dir" ]] && missing_requirements+=("$dir")
    done

    local required_tools=("clangd-server" "fzf-0.67.0" "lua-server" "ripgrep-15.1.0")
    for tool in "${required_tools[@]}"; do
        [[ ! -d "$TOOL_DIR/$tool" ]] && [[ ! -f "$TOOL_DIR/$tool" ]] && missing_requirements+=("$TOOL_DIR/$tool")
    done

    if [[ ${#missing_requirements[@]} -gt 0 ]]; then
        print_error "缺少必要的文件或目录:"
        for item in "${missing_requirements[@]}"; do echo "  - $item"; done
        exit 1
    fi

    [[ ! -f "$NVIM_DIR/bin/nvim" ]] && { print_error "未找到 Neovim 可执行文件"; exit 1; }

    # 检查配置文件结构
    local required_config_dirs=("lua" "pack" "plugin" "plugins" "themes")
    for config_dir in "${required_config_dirs[@]}"; do
        [[ ! -d "$CONFIG_DIR/$config_dir" ]] && print_warning "配置目录不存在: $CONFIG_DIR/$config_dir"
    done

    print_success "环境检查通过"
}

# =============================================================================
# 查找可执行文件函数
# =============================================================================
find_executable() {
    local tool_dir="$1"
    local preferred_name="$2"

    # 优先检查首选路径
    if [[ -n "$preferred_name" ]]; then
        local preferred_paths=("$tool_dir/$preferred_name" "$tool_dir/bin/$preferred_name")
        for path in "${preferred_paths[@]}"; do
            [[ -f "$path" && -x "$path" ]] && { echo "$path"; return 0; }
        done
    fi

    # 搜索可执行文件
    local executables=($(find "$tool_dir" -type f -executable ! -name "*.so" ! -name "*.dll" ! -name "*.a" 2>/dev/null || true))
    [[ ${#executables[@]} -eq 0 ]] && return 1

    # 优先选择无扩展名的文件
    for exec in "${executables[@]}"; do
        [[ ! "$(basename "$exec")" =~ \. ]] && { echo "$exec"; return 0; }
    done

    echo "${executables[0]}"
    return 0
}

# =============================================================================
# 创建符号链接函数
# =============================================================================
create_symlink() {
    local source="$1"
    local target="$2"
    local description="$3"

    if [[ -e "$target" ]]; then
        if [[ -L "$target" ]]; then
            print_warning "符号链接已存在: $target，重新创建"
            rm "$target"
        else
            print_warning "文件已存在: $target，备份为 $target.bak"
            mv "$target" "$target.bak"
        fi
    fi

    if ln -sf "$source" "$target" 2>/dev/null; then
        print_success "创建 $description 符号链接: $target → $source"
    else
        print_warning "符号链接创建失败，尝试复制文件"
        cp -r "$source" "$target" 2>/dev/null && print_success "复制 $description: $target" || {
            print_error "无法创建 $description: $target"; return 1;
        }
    fi
}

# =============================================================================
# 配置工具符号链接
# =============================================================================
setup_tool_links() {
    print_step "配置工具符号链接..."

    mkdir -p "$BIN_DIR"

    # Neovim
    create_symlink "$NVIM_DIR/bin/nvim" "$BIN_DIR/nvim" "Neovim"

    # 工具配置
    declare -A tools=(
        ["clangd-server"]="clangd"
        ["fzf-0.67.0"]="fzf"
        ["lua-server"]="lua-language-server"
        ["ripgrep-15.1.0"]="rg"
    )

    declare -A tool_executables=(
        ["clangd-server"]="bin/clangd"
        ["fzf-0.67.0"]="fzf"
        ["lua-server"]="bin/lua-language-server"
        ["ripgrep-15.1.0"]="rg"
    )

    for tool_dir in "${!tools[@]}"; do
        local tool_path="$TOOL_DIR/$tool_dir"
        local link_name="$BIN_DIR/${tools[$tool_dir]}"
        local preferred_exec="${tool_executables[$tool_dir]}"

        [[ ! -d "$tool_path" ]] && [[ ! -f "$tool_path" ]] && {
            print_warning "工具目录不存在: $tool_path"; continue;
        }

        local executable=$(find_executable "$tool_path" "$preferred_exec")

        if [[ -n "$executable" ]]; then
            chmod +x "$executable" 2>/dev/null || true
            create_symlink "$executable" "$link_name" "${tools[$tool_dir]}"
        else
            print_warning "在 $tool_dir 中未找到可执行文件"
            [[ -f "$tool_path" && -x "$tool_path" ]] && create_symlink "$tool_path" "$link_name" "${tools[$tool_dir]}"
        fi
    done

    print_success "工具符号链接配置完成"
}

# =============================================================================
# 创建模块化配置文件
# =============================================================================
create_module_config() {
    print_step "创建模块化配置文件..."

    # 删除已存在的配置文件
    [[ -f "$CONFIG_FILE" ]] && {
        print_warning "配置文件已存在，重新创建"
        rm "$CONFIG_FILE"
    }

    # 创建配置文件内容
    cat > "$CONFIG_FILE" << 'EOF'
# =============================================================================
# Neovim 开发环境配置模块
# 此文件由初始化脚本自动生成，请勿手动修改
# =============================================================================

# 检查配置是否已加载
if [[ -n "$NVIM_DEV_CONFIG_LOADED" ]]; then
    return 0
fi

export NVIM_DEV_CONFIG_LOADED=1

# =============================================================================
# 基础路径配置
# =============================================================================
export NVIM_DEV_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$NVIM_DEV_ROOT/bin:$PATH"

# =============================================================================
# XDG 基础目录规范配置
# =============================================================================
export XDG_CONFIG_HOME="$NVIM_DEV_ROOT"
export XDG_DATA_HOME="$NVIM_DEV_ROOT/.local/share"
export XDG_CACHE_HOME="$NVIM_DEV_ROOT/.cache"

# 确保目录存在
mkdir -p "$XDG_DATA_HOME" "$XDG_CACHE_HOME" 2>/dev/null || true

# =============================================================================
# 工具路径配置
# =============================================================================
export CLANGD_PATH="$NVIM_DEV_ROOT/tool/clangd-server/bin/clangd"
export LUA_LANGUAGE_SERVER_PATH="$NVIM_DEV_ROOT/tool/lua-server/bin/lua-language-server"

# =============================================================================
# 别名定义
# =============================================================================
alias nvim="$NVIM_DEV_ROOT/bin/nvim"
alias nvim-dev="nvim"
alias nvim-cfg="nvim \$NVIM_DEV_ROOT/nvim"

# Packer 插件管理相关命令
alias nvim-pack-sync="nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'"
alias nvim-pack-install="nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerInstall'"
alias nvim-pack-update="nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerUpdate'"

# =============================================================================
# 工具函数
# =============================================================================
nvim-dev-info() {
    echo "=== Neovim 开发环境信息 ==="
    echo "根目录: $NVIM_DEV_ROOT"
    echo "配置目录: $XDG_CONFIG_HOME"
    echo "数据目录: $XDG_DATA_HOME"
    echo "缓存目录: $XDG_CACHE_HOME"
    echo "Neovim 路径: $(which nvim)"
    echo "Neovim 版本: $(nvim --version 2>/dev/null | head -1 || echo '不可用')"
}

nvim-dev-clean() {
    echo "清理 Neovim 开发环境缓存..."
    rm -rf "$XDG_CACHE_HOME/nvim"
    rm -rf "$XDG_DATA_HOME/nvim"
    echo "缓存清理完成"
}

nvim-dev-reload() {
    unset NVIM_DEV_CONFIG_LOADED
    source "$NVIM_DEV_ROOT/$(basename "${BASH_SOURCE[0]}")"
    echo "Neovim 开发环境配置已重新加载"
}

# =============================================================================
# 自动完成函数（可选）
# =============================================================================
if command -v complete >/dev/null 2>&1; then
    _nvim_dev_commands() {
        local cur prev words cword
        _get_comp_words_by_ref -n : cur prev words cword
        
        local commands="info clean reload"
        case "${cword}" in
            1)
                COMPREPLY=($(compgen -W "$commands" -- "$cur"))
                ;;
        esac
    }
    complete -F _nvim_dev_commands nvim-dev- 2>/dev/null || true
fi

EOF

    # 替换配置文件中的路径变量
    sed -i "s|\\\$NVIM_DEV_ROOT|$SCRIPT_DIR|g" "$CONFIG_FILE"

    chmod +x "$CONFIG_FILE"
    print_success "模块化配置文件创建完成: $CONFIG_FILE"
}

# =============================================================================
# 配置 Bashrc 加载
# =============================================================================
setup_bashrc_integration() {
    print_step "配置 Bashrc 集成..."

    local marker="# NVIM_DEV_CONFIG"
    local marker_end="# END_NVIM_DEV_CONFIG"

    # 删除旧配置（如果存在）
    if grep -q "$marker" "$BASHRC_FILE" 2>/dev/null; then
        print_warning "检测到旧配置，正在更新..."
        sed -i "/$marker/,/$marker_end/d" "$BASHRC_FILE" 2>/dev/null || {
            print_warning "sed 操作失败，使用备份方案"
            grep -v "$marker" "$BASHRC_FILE" > "$BASHRC_FILE.tmp" && 
            mv "$BASHRC_FILE.tmp" "$BASHRC_FILE"
        }
    fi

    # 添加新配置
    cat >> "$BASHRC_FILE" << EOF

$marker
# Neovim 开发环境配置
# 此配置由初始化脚本自动生成
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "警告: Neovim 开发环境配置文件不存在: $CONFIG_FILE"
    echo "请运行初始化脚本重新配置"
fi
$marker_end
EOF

    print_success "Bashrc 集成配置完成"
}

# =============================================================================
# 配置 Neovim 运行时路径
# =============================================================================
setup_neovim_runtime() {

    # 验证配置目录结构
    print_info "验证 Neovim 配置目录结构..."

    local expected_dirs=("lua" "pack" "plugin" "plugins" "themes")
    for dir in "${expected_dirs[@]}"; do
        if [[ -d "$CONFIG_DIR/$dir" ]]; then
            local file_count=$(find "$CONFIG_DIR/$dir" -name "*.lua" -o -name "*.vim" | wc -l)
            print_success "目录 $dir: 包含 $file_count 个配置文件"
        else
            print_warning "目录 $dir 不存在"
        fi
    done
}

# =============================================================================
# 验证安装
# =============================================================================
verify_installation() {
    print_step "验证安装..."

    # 检查工具符号链接
    local tools=("nvim" "fzf" "rg" "clangd" "lua-language-server")
    for tool in "${tools[@]}"; do
        local tool_path="$BIN_DIR/$tool"
        if [[ -e "$tool_path" ]]; then
            if [[ -L "$tool_path" ]]; then
                local target=$(readlink "$tool_path")
                print_success "$tool: $tool_path → $target"
            else
                print_success "$tool: $tool_path"
            fi
        else
            print_warning "$tool 未找到在 $BIN_DIR 中"
        fi
    done

    # 测试 Neovim
    if "$BIN_DIR/nvim" --version >/dev/null 2>&1; then
        local nvim_version=$("$BIN_DIR/nvim" --version | head -1)
        print_success "Neovim 可用: $nvim_version"
    else
        print_warning "Neovim 无法执行"
    fi

    # 验证配置文件
    if [[ -f "$CONFIG_FILE" ]]; then
        print_success "模块化配置文件存在: $CONFIG_FILE"
        # 测试配置文件语法
        if bash -n "$CONFIG_FILE" 2>/dev/null; then
            print_success "配置文件语法正确"
        else
            print_warning "配置文件语法检查失败"
        fi
    else
        print_error "模块化配置文件不存在"
    fi

    # 验证 Bashrc 集成
    if grep -q "source.*$(basename "$CONFIG_FILE")" "$BASHRC_FILE"; then
        print_success "Bashrc 集成配置正确"
    else
        print_warning "Bashrc 集成配置可能有问题"
    fi
}

# =============================================================================
# 显示使用说明
# =============================================================================
show_usage() {
    print_divider
    echo -e "${GREEN}Neovim 开发环境配置完成！${NC}"
    echo ""
    echo -e "${CYAN}模块化配置特性：${NC}"
    echo -e "  • 配置集中在 ${YELLOW}$(basename "$CONFIG_FILE")${NC} 文件中"
    echo -e "  • 易于维护和版本控制"
    echo -e "  • 支持动态重载配置"
    echo ""
    echo -e "${CYAN}立即生效命令：${NC}"
    echo -e "  ${YELLOW}source ~/.bashrc${NC}"
    echo -e "  或 ${YELLOW}source \"$CONFIG_FILE\"${NC}"
    echo ""
    echo -e "${CYAN}新增工具函数：${NC}"
    echo "  nvim-dev-info      # 显示环境信息"
    echo "  nvim-dev-clean     # 清理缓存"
    echo "  nvim-dev-reload    # 重载配置"
    echo ""
    echo -e "${CYAN}传统命令仍然可用：${NC}"
    echo "  nvim               # 启动 Neovim"
    echo "  nvim-dev           # 同 nvim"
    echo "  nvim-cfg           # 编辑配置"
    echo "  nvim-pack-sync     # 同步插件"
    echo ""
    echo -e "${CYAN}验证命令：${NC}"
    echo "  nvim-dev-info"
    echo "  nvim --version"
    echo "  echo \$XDG_CONFIG_HOME"
    echo "  echo \$NVIM_DEV_ROOT"
    print_divider
}

# =============================================================================
# 清理函数（用于卸载）
# =============================================================================
cleanup_old_config() {
    print_step "清理旧配置..."

    # 清理旧的直接写入 bashrc 的配置
    local old_markers=("# NEOVIM_DEV_ENV" "# XDG_CONFIG_HOME")
    local marker_end_patterns=("# END_NEOVIM_DEV_ENV" "# END_XDG_CONFIG_HOME")
    
    for i in "${!old_markers[@]}"; do
        if grep -q "${old_markers[i]}" "$BASHRC_FILE" 2>/dev/null; then
            print_warning "清理旧配置标记: ${old_markers[i]}"
            sed -i "/${old_markers[i]}/,/${marker_end_patterns[i]}/d" "$BASHRC_FILE" 2>/dev/null || true
        fi
    done

    print_success "旧配置清理完成"
}

# =============================================================================
# 主函数
# =============================================================================
main() {
    print_divider
    echo -e "${GREEN}开始配置 Neovim 开发环境（模块化版本）${NC}"
    echo -e "工作目录: ${CYAN}$SCRIPT_DIR${NC}"
    echo -e "配置目录: ${CYAN}$CONFIG_DIR${NC}"
    echo -e "配置文件: ${CYAN}$CONFIG_FILE${NC}"
    print_divider

    check_requirements
    cleanup_old_config      # 清理旧配置
    setup_tool_links
    create_module_config    # 创建模块化配置文件
    setup_bashrc_integration # 配置 bashrc 集成
    setup_neovim_runtime
    verify_installation
    show_usage

    print_success "模块化配置完成！"
    echo ""
    print_info "配置摘要："
    echo -e "  ${CYAN}主配置:${NC} $CONFIG_FILE"
    echo -e "  ${CYAN}Bashrc 集成:${NC} 已添加 source 命令"
    echo -e "  ${CYAN}工具链接:${NC} $BIN_DIR/"
    echo ""
    print_warning "请运行以下命令使配置立即生效："
    echo -e "  ${YELLOW}source ~/.bashrc${NC}"
    echo -e "  或 ${YELLOW}source \"$CONFIG_FILE\"${NC}"
}

# =============================================================================
# 脚本入口
# =============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    [[ ! -d "$BIN_DIR" ]] && {
        print_error "请在项目根目录运行此脚本"
        echo "当前目录: $(pwd)"
        exit 1
    }
    main "$@"
fi
