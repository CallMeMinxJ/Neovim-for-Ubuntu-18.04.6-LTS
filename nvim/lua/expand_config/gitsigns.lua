-- File: lua/basic_setting/gitsigns.lua
-- Git signs plugin configuration
-- Features: side column marks, stage by hunk, blame, diff, etc.

-------------------------------------------------
-- Highlight groups for better visual distinction
-- Adjust these colors to match your theme
-------------------------------------------------
local set_hl = vim.api.nvim_set_hl
set_hl(0, "GitSignsAddUnstaged",    { fg = "#E06C75" }) -- red-ish
set_hl(0, "GitSignsChangeUnstaged", { fg = "#E5C07B" }) -- yellow-ish
set_hl(0, "GitSignsDeleteUnstaged", { fg = "#E06C75" })
set_hl(0, "GitSignsAddStaged",      { fg = "#98C379" }) -- green
set_hl(0, "GitSignsChangeStaged",   { fg = "#61AFEF" }) -- blue
set_hl(0, "GitSignsDeleteStaged",   { fg = "#98C379" })

require("gitsigns").setup({
	-------------------------------------------------
	-- Signs (unstaged changes) – thin bars with warm colors
	-------------------------------------------------
	signs = {
		add          = { text = "▎", hl = "GitSignsAddUnstaged" },    -- new line, not staged
		change       = { text = "▎", hl = "GitSignsChangeUnstaged" }, -- modified, not staged
		delete       = { text = "▁", hl = "GitSignsDeleteUnstaged" },
		topdelete    = { text = "‾", hl = "GitSignsDeleteUnstaged" },
		changedelete = { text = "~", hl = "GitSignsChangeUnstaged" },
		untracked    = { text = "┆", hl = "GitSignsAddUnstaged" },
	},
	-------------------------------------------------
	-- Signs for staged changes – thick bars with cool colors
	-------------------------------------------------
	signs_staged = {
		add          = { text = "▌", hl = "GitSignsAddStaged" },
		change       = { text = "▌", hl = "GitSignsChangeStaged" },
		delete       = { text = "▁", hl = "GitSignsDeleteStaged" },
		topdelete    = { text = "‾", hl = "GitSignsDeleteStaged" },
		changedelete = { text = "~", hl = "GitSignsChangeStaged" },
		untracked    = { text = "┆", hl = "GitSignsAddStaged" },
	},
	signs_staged_enable = true,   -- enable staged marks
	signcolumn  = true,           -- :Gitsigns toggle_signs
	numhl       = false,
	linehl      = false,
	word_diff   = false,

	watch_gitdir = {
		follow_files = true,
	},
	auto_attach          = true,
	attach_to_untracked  = false,
	update_debounce      = 100,
	max_file_length      = 40000,
	sign_priority        = 6,

	current_line_blame      = false,
	current_line_blame_opts = {
		virt_text          = true,
		virt_text_pos      = "eol",
		delay              = 1000,
		ignore_whitespace  = false,
		virt_text_priority = 100,
		use_focus          = true,
	},
	current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",

	status_formatter = nil,
	preview_config = {
		style    = "minimal",
		relative = "cursor",
		row      = 0,
		col      = 1,
	},
})

-------------------------------------------------
-- Custom commands (you can still use :Gitsigns <subcmd>)
-------------------------------------------------
local gs = require("gitsigns")

-- Hunk navigation
vim.api.nvim_create_user_command("GitSignsNextHunk", function() gs.next_hunk() end,
	{ desc = "Jump to next hunk" })
vim.api.nvim_create_user_command("GitSignsPrevHunk", function() gs.prev_hunk() end,
	{ desc = "Jump to previous hunk" })

-- Stage / unstage
vim.api.nvim_create_user_command("GitSignsStageHunk",     function() gs.stage_hunk() end,
	{ desc = "Stage current hunk (git add)" })
vim.api.nvim_create_user_command("GitSignsUndoStageHunk", function() gs.undo_stage_hunk() end,
	{ desc = "Unstage current hunk" })

-- Preview and diff
vim.api.nvim_create_user_command("GitSignsPreviewHunk", function() gs.preview_hunk() end,
	{ desc = "Preview current hunk" })
vim.api.nvim_create_user_command("GitSignsDiffThis",    function() gs.diffthis() end,
	{ desc = "Show file diff (staged / unstaged separated)" })

-- Blame
vim.api.nvim_create_user_command("GitSignsBlameLine", function() gs.blame_line() end,
	{ desc = "Git blame for current line" })
vim.api.nvim_create_user_command("GitSignsBlame",      function() gs.blame() end,
	{ desc = "Git blame for entire file" })

