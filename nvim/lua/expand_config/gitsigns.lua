-- File: lua/basic_setting/gitsigns.lua

require('gitsigns').setup {
  signs = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signs_staged = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signs_staged_enable = true,
  signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
  numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    follow_files = true
  },
  auto_attach = true,
  attach_to_untracked = false,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
    virt_text_priority = 100,
    use_focus = true,
  },
  current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000, -- Disable if file is longer than this (in lines)
  preview_config = {
    -- Options passed to nvim_open_win
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
}
-- 使用 vim.api.nvim_create_user_command 定义命令
vim.api.nvim_create_user_command(
  'GitSignsNextHunk',
  function()
    require('gitsigns').next_hunk()  -- 跳到下一个 hunk
  end,
  { desc = 'Jump to next hunk' }
)

vim.api.nvim_create_user_command(
  'GitSignsPrevHunk',
  function()
    require('gitsigns').prev_hunk()  -- 跳到上一个 hunk
  end,
  { desc = 'Jump to previous hunk' }
)

vim.api.nvim_create_user_command(
  'GitSignsStageHunk',
  function()
    require('gitsigns').stage_hunk()  -- 阶段化当前变动
  end,
  { desc = 'Stage current hunk' }
)

vim.api.nvim_create_user_command(
  'GitSignsUndoStageHunk',
  function()
    require('gitsigns').undo_stage_hunk()  -- 撤销阶段化当前变动
  end,
  { desc = 'Undo stage current hunk' }
)

vim.api.nvim_create_user_command(
  'GitSignsPreviewHunk',
  function()
    require('gitsigns').preview_hunk()  -- 预览当前变动
  end,
  { desc = 'Preview current hunk' }
)

vim.api.nvim_create_user_command(
  'GitSignsBlameLine',
  function()
    require('gitsigns').blame_line()  -- 查看当前行的 blame 信息
  end,
  { desc = 'Show Git blame for current line' }
)

vim.api.nvim_create_user_command(
  'GitSignsBlame',
  function()
    require('gitsigns').blame()  -- 查看当前行的 blame 信息
  end,
  { desc = 'Show Git blame' }
)

vim.api.nvim_create_user_command(
  'GitSignsDiffThis',
  function()
    require('gitsigns').diffthis()  -- 查看当前文件的 diff
  end,
  { desc = 'Show current file diff' }
)

