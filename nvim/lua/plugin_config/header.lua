require("header").setup({
    allow_autocmds = true,
    file_name = true,
    author = "Astor.Jiang",
    date_created = true,
    date_created_fmt = "%Y-%m-%d %H:%M:%S",
    date_modified = true,
    date_modified_fmt = "%Y-%m-%d %H:%M:%S",
    line_separator = "------",
    use_block_header = false,
    copyright_text = {
      "Copyright (c) 2025 Astor.Jiang",
      "GoerTek",
      "All rights reserved."
    },
    license_from_file = false,
    author_from_git = false,
})

vim.keymap.set("n", "<leader>//", function() require("header").add_headers() end)
