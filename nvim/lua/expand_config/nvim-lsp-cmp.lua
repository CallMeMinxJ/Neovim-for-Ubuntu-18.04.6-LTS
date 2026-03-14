-- File: lua/plugins/nvim-lsp-cmp.lua
-- Purpose: Provide LSP capabilities enhanced by cmp-nvim-lsp.
--          This module returns a capabilities table that should be passed
--          to every LSP server configuration.

local cmp_nvim_lsp = require("cmp_nvim_lsp")

-- Generate default capabilities that include LSP completion features
-- supported by nvim-cmp (e.g., snippets, auto-trigger, etc.)
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend(
	"force",
	capabilities,
	cmp_nvim_lsp.default_capabilities() -- merges snippet support, resolve support, etc.
)

return capabilities
