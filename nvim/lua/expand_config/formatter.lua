-- Utilities for creating configurations
local util = require("formatter.util")

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
        c = {
            -- Custom C formatting using clang-format
            function()
                return {
                    exe = "clang-format", -- The executable for C formatting
                    args = {
                        "--style=Google", -- Use Google style for formatting
                        "--indent-width",
                        "4", -- Use 4 spaces for indentation
                        "--sort-includes", -- Sort includes alphabetically
                        "--column-limit",
                        "80", -- Set max line length to 80 characters
                    },
                    stdin = true, -- Read from stdin
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
