require("header").setup({
    allow_autocmds = true,
    file_name = true,
    author = "Astor.Jiang",
    date_created = true,
    date_created_fmt = "%Y-%m-%d %H:%M:%S",
    date_modified = false,
    use_block_header = true,
    copyright_text = {
      "Copyright (c) " .. os.date("%Y") .. " GoerTek. All rights reserved."
    },
    license_from_file = false,
    author_from_git = false,
})


-- Create new command
vim.api.nvim_create_user_command(
    "AddHeader",
    function()
        require("header").add_headers()
    end,
    { nargs = 0}
)

