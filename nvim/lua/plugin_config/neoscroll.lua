local neoscroll = require('neoscroll')

neoscroll.setup({
  mappings = {}, -- 禁用所有默认键位
  hide_cursor = true,
  stop_eof = true,
  respect_scrolloff = false,
  cursor_scrolls_alone = true,
  duration_multiplier = 1.0,
  easing = 'linear',
  pre_hook = nil,
  post_hook = nil,
  performance_mode = false,
  ignored_events = { 'WinScrolled', 'CursorMoved' },
})

-- 只绑定你需要的两个键位
local keymap = {
  ["<C-k>"] = function()
    neoscroll.scroll(-10.0, { move_cursor = true, duration = 200 })
  end,
  ["<C-j>"] = function()
    neoscroll.scroll(10.0, { move_cursor = true, duration = 200 })
  end,
}

local modes = { "n", "v", "x" }
for key, func in pairs(keymap) do
  vim.keymap.set(modes, key, func, { silent = true })
end

