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
opt.list = false
opt.listchars = {
    tab      = '· ',   -- tab 显示成 ▸ 加空格
    trail    = '+',    -- 行尾空格
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

-- change tab and space 4
local use_spaces = true

local function toggle_tab()
    use_spaces = not use_spaces
    
    if use_spaces then
        -- 空格模式
        vim.bo.expandtab = true
        vim.bo.tabstop = 4
        vim.bo.softtabstop = 4
        vim.bo.shiftwidth = 4
        print("✅ use Space: width 4")
    else
        -- Tab 模式
        vim.bo.expandtab = false
        vim.bo.tabstop = 4
        vim.bo.shiftwidth = 4
        print("✅ use Tab")
    end
end

-- show tab mode now
local function show_tab_status()
    local status = vim.bo.expandtab and "Space" or "Tab"
    print("Setting is : " .. status .. " (width: " .. vim.bo.shiftwidth .. ")")
end

-- keymap binding
vim.keymap.set('n', '<leader>tt', toggle_tab, { desc = 'switch Space/Tab mode' })
vim.keymap.set('n', '<leader>ts', show_tab_status, { desc = 'show Tab setting' })

-- apply all buffers
vim.api.nvim_create_autocmd('FileType', {
    pattern = '*',
    callback = function()
        if use_spaces then
            vim.bo.expandtab = true
            vim.bo.tabstop = 4
            vim.bo.softtabstop = 4
            vim.bo.shiftwidth = 4
        else
            vim.bo.expandtab = false
            vim.bo.tabstop = 4
            vim.bo.shiftwidth = 4
        end
    end
})

