local config_dir = vim.fn.stdpath("config")
local plugins_dir = config_dir .. "/addons/"
local colors_dir = config_dir .. "/themes/"

require("lazy").setup({
  -- ============================================================
  -- Always-loaded essentials (lazy = false)
  -- ============================================================
  { dir = plugins_dir .. "nvim-web-devicons", lazy = false },
  { dir = plugins_dir .. "plenary.nvim", lazy = false },
  { dir = plugins_dir .. "nui.nvim", lazy = false },

  -- ============================================================
  -- UI Plugins (VeryLazy = after UI renders, near-instant)
  -- ============================================================
  {
    dir = plugins_dir .. "lualine.nvim",
    event = "VeryLazy",
    config = function()
      require("expand_config.lualine")
    end,
  },
  {
    dir = plugins_dir .. "bufferline.nvim",
    event = "VeryLazy",
    config = function()
      require("expand_config.bufferline")
    end,
  },
  {
    dir = plugins_dir .. "which-key",
    event = "VeryLazy",
    config = function()
      require("expand_config.which-key")
      require("basic_setting.keymaps")
    end,
  },
  {
    dir = plugins_dir .. "neoscroll.nvim",
    event = "VeryLazy",
    config = function()
      require("expand_config.neoscroll")
    end,
  },
  {
    dir = plugins_dir .. "indent-blankline.nvim",
    event = "VeryLazy",
    config = function()
      require("expand_config.indent-blankline")
    end,
  },
  {
    dir = plugins_dir .. "marks.nvim",
    event = "VeryLazy",
    config = function()
      require("expand_config.marks")
    end,
  },

  -- ============================================================
  -- LSP (loaded when files are opened)
  -- ============================================================
  {
    dir = plugins_dir .. "nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "cmp-nvim-lsp",
      "nvim-navic",
    },
    config = function()
      require("expand_config.lspconfig")
    end,
  },
  {
    dir = plugins_dir .. "cmp-nvim-lsp",
    event = { "BufReadPost", "BufNewFile" },
  },
  {
    dir = plugins_dir .. "nvim-navic",
    event = "LspAttach",
    config = function()
      require("expand_config.navic")
    end,
  },
  {
    dir = plugins_dir .. "tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    config = function()
      require("expand_config.tiny-inline-diagnostic")
    end,
  },

  -- ============================================================
  -- Completion (loaded on InsertEnter)
  -- ============================================================
  {
    dir = plugins_dir .. "nvim-cmp",
    event = "InsertEnter",
    config = function()
      require("expand_config.nvim-cmp")
    end,
  },
  {
    dir = plugins_dir .. "luasnip",
    event = "InsertEnter",
    config = function()
      require("expand_config.luasnip")
    end,
  },
  {
    dir = plugins_dir .. "cmp-luasnip",
    event = "InsertEnter",
  },
  {
    dir = plugins_dir .. "nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("expand_config.autopairs")
    end,
  },

  -- ============================================================
  -- Treesitter (loaded when files are opened)
  -- ============================================================
  {
    dir = plugins_dir .. "nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("expand_config.nvim-treesitter")
    end,
  },
  {
    dir = plugins_dir .. "nvim-treesitter-context",
    event = "BufReadPost",
    config = function()
      require("expand_config.treesitter-context")
    end,
  },

  -- ============================================================
  -- Git (loaded when files are opened)
  -- ============================================================
  {
    dir = plugins_dir .. "gitsigns.nvim",
    event = "BufReadPost",
    config = function()
      require("expand_config.gitsigns")
    end,
  },

  -- ============================================================
  -- Cmd-triggered (only loaded when you use them)
  -- ============================================================
  {
    dir = plugins_dir .. "telescope.nvim",
    cmd = {
      "Telescope",
      "FindFiles",
      "FindGrep",
      "FindHelp",
      "FindString",
      "FindSymbol",
      "SearchTags",
    },
    dependencies = {
      { dir = plugins_dir .. "telescope-fzf-native.nvim" },
    },
    config = function()
      require("expand_config.telescope")
    end,
  },
  {
    dir = plugins_dir .. "neo-tree.nvim",
    cmd = {
      "NeotreeToggle",
      "NeotreeToggleFloat",
      "NeotreeToggleCurrent",
      "Neotree",
    },
    config = function()
      require("expand_config.neo-tree")
    end,
  },
  {
    dir = plugins_dir .. "neogen",
    cmd = { "Neogen", "AddComment" },
    config = function()
      require("expand_config.neogen")
    end,
  },
  {
    dir = plugins_dir .. "header.nvim",
    cmd = "AddHeader",
    config = function()
      require("expand_config.header")
    end,
  },
  {
    dir = plugins_dir .. "outline.nvim",
    cmd = "Outline",
    config = function()
      require("expand_config.outline")
    end,
  },
  {
    dir = plugins_dir .. "flash.nvim",
    cmd = {
      "FlashJump",
      "FlashLine",
      "FlashWindows",
      "FlashTreesitter",
      "FlashRemote",
      "FlashToggle",
    },
    config = function()
      require("expand_config.flash")
    end,
  },
  {
    dir = plugins_dir .. "trouble.nvim",
    cmd = "Trouble",
    config = function()
      require("expand_config.trouble")
    end,
  },
  {
    dir = plugins_dir .. "conform.nvim",
    cmd = { "Format", "FormatWrite", "FormatToggle" },
    config = function()
      require("expand_config.conform")
    end,
  },
  {
    dir = plugins_dir .. "mason.nvim",
    cmd = "Mason",
    config = function()
      require("expand_config.mason")
    end,
  },
  {
    dir = plugins_dir .. "mason-lspconfig.nvim",
    event = "VeryLazy",
  },

  -- ============================================================
  -- Filetype-triggered
  -- ============================================================
  {
    dir = plugins_dir .. "markview.nvim",
    ft = "markdown",
    config = function()
      require("expand_config.markview")
    end,
  },

  -- ============================================================
  -- Key-triggered
  -- ============================================================
  {
    dir = plugins_dir .. "comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" } },
      { "gb", mode = { "n", "v" } },
    },
    config = function()
      require("expand_config.comment")
    end,
  },

  -- ============================================================
  -- Start screen (loaded on VimEnter with no file)
  -- ============================================================
  {
    dir = plugins_dir .. "vim-startify",
    event = "VimEnter",
    config = function()
      require("expand_config.startify")
    end,
  },

  -- ============================================================
  -- Themes (all loaded at startup, lazy = false for colorscheme)
  -- ============================================================
  { dir = colors_dir .. "catppuccin", lazy = false },
  { dir = colors_dir .. "gruvbox", lazy = false },
  { dir = colors_dir .. "kanagawa", lazy = false },
  { dir = colors_dir .. "rosepine", lazy = false },
  { dir = colors_dir .. "tokyonight", lazy = false },
  { dir = colors_dir .. "melange-nvim", name = "melange", lazy = false },
  { dir = colors_dir .. "toast.vim", name = "toast", lazy = false },
  { dir = colors_dir .. "vscode.nvim", name = "vscode", lazy = false },
  { dir = colors_dir .. "neovim-ayu", name = "ayu", lazy = false },
  { dir = colors_dir .. "vim-open-color", name = "open-color", lazy = false },
  {
    dir = colors_dir .. "papercolor-theme-slim",
    name = "PaperColorSlim",
    lazy = false,
  },
  { dir = colors_dir .. "noctis-nvim", name = "noctis", lazy = false },
  { dir = colors_dir .. "everforest", lazy = false },
  { dir = colors_dir .. "dracula.nvim", name = "dracula", lazy = false },

  },
  {
    git = {
      cmd = "false",
    },
    dev = {
      path = plugins_dir,
    },
    install = {
      missing = false,
    },
    checker = {
      enabled = false,
    },
    change_detection = {
      enabled = false,
    },
  })
