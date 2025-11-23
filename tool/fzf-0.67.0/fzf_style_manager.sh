#!/bin/bash

# 增强版fzf样式管理器脚本
# 功能：切换并永久保存fzf样式，支持恢复默认样式，配置与脚本同级

# 关键修改：配置文件与脚本位于同级目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
CONFIG_FILE="${SCRIPT_DIR}/.fzf_style.conf" # 配置文件放在脚本同级目录，并为隐藏文件

# 定义样式库
declare -A STYLES=(
    # 1. 现代深灰主题 - 沉稳专业
    ["modern-dark"]="--height=40% --layout=reverse --border=rounded --margin=3%,1% --pointer='▸' --marker='▪' --color='dark,fg:#e5e5e5,bg+:#333333,bg:#1a1a1a,hl:#8ec07c,hl+:#83a598,info:#d3869b,prompt:#fabd2f,pointer:#fe8019,marker:#fb4934,spinner:#b8bb26,header:#458588'"

    # 2. 柔和护眼主题 - 长时间使用舒适
    ["nord-soft"]="--height=40% --layout=reverse --border=sharp --padding=1,3 --color='fg:#d8dee9,bg:#2e3440,bg+:#3b4252,hl:#81a1c1,hl+:#88c0d0,info:#b48ead,prompt:#8fbcbb,pointer:#8fbcbb,marker:#a3be8c,header:#5e81ac,border:#4c566a'"

    # 3. 蓝调专业主题 - 代码工作优选
    ["blue-professional"]="--height=45% --layout=reverse-list --border=double --pointer='→' --marker='✓' --color='fg:#c8d1de,bg:#1c2128,bg+:#2a303c,hl:#5e81ac,hl+:#81a1c1,info:#d08770,prompt:#a3be8c,pointer:#bf616a,marker:#ebcb8b,border:#4c566a,query:#c8d1de'"

    # 4. 单色极简主题 - 极致简约
    ["monochrome"]="--height=35% --layout=reverse --border=horizontal --info=hidden --pointer='›' --color='fg:7,bg:0,hl:15,hl+:15,marker:15,pointer:15,prompt:7,border:8'"

    # 5. 深紫渐变主题 - 优雅独特
    ["deep-purple"]="--height=40% --layout=reverse --border=rounded --padding=2,4 --pointer='✦' --marker='◈' --color='fg:#e2d9f2,bg:#1a102b,bg+:#2d1b4a,hl:#bb9af7,hl+:#c8b4f7,info:#7dcfff,prompt:#9ece6a,pointer:#f7768e,marker:#ff9e64,header:#7aa2f7,border:#565f89'"

    # 6. 石墨灰主题 - 商务风格
    ["graphite"]="--height=42% --layout=reverse --border=sharp --margin=2%,2% --pointer='▶' --marker='•' --color='fg:#d4d4d4,bg:#1f1f1f,bg+:#2a2a2a,hl:#8f8f8f,hl+:#a8a8a8,info:#afaf87,prompt:#87af87,pointer:#d7875f,marker:#d7af5f,border:#5f5f5f'"

    # 7. 森林绿主题 - 清新自然
    ["forest"]="--height=40% --layout=reverse --border=rounded --pointer='➤' --marker='◉' --color='fg:#d8e6c8,bg:#1a2a1a,bg+:#2a3a2a,hl:#81c784,hl+:#a5d6a7,info:#ffb74d,prompt:#4db6ac,pointer:#ff8a65,marker:#fff176,header:#7986cb,border:#455a64'"

    # 8. 午夜蓝主题 - 深邃宁静
    ["midnight-blue"]="--height=45% --layout=reverse-list --border=double --padding=1,2 --pointer='▷' --marker='○' --color='fg:#b0c4de,bg:#0f1a2a,bg+:#1a2b3c,hl:#6a93c7,hl+:#8fa8d7,info:#d4a1e7,prompt:#a1e7d4,pointer:#e7a1a1,marker:#e7d4a1,header:#93c76a,border:#3c5a7d'"

    # 9. 暖灰主题 - 阅读友好
    ["warm-gray"]="--height=38% --layout=reverse --border=top --padding=1 --pointer='❯' --marker='•' --color='fg:#e0d8d0,bg:#2a2622,bg+:#3a3632,hl:#d4b88c,hl+:#e4c89c,info:#d4b88c,prompt:#a8c8a0,pointer:#c8a8a0,marker:#a0a8c8,header:#b8a4d8,border:#5a5652'"

    # 10. 现代化扁平主题 - 简洁明快
    ["flat-modern"]="--height=40% --layout=reverse --border=block --padding=0 --pointer='⮞' --marker='☑' --color='fg:#333333,bg:#f5f5f5,bg+:#e0e0e0,hl:#4285f4,hl+:#34a853,info:#ea4335,prompt:#fbbc05,pointer:#ea4335,marker:#34a853,header:#4285f4,border:#dadce0'"

    # 11. github 首页
    ["hbase-dashboard"]="--height=50% --layout=reverse --border=sharp --info=right --pointer='▶' --marker='●' --color='fg:#e0e0e0,bg:#0d1117,bg+:#161b22,hl:#3fb950,hl+:#3fb950,fg+:#ffffff,query:#e0e0e0,info:#8b949e,prompt:#3fb950,pointer:#3fb950,marker:#3fb950,border:#30363d,header:#8b949e,gutter:#0d1117' --preview='if [ -d {} ]; then tree -C {} | head -100; elif [ -f {} ]; then bat --style=numbers --color=always {} 2>/dev/null || head -n 50 {}; else echo {}; fi' --preview-window='right:60%:wrap' --bind='?:toggle-preview'"
)

# 应用样式函数
apply_style() {
    local style_name="$1"
    local style_opts="${STYLES[$style_name]}"

    if [[ -z "$style_opts" ]]; then
        echo "错误：未知样式 '$style_name'"
        return 1
    fi

    # 将样式配置写入与脚本同级的配置文件
    echo "export FZF_DEFAULT_OPTS=\"$style_opts\"" > "$CONFIG_FILE"
    echo "✅ 已永久切换到样式: $style_name"
    echo "📁 配置文件位置: $CONFIG_FILE"

    # 尝试在当前shell中立即生效（如果脚本是source执行的）
    if [[ ${BASH_SOURCE[0]} != "${0}" ]]; then
        export FZF_DEFAULT_OPTS="$style_opts"
        echo "💡 提示：当前会话的fzf样式已更新。"
    else
        echo "💡 提示：请执行 'source $CONFIG_FILE' 或重新打开终端以使新样式生效。"
    fi

    # 调用函数，确保shell配置文件中包含了自动加载代码
    setup_auto_load
}

# 恢复默认样式函数
reset_to_default() {
    if [[ -f "$CONFIG_FILE" ]]; then
        rm -f "$CONFIG_FILE"
        echo "✅ 已删除样式配置文件，恢复fzf默认行为。"
    else
        echo "ℹ️  未检测到自定义样式配置文件，fzf已为默认状态。"
    fi
    
    # 从当前shell环境中移除变量（如果脚本是source执行的）
    if [[ ${BASH_SOURCE[0]} != "${0}" ]]; then
        unset FZF_DEFAULT_OPTS 2>/dev/null
        echo "💡 提示：当前会话的fzf已恢复默认样式。"
    fi
}

# 显示当前样式函数
show_current_style() {
    if [[ -f "$CONFIG_FILE" ]]; then
        echo "当前生效的fzf样式配置 (来自: $CONFIG_FILE)："
        cat "$CONFIG_FILE"
    else
        echo "当前使用fzf默认样式。"
    fi
}

# 核心新增函数：智能配置自动加载
setup_auto_load() {
    local shell_rc_file=""
    local auto_load_snippet="# Auto-load fzf style configuration - Managed by $SCRIPT_NAME
if [[ -f \"$CONFIG_FILE\" ]]; then
    source \"$CONFIG_FILE\"
fi
# End of auto-load snippet"

    # 确定使用的shell和其配置文件
    if [[ -n "$BASH_VERSION" ]]; then
        shell_rc_file="$HOME/.bashrc"
    elif [[ -n "$ZSH_VERSION" ]]; then
        shell_rc_file="$HOME/.zshrc"
    else
        echo "⚠️  无法自动确定shell类型，请手动将以下代码添加到您的shell配置文件中:"
        echo "$auto_load_snippet"
        return 1
    fi

    # 检查配置代码块是否已存在
    if grep -q "Auto-load fzf style configuration - Managed by $SCRIPT_NAME" "$shell_rc_file" 2>/dev/null; then
        echo "ℹ️  自动加载配置已存在于 $shell_rc_file"
    else
        # 不存在则追加
        echo "$auto_load_snippet" >> "$shell_rc_file"
        echo "✅ 已为您的shell ($shell_rc_file) 添加自动加载配置，新终端会话将自动应用样式。"
        echo "💡 要使当前会话立即生效，请执行: source $shell_rc_file"
    fi
}

# 显示帮助信息
show_help() {
    cat << EOF
用法: source $SCRIPT_NAME [样式名称 | --reset | --current | --setup | --help]

这是一个fzf样式管理器，可以交互式或直接切换fzf样式，并使选择永久生效。

选项：
    [无参数]          进入交互式样式选择界面
    <样式名称>        直接切换到指定样式（如：minimal, practical等）
    --reset, -r      恢复fzf的默认样式
    --current, -c    显示当前生效的样式配置
    --setup          检查并修复shell配置文件的自动加载功能
    --help, -h       显示此帮助信息

可用的样式名称：
    minimal         极简风格 (布局紧凑，视觉干扰少)
    practical       实用风格 (带预览，适合文件浏览) [推荐]
    high-contrast   高对比度 (视觉突出)
    solarized-dark  Solarized 深色主题
    custom-ptr      自定义指针和标记

示例：
    source $SCRIPT_NAME practical      # 直接切换到实用风格
    source $SCRIPT_NAME --reset         # 恢复默认样式

注意：请使用 'source' 命令执行此脚本，以使样式在当前会话立即生效。
EOF
}

# 主逻辑
main() {
    # 如果配置文件已存在，则加载它（适用于当前会话）
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE" 2>/dev/null
    fi

    case "$1" in
        "--reset"|"-r")
            reset_to_default
            ;;
        "--current"|"-c")
            show_current_style
            ;;
        "--setup")
            setup_auto_load
            ;;
        "--help"|"-h")
            show_help
            ;;
        "")
            # 交互式选择模式
            echo "请选择要切换的fzf样式："
            echo "当前样式: $([ -f "$CONFIG_FILE" ] && echo "自定义" || echo "默认")"
            echo "配置文件: $CONFIG_FILE"
            echo
            
            # 生成选择列表
            selected_style=$(printf "%s\n" "${!STYLES[@]}" | fzf --height 40% --layout=reverse --border --prompt="选择样式 > ")
            
            if [[ -n "$selected_style" ]]; then
                apply_style "$selected_style"
            else
                echo "操作已取消。"
            fi
            ;;
        *)
            # 直接指定样式名
            if [[ -n "${STYLES[$1]}" ]]; then
                apply_style "$1"
            else
                echo "错误：未知样式 '$1'"
                echo "使用 'source $SCRIPT_NAME --help' 查看可用选项。"
                return 1
            fi
            ;;
    esac
}

# 如果脚本被source执行，则运行主函数；如果直接执行，则提示正确用法
if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    echo "注意：请使用 'source ${BASH_SOURCE[0]}' 命令来执行此脚本，以便样式在当前会话立即生效。"
    echo "直接运行 ./${BASH_SOURCE[0]} 不会在当前会话中永久应用样式。"
    echo "如需更多信息，请执行: source ${BASH_SOURCE[0]} --help"
else
    main "$@"
fi
