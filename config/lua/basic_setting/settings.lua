-- Basic settings module
-- File: lua/settings.lua

local opt = vim.opt

-- UI
opt.number = true               -- Show line numbers
opt.relativenumber = true       -- Show relative line numbers
opt.cursorline = true           -- Highlight current line
opt.termguicolors = true        -- Enable 24-bit RGB colors
opt.signcolumn = "yes"          -- Always show sign column
opt.wrap = false                -- Disable line wrap
opt.scrolloff = 8               -- Keep 8 lines above/below cursor
opt.sidescrolloff = 8           -- Keep 8 columns left/right of cursor
opt.colorcolumn = "81"          -- Set a visual guide at column 80
opt.list = true
opt.listchars = {
    tab      = '▸ ',   -- tab 显示成 ▸ 加空格
    trail    = '●',    -- 行尾空格
    extends  = '❯',   -- 行被折断时的右箭头
    precedes = '❮',   -- 行被折断时的左箭头
    nbsp     = '␣',   -- 不间断空格
}

-- Search
opt.ignorecase = true           -- Case insensitive search
opt.smartcase = true            -- Smart case
opt.incsearch = true            -- Incremental search
opt.hlsearch = true             -- Highlight search results

-- Editing
opt.expandtab = true            -- Use spaces instead of tabs
opt.shiftwidth = 4              -- Shift 4 spaces for indentation
opt.tabstop = 4                 -- Tab character width 4
opt.softtabstop = 4             -- Editing tab width
opt.smartindent = true          -- Enable smart indentation
opt.clipboard = "unnamedplus"   -- Use system clipboard
opt.mouse = "a"                 -- Enable mouse support
opt.hidden = true               -- Allow hidden buffers
opt.wrap = true                 -- Auto enter
opt.linebreak = true            -- Defent cut word off
opt.sidescroll = 0              -- Ban horizion scroll

-- Performance
opt.updatetime = 300            -- Time in ms to trigger CursorHold
opt.timeoutlen = 500            -- Time in ms for mapped sequence completion

-- Files
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true             -- Enable undo file
