--[[
Author: CallMeMinxJ@outlook.com
Date: 2025-11-01 01:23:08
LastEditors: CallMeMinxJ@outlook.com
LastEditTime: 2025-11-01 01:23:09
FilePath: \neovim\nvim\lua\nvim-tree_config.lua
Description: 

Copyright (c) 2025 by CallMeMinxJ@outlook.com, All Rights Reserved. 
--]]
require('nvim-tree').setup {
  sort_by = "case_sensitive",
  view = {
    width = 30,
    side = "left",
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false, -- 是否隐藏点文件
  },
}

vim.keymap.set('n', '<leader>n', ':NvimTreeToggle<CR>', {desc = 'Toggle file explorer'})
vim.keymap.set('n', '<leader>m', ':NvimTreeFindFile<CR>', { noremap = true, silent = true, desc = '定位当前文件在树中位置' })
