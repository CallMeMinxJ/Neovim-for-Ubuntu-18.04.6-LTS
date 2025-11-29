-- open osc52 clipboard
vim.g.clipboard = {
    name = 'OSC52',
    copy = {
        ['+'] = require('vim.ui.clipboard.osc52').copy '+',
        ['*'] = require('vim.ui.clipboard.osc52').copy '*',
    },
    paste = {
        ['+'] = function() return vim.fn.getreg '"' end,
        ['*'] = function() return vim.fn.getreg '"' end,
    },
}

-- init.lua Main Enterement

-- Basic config
require('basic_setting.settings')

-- LSP config
require('basic_setting.lsp')

-- Keymaps setting
require('basic_setting.keymaps')

-- Plugins config
require('basic_setting.plugins')


-- Theme config
vim.cmd.colorscheme "catppuccin-macchiato"
