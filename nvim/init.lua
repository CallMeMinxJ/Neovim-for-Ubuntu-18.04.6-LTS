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

-- init.lua Main Entry

-- Bootstrap lazy.nvim (offline, from local directory)
local lazypath = vim.fn.stdpath("config") .. "/addons/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

-- Load plugins via lazy.nvim
require("basic_setting.lazy_plugins")

-- Load theme color configs (must run before colorscheme is applied)
local color_configs = {
	"color_config.dracular_soft",
	"color_config.catppuccin",
	"color_config.gruvbox",
	"color_config.tokyonight",
	"color_config.rosepine",
	"color_config.kanagawa",
}
for _, name in ipairs(color_configs) do
	pcall(require, name)
end

-- Theme config (applies colorscheme, needs settings)
require("basic_setting.settings")
require("basic_setting.theme")

-- Utility modules
require("expand_config.auto_fold")
require("expand_config.tab-mode")
