<div align="center">

  <img src="https://github.com/Astor-Zore/NeovimZero/blob/lsp-migration/assert/logo.png" alt="NvimZero" width="300" style="border-radius: 30px; margin-bottom: 10px;">
  
  <h1><strong>⚡ NeovimZero ⚡</strong></h1>
  <p><em>开箱即用 · 离线部署 · 插件自包含</em></p>


[![GitHub stars](https://img.shields.io/github/stars/Astor-Zore/NeovimZero?style=flat-square)](https://github.com/Astor-Zore/NeovimZero/stargazers)
[![GitHub license](https://img.shields.io/github/license/Astor-Zore/NeovimZero?style=flat-square)](https://github.com/Astor-Zore/NeovimZero/blob/main/LICENSE)
[![Neovim](https://img.shields.io/badge/Neovim-0.9+-blue?style=flat-square&logo=neovim)](https://neovim.io)
[![Platform](https://img.shields.io/badge/platform-linux%20x64-lightgrey?style=flat-square)]()

</div>

---

## 1. 项目介绍

NeovimZero是一个neovim的整合，旨在实现开发过程中，做到快速部署，开箱即用，特性如下：

- 脚本一键离线部署，网络零依赖，可视化的部署信息
  
- 包含静态编译nvim本体，支持版本较低的服务器（例如：ubuntu 18.04.6 LTS）
  
- 无需联网，插件自包含，插件依赖的工具均静态编译，不依赖系统版本（仅x64）
  
- 框架清晰，易于拓展和维护，客制化程度高
  

## 2. 部署步骤

**a. clone 项目**

虽然离线部署是NeovimZero的特点之一，但是获取该项目终究还是需要一台联网设备，具有git工具。

```bash
git clone https://github.com/Astor-Zore/NeovimZero
```

> 项目体积偏大，如若网速受限，请根据自身情况进行代理

clone完成后，需要install lfs

```bash
cd NeovimZero
git lfs install
git lfs pull
```

获取通过lfs管理的大文件

> 由于部分文件通过lfs管理，所以直接下载zip不能保证nvim具有完整功能

**b. 清除环境**

不管是否第一次安装nvim，或是NeovimZero，部署前最好清除当前环境残留

```bash
rm ~/.config/nvim
rm ~/.local/share/nvim
```

> 若是部署NeovimZero残留，以上命令可以清除，若是nvim残留文件夹，添加-rf参数清除

**c. 脚本部署**

直接运行项目下的init脚本

```bash
cd NeovimZero

./init.sh
```

部署过程会有过程信息，一般如下：

```bash
This script will remove existing directories:
  /home/astor/.config/nvim
  /home/astor/.local/share/nvim
Make sure you have backups if needed.\033[0m
Continue? (y/N) y

=========================================
  Neovim Dev Environment Setup (v4.0)
=========================================

----------------------------------------
[INFO] Validating environment...
[SUCCESS] Environment validation passed
[SUCCESS] Step 'validate_environment' completed
----------------------------------------
[INFO] Cleaning up old configuration symlinks/directories
[SUCCESS] Step 'cleanup_old_config' completed
----------------------------------------
[INFO] Setting up configuration symlinks
[SUCCESS] Created symlink: /home/astor/.config/nvim -> /home/astor/software/NeovimZero/nvim (Neovim config)
[SUCCESS] Created symlink: /home/astor/.local/share/nvim -> /home/astor/software/NeovimZero/.local/share/nvim (Neovim data)
[SUCCESS] Step 'setup_config_symlinks' completed
----------------------------------------
[INFO] Setting up treesitter parser symlink
[SUCCESS] Created symlink: /home/astor/software/NeovimZero/nvim/addons/nvim-treesitter/parser -> /home/astor/software/NeovimZero/app/lib/nvim/parser (Treesitter parsers)
[SUCCESS] Step 'setup_parser_symlink' completed
----------------------------------------
[INFO] Setting up tool symlinks in /home/astor/software/NeovimZero/bin
[SUCCESS] Created directory: /home/astor/software/NeovimZero/bin
[INFO] Cleaning up old tool symlinks in /home/astor/software/NeovimZero/bin
[SUCCESS] Created symlink: /home/astor/software/NeovimZero/bin/node -> /home/astor/software/NeovimZero/tool/node-v16.20.2-linux-x64/bin/node (Tool node)
[SUCCESS] Created symlink: /home/astor/software/NeovimZero/bin/corepack -> /home/astor/software/NeovimZero/tool/node-v16.20.2-linux-x64/lib/node_modules/corepack/dist/corepack.js (Tool corepack)
[SUCCESS] Created symlink: /home/astor/software/NeovimZero/bin/fzf -> /home/astor/software/NeovimZero/tool/fzf-0.67.0/fzf (Tool fzf)
[SUCCESS] Created symlink: /home/astor/software/NeovimZero/bin/rg -> /home/astor/software/NeovimZero/tool/ripgrep-15.1.0/rg (Tool rg)
[SUCCESS] Created symlink: /home/astor/software/NeovimZero/bin/npm -> /home/astor/software/NeovimZero/tool/node-v16.20.2-linux-x64/lib/node_modules/npm/bin/npm-cli.js (Tool npm)
[SUCCESS] Created symlink: /home/astor/software/NeovimZero/bin/npx -> /home/astor/software/NeovimZero/tool/node-v16.20.2-linux-x64/lib/node_modules/npm/bin/npx-cli.js (Tool npx)
[SUCCESS] Created symlink: /home/astor/software/NeovimZero/bin/nvim -> /home/astor/software/NeovimZero/app/bin/nvim (Neovim)
[SUCCESS] Step 'setup_tool_links' completed
----------------------------------------
[INFO] Adding /home/astor/software/NeovimZero/bin to PATH in ~/.bashrc
[INFO] Removed old PATH block from .bashrc
[SUCCESS] PATH updated in .bashrc. Please run 'source ~/.bashrc' or restart your shell to apply.
[SUCCESS] Step 'add_bin_to_path' completed
----------------------------------------
[INFO] Verifying installation...
[SUCCESS] Symlink /home/astor/.config/nvim is valid
[SUCCESS] Symlink /home/astor/.local/share/nvim is valid
[SUCCESS] Tool nvim is executable
[SUCCESS] Tool fzf is executable
[SUCCESS] Tool rg is executable
[SUCCESS] Tool node is executable
[SUCCESS] Tool npm is executable
[WARNING] Tool pyright not found or not executable in /home/astor/software/NeovimZero/bin
[INFO] Verification completed: 7/8 checks passed.
[SUCCESS] Step 'verify_installation' completed
----------------------------------------
[SUCCESS] All steps completed successfully!
```

> 这里pyright我用不到，暂时忽略，需要的时候我会解这个问题

**d. 环境生效**

init脚本会直接在```~/.bashrc```最后会将当前```NeovimZero/bin```的绝对路径添加到环境，你可以在bashrc中看到：

```bash
# >>> NEOVIM_DEV_ENV_PATH >>>
export PATH="/home/astor/software/NeovimZero/bin:$PATH"
# <<< NEOVIM_DEV_ENV_PATH <<<
```

如果你用的是`bash shell`，直接

```bash
source ~/.bashrc
```

即可直接让环境生效，如果使用的是```zsh shell``` 或是```fish shell```，请自行将路径添加到对应位置。

**e. 启动步骤**

当前直接运行nvim即可打开NeovimZero

```bash
nvim
```

第一次打开遇到一堆报错不用管，因为在当前环境下，还没有正式安装插件，在nvim中执行：

```bash
// 先退出nvim
:q


// 重新打开
nvim
:PackerSync
```

执行后会正式安装包含的全部插件。然后再次退出重启：

```bash
:qa

nvim
```

此时报错全部消失，你可以使用全新的功能完备的NeovimZero。

## 3. 使用说明

NeovimZero包含了广泛和强大的插件内容，这里说最重要的几个功能，完整清单将在后面列出。

**重要功能：**

- LSP语法检查，包含语法提示，错误诊断，代码片段，语法跳转，支持compile_command.json
  
- 快速搜索，包含fzf文件搜索、rigrep字符搜索、telescope搜索buffer等
  
- git diff、blame查看，查看代码片段的提交日期和提交人
  
- 文件树，支持文件操作，支持左边栏和浮动模式
  
- 支持代码格式化，含有clangd-format工具
  
- buffer标签页管理，可快速排序
  
- 内置若干好评如潮的主题，可快速切换
  

.......

> 内容过多，这里不详细展开，完整请查阅插件目录以及快捷键表

**快捷键对照表：**

| 快捷键 | 模式  | 功能说明 |
| --- | --- | --- |
| `<leader>?` | n   | 显示快捷键列表（which-key） |
| `<leader>tt` | n   | 切换空格/制表符缩进模式 |
| `<leader>ts` | n   | 显示当前缩进设置 |
| `<leader>fmt` | n   | 切换自动格式化模式 |
| `<leader>e` | n   | 重新加载当前 Lua 文件 |
| `<leader>w` | n   | 保存文件 |
| `<leader>q` | n   | 关闭文件 |
| `<leader>wq` | n   | 保存并关闭 |
| `<leader>qa` | n   | 退出全部 |
| `<leader>bb` | n   | 选择缓冲区 |
| `<leader>bd` | n   | 关闭当前缓冲区 |
| `<leader>bo` | n   | 关闭其他缓冲区 |
| `<leader>br` | n   | 关闭右侧缓冲区 |
| `<leader>bl` | n   | 关闭左侧缓冲区 |
| `<leader>bl` | n   | 列出所有缓冲区 |
| `<leader>b>` | n   | 向右移动缓冲区 |
| `<leader>b<` | n   | 向左移动缓冲区 |
| `<leader>bs` | n   | 按目录排序缓冲区 |
| `<leader>bS` | n   | 按扩展名排序缓冲区 |
| `<C-d>` | n   | 下一个缓冲区 |
| `<C-a>` | n   | 上一个缓冲区 |
| `<leader>~` | n   | 切换快捷列表 |
| `<leader>p` | n   | 显示文件完整路径 |
| `<leader>cp` | n   | 复制文件路径 |
| `<Esc><Esc>` | n   | 取消搜索高亮 |
| `<leader>//` | n   | 添加文件头注释 |
| `<leader>/` | n   | 添加函数/文件注释 |
| `<leader>nn` | n   | 切换文件浏览器 |
| `<leader>nf` | n   | 浮动文件浏览器 |
| `<leader>nc` | n   | 当前缓冲区文件浏览器 |
| `<leader>nw` | n   | 定位当前文件 |
| `<leader>l` | n   | 打开大纲 |
| `<leader>xx` | n   | 诊断信息（当前文档） |
| `<leader>xw` | n   | 诊断信息（工作区） |
| `<leader>xs` | n   | 符号（当前文档） |
| `<leader>xS` | n   | LSP 引用/定义 |
| `<leader>xl` | n   | 位置列表 |
| `<leader>xq` | n   | 快速修复列表 |
| `<leader>xc` | n   | 关闭 Trouble |
| `<leader>ff` | n   | 查找文件 |
| `<leader>fg` | n   | 实时搜索文本 |
| `<leader>fh` | n   | 帮助标签 |
| `<leader>fs` | n   | 搜索当前单词 |
| `<leader>ft` | n   | 搜索当前单词 |
| `<leader>fT` | n   | 搜索当前单词 |
| `<leader>fb` | n   | 搜索缓冲区 |
| `<leader>fo` | n   | 搜索最近文件 |
| `s` | n   | 搜索单词 |
| `<C-k>` | n   | 向上滚动 |
| `<C-j>` | n   | 向下滚动 |
| `<leader>FF` | n   | 格式化代码 |
| `<leader>tn` | n   | 下一个主题 |
| `<leader>tm` | n   | 切换主题模式 |
| `<leader>tf` | n   | 切换主题模式 |
| `<leader>gn` | n   | 跳转到下一个差异块 |
| `<leader>gp` | n   | 跳转到上一个差异块 |
| `<leader>gh` | n   | 预览当前差异块 |
| `<leader>gl` | n   | 显示当前行提交信息 |
| `<leader>gb` | n   | 显示当前行提交信息 |
| `<leader>gd` | n   | 显示当前文件差异 |
| `<leader>ga` | n   | 暂存此差异块 |
| `<leader>gu` | n   | 撤销暂存此差异块 |

当前的<leader>键被设置为了`,`键。

如对插件功能和用法不明确，请自行查阅插件的项目地址

**插件目录：**

| 插件名 | 用途  | 仓库链接 |
| --- | --- | --- |
| bufferline.nvim | 顶部标签栏 / 缓冲区管理 | https://github.com/akinsho/bufferline.nvim |
| header.nvim | 自定义启动头部 / 仪表盘 | https://github.com/attilarepka/header.nvim |
| mason.nvim | LSP/DAP/Linter/Formatter 包管理器 | https://github.com/williamboman/mason.nvim |
| nvim-lspconfig | LSP 服务器通用配置 | https://github.com/neovim/nvim-lspconfig |
| plenary.nvim | 通用 Lua 函数库（多插件依赖） | https://github.com/nvim-lua/plenary.nvim |
| cmp-luasnip | nvim-cmp 的 LuaSnip 补全源 | https://github.com/L3MON4D3/cmp_luasnip |
| indent-blankline.nvim | 缩进对齐线 | https://github.com/lukas-reineke/indent-blankline.nvim |
| neo-tree.nvim | 现代化文件树 / 浏览器 | https://github.com/nvim-neo-tree/neo-tree.nvim |
| nvim-navic | 在状态栏 / winbar 显示代码上下文路径 | https://github.com/SmiteshP/nvim-navic |
| telescope-fzf-native.nvim | 为 Telescope 提供 fzf 原生排序算法 | https://github.com/nvim-telescope/telescope-fzf-native.nvim |
| cmp-nvim-lsp | nvim-cmp 的 LSP 补全源 | https://github.com/hrsh7th/cmp-nvim-lsp |
| lualine.nvim | 状态栏 | https://github.com/nvim-lualine/lualine.nvim |
| neogen | 自动生成注释（函数/文件头） | https://github.com/danymat/neogen |
| nvim-tree.lua | 文件树（传统实现） | https://github.com/nvim-tree/nvim-tree.lua |
| telescope.nvim | 模糊查找器（文件、符号、grep 等） | https://github.com/nvim-telescope/telescope.nvim |
| comment.nvim | 智能注释 / 反注释 | https://github.com/numToStr/Comment.nvim |
| luasnip | 代码片段引擎 | https://github.com/L3MON4D3/LuaSnip |
| neoscroll.nvim | 平滑滚动 | https://github.com/karb94/neoscroll.nvim |
| nvim-treesitter | 语法树高亮、折叠、文本对象等 | https://github.com/nvim-treesitter/nvim-treesitter |
| tiny-inline-diagnostic.nvim | 行内诊断信息（如错误虚影） | https://github.com/ray-x/tiny-inline-diagnostic.nvim |
| conform.nvim | 异步代码格式化 | https://github.com/stevearc/conform.nvim |
| marks.nvim | 可视化显示标记（本地标记） | https://github.com/chentoast/marks.nvim |
| nui.nvim | UI 组件库（输入框、弹窗等） | https://github.com/MunifTanjim/nui.nvim |
| nvim-treesitter-context | 显示当前光标所在代码块上下文 | https://github.com/nvim-treesitter/nvim-treesitter-context |
| trouble.nvim | 诊断 / 引用 / 符号列表 | https://github.com/folke/trouble.nvim |
| flash.nvim | 快速字符跳转与搜索高亮 | https://github.com/folke/flash.nvim |
| markview.nvim | Markdown 实时预览 | https://github.com/OXY2DEV/markview.nvim |
| nvim-autopairs | 自动配对括号、引号等 | https://github.com/windwp/nvim-autopairs |
| nvim-web-devicons | 文件图标（多插件依赖） | https://github.com/nvim-tree/nvim-web-devicons |
| vim-startify | 启动页面 / 仪表盘 | https://github.com/mhinz/vim-startify |
| gitsigns.nvim | Git 增删改标记、行内 blame | https://github.com/lewis6991/gitsigns.nvim |
| mason-lspconfig.nvim | 桥接 mason 与 lspconfig，自动配置服务器 | https://github.com/williamboman/mason-lspconfig.nvim |
| nvim-cmp | 自动补全框架 | https://github.com/hrsh7th/nvim-cmp |
| outline.nvim | 代码大纲 / 符号侧边栏 | https://github.com/hedyhli/outline.nvim |
| which-key | 快捷键提示菜单 | https://github.com/folke/which-key.nvim |

> 多数插件需要进行客制化的配置，可查阅`lua/expand_config`文件夹下的插件同名lua文件，进行客制化修改

**主题列表：**

| 主题名 | 用途/风格 | 仓库链接 |
| --- | --- | --- |
| catppuccin-latte | Catppuccin 浅色暖系 | https://github.com/catppuccin/nvim |
| catppuccin-frappe | Catppuccin 淡紫冷系 | 同上  |
| catppuccin-macchiato | Catppuccin 中深冷系 | 同上  |
| catppuccin-mocha | Catppuccin 深色暖冷混合 | 同上  |
| gruvbox | 复古暖色（深/浅） | https://github.com/ellisonleao/gruvbox.nvim |
| kanagawa | 经典浮世绘风格暗色 | https://github.com/rebelot/kanagawa.nvim |
| kanagawa-wave | Kanagawa 的蓝色变体 | 同上  |
| kanagawa-dragon | Kanagawa 的暗紫变体 | 同上  |
| kanagawa-lotus | Kanagawa 的浅色米白变体 | 同上  |
| rose-pine | 柔和粉暖色调暗主题 | https://github.com/rose-pine/neovim |
| tokyonight-night | TokyoNight 深暗蓝背景 | https://github.com/folke/tokyonight.nvim |
| tokyonight-moon | TokyoNight 月光暗蓝 | 同上  |
| tokyonight-storm | TokyoNight 风暴蓝灰 | 同上  |
| tokyonight-day | TokyoNight 日间浅色 | 同上  |
| melange | 温暖低对比度暗色 | https://github.com/savq/melange-nvim |
| toast | 烘焙暖橙/黄色调浅色主题 | https://github.com/whoisjake/toast.nvim |
| vscode | 仿 Visual Studio Code 暗色/亮色 | https://github.com/Mofiqul/vscode.nvim |
| ayu-dark | Ayu 暗色主题 | https://github.com/Shatur/neovim-ayu |
| ayu-light | Ayu 亮色主题 | 同上  |
| ayu-mirage | Ayu 幻境暗蓝主题 | 同上  |
| open-color | 基于 Open Color 色板的简约亮色 | https://github.com/archibate/open-color.nvim |
| PaperColorSlim | PaperColor 的简约高对比版 | https://github.com/NLKNguyen/papercolor-theme |
| noctis | Noctis 蓝调暗色 | https://github.com/kartikp10/noctis.nvim |
| noctis-bordo | Noctis 酒红变体 | 同上  |
| noctis-uva | Noctis 葡萄紫变体 | 同上  |
| noctis-viola | Noctis 紫罗兰变体 | 同上  |
| noctis-lux | Noctis 暖亮变体 | 同上  |
| noctis-lilac | Noctis 丁香紫变体 | 同上  |
| noctis-hibernus | Noctis 冬日白亮变体 | 同上  |
| everforest | 森系低对比柔和主题（多风格） | https://github.com/sainnhe/everforest |

## 4. 贡献方式

该项目存在较大的个人偏好，由本人一人维护，如有想法交流可以联系我 astor.jiang@outlook.com 或提 issue，感谢！

关于开箱即用的其他工具收纳，欢迎关注项目：

[Astor-Zore/AstorKit](https://github.com/Astor-Zore/AstorKit)

---

All the best !!!

Happy Coding Everyday !!!
