local ok, telescope = pcall(require, 'telescope')
if not ok then
  vim.notify('telescope not found', vim.log.levels.ERROR)
  return
end

local actions = require('telescope.actions')

telescope.setup{
    defaults = {
        prompt_prefix = '❯ ',
        selection_caret = '➜ ',
        path_display = {"smart"},
        mappings = {
            i = {
                ["<esc>"] = actions.close,
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
            },
            n = {
                ["q"] = actions.close,
            },
        },
    },
    pickers = {
        find_files = {
          theme = "dropdown",
        },
        buffers = {
          sort_lastused = true,
          previewer = false,
        },
    },
    -- 默认就用 rg
    vimgrep_arguments = {
      "rg",                       -- 0. 必须
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden",                 -- 想要搜索隐藏文件就加
      "--glob=!.git/",            -- 排除 .git
    },
    file_ignore_patterns = { "%.jpg", "%.png", "%.git/" },
    extensions = {
        fzf = {
          fuzzy = true,               -- 模糊匹配
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",   -- 大小写策略
        },
    }
}
require('telescope').load_extension('fzf')

-- 快捷使用的一组 keymaps（可移动到 keymaps.lua）
local builtin = require('telescope.builtin')
local map = vim.keymap.set
map('n', '<leader>ff', builtin.find_files, {desc = 'Telescope find_files'})
map('n', '<leader>fg', builtin.live_grep,  {desc = 'Telescope live_grep'})
map('n', '<leader>fb', builtin.buffers,    {desc = 'Telescope buffers'})
map('n', '<leader>fh', builtin.help_tags,  {desc = 'Telescope help_tags'})
map('n', '<leader>s', function()
    require('telescope.builtin').grep_string({
        search = vim.fn.expand('<cword>'),
        only_sort_text = true,
        word_match = '-w',  -- 全词匹配
        use_regex = false,  -- 不使用正则，直接搜索字面量
    })
end)--可带参数调用，例如显示隐藏文件:
-- map('n', '<leader>fF', function() builtin.find_files({hidden=true, no_ignore=true}) end, {desc = 'find files (hidden)'})

