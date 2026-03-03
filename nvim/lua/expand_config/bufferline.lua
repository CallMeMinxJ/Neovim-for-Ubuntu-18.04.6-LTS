-- =============================================================================
-- Bufferline.nvim Configuration
-- A snazzy buffer line (tab integration) for Neovim
-- =============================================================================

-- Required: Enable true colors support for proper rendering
vim.opt.termguicolors = true

local bufferline = require("bufferline")

-- =============================================================================
-- Helper Functions
-- =============================================================================

-- Custom numbers: show ordinal/total (e.g., "2/5")
local function buffer_numbers(opts)
    local total_buffers = #vim.fn.getbufinfo({ buflisted = 1 })
    return string.format("%d/%d", opts.ordinal, total_buffers)
end

-- Custom filter: hide help and quickfix buffers from bufferline
local function custom_filter(buf_number, buf_numbers)
    -- Filter out help buffers
    if vim.bo[buf_number].filetype == "help" then
        return false
    end
    -- Filter out quickfix buffers
    if vim.bo[buf_number].buftype == "quickfix" then
        return false
    end
    -- Filter out specific file patterns (example: log files)
    if vim.fn.bufname(buf_number):match("%.log$") then
        return false
    end
    return true
end

-- Diagnostics indicator with icons
local function diagnostics_indicator(count, level, diagnostics_dict, context)
    local icons = {
        error = " ",
        warning = " ",
        info = " ",
        hint = " ",
    }
    local icon = icons[level] or " "
    return " " .. icon .. count
end

-- =============================================================================
-- Main Setup
-- =============================================================================

bufferline.setup({
    options = {
        -- Mode: "buffers" (default) or "tabs"
        mode = "buffers",

        -- Style preset: default, minimal, no_bold, no_italic, or combined
        style_preset = bufferline.style_preset.default,

        -- Allow colorscheme to override highlights
        themable = true,

        -- Number display: "none" | "ordinal" | "buffer_id" | "both" | function
        numbers = buffer_numbers,

        -- Mouse actions
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        left_mouse_command = "buffer %d",
        middle_mouse_command = nil,

        -- Active buffer indicator
        indicator = {
            icon = "▎",
            style = "icon", -- "icon" | "underline" | "none"
        },

        -- Icons configuration
        buffer_close_icon = "󰅗", -- Close icon for each buffer
        modified_icon = "●",
        close_icon = "x", -- Global close icon
        left_trunc_marker = "",
        right_trunc_marker = "",

        -- Name formatting
        max_name_length = 18,
        max_prefix_length = 15,
        truncate_names = true,
        tab_size = 18,

        -- LSP Diagnostics integration
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        diagnostics_update_on_event = true,
        diagnostics_indicator = diagnostics_indicator,

        -- Custom filter for hiding specific buffers
        custom_filter = custom_filter,

        -- Sidebar offsets (file explorers)
        offsets = {
            {
                filetype = "NvimTree",
                text = "File Explorer",
                text_align = "left",
                separator = true,
            },
            {
                filetype = "neo-tree",
                text = "Neo-tree",
                text_align = "left",
                separator = true,
            },
            {
                filetype = "undotree",
                text = "Undo Tree",
                text_align = "center",
                separator = true,
            },
            {
                filetype = "Outline",
                text = "Symbols",
                text_align = "right",
                separator = true,
            },
        },

        -- Appearance options
        color_icons = true,
        show_buffer_icons = true,
        show_buffer_close_icons = true, -- Enable close icons on hover
        show_close_icon = true,
        show_tab_indicators = true,
        show_duplicate_prefix = true,
        duplicates_across_groups = true,
        persist_buffer_sort = true,
        move_wraps_at_ends = false,

        -- Separator style: "slant" | "slope" | "thick" | "thin" | "none" | { "any", "any" }
        separator_style = "slant",

        -- Tab sizing
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        auto_toggle_bufferline = true,

        -- Hover events: show close icon on hover
        hover = {
            enabled = true,
            delay = 200,
            reveal = { "close" },
        },

        -- Sorting
        sort_by = "insert_after_current", -- "insert_after_current" | "insert_at_end" | "id" | "extension" | "relative_directory" | "directory" | "tabs"

        -- Buffer groups with pin icon
        groups = {
            items = {},
        },

        -- Pick buffer by letter
        pick = {
            alphabet = "abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMOPQRSTUVWXYZ1234567890",
        },
    },

    -- =============================================================================
    -- Highlight Configuration (Auto-derived from colorscheme)
    -- =============================================================================
    highlights = {
        buffer_selected = {
            bold = true,
            italic = true,
        },
    },
})

