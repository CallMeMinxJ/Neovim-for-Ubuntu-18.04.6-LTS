-- =============================================================================
-- Bufferline.nvim Configuration
-- Modern, clean buffer line with dark theme compatibility
-- =============================================================================

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
    if vim.bo[buf_number].filetype == "help" then
        return false
    end
    if vim.bo[buf_number].buftype == "quickfix" then
        return false
    end
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
        mode = "buffers",
        style_preset = bufferline.style_preset.default,
        themable = true,

        numbers = buffer_numbers,

        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        left_mouse_command = "buffer %d",
        middle_mouse_command = nil,

        -- Active buffer indicator
        indicator = {
            icon = "▎",
            style = "icon",
        },

        -- Icons
        buffer_close_icon = "󰅖",
        modified_icon = "●",
        close_icon = "󰅖",
        left_trunc_marker = "",
        right_trunc_marker = "",

        -- Name formatting
        max_name_length = 22,
        max_prefix_length = 15,
        truncate_names = true,
        tab_size = 0, -- auto-size

        -- LSP Diagnostics
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        diagnostics_update_on_event = true,
        diagnostics_indicator = diagnostics_indicator,

        -- Filter
        custom_filter = custom_filter,

        -- Sidebar offsets
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

        -- Appearance
        color_icons = true,
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        show_duplicate_prefix = true,
        duplicates_across_groups = true,
        persist_buffer_sort = true,
        move_wraps_at_ends = false,

        -- Thin separator: 1px line between tabs, no white gaps
        separator_style = "thin",

        -- Tab sizing
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        auto_toggle_bufferline = true,

        -- Hover shows close button
        hover = {
            enabled = true,
            delay = 200,
            reveal = { "close" },
        },

        -- Sorting
        sort_by = "insert_after_current",

        -- Buffer groups
        groups = {
            items = {},
        },

        -- Pick buffer by letter
        pick = {
            alphabet = "abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMOPQRSTUVWXYZ1234567890",
        },
    },

    -- =============================================================================
    -- Highlights: let the theme handle everything (themable = true)
    -- Only override separator to avoid white gaps
    -- =============================================================================
    highlights = {
        -- Blend separators into the bar background, preventing white gaps
        separator = {
            fg = { attribute = "bg", highlight = "TabLine" },
        },
        separator_selected = {
            fg = { attribute = "bg", highlight = "TabLine" },
        },
        separator_visible = {
            fg = { attribute = "bg", highlight = "TabLine" },
        },
        -- Active tab text: bold, no italic
        buffer_selected = {
            bold = true,
            italic = false,
        },
    },
})