-- ~/.config/nvim/lua/plugins/navic.lua
-- For lazy.nvim users, just return this table
return {
  "SmiteshP/nvim-navic",
  dependencies = {
    "neovim/nvim-lspconfig",          -- required for LSP integration
    "nvim-tree/nvim-web-devicons",    -- optional: filetype icons
  },
  config = function()
    local navic = require("nvim-navic")

    navic.setup {
      -- Icons for different symbol kinds (requires a Nerd Font)
      icons = {
        File          = "󰈙 ",
        Module        = " ",
        Namespace     = "󰌗 ",
        Package       = " ",
        Class         = "󰌗 ",
        Method        = "󰆧 ",
        Property      = " ",
        Field         = "󰜢 ",
        Constructor   = " ",
        Enum          = " ",
        Interface     = "󰜢 ",
        Function      = "󰊕 ",
        Variable      = "󰀫 ",
        Constant      = "󰏿 ",
        String        = "󰉿 ",
        Number        = "󰎠 ",
        Boolean       = "◩ ",
        Array         = "󰅪 ",
        Object        = "󰅩 ",
        Key           = "󰌋 ",
        Null          = "󰟢 ",
        EnumMember    = " ",
        Struct        = "󰌗 ",
        Event         = " ",
        Operator      = "󰆕 ",
        TypeParameter = "󰉨 ",
      },
      highlight = true,                -- Highlight the symbol under cursor
      separator = "  ",              -- Breadcrumb separator
      depth_limit = 0,                 -- Max depth (0 = no limit)
      depth_limit_indicator = "..",   -- Shown when depth limit is exceeded
    }

    -- Automatically attach navic to LSP clients that support document symbols
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("NavicAttach", { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client == nil then
          return
        end
        if client.server_capabilities.documentSymbolProvider then
          navic.attach(client, args.buf)
        end
      end,
    })

  end,
}
