-- lua/mappings.lua

-- Leader key
vim.g.mapleader = ','

-- <leader> e: fresh neovim
vim.keymap.set("n","<leader>e",":source %<CR>",
    { desc = "Reload current lua file"})

-- Switch tab: use Ctrl+A or Ctrl+D
vim.keymap.set('n', '<C-D>', function()
  local current = vim.fn.tabpagenr()
  local total = vim.fn.tabpagenr('$')
  vim.cmd(current == total and 'tabfirst' or 'tabnext')
end, { noremap = true, silent = true })

vim.keymap.set('n', '<C-A>', function()
  local current = vim.fn.tabpagenr()
  vim.cmd(current == 1 and 'tablast' or 'tabprevious')
end, { noremap = true, silent = true })

-- <leader>w: write file
vim.keymap.set('n', '<leader>w', ':w<CR>',
    { desc = 'Write file', silent = true })

-- <leader>q: quit current file
vim.keymap.set('n', '<leader>q', ':bd<CR>',
    { desc = 'Quit file', silent = true })

-- <leader>wq: write and quit current file
vim.keymap.set('n', '<leader>wq', '<Cmd>w<Bar>bd<CR>', 
    { desc = 'Write and quit', silent = true })

-- <leader>qa: quit all files
vim.keymap.set('n', '<leader>qa', ':qa<CR>', 
    { desc = 'Quit all', silent = true })

-- <Esc><Esc>: cansel highlight
vim.keymap.set('n', '<Esc><Esc>', '<cmd>nohlsearch<CR>',
    { silent = true }) 

-- <leader>`: switch toggle list: show the space and tab
vim.keymap.set('n', '<leader>~', ':set list!<CR>',
    { desc = 'switch toggle list'})

-- <leader>p: show the full pathway
vim.keymap.set('n', '<Leader>p', function()
    local path = vim.fn.expand('%:p')
    print("📁 " .. path)
end, { desc = '显示文件完整路径' })

-- <leader>cp: show the full pathway and copy
vim.keymap.set('n', '<Leader>cp', function()
    local path = vim.fn.expand('%:p')
    vim.fn.setreg('+', path)
    vim.notify("📋 已复制: " .. path, vim.log.levels.INFO)
end, { desc = '复制文件路径' })

