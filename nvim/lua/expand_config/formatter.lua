-- formatter.lua
-- Formatter configuration for various filetypes
-- Uses clang-format for C/C++ files with dynamic or project-based formatting
local util = require("formatter.util")

-- Function to create dynamic C/C++ formatting configurations
local function clang_format_config()
	return function()
		-- Check for existence of a .clang-format configuration file
		local config_path = vim.fn.findfile(".clang-format", ".;")
		local style_arg

		if config_path ~= "" then
			-- Use project-specific .clang-format configuration file
			style_arg = "-style=file"
		else
			-- No project configuration found, use dynamic formatting
			-- Retrieve current buffer's indentation settings
			local expandtab = vim.bo.expandtab
			local shiftwidth = vim.bo.shiftwidth
			local tabstop = vim.bo.tabstop

			-- Determine indentation method based on buffer settings
			local use_tab = expandtab and "Never" or "Always"

			-- Use shiftwidth if defined, otherwise fallback to tabstop
			local indent_width = shiftwidth > 0 and shiftwidth or tabstop

			-- Construct style string with dynamic formatting options
			style_arg = string.format(
				"--style={BasedOnStyle: Google, IndentWidth: %d, TabWidth: %d, UseTab: %s, ColumnLimit: 80, SortIncludes: true}",
				indent_width,
				tabstop,
				use_tab
			)
		end

		return {
			exe = "clang-format", -- Executable for C/C++ formatting
			args = { style_arg }, -- Dynamic or project-based style
			stdin = true, -- Read input from standard input
		}
	end
end

-- Stylua configuration for Lua files
local function stylua_config()
	return {
		exe = "stylua", -- Executable for Lua formatting
		args = {
			"--search-parent-directories", -- Search parent directories for configuration
			"--stdin-filepath",
			util.escape_path(util.get_current_buffer_file_path()),
			"--", -- Argument delimiter
			"-", -- Read from stdin
		},
		stdin = true, -- Read input from standard input
	}
end

-- shfmt configuration for shell script formatting
local function shfmt_config()
	return {
		exe = "shfmt", -- Executable for shell script formatting
		args = {
			"-i 4", -- Indent with 4 spaces
			"-ln bash", -- Language: bash
			"-ci", -- Redirect operators with leading space
			"-sr", -- Simplify code
		},
		stdin = true, -- Read input from standard input
	}
end

-- JSON formatter configuration
local function json_config()
	return {
		exe = "python3", -- Use Python's JSON tool
		args = { "-m", "json.tool", "--indent", "4" },
		stdin = true, -- Read input from standard input
	}
end

-- Main formatter setup
require("formatter").setup({
	-- Enable logging for debugging purposes
	logging = true,
	-- Set log level to display warnings and errors
	log_level = vim.log.levels.WARN,

	-- Formatter configurations for specific filetypes
	filetype = {
		-- Lua file formatting
		lua = stylua_config,

		-- Bash shell script formatting
		bash = shfmt_config,
		sh = shfmt_config,

		-- C/C++ file formatting with dynamic configuration
		c = clang_format_config(),
		cpp = clang_format_config(),
		h = clang_format_config(),
		hpp = clang_format_config(),

		-- JSON file formatting
		json = json_config,

		-- Default formatter for all other filetypes
		["*"] = {
			-- Remove trailing whitespace in any filetype
			require("formatter.filetypes.any").remove_trailing_whitespace,
		},
	},
})

local function auto_format_toggle()
	local auto_format = require("basic_setting.settings").get_config("auto_format", "custom")
	auto_format = not auto_format
	require("basic_setting.settings").set_config("auto_format", auto_format, "custom")

	if auto_format then
		print("✅ Open auto format")
	else
		print("✅ Close auto format")
	end
end

vim.api.nvim_create_user_command("AutoFormatToggle", function()
	auto_format_toggle()
end, { nargs = 0 })

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
augroup("__formatter__", { clear = true })
autocmd("BufWritePost", {
	group = "__formatter__",
	callback = function(args)
		local auto_format = require("basic_setting.settings").get_config("auto_format", "custom")
		if auto_format then
			vim.cmd("FormatWrite")
		end
	end,
	-- command = ":FormatWrite",
})
