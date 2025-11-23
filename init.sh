#!/bin/bash

# =============================================================================
# Neovim 开发环境初始化脚本
# 功能：配置无外网环境的 Neovim 开发环境
# 作者：AI Assistant
# 版本：1.2 - 简化版
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
CONFIG_DIR="$SCRIPT_DIR/config"
TOOL_DIR="$SCRIPT_DIR/tool"
NVIM_DIR="$SCRIPT_DIR/nvim"

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
# 配置环境变量
# =============================================================================
setup_environment() {
    print_step "配置环境变量..."
    
    local bashrc_file="$HOME/.bashrc"
    local marker="# NEOVIM_DEV_ENV"
    local marker_end="# END_NEOVIM_DEV_ENV"
    
    # 删除旧配置（如果存在）
    if grep -q "$marker" "$bashrc_file" 2>/dev/null; then
        print_warning "环境变量已配置，正在更新..."
        sed -i "/$marker/,/$marker_end/d" "$bashrc_file" 2>/dev/null || true
    fi
    
    # 添加新配置
    cat >> "$bashrc_file" << EOF

$marker
# Neovim 开发环境配置
export NVIM_DEV_ROOT="$SCRIPT_DIR"
export PATH="\$NVIM_DEV_ROOT/bin:\$PATH"
export NVIM_APPNAME="nvim-dev"

# Neovim 相关别名
alias nvim-dev="NVIM_APPNAME=nvim-dev \$NVIM_DEV_ROOT/bin/nvim"
alias nvim-cfg="nvim-dev \$NVIM_DEV_ROOT/config"

# 工具配置
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git/'"
export FZF_CTRL_T_COMMAND="\$FZF_DEFAULT_COMMAND"

# 主命令别名
alias nvim="NVIM_APPNAME=nvim-dev \$NVIM_DEV_ROOT/bin/nvim"
$marker_end
EOF
    
    print_success "环境变量配置完成"
}

# =============================================================================
# 配置 Neovim 环境
# =============================================================================
setup_neovim_config() {
    print_step "配置 Neovim 环境..."
    
    local xdg_config_dir="$HOME/.config/nvim-dev"
    mkdir -p "$(dirname "$xdg_config_dir")"
    
    # 创建配置目录符号链接
    [[ -L "$xdg_config_dir" || -d "$xdg_config_dir" ]] && rm -rf "$xdg_config_dir" 2>/dev/null || true
    ln -sf "$CONFIG_DIR" "$xdg_config_dir"
    
    print_success "创建 Neovim 配置链接: $xdg_config_dir → $CONFIG_DIR"
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
    
    # 检查配置链接
    if [[ -L "$HOME/.config/nvim-dev" ]]; then
        local config_target=$(readlink "$HOME/.config/nvim-dev")
        print_success "Neovim 配置目录链接: $HOME/.config/nvim-dev → $config_target"
    else
        print_warning "Neovim 配置目录链接未创建"
    fi
    
    # 测试 Neovim
    if "$BIN_DIR/nvim" --version >/dev/null 2>&1; then
        local nvim_version=$("$BIN_DIR/nvim" --version | head -1)
        print_success "Neovim 可用: $nvim_version"
    else
        print_warning "Neovim 无法执行"
    fi
}

# =============================================================================
# 显示使用说明
# =============================================================================
show_usage() {
    print_divider
    echo -e "${GREEN}Neovim 开发环境配置完成！${NC}"
    echo ""
    echo -e "${CYAN}立即生效命令：${NC}"
    echo -e "  ${YELLOW}source ~/.bashrc${NC}"
    echo ""
    echo -e "${CYAN}使用方法：${NC}"
    echo "  nvim          # 启动 Neovim"
    echo "  nvim-dev      # 同 nvim"
    echo "  nvim-cfg      # 编辑配置"
    echo ""
    echo -e "${CYAN}验证命令：${NC}"
    echo "  nvim --version"
    echo "  which nvim"
    echo "  which rg"
    print_divider
}

# =============================================================================
# 主函数
# =============================================================================
main() {
    print_divider
    echo -e "${GREEN}开始配置 Neovim 开发环境${NC}"
    echo -e "工作目录: ${CYAN}$SCRIPT_DIR${NC}"
    print_divider
    
    check_requirements
    setup_tool_links
    setup_environment
    setup_neovim_config
    verify_installation
    show_usage
    
    print_success "配置完成！"
    echo ""
    print_warning "请运行以下命令使配置立即生效："
    echo -e "  ${YELLOW}source ~/.bashrc${NC}"
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
