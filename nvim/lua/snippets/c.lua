-- ~/.config/nvim/lua/snippets/c.lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

-- 辅助函数：计算填充长度
local fill_line = function(args)
	local text = args[1][1]
	local total = 80
	local used = 6 + #text -- "/* " + " */" = 6 chars
	local fill = total - used
	return string.rep("-", math.max(fill, 0))
end

return {
	-- 行注释：输入 line<Tab>
	s(
		"line",
		fmt("/* {} {}*/", {
			i(1, "Description"),
			f(fill_line, { 1 }),
		})
	),

	-- C++ 头文件保护：输入 ifcpp<Tab>
	s(
		"ifcpp",
		fmt(
			[[
#ifndef {}_H
#define {}_H

#ifdef __cplusplus
extern "C" {{
#endif

{}

#ifdef __cplusplus
}}
#endif

#endif /* {} */
]],
			{
				i(1, "FILENAME"),
				f(function(args)
					return args[1][1]
				end, { 1 }), -- 复制第1个
				i(2, "// your code here"),
				f(function(args)
					return args[1][1]
				end, { 1 }), -- 复制第1个
			}
		)
	),

	-- string function comments result
	s(
		"rst",
			fmt("0 for success, others for fail", {})
	),
}

