require("which-key").setup({
  plugins = {
    presets = {
      operators = false,
      motions = false,
      text_objects = false,
      windows = false,
      nav = false,
      z = false,
      g = false,
    },
  },
  triggers = {}, -- ✅ 禁用所有自动触发
})

vim.keymap.set("n", "<leader>?", function()
  require("which-key").show("", { mode = "n"})
end, { desc = "Show keymaps (which-key)" })
