-- Ensure packer is loaded (since we put it under ~/neovim/nvim/pack)
vim.cmd [[packadd packer.nvim]]

local ok, packer = pcall(require, 'packer')
if not ok then
    print('Error: packer.nvim not found (packadd failed).')
    return
end

-- Get current path
local config_dir = vim.fn.stdpath('config')  -- e.g. z:\home\astor\neovim\nvim
local plugins_dir = vim.fn.fnamemodify(config_dir .. '/addons/', ':p')
local colors_dir = vim.fn.fnamemodify(config_dir .. '/themes/', ':p')

packer.init {
    git = {
        cmd = 'false',
    },
    auto_clean = false,
}

packer.startup(function(use)

    -- register local plugins from ./plugins/<name>
    use { plugins_dir .. "nvim-web-devicons"}
    use { plugins_dir .. "lualine.nvim"}
    use { plugins_dir .. "nvim-tree.lua"}
    use { plugins_dir .. "plenary.nvim"}
    use { plugins_dir .. "telescope.nvim"}
    use { plugins_dir .. "telescope-fzf-native.nvim", run = 'make' }
    use { plugins_dir .. "bufferline.nvim"}
    use { plugins_dir .. "coc.nvim"}
    use { plugins_dir .. "nvim-treesitter"}
    use { plugins_dir .. "comment.nvim"}
    use { plugins_dir .. "indent-blankline.nvim"}
    use { plugins_dir .. "neoscroll.nvim"}
    use { plugins_dir .. "which-key"}
    use { plugins_dir .. "neogen"}
    use { plugins_dir .. "header.nvim"}
    use { plugins_dir .. "alpha.nvim"}
    use { plugins_dir .. "marks.nvim"}

    -- register local theme from ./colors/<name>
    use { colors_dir .. "catppuccin", as = "catppuccin" }
    -- use_theme(use, 'tokyonight')
    -- use_theme(use, 'rosepine')
    -- use_theme(use, 'gruvbox')
    -- use_theme(use, 'catppuccin')
    -- use_theme(use, 'kanagawa')

    -- Example: if a local plugin requires config, you can do:
    -- use { plugins_dir .. 'lualine.nvim', config = function() require('lualine').setup{} end }
end)

-- External expand configs
local expand_configs = {
    -- plugin manage
    'expand_config.nvim-web-devicons',
    'expand_config.lualine',
    'expand_config.nvim-tree',
    'expand_config.telescope',
    'expand_config.bufferline',
    'expand_config.coc',
    'expand_config.nvim-treesitter',
    'expand_config.comment',
    'expand_config.indent-blankline',
    'expand_config.neoscroll',
    'expand_config.which-key',
    'expand_config.neogen',
    'expand_config.header',
    'expand_config.alpha',
    'expand_config.marks',

    -- expand lua scripts
    'expand_config.tab-mode',

    -- theme manage
    'color_config.catppuccin',
    -- 'color_config.gruvbox',
    -- 'color_config.tokyonight',
    -- 'color_config.rosepine',
    -- 'color_config.kanagawa',
}

for _, name in ipairs(expand_configs) do
    local ok, _ = pcall(require, name)
    if not ok then
        print("Warning: no config found for " .. name)
        -- 添加调试信息查看具体路径
        local module_path = name:gsub('%.', '/')
        print("  Expected file: lua/" .. module_path .. ".lua")
    end
end
