-- File: lua/basic_setting/theme.lua

local theme = {}

-- get current theme
local function get_current_theme()
	return require('basic_setting.settings').get_config("current", "themes") or "catppuccin"  -- default to 'catppuccin'
end

-- set current theme
local function set_current_theme(new_theme)
	local available_themes = require('basic_setting.settings').get_config("available", "themes") or {}
	local is_valid_theme = false
	for _, theme_name in ipairs(available_themes) do
		if theme_name == new_theme then
			is_valid_theme = true
			break
		end
	end

	if not is_valid_theme then
		print("❌ Theme " .. new_theme .. " is not available!")
		return
	end

	require('basic_setting.settings').set_config("current", new_theme, "themes")

	vim.cmd("colorscheme " .. new_theme)
	-- vim.notify("✅ Switched to " .. new_theme .. " theme!")
end

-- switch next theme
theme.toggle_next_theme = function()
	local current_theme = get_current_theme()
	local available_themes = require('basic_setting.settings').get_config("available", "themes") or {}

	local next_theme_index = 1
	for i, theme_name in ipairs(available_themes) do
		if theme_name == current_theme then
			next_theme_index = (i % #available_themes) + 1
			break
		end
	end

	local next_theme = available_themes[next_theme_index]
	set_current_theme(next_theme)
end

-- switch theme by name
theme.switch_theme = function(theme_name)
	set_current_theme(theme_name)
end

-- display current theme
theme.show_current_theme = function()
	local current_theme = get_current_theme()
	vim.notify("Current theme: " .. current_theme)
end

-- load current theme
theme.load_theme = function()
	theme.switch_theme(get_current_theme())
end

-- switch light and dark mode
theme.switch_theme_mod = function()
	local mode = require('basic_setting.settings').get_config("background", "options") or "dark"
	if mode == "light" then
		require('basic_setting.settings').set_config("background", "dark", "options")
	else
		require('basic_setting.settings').set_config("background", "light", "options")
	end
end

-- choose theme interactively using telescope
theme.choose_theme = function()
	local available_themes = require('basic_setting.settings').get_config("available", "themes") or {}
	if #available_themes == 0 then
		vim.notify("No available themes found!", vim.log.levels.WARN)
		return
	end

	local ok, telescope = pcall(require, 'telescope.builtin')
	if not ok then
		vim.notify("Telescope not found, falling back to vim.ui.select", vim.log.levels.WARN)
		vim.ui.select(available_themes, {
			prompt = "Select theme:",
			format_item = function(item) return item end,
		}, function(choice)
			if choice then
				theme.switch_theme(choice)
			end
		end)
		return
	end

	-- Use telescope pickers with a static list
	local pickers = require('telescope.pickers')
	local finders = require('telescope.finders')
	local conf = require('telescope.config').values
	local actions = require('telescope.actions')
	local action_state = require('telescope.actions.state')

	pickers.new({}, {
		prompt_title = "Choose Theme",
		finder = finders.new_table {
			results = available_themes,
			entry_maker = function(entry)
				return {
					value = entry,
					display = entry,
					ordinal = entry,
				}
			end,
		},
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				if selection then
					theme.switch_theme(selection.value)
				end
			end)
			return true
		end,
	}):find()
end

-- load current theme at startup
theme.load_theme()

-- create user commands
vim.api.nvim_create_user_command(
	'ThemeNext',
	function()
		theme.toggle_next_theme()
	end,
	{ desc = 'Switch to the next available theme' }
)

vim.api.nvim_create_user_command(
	'ThemeSet',
	function(opts)
		theme.switch_theme(opts.args)
	end,
	{ nargs = 1, desc = 'Switch to a specific theme (e.g., :ThemeSet catppuccin)' }
)

vim.api.nvim_create_user_command(
	'ThemeMode',
	function()
		theme.switch_theme_mod()
	end,
	{ desc = 'Switch theme mode' }
)

vim.api.nvim_create_user_command(
	'ThemeChoose',
	function()
		theme.choose_theme()
	end,
	{ desc = 'Select a theme interactively with Telescope' }
)

return theme

