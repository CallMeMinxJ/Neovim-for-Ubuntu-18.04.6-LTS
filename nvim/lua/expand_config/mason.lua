-- File: lua/plugins/mason.lua
require("mason").setup({
	ui = { check_outdated_packages_on_open = false },
})

require("mason-lspconfig").setup({
	ensure_installed = {
		-- LSP servers
	},
	automatic_installation = false,
})
