-- File: lua/plugins/lsp.lua
-- Purpose: Configure LSP clients using Neovim's built-in vim.lsp.config (Nvim 0.12+).
--          This file defines common on_attach, capabilities, and per‑server settings.

-- 1. Common capabilities for completion (used by nvim-cmp).
--    These tell LSP servers that we support snippets, signature help, etc.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend(
	"force",
	capabilities,
	require("cmp_nvim_lsp").default_capabilities() -- adds snippet support
)

-- 2. Common on_attach function: sets up keymaps and buffer‑local options.
--    This function runs every time an LSP client attaches to a buffer.
local on_attach = function(client, bufnr)
	-- Enable completion triggered by <c-x><c-o> (built-in omnifunc)
	vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

	-- Mappings.
	local opts = { buffer = bufnr, noremap = true, silent = true }

	-- Jump to definition
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	-- Find references
	vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	-- Hover documentation
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	-- Rename symbol
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	-- Code actions
	vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
	-- Go to previous/next diagnostic
	vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
	vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
	-- Show diagnostics in a floating window
	vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)

	-- If the server supports formatting, set up a keymap for it
	if client.server_capabilities.documentFormattingProvider then
		vim.keymap.set("n", "<leader>f", function()
			vim.lsp.buf.format({ async = true })
		end, opts)
	end
end

-- 3. Per‑server configurations.
--    Each vim.lsp.config.<server_name> table will be merged with the default
--    configuration provided by nvim-lspconfig (if any).
--    You only need to specify options you want to override or add.

-- Lua (lua_ls)
vim.lsp.config.lua_ls = {
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } }, -- Recognize 'vim' global
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true), -- Load Neovim runtime files
				checkThirdParty = false, -- Disable third-party checks
			},
			telemetry = { enable = false },
		},
	},
}

-- Python (pyright)
vim.lsp.config.pyright = {
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		python = {
			analysis = {
				typeCheckingMode = "basic", -- 'off', 'basic', or 'strict'
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
			},
		},
	},
}

-- TypeScript/JavaScript (tsserver)
vim.lsp.config.tsserver = {
	capabilities = capabilities,
	on_attach = on_attach,
	-- tsserver usually works out of the box; no extra settings needed.
}

-- Rust (rust_analyzer)
vim.lsp.config.rust_analyzer = {
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		["rust-analyzer"] = {
			-- Enable advanced features like inlay hints
			checkOnSave = { command = "clippy" },
			inlayHints = { enable = true },
		},
	},
}

-- C/C++ (clangd)
vim.lsp.config.clangd = {
	capabilities = capabilities,
	on_attach = on_attach,
	-- clangd usually works out of the box; you can add compile_commands.json hints if needed
	cmd = { "clangd", "--background-index" },
	init_options = { usePlaceholders = true },
}

-- Go (gopls)
vim.lsp.config.gopls = {
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		gopls = {
			analyses = { unusedparams = true },
			staticcheck = true,
			gofumpt = true, -- if you prefer gofumpt over gofmt
		},
	},
}

-- Java (jdtls)
-- Note: jdtls requires a workspace directory and may need extra setup.
-- The minimal configuration below works, but for full functionality consider using nvim-jdtls plugin.
vim.lsp.config.jdtls = {
	capabilities = capabilities,
	on_attach = on_attach,
	-- The cmd usually points to the launcher script provided by jdtls.
	-- Mason installs jdtls, but the command is "jdtls" (the launcher).
	cmd = { "jdtls" },
	-- It's recommended to set a workspace folder per project.
	-- You can set root_dir to a function that returns the project root.
	-- For simplicity, we rely on lspconfig's default root pattern.
	settings = {
		java = {
			-- You can add specific settings here, e.g., eclipse preferences
		},
	},
}

-- TOML (taplo)
vim.lsp.config.taplo = {
	capabilities = capabilities,
	on_attach = on_attach,
	-- taplo LSP also provides formatting; you can call vim.lsp.buf.format() to use it.
}

-- JSON (jsonls)
vim.lsp.config.jsonls = {
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		json = {
			-- schemas = require("schemastore").json.schemas(), -- optional: if you install "b0o/schemastore.nvim"
			validate = { enable = true },
		},
	},
}

-- Bash (bashls)
vim.lsp.config.bashls = {
	capabilities = capabilities,
	on_attach = on_attach,
	-- bashls provides diagnostics and completion.
}

-- Enable all new servers
vim.lsp.enable("clangd")
vim.lsp.enable("gopls")
vim.lsp.enable("jdtls")
vim.lsp.enable("taplo")
vim.lsp.enable("jsonls")
vim.lsp.enable("bashls")
