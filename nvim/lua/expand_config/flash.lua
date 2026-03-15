-- ~/.config/nvim/lua/config/flash.lua
-- Flash.nvim configuration - Direct require format

-- Setup Flash.nvim
require("flash").setup({
	highlight = {
		backdrop = true,
		groups = {
			match = "FlashMatch",
			current = "FlashCurrent",
			label = "FlashLabel",
		},
	},
	label = {
		rainbow = {
			enabled = true,
			shade = 5,
		},
		style = "inline",
	},
	modes = {
		char = { enabled = false },
	},
	search = {
		multi_window = false,
		wrap = true,
	},
})

-- Create user commands
local flash = require("flash")

vim.api.nvim_create_user_command("FlashJump", function()
	flash.jump()
end, { nargs = 0, desc = "Flash jump to word" })

vim.api.nvim_create_user_command("FlashLine", function()
	flash.jump({
		pattern = ".",
		search = { max_length = 0 },
	})
end, { nargs = 0, desc = "Flash jump in line" })

vim.api.nvim_create_user_command("FlashWindows", function()
	flash.jump({
		search = { multi_window = true },
	})
end, { nargs = 0, desc = "Flash jump across windows" })

vim.api.nvim_create_user_command("FlashTreesitter", function()
	flash.treesitter()
end, { nargs = 0, desc = "Flash treesitter jump" })

vim.api.nvim_create_user_command("FlashRemote", function()
	flash.remote()
end, { nargs = 0, desc = "Flash remote mode" })

vim.api.nvim_create_user_command("FlashToggle", function()
	flash.toggle()
end, { nargs = 0, desc = "Toggle Flash mode" })
