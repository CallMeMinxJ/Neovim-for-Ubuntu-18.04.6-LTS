local ok, telescope = pcall(require, "telescope")
if not ok then
    vim.notify("telescope not found", vim.log.levels.ERROR)
    return
end

local actions = require("telescope.actions")

telescope.setup({
    defaults = {
        prompt_prefix = "❯ ",
        selection_caret = "➜ ",
        path_display = { "smart" },
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
        "rg", -- 0. 必须
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--hidden", -- 想要搜索隐藏文件就加
        "--glob=!.git/", -- 排除 .git
    },
    file_ignore_patterns = { "%.jpg", "%.png", "%.git/" },
    extensions = {
        fzf = {
            fuzzy = true, -- 模糊匹配
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case", -- 大小写策略
        },
    },
})
require("telescope").load_extension("fzf")

local char_aspect_ratio = 2.0

local function get_adaptive_layout(correction_factor)
    correction_factor = correction_factor or 2.0

    local win_id = vim.api.nvim_get_current_win()
    local win_width = vim.api.nvim_win_get_width(win_id)
    local win_height = vim.api.nvim_win_get_height(win_id)

    -- 计算校正后的视觉宽高比
    local visual_ratio = win_width / (win_height * correction_factor)

    -- 判断布局
    if visual_ratio > 1.0 then
        -- 水平布局
        return {
            layout_strategy = "horizontal",
            layout_config = {
                horizontal = {
                    preview_width = 0.6,
                    width = 0.8,
                    height = 0.8,
					prompt_position = "top",
                },
            },
        }
    else
        -- 垂直布局
        return {
            layout_strategy = "vertical",
            layout_config = {
                vertical = {
                    preview_height = 0.6,
                    width = 0.8,
                    height = 0.8,
                    prompt_position = "top",
                },
            },
        }
    end
end

-- Create new command
vim.api.nvim_create_user_command("FindFiles", function()
    local layout = get_adaptive_layout(char_aspect_ratio)
    require("telescope.builtin").find_files(vim.tbl_extend("force", layout, {
        initial_mode = "insert",
    }))
end, { nargs = 0 })

vim.api.nvim_create_user_command("FindGrep", function()
    local layout = get_adaptive_layout(char_aspect_ratio)
    require("telescope.builtin").live_grep(vim.tbl_extend("force", layout, {
        initial_mode = "insert",
    }))
end, { nargs = 0 })

vim.api.nvim_create_user_command("FindHelp", function()
    local layout = get_adaptive_layout(char_aspect_ratio)
    require("telescope.builtin").help_tags(vim.tbl_extend("force", layout, {
        initial_mode = "insert",
    }))
end, { nargs = 0 })

vim.api.nvim_create_user_command("FindString", function()
    local layout = get_adaptive_layout(char_aspect_ratio)
    require("telescope.builtin").grep_string(vim.tbl_extend("force", layout, {
        search = vim.fn.expand("<cword>"),
        only_sort_text = true,
        word_match = "-w",
        use_regex = false,
    }))
end, { nargs = 0 })

vim.api.nvim_create_user_command("FindSymbol", function()
    local layout = get_adaptive_layout(char_aspect_ratio)
    local word = vim.fn.expand("<cword>")
    require("telescope.builtin").tags(vim.tbl_extend("force", layout, {
        default_text = word,
        initial_mode = "normal",
        search = "^" .. word .. "$",
    }))
end, { nargs = 0, desc = "Find tags for current word" })

vim.api.nvim_create_user_command("SearchTags", function()
    local layout = get_adaptive_layout(char_aspect_ratio)
    require("telescope.builtin").tags(vim.tbl_extend("force", layout, {
        initial_mode = "insert",
    }))
end, { nargs = 0, desc = "Search tags (empty dialog)" })
