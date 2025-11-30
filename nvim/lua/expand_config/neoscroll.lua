local neoscroll = require('neoscroll')

neoscroll.setup({
  mappings = {}, -- disable default keymaps
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

-- Create new command
vim.api.nvim_create_user_command(
    'Scroll',
    function(opts)
        local lines = tonumber(opts.args)
        neoscroll.scroll(lines, { move_cursor = true, duration = 50 })
    end,
    { nargs = 1 }
)

-- Ensure keybinding is for normal mode
-- vim.keymap.set('n', '<C-k>', '<cmd>Scroll -10<CR>', { noremap = true, silent = true, desc = "scroll up" })
-- vim.keymap.set('n', '<C-j>', '<cmd>Scroll 10<CR>', { noremap = true, silent = true, desc = "scroll down" })

