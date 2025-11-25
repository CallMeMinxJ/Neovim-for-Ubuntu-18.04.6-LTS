-- Configs of bufferline plugin


-- Can close buffers by clicking icon
vim.opt.termguicolors = true
require("bufferline").setup{
  options = {
    show_buffer_icons = true,         -- 显示文件图标
    show_buffer_close_icons = true,   -- 显示关闭按钮图标
    show_close_icon = false,
    separator_style = "slant", -- 可选："slant" | "thick" | "thin" | "none"
    show_buffer_close_icons = true,
    show_close_icon = false,
    diagnostics = "nvim_lsp", -- 如果你启用了 LSP，可以显示诊断信息
    offsets = {
      {
        filetype = "NvimTree",
        text = "File Explorer",
        highlight = "Directory",
        text_align = "left"
      }
    },
  }
}


