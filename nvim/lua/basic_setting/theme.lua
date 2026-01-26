-- File: lua/basic_setting/theme.lua

local theme = {}

-- get cureent theme
local function get_current_theme()
    return require('basic_setting.settings').get_config("current", "themes") or "catppuccin"  -- 默认使用 'catppuccin'
end

-- set current theme
local function set_current_theme(new_theme)
    local available_themes = require('basic_setting.settings').get_config("available", "themes") or {}
    local is_valid_theme = false
    for _, theme in ipairs(available_themes) do
        if theme == new_theme then
            is_valid_theme = true
            break
        end
    end
    
    if not is_valid_theme then
        print("❌ Theme " .. new_theme .. " is not available!")
        return
    end

    require('basic_setting.settings').set_config("current", new_theme, "themes")

    vim.cmd("colorscheme " .. new_theme)
    -- vim.notify("✅ Switched to " .. new_theme .. " theme!")
end

-- switch next theme
theme.toggle_next_theme = function()
    local current_theme = get_current_theme()
    local available_themes = require('basic_setting.settings').get_config("available", "themes") or {}
    
    local next_theme_index = 1
    for i, theme in ipairs(available_themes) do
        if theme == current_theme then
            next_theme_index = (i % #available_themes) + 1
            break
        end
    end
    
    local next_theme = available_themes[next_theme_index]
    set_current_theme(next_theme)
end

-- switch theme by name
theme.switch_theme = function(theme_name)
    set_current_theme(theme_name)
end

-- display cureent theme
theme.show_current_theme = function()
    local current_theme = get_current_theme()
    vim.notify("Current theme: " .. current_theme)
end

-- Load current theme
theme.load_theme = function()
    theme.switch_theme(get_current_theme())
end

-- Switch light and dark module
theme.switch_theme_mod = function ()
    local mode = require('basic_setting.settings').get_config("background", "options") or "dark"
    if mode == "light" then
        require('basic_setting.settings').set_config("background", "dark", "options")
    else
        require('basic_setting.settings').set_config("background", "light", "options")
    end
end

theme.load_theme()

-- create new command
vim.api.nvim_create_user_command(
    'ThemeNext',
    function()
        theme.toggle_next_theme()
    end,
    { desc = 'Switch to the next available theme' }
)

vim.api.nvim_create_user_command(
    'ThemeSet',
    function(opts)
        theme.switch_theme(opts.args)
    end,
    { nargs = 1, desc = 'Switch to a specific theme (e.g., :ThemeSet catppuccin)' }
)

vim.api.nvim_create_user_command(
    'ThemeMode',
    function ()
        theme.switch_theme_mod()
    end,
    {desc = 'Switch theme mode'}
)

return theme

