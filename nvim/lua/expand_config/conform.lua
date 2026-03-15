-- conform.nvim configuration
-- Unified formatter management, faster than LSP formatting

local ok, conform = pcall(require, "conform")
if not ok then
	print("Error: conform.nvim not found")
	return
end

conform.setup({
	-- Formatter selection by filetype
	formatters_by_ft = {
		-- Lua: stylua with 4-space indent
		lua = { "stylua" },

		-- Python: import sorting then formatting
		python = { "isort", "black" },

		-- Web frontend
		javascript = { "prettier" },
		typescript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },

		-- Data formats
		json = { "prettier" },
		yaml = { "prettier" },
		markdown = { "prettier" },
		toml = { "taplo" },

		-- C/C++: clang-format with .clang-format file detection
		c = { "clang_format" },
		cpp = { "clang_format" },

		-- Shell scripts
		sh = { "shfmt" },
		bash = { "shfmt" },
		zsh = { "shfmt" },
	},

	-- Auto-format on save
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true, -- Fallback to LSP if no formatter configured
	},

	-- Individual formatter options
	formatters = {
		-- Lua: 4 spaces, no semicolons
		stylua = {
			prepend_args = {
				"--indent-type",
				"Tabs",
				"--indent-width",
				"4",
				"--column-width",
				"80",
			},
		},

		-- Python: 88 char line length (black default)
		black = {
			prepend_args = { "--line-length", "80" },
		},

		-- C/C++: Use tab with width 8, detect .clang-format in project root
		clang_format = {
			-- Default style when no .clang-format file found
			-- Use LLVM style with tabs
			prepend_args = function(self, ctx)
				local args = {
					"--style={\
						BasedOnStyle: LLVM,\
						IndentWidth: 8,\
						TabWidth: 8,\
						UseTab: Always,\
						ColumnLimit: 80,\
						BreakBeforeBraces: Attach,\
						AllowShortIfStatementsOnASingleLine: false,\
					}",
				}

				-- Check for .clang-format file in project root or current directory
				-- If found, clang-format will automatically use it (ignore --style)
				local clang_format_file =
					vim.fn.findfile(".clang-format", ctx.dirname .. ";")
				if clang_format_file ~= "" then
					-- .clang-format exists, let clang-format use it
					-- Remove --style argument by returning empty or minimal args
					return {}
				end

				return args
			end,
		},

		-- Shell: tabs, indent 4
		shfmt = {
			prepend_args = { "-i", "4", "-ci", "-bn" },
		},

		-- TOML: standard formatting
		taplo = {
			prepend_args = { "format", "-" },
		},

		-- Prettier: use project config if exists, else default
		prettier = {
			-- Prettier automatically finds .prettierrc, package.json, etc.
			-- No need for explicit args unless overriding
			prepend_args = function(self, ctx)
				-- Check for project config files
				local config_files = {
					".prettierrc",
					".prettierrc.json",
					".prettierrc.yml",
					".prettierrc.yaml",
					".prettierrc.js",
					"prettier.config.js",
					"package.json",
				}

				for _, config in ipairs(config_files) do
					if vim.fn.findfile(config, ctx.dirname .. ";") ~= "" then
						-- Project config found, use it
						return {}
					end
				end

				-- No config found, use reasonable defaults
				return {
					"--tab-width",
					"4",
					"--use-tabs",
					"true",
					"--print-width",
					"80",
					"--trailing-comma",
					"allConformInfoConformInfo",
					"--bracket-spacing",
					"true",
				}
			end,
		},
	},

	-- Notify on format errors
	notify_on_error = true,

	-- Custom format function for range formatting
	format = function(opts)
		return conform.format(opts)
	end,
})

-- Manual format command with optional range support
vim.api.nvim_create_user_command("Format", function(args)
	local range = nil
	if args.count ~= -1 then
		local end_line =
			vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
		range = {
			start = { args.line1, 0 },
			["end"] = { args.line2, end_line:len() },
		}
	end

	conform.format({
		async = true,
		lsp_fallback = true,
		range = range,
	})

	print("Call Format")
end, { range = true, desc = "Format buffer or visual selection" })

-- Format and save command
vim.api.nvim_create_user_command("FormatWrite", function()
	conform.format({
		async = false,
		lsp_fallback = true,
	})
	vim.cmd.write()
end, { desc = "Format then save" })

-- Toggle auto-format on save
local format_on_save_enabled = true

vim.api.nvim_create_user_command("FormatToggle", function()
	format_on_save_enabled = not format_on_save_enabled
	conform.setup({
		format_on_save = format_on_save_enabled and {
			timeout_ms = 500,
			lsp_fallback = true,
		} or false,
	})
	print(
		"Format on save: "
			.. (format_on_save_enabled and "enabled" or "disabled")
	)
end, { desc = "Toggle auto-format on save" })
