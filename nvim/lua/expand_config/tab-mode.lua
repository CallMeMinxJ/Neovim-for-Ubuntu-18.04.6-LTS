-- File: lua/expand_config/tab-mode.lua

local tab_mod = {}

-- Function to apply tab/space settings globally and persist them directly using set_config
local function apply_tab_space(use_spaces)
	-- Persist the setting directly through set_config (and apply immediately)
	require("basic_setting.settings").set_config(
		"use_spaces",
		use_spaces,
		"custom"
	)

	-- Set the options directly and persist them
	if use_spaces then
		require("basic_setting.settings").set_config(
			"expandtab",
			true,
			"options"
		)
	else
		require("basic_setting.settings").set_config(
			"expandtab",
			false,
			"options"
		)
	end
end

-- Toggle between space and tab mode
tab_mod.toggle_tab = function()
	-- Get the current setting, default to true (space mode) if not set
	local use_spaces =
		require("basic_setting.settings").get_config("use_spaces", "custom")

	-- Toggle the mode
	use_spaces = not use_spaces
	apply_tab_space(use_spaces) -- Apply the new setting and persist it

	local status = use_spaces and "Space" or "Tab"
	print("✅ Using " .. status)
end

-- Show the current tab setting
tab_mod.show_tab_status = function()
	local use_spaces =
		require("basic_setting.settings").get_config("use_spaces", "custom")
	local status = use_spaces and "Space" or "Tab"
	print(
		"Current setting: "
			.. status
			.. " (width: "
			.. vim.opt.shiftwidth:get()
			.. ")"
	)
end

-- Switch tab space etc. display
tab_mod.toggle_list = function()
	local list = require("basic_setting.settings").get_config("list", "options")
	list = not list
	require("basic_setting.settings").set_config("list", list, "options")
	local status = list and "Show" or "Donot Show"
	print("Change status to " .. status)
end

-- Create new command
vim.api.nvim_create_user_command("TabToggle", function()
	tab_mod.toggle_tab()
end, { nargs = 0 })

vim.api.nvim_create_user_command("TabStatus", function()
	tab_mod.show_tab_status()
end, { nargs = 0 })

vim.api.nvim_create_user_command("ListToggle", function()
	tab_mod.toggle_list()
end, { nargs = 0 })

return tab_mod
