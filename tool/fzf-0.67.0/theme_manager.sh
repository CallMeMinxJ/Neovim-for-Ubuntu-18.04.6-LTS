#!/bin/bash

# fzf样式切换脚本
# 使用方法: source fzf-style-switch.sh [样式名称]

FZF_STYLES_DIR="${HOME}/.fzf_styles"
CONFIG_FILE="${FZF_STYLES_DIR}/current_style"

# 创建样式目录
mkdir -p "$FZF_STYLES_DIR"

# 定义样式配置
declare -A FZF_STYLES

# 默认样式
FZF_STYLES["default"]="--height 40% --border --reverse"

# full样式（基于您提供的参数）
FZF_STYLES["full"]="--border --padding 1,2 \
  --border-label ' Demo ' --input-label ' Input ' --header-label ' File Type ' \
  --preview 'bat --color=always {} 2>/dev/null || head -100 {}' \
  --bind 'result:transform-list-label: if [[ -z \$FZF_QUERY ]]; then echo \" \$FZF_MATCH_COUNT items \" else echo \" \$FZF_MATCH_COUNT matches for [\$FZF_QUERY] \" fi ' \
  --bind 'focus:transform-preview-label:[[ -n {} ]] && printf \" Previewing [%s] \" {}' \
  --bind 'focus:+transform-header:file --brief {} || echo \"No file selected\"' \
  --bind 'ctrl-r:change-list-label( Reloading the list )+reload(sleep 2; find . -type f)' \
  --color 'border:#aaaaaa,label:#cccccc' \
  --color 'preview-border:#9999cc,preview-label:#ccccff' \
  --color 'list-border:#669966,list-label:#99cc99' \
  --color 'input-border:#996666,input-label:#ffcccc' \
  --color 'header-border:#6699cc,header-label:#99ccff'"

# minimal简约样式
FZF_STYLES["minimal"]="--height 20% --border=rounded --margin=1 \
  --color=bg+:#3b4252,bg:#2e3440,spinner:#81a1c1,hl:#616e88 \
  --color=fg:#d8dee9,header:#616e88,info:#81a1c1,pointer:#81a1c1 \
  --color=marker:#81a1c1,fg+:#d8dee9,prompt:#81a1c1,hl+:#81a1c1"

# nord配色样式
FZF_STYLES["nord"]="--height 40% --border --reverse \
  --color=fg:#d8dee9,bg:#2e3440,hl:#a3be8c,fg+:#d8dee9,bg+:#434c5e,hl+:#a3be8c \
  --color=pointer:#bf616a,info:#4c566a,spinner:#4c566a,header:#4c566a,prompt:#81a1c1,marker:#ebcb8b"

# dark深色样式
FZF_STYLES["dark"]="--height 40% --border=double --reverse \
  --color=dark,fg:#bbbbbb,fg+:#ffffff,bg:#222222,bg+:#333333,hl:#ff9900,hl+:#ffaa00 \
  --color=info:#888888,prompt:#00aaff,pointer:#ff00aa,marker:#ffff00,spinner:#00ffff,header:#888888"

# light浅色样式
FZF_STYLES["light"]="--height 40% --border --reverse \
  --color=light,fg:#000000,fg+:#000000,bg:#ffffff,bg+:#f0f0f0,hl:#0000ff,hl+:#ff0000 \
  --color=info:#888888,prompt:#0000ff,pointer:#ff0000,marker:#00ff00,spinner:#00aaaa,header:#888888"

# 改进的wide宽屏样式 - 修复预览问题
FZF_STYLES["wide"]="--height 100% --layout=reverse --border=sharp --preview-window=right:60%:wrap \
  --preview 'bat --style=numbers --color=always --line-range :300 {} 2>/dev/null || head -300 {}' \
  --color=fg:#eeeeee,bg:#1a1a1a,hl:#00ff00,fg+:#ffffff,bg+:#2a2a2a,hl+:#ffff00 \
  --color=info:#aaaaaa,prompt:#00ffff,pointer:#ff00ff,marker:#ff8800,spinner:#00ff88,header:#8888ff"

# === 新增带预览功能的主题 ===

# material-material主题
FZF_STYLES["material"]="--height 80% --border=rounded --preview-window=right:60%:wrap \
  --preview 'bat --style=numbers --color=always --line-range :200 {} 2>/dev/null || head -200 {}' \
  --color=bg+:#393939,bg:#212121,border:#616161,spinner:#e0e0e0,hl:#ff6e40 \
  --color=fg:#e0e0e9,header:#ff6e40,info:#b0bec5,pointer:#e0e0e0 \
  --color=marker:#e0e0e0,fg+:#ffffff,prompt:#b0bec5,hl+:#ff6e40"

# gruvbox主题
FZF_STYLES["gruvbox"]="--height 60% --border=double --preview-window=right:50%:wrap \
  --preview 'bat --style=numbers --color=always --line-range :150 {} 2>/dev/null || head -150 {}' \
  --color=bg+:#3c3836,bg:#282828,border:#d5c4a1,spinner:#fb4934,hl:#fe8019 \
  --color=fg:#ebdbb2,header:#fe8019,info:#83a598,pointer:#fb4934 \
  --color=marker:#fb4934,fg+:#ebdbb2,prompt:#b8bb26,hl+:#fe8019"

# solarized主题
FZF_STYLES["solarized"]="--height 70% --border --preview-window=right:55%:wrap \
  --preview 'bat --style=numbers --color=always --line-range :180 {} 2>/dev/null || head -180 {}' \
  --color=bg+:#eee8d5,bg:#fdf6e3,border:#93a1a1,spinner:#dc322f,hl:#859900 \
  --color=fg:#657b83,header:#859900,info:#2aa198,pointer:#dc322f \
  --color=marker:#dc322f,fg+:#657b83,prompt:#268bd2,hl+:#859900"

# dracula主题
FZF_STYLES["dracula"]="--height 65% --border=rounded --preview-window=right:50%:wrap \
  --preview 'bat --style=numbers --color=always --line-range :200 {} 2>/dev/null || head -200 {}' \
  --color=bg+:#44475a,bg:#282a36,border:#6272a4,spinner:#ff79c6,hl:#50fa7b \
  --color=fg:#f8f8f2,header:#50fa7b,info:#8be9fd,pointer:#ff79c6 \
  --color=marker:#ff79c6,fg+:#ffffff,prompt:#bd93f9,hl+:#50fa7b"

# monokai主题
FZF_STYLES["monokai"]="--height 60% --border=sharp --preview-window=right:60%:wrap \
  --preview 'bat --style=numbers --color=always --line-range :180 {} 2>/dev/null || head -180 {}' \
  --color=bg+:#49483e,bg:#272822,border:#f92672,spinner:#a6e22e,hl:#fd971f \
  --color=fg:#f8f8f2,header:#fd971f,info:#66d9ef,pointer:#a6e22e \
  --color=marker:#a6e22e,fg+:#ffffff,prompt:#ae81ff,hl+:#fd971f"

# ocean主题
FZF_STYLES["ocean"]="--height 75% --border=rounded --preview-window=right:50%:wrap \
  --preview 'bat --style=numbers --color=always --line-range :220 {} 2>/dev/null || head -220 {}' \
  --color=bg+:#1c2b39,bg:#0c1c2b,border:#4fa6b8,spinner:#6cd9f2,hl:#f9a825 \
  --color=fg:#c8d4e0,header:#f9a825,info:#a1c1d1,pointer:#6cd9f2 \
  --color=marker:#6cd9f2,fg+:#ffffff,prompt:#4fa6b8,hl+:#f9a825"

# forest主题
FZF_STYLES["forest"]="--height 60% --border=double --preview-window=right:45%:wrap \
  --preview 'bat --style=numbers --color=always --line-range :160 {} 2>/dev/null || head -160 {}' \
  --color=bg+:#2d4a2d,bg:#1c2b1c,border:#6a8c6a,spinner:#a8dba8,hl:#f1c40f \
  --color=fg:#d5e6d5,header:#f1c40f,info:#87b787,pointer:#a8dba8 \
  --color=marker:#a8dba8,fg+:#ffffff,prompt:#6a8c6a,hl+:#f1c40f"

# neon主题
FZF_STYLES["neon"]="--height 70% --border=sharp --preview-window=right:55%:wrap \
  --preview 'bat --style=numbers --color=always --line-range :200 {} 2>/dev/null || head -200 {}' \
  --color=bg+:#1a1a2a,bg:#0a0a1a,border:#ff00ff,spinner:#00ffff,hl:#ffff00 \
  --color=fg:#e0e0ff,header:#ffff00,info:#ff00ff,pointer:#00ffff \
  --color=marker:#00ffff,fg+:#ffffff,prompt:#00ff00,hl+:#ffff00"

# 高级预览主题 - 带git状态和文件信息
FZF_STYLES["advanced"]="--height 80% --border=double --preview-window=right:65%:wrap \
  --preview 'echo \"=== 文件信息 ===\"; file {} 2>/dev/null; echo; echo \"=== 文件大小 ===\"; ls -lh {} 2>/dev/null | cut -d\" \" -f5; echo; echo \"=== 修改时间 ===\"; stat -c %y {} 2>/dev/null || stat -f %Sm {} 2>/dev/null; echo; echo \"=== 内容预览 ===\"; bat --style=numbers --color=always --line-range :100 {} 2>/dev/null || head -100 {}' \
  --bind 'ctrl-g:reload(git status -s 2>/dev/null | cut -c4- || find . -type f | head -1000)' \
  --color=bg+:#2a2a3a,bg:#1a1a2a,border:#8a8aff,spinner:#ff8a8a,hl:#8aff8a \
  --color=fg:#d0d0ff,header:#8aff8a,info:#ff8aff,pointer:#ff8a8a \
  --color=marker:#ff8a8a,fg+:#ffffff,prompt:#8a8aff,hl+:#8aff8a"

# 代码专用主题
FZF_STYLES["coder"]="--height 85% --border=rounded --preview-window=right:70%:wrap \
  --preview 'echo \"📁 文件: {}\"; echo \"📊 大小: $(du -h {} 2>/dev/null | cut -f1 || echo Unknown)\"; echo \"📅 修改: $(stat -c %y {} 2>/dev/null | cut -d. -f1 || stat -f %Sm {} 2>/dev/null)\"; echo; echo \"🔍 内容:\"; bat --style=numbers --color=always --line-range :200 {} 2>/dev/null || head -200 {}' \
  --color=bg+:#1e1e2e,bg:#0f0f1f,border:#89b4fa,spinner:#f5c2e7,hl:#a6e3a1 \
  --color=fg:#cdd6f4,header:#a6e3a1,info:#cba6f7,pointer:#f5c2e7 \
  --color=marker:#f5c2e7,fg+:#ffffff,prompt:#89b4fa,hl+:#a6e3a1"

# 帮助信息
show_help() {
    echo "🎨 FZF样式切换脚本"
    echo "用法:"
    echo "  source fzf-style-switch.sh [样式名称]"
    echo "  . fzf-style-switch.sh [样式名称]"
    echo ""
    echo "可用样式:"
    echo "═══════════════════════════════════════════════════"
    printf "%-12s - %s\n" "default" "默认样式"
    printf "%-12s - %s\n" "full" "完整功能样式"
    printf "%-12s - %s\n" "minimal" "简约样式"
    printf "%-12s - %s\n" "nord" "Nord配色"
    printf "%-12s - %s\n" "dark" "深色主题"
    printf "%-12s - %s\n" "light" "浅色主题"
    printf "%-12s - %s\n" "wide" "宽屏布局"
    printf "%-12s - %s\n" "material" "Material设计"
    printf "%-12s - %s\n" "gruvbox" "Gruvbox配色"
    printf "%-12s - %s\n" "solarized" "Solarized配色"
    printf "%-12s - %s\n" "dracula" "Dracula主题"
    printf "%-12s - %s\n" "monokai" "Monokai配色"
    printf "%-12s - %s\n" "ocean" "海洋主题"
    printf "%-12s - %s\n" "forest" "森林主题"
    printf "%-12s - %s\n" "neon" "霓虹主题"
    printf "%-12s - %s\n" "advanced" "高级预览"
    printf "%-12s - %s\n" "coder" "程序员专用"
    echo ""
    echo "当前样式: $(get_current_style)"
    echo ""
    echo "示例:"
    echo "  source fzf-style-switch.sh material    # 切换到material样式"
    echo "  source fzf-style-switch.sh dracula     # 切换到dracula样式"
    echo "  source fzf-style-switch.sh --interactive # 交互式选择"
}

# 获取当前样式
get_current_style() {
    if [[ -f "$CONFIG_FILE" ]]; then
        cat "$CONFIG_FILE"
    else
        echo "default"
    fi
}

# 保存当前样式
save_style() {
    local style="$1"
    echo "$style" > "$CONFIG_FILE"
}

# 应用样式
apply_style() {
    local style_name="$1"

    if [[ -z "${FZF_STYLES[$style_name]}" ]]; then
        echo "❌ 错误: 未知样式 '$style_name'"
        echo "💡 可用样式: ${!FZF_STYLES[@]}" | tr ' ' '\n' | sort | xargs
        return 1
    fi

    # 设置FZF_DEFAULT_OPTS环境变量
    export FZF_DEFAULT_OPTS="${FZF_STYLES[$style_name]}"

    # 保存当前样式
    save_style "$style_name"

    echo "✅ FZF样式已切换为: $style_name"
    echo "🎯 立即生效!"
    
    # 显示样式预览提示
    if [[ "${FZF_STYLES[$style_name]}" == *"--preview"* ]]; then
        echo "💡 此样式支持文件预览功能"
    fi
}

# 显示当前所有样式预览
list_styles() {
    echo "🎨 可用FZF样式:"
    echo "═══════════════════════════════════════════════════"
    
    local current_style=$(get_current_style)
    
    for style in $(echo "${!FZF_STYLES[@]}" | tr ' ' '\n' | sort); do
        local preview_info=""
        if [[ "${FZF_STYLES[$style]}" == *"--preview"* ]]; then
            preview_info="📊"
        fi
        
        if [[ "$style" == "$current_style" ]]; then
            printf "✅ %-15s %s (当前使用)\n" "$style" "$preview_info"
        else
            printf "   %-15s %s\n" "$style" "$preview_info"
        fi
    done
    
    echo ""
    echo "📊 = 支持文件预览"
}

# 交互式选择样式
interactive_select() {
    echo "🎨 选择FZF样式:"
    echo "使用方向键选择，Enter确认"

    local styles=()
    for style in "${!FZF_STYLES[@]}"; do
        styles+=("$style")
    done

    # 使用当前样式配置的fzf来选择样式（使用默认配置避免循环依赖）
    local selected_style
    selected_style=$(printf "%s\n" "${styles[@]}" | sort | fzf --height 40% --prompt="选择样式 > " --preview "echo '样式预览: {}'; echo '========================'; echo '${FZF_STYLES[{}]}'")

    if [[ -n "$selected_style" ]]; then
        apply_style "$selected_style"
    else
        echo "❌ 取消选择"
    fi
}

# 测试预览功能
test_preview() {
    echo "🔍 测试文件预览功能..."
    if command -v bat &> /dev/null; then
        echo "✅ 检测到 bat 命令，预览功能将更美观"
    else
        echo "⚠️  未检测到 bat 命令，使用 head 作为备用预览"
        echo "💡 建议安装 bat: brew install bat 或 sudo apt install bat"
    fi
    
    # 创建一个测试文件列表用于预览
    if [[ -d "/usr/share/doc" ]]; then
        echo "📁 测试文件列表:"
        find /usr/share/doc -type f -name "*.txt" -o -name "README*" | head -5
    fi
}

# 主函数
main() {
    local style_name="$1"

    case "$style_name" in
        ""|"help"|"-h"|"--help")
            show_help
            ;;
        "list"|"-l"|"--list")
            list_styles
            ;;
        "interactive"|"-i"|"--interactive")
            interactive_select
            ;;
        "current"|"-c"|"--current")
            echo "📌 当前样式: $(get_current_style)"
            ;;
        "test"|"--test")
            test_preview
            ;;
        *)
            apply_style "$style_name"
            ;;
    esac
}

# 如果直接运行脚本，显示使用方法
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "❌ 错误: 这个脚本应该用source命令执行"
    echo ""
    echo "✅ 正确用法:"
    echo "  source ${BASH_SOURCE[0]} [样式名称]"
    echo "  . ${BASH_SOURCE[0]} [样式名称]"
    echo ""
    echo "💡 或者将其添加到您的shell配置文件中:"
    echo "  echo 'source ${BASH_SOURCE[0]}' >> ~/.bashrc"
    echo "  echo 'source ${BASH_SOURCE[0]}' >> ~/.zshrc"
    exit 1
fi

# 自动加载当前样式（如果之前设置过）
if [[ -f "$CONFIG_FILE" ]]; then
    current_style=$(get_current_style)
    if [[ -n "${FZF_STYLES[$current_style]}" ]]; then
        export FZF_DEFAULT_OPTS="${FZF_STYLES[$current_style]}"
    fi
fi

# 执行主函数
main "$@"
