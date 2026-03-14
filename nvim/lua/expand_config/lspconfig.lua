-- File: lua/plugins/lsp.lua
-- Purpose: Configure LSP clients using Neovim's built-in vim.lsp.config (Nvim 0.12+).

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local on_attach = function(client, bufnr)
	vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
	local opts = { buffer = bufnr, noremap = true, silent = true }
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
	vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
	vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
	if client.server_capabilities.documentFormattingProvider then
		vim.keymap.set("n", "<leader>f", function()
			vim.lsp.buf.format({ async = true })
		end, opts)
	end
end

-- Lua (lua_ls)
vim.lsp.config.lua_ls = {
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		Lua =
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } },
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
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
				typeCheckingMode = "basic",
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
			},
		},
	},
}

-- Bash (bashls)
vim.lsp.config.bashls = {
	capabilities = capabilities,
	on_attach = on_attach,
}

-- JSON (jsonls)
vim.lsp.config.jsonls = {
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		json = {
			validate = { enable = true },
		},
	},
}

-- TOML (taplo)
vim.lsp.config.taplo = {
	capabilities = capabilities,
	on_attach = on_attach,
}

-- C/C++ (clangd)
vim.lsp.config.clangd = {
	capabilities = capabilities,
	on_attach = on_attach,
	cmd = { "clangd", "--background-index" },
	init_options = { usePlaceholders = true },
}

-- Enable only the LSP servers you have installed
vim.lsp.enable({
	"bashls",
	"clangd",
	"jsonls",
	"lua_ls",
	"pyright",
	"taplo",
})
