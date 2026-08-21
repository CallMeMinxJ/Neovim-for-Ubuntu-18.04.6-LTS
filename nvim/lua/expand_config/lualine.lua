-- =============================================================================
-- Lualine.nvim Configuration
-- Professional, flat design — follows theme automatically
-- =============================================================================

local navic = require("nvim-navic")

require("lualine").setup({
    options = {
        theme = "auto", -- Follow the colorscheme automatically
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        globalstatus = true,
    },
    sections = {
        lualine_a = {
            { "mode", right_padding = 2 },
        },
        lualine_b = {
            "branch",
            "diff",
            "diagnostics",
        },
        lualine_c = {
            "filename",
            "%=", -- center alignment marker
        },
        lualine_x = {
            "filetype",
        },
        lualine_y = {
            "progress",
        },
        lualine_z = {
            { "location", left_padding = 2 },
        },
    },
    inactive_sections = {
        lualine_a = { "filename" },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { "location" },
    },
    tabline = {},
    extensions = {},
    winbar = {
        lualine_c = {
            {
                function()
                    return navic.get_location()
                end,
                cond = function()
                    return navic.is_available()
                end,
            },
        },
    },
})