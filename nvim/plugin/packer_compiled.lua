-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/jiangmingxing/.cache/nvim/packer_hererocks/2.1.1760617492/share/lua/5.1/?.lua;/home/jiangmingxing/.cache/nvim/packer_hererocks/2.1.1760617492/share/lua/5.1/?/init.lua;/home/jiangmingxing/.cache/nvim/packer_hererocks/2.1.1760617492/lib/luarocks/rocks-5.1/?.lua;/home/jiangmingxing/.cache/nvim/packer_hererocks/2.1.1760617492/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/jiangmingxing/.cache/nvim/packer_hererocks/2.1.1760617492/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  PaperColorSlim = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/PaperColorSlim",
    url = "/home/jiangmingxing/.config/nvim/themes/papercolor-theme-slim"
  },
  ayu = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/ayu",
    url = "/home/jiangmingxing/.config/nvim/themes/neovim-ayu"
  },
  ["bufferline.nvim"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/bufferline.nvim",
    url = "/home/jiangmingxing/.config/nvim/addons/bufferline.nvim"
  },
  catppuccin = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/catppuccin",
    url = "/home/jiangmingxing/.config/nvim/themes/catppuccin"
  },
  ["cmp-luasnip"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/cmp-luasnip",
    url = "/home/jiangmingxing/.config/nvim/addons/cmp-luasnip"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "/home/jiangmingxing/.config/nvim/addons/cmp-nvim-lsp"
  },
  ["comment.nvim"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/comment.nvim",
    url = "/home/jiangmingxing/.config/nvim/addons/comment.nvim"
  },
  ["conform.nvim"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/conform.nvim",
    url = "/home/jiangmingxing/.config/nvim/addons/conform.nvim"
  },
  dracula = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/dracula",
    url = "/home/jiangmingxing/.config/nvim/themes/dracula.nvim"
  },
  everforest = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/everforest",
    url = "/home/jiangmingxing/.config/nvim/themes/everforest"
  },
  ["flash.nvim"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/flash.nvim",
    url = "/home/jiangmingxing/.config/nvim/addons/flash.nvim"
  },
  ["gitsigns.nvim"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/gitsigns.nvim",
    url = "/home/jiangmingxing/.config/nvim/addons/gitsigns.nvim"
  },
  gruvbox = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/gruvbox",
    url = "/home/jiangmingxing/.config/nvim/themes/gruvbox"
  },
  ["header.nvim"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/header.nvim",
    url = "/home/jiangmingxing/.config/nvim/addons/header.nvim"
  },
  ["indent-blankline.nvim"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/indent-blankline.nvim",
    url = "/home/jiangmingxing/.config/nvim/addons/indent-blankline.nvim"
  },
  kanagawa = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/kanagawa",
    url = "/home/jiangmingxing/.config/nvim/themes/kanagawa"
  },
  ["lualine.nvim"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/lualine.nvim",
    url = "/home/jiangmingxing/.config/nvim/addons/lualine.nvim"
  },
  luasnip = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/luasnip",
    url = "/home/jiangmingxing/.config/nvim/addons/luasnip"
  },
  ["marks.nvim"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/marks.nvim",
    url = "/home/jiangmingxing/.config/nvim/addons/marks.nvim"
  },
  ["markview.nvim"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/markview.nvim",
    url = "/home/jiangmingxing/.config/nvim/addons/markview.nvim"
  },
  ["mason-lspconfig.nvim"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/mason-lspconfig.nvim",
    url = "/home/jiangmingxing/.config/nvim/addons/mason-lspconfig.nvim"
  },
  ["mason.nvim"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/mason.nvim",
    url = "/home/jiangmingxing/.config/nvim/addons/mason.nvim"
  },
  melange = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/melange",
    url = "/home/jiangmingxing/.config/nvim/themes/melange-nvim"
  },
  ["neo-tree.nvim"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/neo-tree.nvim",
    url = "/home/jiangmingxing/.config/nvim/addons/neo-tree.nvim"
  },
  neogen = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/neogen",
    url = "/home/jiangmingxing/.config/nvim/addons/neogen"
  },
  ["neoscroll.nvim"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/neoscroll.nvim",
    url = "/home/jiangmingxing/.config/nvim/addons/neoscroll.nvim"
  },
  noctis = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/noctis",
    url = "/home/jiangmingxing/.config/nvim/themes/noctis-nvim"
  },
  ["nui.nvim"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/nui.nvim",
    url = "/home/jiangmingxing/.config/nvim/addons/nui.nvim"
  },
  ["nvim-autopairs"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/nvim-autopairs",
    url = "/home/jiangmingxing/.config/nvim/addons/nvim-autopairs"
  },
  ["nvim-cmp"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/nvim-cmp",
    url = "/home/jiangmingxing/.config/nvim/addons/nvim-cmp"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "/home/jiangmingxing/.config/nvim/addons/nvim-lspconfig"
  },
  ["nvim-navic"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/nvim-navic",
    url = "/home/jiangmingxing/.config/nvim/addons/nvim-navic"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "/home/jiangmingxing/.config/nvim/addons/nvim-treesitter"
  },
  ["nvim-treesitter-context"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/nvim-treesitter-context",
    url = "/home/jiangmingxing/.config/nvim/addons/nvim-treesitter-context"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "/home/jiangmingxing/.config/nvim/addons/nvim-web-devicons"
  },
  ["open-color"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/open-color",
    url = "/home/jiangmingxing/.config/nvim/themes/vim-open-color"
  },
  ["outline.nvim"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/outline.nvim",
    url = "/home/jiangmingxing/.config/nvim/addons/outline.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "/home/jiangmingxing/.config/nvim/addons/plenary.nvim"
  },
  rosepine = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/rosepine",
    url = "/home/jiangmingxing/.config/nvim/themes/rosepine"
  },
  ["telescope-fzf-native.nvim"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/telescope-fzf-native.nvim",
    url = "/home/jiangmingxing/.config/nvim/addons/telescope-fzf-native.nvim"
  },
  ["telescope.nvim"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "/home/jiangmingxing/.config/nvim/addons/telescope.nvim"
  },
  ["tiny-inline-diagnostic.nvim"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/tiny-inline-diagnostic.nvim",
    url = "/home/jiangmingxing/.config/nvim/addons/tiny-inline-diagnostic.nvim"
  },
  toast = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/toast",
    url = "/home/jiangmingxing/.config/nvim/themes/toast.vim"
  },
  tokyonight = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/tokyonight",
    url = "/home/jiangmingxing/.config/nvim/themes/tokyonight"
  },
  ["trouble.nvim"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/trouble.nvim",
    url = "/home/jiangmingxing/.config/nvim/addons/trouble.nvim"
  },
  ["vim-startify"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/vim-startify",
    url = "/home/jiangmingxing/.config/nvim/addons/vim-startify"
  },
  vscode = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/vscode",
    url = "/home/jiangmingxing/.config/nvim/themes/vscode.nvim"
  },
  ["which-key"] = {
    loaded = true,
    path = "/home/jiangmingxing/.local/share/nvim/site/pack/packer/start/which-key",
    url = "/home/jiangmingxing/.config/nvim/addons/which-key"
  }
}

time([[Defining packer_plugins]], false)

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
