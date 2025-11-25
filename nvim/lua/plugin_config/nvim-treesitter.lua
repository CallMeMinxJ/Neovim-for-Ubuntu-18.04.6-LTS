require("nvim-treesitter.configs").setup({
  ensure_installed = { "bash", "lua", "python", "cpp", "json" }, -- 支持的语言
  sync_install = false, -- 是否同步安装 parser
  auto_install = true,  -- 自动安装缺失的 parser
  highlight = {
    enable = true,      -- 启用语法高亮
    additional_vim_regex_highlighting = false,
    custom_captures = {
      ["injection.content"] = "InactiveCode", -- 关键：替换原来的 set_custom_captures
      ["constant.macro"] = "ConstantMacro",
      ["variable.parameter"] = "MacroParameter"
    },
  },
  indent = {
    enable = true       -- 启用智能缩进
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn", -- 初始化选择
      node_incremental = "grn", -- 增量选择
      node_decremental = "grm", -- 反向选择
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
  },
})
-- 设置条件编译代码为灰色
vim.api.nvim_set_hl(0, 'PreProc', { fg = '#808080' })      -- 预处理指令
vim.api.nvim_set_hl(0, 'Define', { fg = '#808080' })       -- #define
vim.api.nvim_set_hl(0, 'Conditional', { fg = '#808080' })   -- #if, #ifdef 等

-- lua/user/winbar.lua
local function sticky_fn()
  local node = vim.treesitter.get_node()
  if not node then return "" end
  while node do
    local type = node:type()
    if type:match("function") or type:match("method") or type:match("class") then
      -- 只取函数签名，去掉函数体
      local text = vim.treesitter.get_node_text(node, 0):match("[^{;]+")
      text = text:gsub("%s+", " ")               -- 压缩多余空格
      -- 图标 + 加粗 + 黄色 + 左右空格 → 更美观
      return "%#StlFunction# 󰊕 %#StlFunctionText#" .. text .. " "
    end
    node = node:parent()
  end
  return "" -- 没找到就留空
end

-- 全局可见
_G.sticky_fn = sticky_fn

-- 一次性设置高亮 + winbar
vim.api.nvim_create_autocmd("UIEnter", {
  callback = function()
    -- 黄色 + 加粗
    vim.api.nvim_set_hl(0, "StlFunction",     { fg = "#ffd700", bold = true })
    vim.api.nvim_set_hl(0, "StlFunctionText", { fg = "#ffd700", bold = true })

    -- 顶部背景条（圆角感：靠终端字体，(bg 与主题一致即可)）
    vim.api.nvim_set_hl(0, "WinBar",          { bg = "#1f2335", fg = "#ffd700" })

    -- 最终 winbar 格式
    vim.opt.winbar = "%#WinBar#%{%v:lua.sticky_fn()%}%*"
  end,
})


