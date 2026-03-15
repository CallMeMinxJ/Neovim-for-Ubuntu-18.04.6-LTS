-- luasnip
require("luasnip").config.setup({
	history = true,
	updateevents = "TextChanged,TextChangedI",
	enable_autosnippets = true,
	ext_opts = nil,
	parser_nested_assembler = nil,
	load_ft_func = require("luasnip.extras.filetype_functions").from_filetype_load,
})

-- my snippets declare
local config_dir = vim.fn.stdpath("config") -- e.g. z:\home\astor\neovim\nvim
local snippets_dir = config_dir .. "/lua/snippets"

require("luasnip.loaders.from_lua").load({
	paths = snippets_dir,
})

require("luasnip").filetype_extend("h", { "c" })
require("luasnip").filetype_extend("cpp", { "c" })
