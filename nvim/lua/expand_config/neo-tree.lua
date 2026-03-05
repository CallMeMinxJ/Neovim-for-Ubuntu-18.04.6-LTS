-- neo-tree.lua
-- Configuration for neo-tree file explorer

-- Define custom commands for toggling neo-tree
local function neotree_toggle()
	-- Toggle neo-tree in left sidebar with width 30
	vim.cmd("Neotree position=left toggle")
end

local function neotree_toggle_float()
	-- Toggle neo-tree in floating window with width 40, aligned to left
	vim.cmd("Neotree position=float toggle")
end

local function neotree_toggle_current()
	-- Toggle neo-tree in current window/buffer (like netrw)
	vim.cmd("Neotree position=current toggle")
end

-- Register custom commands
vim.api.nvim_create_user_command("NeotreeToggle", function()
	neotree_toggle()
end, { nargs = 0 })

vim.api.nvim_create_user_command("NeotreeToggleFloat", function()
	neotree_toggle_float()
end, { nargs = 0 })

vim.api.nvim_create_user_command("NeotreeToggleCurrent", function()
	neotree_toggle_current()
end, { nargs = 0 })

-- Main neo-tree configuration
require("neo-tree").setup({
	-- Basic settings
	sources = { "filesystem", "buffers", "git_status", "document_symbols" },
	close_if_last_window = false, -- Close neo-tree if it's the last window
	enable_diagnostics = true, -- Show diagnostics (works with COC)
	enable_git_status = true, -- Show git status indicators
	default_source = "filesystem", -- Default to filesystem view

	-- Window configuration
	popup_border_style = "rounded", -- Rounded borders for floating windows
	window = {
		position = "left", -- Default position
		width = 30, -- Default width for sidebar
		popup = {
			-- Floating window settings
			size = {
				height = "90%",
				width = "30%", -- Width for floating window
			},
			position = { row = "100%", col = "0%" }, -- Align to left side of screen
			row_offset = -1, -- Move up by 1 row to be fully visible
			col_offset = 0, -- No horizontal offset
		},
	},

	-- Filesystem settings
	filesystem = {
		follow_current_file = {
			enabled = true, -- Automatically reveal and focus current file
			leave_dirs_open = false, -- Close auto-expanded directories when leaving
		},
		hijack_netrw_behavior = "disabled", -- Disable netrw integration
		use_libuv_file_watcher = false, -- Use libuv for better file watching performance

		-- File filtering settings
		filtered_items = {
			visible = false, -- Hide filtered items by default
			hide_dotfiles = true,
			hide_gitignored = true,
			never_show = { -- Always hide these items
				".git",
				"node_modules",
				".cache",
				"__pycache__",
				-- "target",
				-- "dist",
				-- "build",
			},
		},
	},

	-- Buffers settings
	buffers = {
		follow_current_file = {
			enabled = true, -- Follow the current buffer
			leave_dirs_open = false,
		},
		show_unloaded = true, -- Show unloaded buffers
	},

	-- Git status settings
	git_status = {
		window = {
			-- Git status will use the default window settings
		},
	},

	-- Document symbols settings (compatible with COC)
	document_symbols = {
		follow_cursor = true, -- Follow cursor movement in the symbols tree
		client_filters = false, -- Use the first available LSP client
	},

	-- Default component configurations
	default_component_configs = {
		indent = {
			indent_size = 2,
			padding = 1,
			with_markers = true,
			indent_marker = "│",
			last_indent_marker = "└",
		},
		icon = {
			folder_closed = "",
			folder_open = "",
			folder_empty = "",
			default = "*",
			highlight = "NeoTreeFileIcon",
		},
		name = {
			trailing_slash = false,
			use_git_status_colors = true,
			highlight = "NeoTreeFileName",
		},
		git_status = {
			symbols = {
				added = "✚",
				modified = "",
				deleted = "✖",
				renamed = "󰁕",
				untracked = "",
				ignored = "",
				unstaged = "󰄱",
				staged = "",
				conflict = "",
			},
		},
	},
})
