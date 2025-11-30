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

-- Create new command
vim.api.nvim_create_user_command(
    'FindFiles',
    function()
        require('telescope.builtin').find_files()
    end,
    { nargs = 0 }
)

vim.api.nvim_create_user_command(
    'FindGrep',
    function()
        require('telescope.builtin').live_grep()
    end,
    { nargs = 0 }
)

vim.api.nvim_create_user_command(
    'FindHelp',
    function()
        require('telescope.builtin').help_tags()
    end,
    { nargs = 0 }
)

vim.api.nvim_create_user_command(
    'FindString',
    function()
        require('telescope.builtin').grep_string({
            search = vim.fn.expand('<cword>'),
            only_sort_text = true,
            word_match = '-w',
            use_regex = false
        })
    end,
    { nargs = 0 }
)



