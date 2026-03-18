-- File: lua/plugins/nvim-cmp.lua
-- Purpose: Configure nvim-cmp (completion engine) and integrate with LuaSnip.

local cmp = require("cmp")
local luasnip = require("luasnip")

-- 1. LuaSnip setup (if not already configured elsewhere)
require("luasnip").setup({
	history = true,
	updateevents = "TextChanged,TextChangedI",
})

-- 2. nvim-cmp configuration
cmp.setup({
	-- How snippets are expanded (using LuaSnip)
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},

	-- Key mappings
	mapping = cmp.mapping.preset.insert({
		-- Scroll documentation window
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),

		-- Open completion menu manually
		["<C-Space>"] = cmp.mapping.complete(),

		-- Close completion menu
		["<C-e>"] = cmp.mapping.abort(),

		-- Accept the selected item (if none selected, accept the first)
		["<CR>"] = cmp.mapping.confirm({ select = true }),

		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),  -- i=插入模式, s=选择模式

		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),

	-- Completion sources (order matters: first source has highest priority)
	sources = cmp.config.sources({
		{ name = "nvim_lsp" }, -- LSP suggestions (requires cmp-nvim-lsp)
		{ name = "luasnip" }, -- Snippet suggestions
		{ name = "buffer" }, -- Words from current buffer
		{ name = "path" }, -- File system paths
	}),

	-- Optional: customize the appearance of completion items
	formatting = {
		format = function(entry, vim_item)
			-- Add source name as a small label
			vim_item.menu = ({
				nvim_lsp = "[LSP]",
				luasnip = "[Snip]",
				buffer = "[Buf]",
				path = "[Path]",
			})[entry.source.name]
			return vim_item
		end,
	},

	experimental = {
		ghost_text = true,
	},
})

-- 3. Command-line completion (for : and / modes)
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" }, -- file paths
	}, {
		{ name = "cmdline" }, -- vim commands
	}),
})

cmp.setup.cmdline("/", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" }, -- search history from buffer
	},
})
