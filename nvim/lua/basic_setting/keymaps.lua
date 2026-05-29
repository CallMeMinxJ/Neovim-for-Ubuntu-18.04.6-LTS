local wk = require("which-key")

-- Leader key
vim.g.mapleader = ","

-- Register all keybindings using the new which-key spec
wk.add({
	-- Nomal mode keybindings
	{
		mode = "n",

		-- Which key search keymaps
		{
			"<leader>?",
			"<Cmd>lua require('which-key').show('', { mode = 'n' })<CR>",
			desc = "Show keymaps (which-key)",
		},

		-- Keymap bindings
		{
			"<leader>tt",
			"<cmd>TabToggle<CR>",
			desc = "Switch Space/Tab mode",
		},
		{
			"<leader>ts",
			"<cmd>TabStatus<CR>",
			desc = "Show current tab setting",
		},

		-- Auto format
		{
			"<leader>fmt",
			"<cmd>FormatToggle<CR>",
			desc = "Switch auto format mode",
		},

		-- File operations
		{ "<leader>e", ":source %<CR>", desc = "Reload current lua file" },
		{ "<leader>w", ":w<CR>", desc = "Write file" },
		{ "<leader>q", ":bd<CR>", desc = "Quit file" },
		{ "<leader>wq", "<Cmd>w<Bar>bd<CR>", desc = "Write and quit" },
		{ "<leader>qa", ":qa<CR>", desc = "Quit all" },

		-- Buffer operations
		{ "<leader>b", group = "buffer" },
		-- Navigation
		{ "<C-d>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
		{ "<C-a>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },
		-- Move
		{ "<leader>b>", "<Cmd>BufferLineMoveNext<CR>", desc = "Move right" },
		{ "<leader>b<", "<Cmd>BufferLineMovePrev<CR>", desc = "Move left" },
		-- Pick & Close
		{ "<leader>bb", "<Cmd>BufferLinePick<CR>", desc = "Pick buffer" },
		{ "<leader>bd", "<Cmd>bdelete<CR>", desc = "Close current" },
		{
			"<leader>bo",
			"<Cmd>BufferLineCloseOthers<CR>",
			desc = "Close others",
		},
		{
			"<leader>br",
			"<Cmd>BufferLineCloseRight<CR>",
			desc = "Close right",
		},
		{ "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Close left" },
		-- Sort only, no groups
		{
			"<leader>bs",
			"<Cmd>BufferLineSortByDirectory<CR>",
			desc = "By directory",
		},
		{
			"<leader>bS",
			"<Cmd>BufferLineSortByExtension<CR>",
			desc = "By extension",
		},
		{ "<leader>bl", ":buffers<CR>", desc = "List buffers" },

		-- Display settings
		{ "<leader>~", "<cmd>ListToggle<CR>", desc = "Switch toggle list" },

		-- File path operations
		{
			"<leader>p",
			"<Cmd>lua print('📁 ' .. vim.fn.expand('%:p'))<CR>",
			desc = "Show full file path",
		},
		{
			"<leader>cp",
			"<Cmd>lua local path = vim.fn.expand('%:p'); vim.fn.setreg('+', path); vim.notify('📋 Copied: ' .. path, vim.log.levels.INFO)<CR>",
			desc = "Copy file path",
		},

		-- Buffer navigation
		{ "<Esc><Esc>", "<cmd>nohlsearch<CR>", desc = "Cancel highlight" },

		-- Add coments header and func/file annotations
		{ "<leader>//", "<cmd>AddHeader<CR>", desc = "Add header comment" },
		{
			"<leader>/",
			"<cmd>AddComment<CR>",
			desc = "Add func/file comment",
		},

		-- Nvim tree keybindings
		-- {
		-- 	"<leader>n",
		-- 	"<cmd>NvimTreeToggle<CR>",
		-- 	desc = "Toggle file explorer",
		-- },
		-- {
		-- 	"<leader>m",
		-- 	"<cmd>NvimTreeFindFile<CR>",
		-- 	desc = "Find the file location",
		-- },
		-- {
		-- 	"<leader>>",
		-- 	":vertical resize +5<CR>",
		-- 	desc = "Expanding nvim tree width",
		-- },
		-- {
		-- 	"<leader><",
		-- 	":vertical resize -5<CR>",
		-- 	desc = "Reduce nvim tree width",
		-- },

		-- Neo tree keybindings
		{ "<leader>n", group = "neotree" },
		{
			"<leader>nn",
			"<cmd>NeotreeToggle<CR>",
			desc = "Toggle file explorer",
		},
		{
			"<leader>nf",
			"<cmd>NeotreeToggleFloat<CR>",
			desc = "Toggle file explorer float",
		},
		{
			"<leader>nc",
			"<cmd>NeotreeToggleCurrent<CR>",
			desc = "Toggle file explorer this buffer",
		},
		{
			"<leader>nw",
			"<cmd>Neotree reveal<CR>",
			desc = "Where is current file",
		},

		-- Open the outline
		{
			"<leader>l",
			"<cmd>Outline<CR>",
			desc = "Open outline",
		},

		-- Trouble
		{ "<leader>x", group = "troube" },
		{
			"<leader>xx",
			"<cmd>Trouble diagnostics toggle<cr>",
			desc = "Diagnostics (document)",
		},
		{
			"<leader>xw",
			"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
			desc = "Diagnostics (workspace)",
		},
		{
			"<leader>xs",
			"<cmd>Trouble symbols toggle<cr>",
			desc = "Symbols (document)",
		},
		{
			"<leader>xS",
			"<cmd>Trouble lsp toggle focus=false<cr>",
			desc = "LSP references/definitions",
		},
		{
			"<leader>xl",
			"<cmd>Trouble loclist toggle<cr>",
			desc = "Location list",
		},
		{
			"<leader>xq",
			"<cmd>Trouble qflist toggle<cr>",
			desc = "Quickfix list",
		},
		{ "<leader>xc", "<cmd>Trouble close<cr>", desc = "Close Trouble" },

		-- Telescope search files and string
		{ "<leader>f", group = "telescope" },
		-- Telescope file operations
		{ "<leader>ff", "<cmd>FindFiles<CR>", desc = "Find files" },
		{ "<leader>fg", "<cmd>FindGrep<CR>", desc = "Live grep" },
		-- Telescope helps
		{ "<leader>fh", "<cmd>FindHelp<CR>", desc = "Help tags" },
		-- Telescope search one word
		{ "<leader>fs", "<cmd>FindString<CR>", desc = "Search current word" },
		-- Telescope search one symbol bt tags
		{ "<leader>ft", "<cmd>FindSymbol<CR>", desc = "Search current word" },
		-- Telescope search symbol
		{ "<leader>fT", "<cmd>SearchTags<CR>", desc = "Search current word" },
		-- Telescope search buffer
		{ "<leader>fb", "<cmd>:Telescope buffers<CR>",  desc = "Search buffers" },
		-- Telescope search used file
		{ "<leader>fo", "<cmd>:Telescope oldfiles<CR>", desc = "Search oled files" },

		-- Flash search words
		{ "s", "<cmd>FlashJump<CR>", desc = "Search word" },

		-- Neoscroll keybindings
		{ "<C-k>", "<cmd>Scroll -5<CR>", desc = "scroll up" },
		{ "<C-j>", "<cmd>Scroll 5<CR>", desc = "scroll down" },

		-- Fommatter keybindings
		{ "<leader>FF", "<cmd>Format<CR>", desc = "format code" },

		-- Theme change
		{ "<leader>tn", "<cmd>ThemeNext<CR>", desc = "Theme next" },
		{ "<leader>tm", "<cmd>ThemeMode<CR>", desc = "Theme mode switch" },
		{ "<leader>tf", "<cmd>ThemeChoose<CR>", desc = "Theme mode switch" },

		{ "<leader>g",  group = "gitsigns" },
		{
			"<leader>gn",
			"<cmd>GitSignsNextHunk<CR>",
			desc = "Jump to next hunk",
		},
		{
			"<leader>gp",
			"<cmd>GitSignsPrevHunk<CR>",
			desc = "Jump to previous hunk",
		},
		{
			"<leader>gh",
			"<cmd>GitSignsPreviewHunk<CR>",
			desc = "Preview current hunk",
		},
		{
			"<leader>gl",
			"<cmd>GitSignsBlameLine<CR>",
			desc = "Show blame for current line",
		},
		{
			"<leader>gb",
			"<cmd>GitSignsBlame<CR>",
			desc = "Show blame for current line",
		},
		{
			"<leader>gd",
			"<cmd>GitSignsDiffThis<CR>",
			desc = "Show diff of current file",
		},
		{
			"<leader>ga",
			"<cmd>GitSignsStageHunk<CR>",
			desc = "Add this hunk",
		},
		{
			"<leader>gu",
			"<cmd>GitSignsUndoStageHunk<CR>",
			desc = "Undo add this hunk",
		},
	},

	-- Both insert and nomal mode keybindings
	{
		mode = { "n", "i" },
		-- Multi-mode Coc mappings
	},

	-- Insert mode keybindings
	{
		mode = "i",
	},

	-- Visual mode keybindings
	{
		mode = "v",
	},
})
