/*
 * README.md for Neovim-for-Ubuntu-18.04.6-LTS
 * 完整内容，无嵌套代码块
 */

# Neovim for Ubuntu 18.04.6 LTS

<div align="center">






**开箱即用的 Neovim 开发环境，专为 Ubuntu 18.04.6 LTS 优化**

[项目介绍] • [特性] • [快速开始] • [项目结构] • [工具集] • [配置说明]

</div>

## 项目介绍

这是一个为 **Ubuntu 18.04.6 LTS** 服务器环境精心打造的 **Neovim 开发环境**。专为无外网访问限制的环境设计，所有依赖和工具都已预编译打包，真正做到开箱即用。

### 核心优势

- ✅ **无需外网访问** - 所有工具和配置完全离线可用
- ✅ **无需管理员权限** - 所有文件安装在用户目录下
- ✅ **即装即用** - 一键配置，无需复杂安装步骤
- ✅ **生产就绪** - 包含完整的开发工具链

## 特性

### 编辑器核心
- **Neovim 0.12.0** - 最新开发版本，性能卓越
- **Lua 配置** - 现代化配置，启动速度快
- **完整的 LSP 支持** - 智能代码补全和诊断

### 开发工具
- **clangd** - C/C++ 语言服务器
- **Lua Language Server** - Lua 语言支持
- **ripgrep** - 超快速代码搜索
- **fzf** - 模糊文件查找

### 环境特性
- 环境隔离 - 独立配置，不影响系统环境
- 快速启动 - 优化的启动配置
- 高度可定制 - 模块化配置，易于扩展

## 快速开始

### 系统要求
- Ubuntu 18.04.6 LTS (其他版本可能兼容但未测试)
- Bash shell 环境
- 基本的终端操作知识

### 安装步骤

1. 克隆仓库
git clone https://github.com/CallMeMinxJ/Neovim-for-Ubuntu-18.04.6-LTS.git
cd Neovim-for-Ubuntu-18.04.6-LTS

2. 运行初始化脚本
./script/init.sh

3. 激活环境配置
source ~/.bashrc

4. 验证安装
nvim --version

### 验证安装成功

检查 Neovim 版本
nvim --version

检查工具是否可用
which clangd
which fzf
which rg
which lua-language-server

## 项目结构

项目目录结构：
- bin/                 # 可执行文件符号链接
- config/              # Neovim Lua 配置
  - lua/              # Lua 模块配置
  - plugin/           # 插件配置
- nvim/               # Neovim 二进制文件
  - bin/
  - lib/
  - share/
- script/             # 配置脚本
  - init.sh          # 主初始化脚本
- tool/              # 开发工具
  - clangd-server/   # C/C++ LSP 服务器
  - fzf-0.67.0/      # 模糊查找工具
  - lua-server/      # Lua LSP 服务器
  - ripgrep-15.1.0/  # 快速代码搜索

## 工具集

| 工具 | 版本 | 用途 | 状态 |
|------|------|------|------|
| Neovim | 0.12.0-dev | 编辑器核心 | 预配置 |
| clangd | 最新版 | C/C++ 语言服务器 | 预配置 |
| Lua LS | 最新版 | Lua 语言服务器 | 预配置 |
| ripgrep | 15.1.0 | 代码搜索工具 | 预配置 |
| fzf | 0.67.0 | 模糊查找工具 | 预配置 |

## 配置说明

### 环境变量
初始化脚本会自动配置以下环境变量：

export NVIM_DEV_ROOT="~/neovim"      # 项目根目录
export PATH="$NVIM_DEV_ROOT/bin:$PATH" # 工具路径
export NVIM_APPNAME="nvim-dev"       # 独立配置命名空间

### 可用命令别名
nvim        # 启动 Neovim (使用自定义配置)
nvim-dev    # 同 nvim 命令
nvim-cfg    # 直接编辑 Neovim 配置

### 自定义配置
要添加个人配置，请编辑 config/lua/custom/ 目录下的文件：

在 config/lua/custom/init.lua 中添加个人配置
vim.g.mapleader = " "  -- 设置 leader 键

自定义按键映射
vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>')

## 故障排除

### 常见问题

问题1: 初始化后命令找不到
解决方案：重新加载 bash 配置
source ~/.bashrc

问题2: 符号链接创建失败
解决方案：手动创建符号链接
ln -sf ~/neovim/nvim/bin/nvim ~/neovim/bin/nvim

问题3: 工具权限问题
解决方案：添加执行权限
chmod +x tool/*/bin/* 2>/dev/null

### 日志和调试
启用调试模式：
设置调试环境变量
export NVIM_LOG_FILE=~/neovim.log
nvim --cmd "set verbose=9"

## 贡献指南

我们欢迎贡献！请遵循以下步骤：

1. Fork 本仓库
2. 创建特性分支 (git checkout -b feature/AmazingFeature)
3. 提交更改 (git commit -m 'Add some AmazingFeature')
4. 推送到分支 (git push origin feature/AmazingFeature)
5. 开启 Pull Request

### 开发规范
- 遵循现有的代码风格
- 确保所有工具都包含在 tool/ 目录
- 更新相应的文档
- 测试在 Ubuntu 18.04.6 上的兼容性

## 更新日志

### v1.0.0 (2024-01-20)
- 初始版本发布
- 完整的 Neovim 0.12.0 环境
- 集成 LSP 工具链
- 一键初始化脚本

## 许可证

本项目采用 MIT 许可证 - 查看 LICENSE 文件了解详情。

## 维护者

- CallMeMinxJ - 项目创建者和维护者

## 致谢

感谢以下开源项目：
- Neovim - 优秀的现代编辑器
- clangd - C/C++ 语言服务器
- Lua Language Server - Lua 语言支持

---

<div align="center">

### 如果这个项目对你有帮助，请给个 Star！

**快乐编码！**

</div>

---

*最后更新: 2024年1月20日*
