require("nvim-treesitter.configs").setup({
	ensure_installed = { "bash", "lua", "python", "cpp", "json" }, -- 支持的语言
	sync_install = false, -- 是否同步安装 parser
	auto_install = false, -- 自动安装缺失的 parser
	highlight = {
		enable = true, -- 启用语法高亮
		additional_vim_regex_highlighting = false,
		custom_captures = {
			["injection.content"] = "InactiveCode", -- 关键：替换原来的 set_custom_captures
			["constant.macro"] = "ConstantMacro",
			["variable.parameter"] = "MacroParameter",
		},
	},
	indent = {
		enable = true, -- 启用智能缩进
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "gnn", -- 初始化选择
			node_incremental = "grn", -- 增量选择
			node_decremental = "grm", -- 反向选择
		},
	},
	textobjects = {
		select = {
			enable = true,
			lookahead = true,
			keymaps = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
			},
		},
	},
})
