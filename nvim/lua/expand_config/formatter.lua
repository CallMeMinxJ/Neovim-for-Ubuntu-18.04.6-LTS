-- Utilities for creating configurations
local util = require("formatter.util")

-- Formatter configurations for C/C++ files that adapts to Neovim's indentation settings
local function clang_format_config()
    return function()
        -- Get current buffer's indentation settings
        local expandtab = vim.bo.expandtab
        local shiftwidth = vim.bo.shiftwidth
        local tabstop = vim.bo.tabstop
        
        -- Determine if we should use tabs or spaces based on expandtab
        local use_tab = expandtab and "Never" or "Always"
        
        -- Use shiftwidth if set, otherwise fall back to tabstop
        local indent_width = shiftwidth > 0 and shiftwidth or tabstop
        
        -- Build the style string
        local style_str = string.format(
            "--style='{" ..
            "BasedOnStyle: Google, " ..
            "IndentWidth: %d, " ..
            "TabWidth: %d, " ..
            "UseTab: %s, " ..
            "ColumnLimit: 80, " ..
            "SortIncludes: true" ..
            "}'",
            indent_width,
            tabstop,
            use_tab
        )
        
        return {
            exe = "clang-format", -- The executable for C/C++ formatting
            args = { style_str },  -- Dynamic style based on Neovim settings
            stdin = true,         -- Read from stdin
        }
    end
end

-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
require("formatter").setup({
    -- Enable or disable logging
    logging = true,
    -- Set the log level
    log_level = vim.log.levels.WARN,

    -- All formatter configurations are opt-in
    filetype = {
        -- Formatter configurations for lua files
        lua = {
            -- Use the default lua configuration (stylua)
            require("formatter.filetypes.lua").stylua,

            -- Custom Lua formatting configuration
            function()
                return {
                    exe = "stylua", -- The executable to use for formatting
                    args = {
                        "--search-parent-directories", -- Search parent directories for stylua.toml
                        "--stdin-filepath",
                        util.escape_path(util.get_current_buffer_file_path()), -- Ensure the file is passed properly
                        "--column-width 80",
                        "--indent-type Spaces",
                        "--",
                        "-",
                    },
                    stdin = true, -- Read from stdin
                }
            end,
        },

        -- Formatter configurations for bash files
        bash = {
            -- Custom Bash formatting using shfmt
            function()
                return {
                    exe = "shfmt", -- The executable for bash formatting
                    args = {
                        "-i 4",
                        "-ln bash",
                        "-ci",
                        "-sr",
                    },
                    stdin = true, -- Read from stdin
                }
            end,
        },

        sh = {
            -- Custom Bash formatting using shfmt
            function()
                return {
                    exe = "shfmt", -- The executable for bash formatting
                    args = {
                        "-i 4",
                        "-ln bash",
                        "-ci",
                        "-sr",
                    },
                    stdin = true, -- Read from stdin
                }
            end,
        },

        -- Formatter configurations for C files
        c = clang_format_config(),
        
        -- Formatter configurations for C++ files
        cpp = clang_format_config(),
        
        -- Formatter configurations for C/C++ header files
        h = clang_format_config(),
        hpp = clang_format_config(),

        -- Formatter configurations for JSON files
        json = {
            function()
                return {
                    exe = "python3",
                    args = { "-m", "json.tool", "--indent", "4" },
                    stdin = true,
                }
            end,
        },

        -- Default formatter configurations for all filetypes
        ["*"] = {
            -- Remove trailing whitespace in any filetype
            require("formatter.filetypes.any").remove_trailing_whitespace,
        },
    },
})
