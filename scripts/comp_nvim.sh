#!/bin/bash
# neovim_make_build.sh - 使用 Make 编译 Neovim (简化版)

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 脚本变量
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$PROJECT_ROOT/src"
BUILD_DIR="$PROJECT_ROOT/build"
INSTALL_DIR="$PROJECT_ROOT/nvim"
TOOLS_DIR="$PROJECT_ROOT/tools"
CMAKE_DIR="$TOOLS_DIR/cmake-3.27.5-linux-x86_64"
CMAKE_BIN="$CMAKE_DIR/bin/cmake"
BIN_DIR="$PROJECT_ROOT/bin"

# 设置 PATH 环境变量，优先使用本地的 CMake
export PATH="$CMAKE_DIR/bin:$PATH"

# 获取 CPU 核心数
NPROC=$(nproc 2>/dev/null || sysctl -n hw.logicalcpu 2>/dev/null || echo 2)

# 日志函数
log_info() { echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"; }

# 检查依赖工具
check_dependencies() {
    log_info "检查编译依赖工具..."
    
    # 检查本地 CMake
    if [[ ! -f "$CMAKE_BIN" ]]; then
        log_error "未找到本地 CMake: $CMAKE_BIN"
        return 1
    fi
    
    # 验证 CMake 是否可执行
    if [[ ! -x "$CMAKE_BIN" ]]; then
        chmod +x "$CMAKE_BIN"
    fi
    
    # 检查 CMake 版本
    if "$CMAKE_BIN" --version >/dev/null 2>&1; then
        local cmake_version=$("$CMAKE_BIN" --version | head -n1)
        log_success "本地 CMake 可用: $cmake_version"
    else
        log_error "本地 CMake 无法执行"
        return 1
    fi
    
    # 检查其他基本工具
    local missing_tools=()
    for tool in gcc g++ make; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "缺少必要的编译工具: ${missing_tools[*]}"
        return 1
    fi
    
    log_success "所有依赖工具检查通过"
}

# 核心清理函数
clean_build() {
    log_info "开始清理编译产物..."
    
    if [[ -f "$SRC_DIR/Makefile" ]]; then
        log_info "切换到源码目录执行清理..."
        cd "$SRC_DIR"
        
        if make distclean > /dev/null 2>&1; then
            log_success "make distclean 执行完毕"
        else
            log_warning "make distclean 执行有警告，继续手动清理"
        fi
    fi
    
    # 确保构建目录和依赖目录被清除
    local dirs_to_remove=("$BUILD_DIR" "$SRC_DIR/.deps" "$SRC_DIR/build")
    for dir in "${dirs_to_remove[@]}"; do
        if [[ -d "$dir" ]]; then
            log_info "删除目录: $dir"
            rm -rf "$dir"
        fi
    done

    # 清理安装目录中的编译产物
    if [[ -d "$INSTALL_DIR" ]]; then
        log_info "清理 Neovim 安装文件..."
        local to_remove=("bin" "lib" "share" "include")
        for dir in "${to_remove[@]}"; do
            if [[ -d "$INSTALL_DIR/$dir" ]]; then
                rm -rf "$INSTALL_DIR/$dir"
            fi
        done
    fi
    
    # 清理 bin 目录中的软链接
    if [[ -d "$BIN_DIR" ]]; then
        log_info "清理 bin 目录中的软链接..."
        if [[ -L "$BIN_DIR/nvim" ]]; then
            rm -f "$BIN_DIR/nvim"
        fi
    fi
    
    log_success "清理完成"
}

# 准备构建环境
prepare_build() {
    log_info "准备构建环境..."
    
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$BIN_DIR"  # 确保 bin 目录存在
    
    if [[ ! -d "$SRC_DIR" ]]; then
        log_error "源码目录不存在: $SRC_DIR"
        return 1
    fi
    
    if [[ ! -f "$SRC_DIR/CMakeLists.txt" ]]; then
        log_error "在源码目录中未找到 CMakeLists.txt"
        return 1
    fi
    
    log_success "构建环境准备就绪"
}

# 使用 make 编译 Neovim
compile_with_make() {
    log_info "切换到源码目录: $SRC_DIR"
    cd "$SRC_DIR"

    log_info "使用的 CMake 路径: $(which cmake)"
    cmake --version

    log_info "开始编译 Neovim..."
    log_info "编译类型: RelWithDebInfo, 安装路径: $INSTALL_DIR"
    log_info "使用的核心数: $NPROC"
    log_info "这可能需要一些时间，请耐心等待..."

    if make \
	CMAKE_BUILD_TYPE=Release \
        CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$INSTALLED_DIR -DUSE_BUNDLED=ON -DCLIPBOARD_SUPPORT=ON" \
        -j"$NPROC"; then
        log_success "Neovim 编译成功"
    else
        log_error "编译过程失败"
        return 1
    fi

    log_info "安装 Neovim 到指定目录..."
    if make \
        CMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
        install; then
        log_success "Neovim 安装成功"
    else
        log_error "安装过程失败"
        return 1
    fi
}

# 创建软链接到 bin 目录
create_symlinks() {
    log_info "创建软链接到 bin 目录..."
    
    local nvim_bin="$INSTALL_DIR/bin/nvim"
    local symlink_target="$BIN_DIR/nvim"
    
    if [[ ! -f "$nvim_bin" ]]; then
        log_error "Neovim 可执行文件不存在: $nvim_bin"
        return 1
    fi
    
    # 删除已存在的软链接或文件
    if [[ -e "$symlink_target" ]]; then
        rm -f "$symlink_target"
    fi
    
    # 创建软链接
    if ln -s "$nvim_bin" "$symlink_target"; then
        log_success "软链接创建成功: $symlink_target -> $nvim_bin"
    else
        log_error "软链接创建失败"
        return 1
    fi
    
    # 验证软链接
    if [[ -L "$symlink_target" && -x "$symlink_target" ]]; then
        log_info "软链接验证成功"
        log_info "Neovim 版本信息:"
        "$symlink_target" --version | head -n 3
    else
        log_error "软链接验证失败"
        return 1
    fi
}

# 显示使用说明
show_usage() {
    cat << EOF
用法: $0 [选项]
选项:
  无参数    清除编译产物并重新编译安装
  -c, --clean   清理编译产物，恢复到编译前状态
  -h, --help    显示此帮助信息
EOF
}

# 主函数
main() {
    log_info "开始 Neovim 编译流程"
    log_info "项目根目录: $PROJECT_ROOT"
    log_info "源码目录: $SRC_DIR"
    log_info "安装目录: $INSTALL_DIR"
    log_info "bin 目录: $BIN_DIR"

    case "${1:-}" in
        -c|--clean)
            clean_build
            log_success "清理操作完成"
            exit 0
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        "")
            ;;
        *)
            log_error "未知参数: $1"
            show_usage
            exit 1
            ;;
    esac

    # 标准编译流程
    log_info "开始标准编译流程..."

    if ! check_dependencies; then
        log_error "依赖检查失败"
        exit 1
    fi

    clean_build

    if ! prepare_build; then
        log_error "构建环境准备失败"
        exit 1
    fi

    if ! compile_with_make; then
        log_error "编译失败"
        exit 1
    fi

    if ! create_symlinks; then
        log_error "软链接创建失败"
        exit 1
    fi

    log_success "🎉 Neovim 编译安装全部完成！"
    log_info "Neovim 可执行文件已链接到: $BIN_DIR/nvim"
    log_info "您可以将以下路径添加到 PATH 环境变量中使用:"
    log_info "export PATH=\"$BIN_DIR:\$PATH\""
}

trap 'log_error "脚本被用户中断"; exit 1' INT TERM
main "$@"
