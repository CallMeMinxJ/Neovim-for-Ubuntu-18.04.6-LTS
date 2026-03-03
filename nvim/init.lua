-- open osc52 clipboard
vim.g.clipboard = {
    name = "OSC52",
    copy = {
        ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
        ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
        ["+"] = function()
            return vim.fn.getreg('"')
        end,
        ["*"] = function()
            return vim.fn.getreg('"')
        end,
    },
}

-- init.lua Main Enterement

-- Theme config
require("basic_setting.theme")

-- Plugins config
require("basic_setting.plugins")

-- Basic config
require("basic_setting.settings")

-- Keymaps setting
require("basic_setting.keymaps")

