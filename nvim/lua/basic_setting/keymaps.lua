local wk = require("which-key")

-- Leader key
vim.g.mapleader = ","

-- Register all keybindings using the new which-key spec
wk.add({
    -- Nomal mode keybindings
    {
        mode = "n",

        -- Which key search keymaps
        {
            "<leader>?",
            "<Cmd>lua require('which-key').show('', { mode = 'n' })<CR>",
            desc = "Show keymaps (which-key)",
        },

        -- Keymap bindings
        {
            "<leader>tt",
            "<cmd>TabToggle<CR>",
            desc = "Switch Space/Tab mode",
        },
        {
            "<leader>ts",
            "<cmd>TabStatus<CR>",
            desc = "Show current tab setting",
        },

        -- File operations
        { "<leader>e",  ":source %<CR>",                desc = "Reload current lua file" },
        { "<leader>w",  ":w<CR>",                       desc = "Write file" },
        { "<leader>q",  ":bd<CR>",                      desc = "Quit file" },
        { "<leader>wq", "<Cmd>w<Bar>bd<CR>",            desc = "Write and quit" },
        { "<leader>qa", ":qa<CR>",                      desc = "Quit all" },

        -- Buffer operations
        { "<leader>b",  group = "buffer" },
        -- Navigation
        { "<C-d>",      "<Cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
        { "<C-a>",      "<Cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },
        -- Move
        { "<leader>b>", "<Cmd>BufferLineMoveNext<CR>",  desc = "Move right" },
        { "<leader>b<", "<Cmd>BufferLineMovePrev<CR>",  desc = "Move left" },
        -- Pick & Close
        { "<leader>bb", "<Cmd>BufferLinePick<CR>",      desc = "Pick buffer" },
        { "<leader>bd", "<Cmd>bdelete<CR>",             desc = "Close current" },
        {
            "<leader>bo",
            "<Cmd>BufferLineCloseOthers<CR>",
            desc = "Close others",
        },
        {
            "<leader>br",
            "<Cmd>BufferLineCloseRight<CR>",
            desc = "Close right",
        },
        { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Close left" },
        -- Sort only, no groups
        {
            "<leader>bs",
            "<Cmd>BufferLineSortByDirectory<CR>",
            desc = "By directory",
        },
        {
            "<leader>bS",
            "<Cmd>BufferLineSortByExtension<CR>",
            desc = "By extension",
        },
        { "<leader>bl", ":buffers<CR>",                 desc = "List buffers" },

        -- Display settings
        { "<leader>~",  "<cmd>ListToggle<CR>",          desc = "Switch toggle list" },

        -- File path operations
        {
            "<leader>p",
            "<Cmd>lua print('📁 ' .. vim.fn.expand('%:p'))<CR>",
            desc = "Show full file path",
        },
        {
            "<leader>cp",
            "<Cmd>lua local path = vim.fn.expand('%:p'); vim.fn.setreg('+', path); vim.notify('📋 Copied: ' .. path, vim.log.levels.INFO)<CR>",
            desc = "Copy file path",
        },

        -- Buffer navigation
        { "<Esc><Esc>", "<cmd>nohlsearch<CR>", desc = "Cancel highlight" },

        -- Add coments header and func/file annotations
        { "<leader>//", "<cmd>AddHeader<CR>",  desc = "Add header comment" },
        {
            "<leader>/",
            "<cmd>AddComment<CR>",
            desc = "Add func/file comment",
        },

        -- Nvim tree keybindings
        {
            "<leader>n",
            "<cmd>NvimTreeToggle<CR>",
            desc = "Toggle file explorer",
        },
        {
            "<leader>m",
            "<cmd>NvimTreeFindFile<CR>",
            desc = "Find the file location",
        },
        {
            "<leader>>",
            ":vertical resize +5<CR>",
            desc = "Expanding nvim tree width",
        },
        {
            "<leader><",
            ":vertical resize -5<CR>",
            desc = "Reduce nvim tree width",
        },

        -- Open the outline
        {
            "<leader>l",
            "<cmd>Outline<CR>",
            desc = "Open outline",
        },

        -- Telescope search files and string
        { "<leader>f",  group = "telescope" },
        -- Telescope file operations
        { "<leader>ff", "<cmd>FindFiles<CR>",  desc = "Find files" },
        { "<leader>fg", "<cmd>FindGrep<CR>",   desc = "Live grep" },
        -- Telescope helps
        { "<leader>fh", "<cmd>FindHelp<CR>",   desc = "Help tags" },
        -- Telescope search one word
        { "<leader>fs", "<cmd>FindString<CR>", desc = "Search current word" },
        -- Telescope search one symbol bt tags
        { "<leader>ft", "<cmd>FindSymbol<CR>", desc = "Search current word" },
        -- Telescope search symbol
        { "<leader>fT", "<cmd>SearchTags<CR>", desc = "Search current word" },

        -- Flash search words
        { "s",          "<cmd>FlashJump<CR>",  desc = "Search word" },

        -- Neoscroll keybindings
        { "<C-k>",      "<cmd>Scroll -5<CR>",  desc = "scroll up" },
        { "<C-j>",      "<cmd>Scroll 5<CR>",   desc = "scroll down" },

        -- Fommatter keybindings
        { "<leader>F",  ":Format<CR>",         desc = "format code" },

        -- Theme change
        { "<leader>tn", "<cmd>ThemeNext<CR>",  desc = "Theme next" },
        { "<leader>tm", "<cmd>ThemeMode<CR>",  desc = "Theme mode switch" },

        { "<leader>g",  group = "gitsigns" },
        {
            "<leader>gn",
            "<cmd>GitSignsNextHunk<CR>",
            desc = "Jump to next hunk",
        },
        {
            "<leader>gp",
            "<cmd>GitSignsPrevHunk<CR>",
            desc = "Jump to previous hunk",
        },
        {
            "<leader>gh",
            "<cmd>GitSignsPreviewHunk<CR>",
            desc = "Preview current hunk",
        },
        {
            "<leader>gl",
            "<cmd>GitSignsBlameLine<CR>",
            desc = "Show blame for current line",
        },
        {
            "<leader>gb",
            "<cmd>GitSignsBlame<CR>",
            desc = "Show blame for current line",
        },
        {
            "<leader>gd",
            "<cmd>GitSignsDiffThis<CR>",
            desc = "Show diff of current file",
        },

        -- Coc diagnostics and navigation
        { "[g", "<Plug>(coc-diagnostic-prev)", desc = "Previous diagnostic" },
        { "]g", "<Plug>(coc-diagnostic-next)", desc = "Next diagnostic" },
        { "gd", "<Plug>(coc-definition)",      desc = "Go to definition" },
        {
            "gy",
            "<Plug>(coc-type-definition)",
            desc = "Go to type definition",
        },
        { "gi", "<Plug>(coc-implementation)",  desc = "Go to implementation" },
        { "gr", "<Plug>(coc-references)",      desc = "Go to references" },
        { "K",  "<CMD>lua _G.show_docs()<CR>", desc = "Show documentation" },

        -- Coc text objects
        { "if", "<Plug>(coc-funcobj-i)",       desc = "Function text object" },
        {
            "af",
            "<Plug>(coc-funcobj-a)",
            desc = "Function text object (all)",
        },
        { "ic",         "<Plug>(coc-classobj-i)", desc = "Class text object" },
        { "ac",         "<Plug>(coc-classobj-a)", desc = "Class text object (all)" },

        -- Coc code actions
        { "<leader>rn", "<Plug>(coc-rename)",     desc = "Rename symbol" },
        { "<leader>FF", "<Plug>(coc-format)",     desc = "Format all code" },
        {
            "<leader>a",
            "<Plug>(coc-codeaction-selected)",
            desc = "Apply code action (selected)",
        },
        {
            "<leader>ac",
            "<Plug>(coc-codeaction-cursor)",
            desc = "Apply code action (cursor)",
        },
        {
            "<leader>as",
            "<Plug>(coc-codeaction-source)",
            desc = "Apply code action (source)",
        },
        {
            "<leader>re",
            "<Plug>(coc-codeaction-refactor)",
            desc = "Refactor code",
        },
        {
            "<leader>r",
            "<Plug>(coc-codeaction-refactor-selected)",
            desc = "Refactor selected code",
        },
        {
            "<leader>cl",
            "<Plug>(coc-codelens-action)",
            desc = "Run code lens action",
        },

        -- Coc lists
        {
            "<space>a",
            ":<C-u>CocList diagnostics<cr>",
            desc = "Show diagnostics",
        },
        {
            "<space>e",
            ":<C-u>CocList extensions<cr>",
            desc = "Manage extensions",
        },
        { "<space>c", ":<C-u>CocList commands<cr>", desc = "Show commands" },
        { "<space>o", ":<C-u>CocList outline<cr>",  desc = "Show outline" },
        {
            "<space>s",
            ":<C-u>CocList -I symbols<cr>",
            desc = "Search symbols",
        },
        { "<space>j", ":<C-u>CocNext<cr>",       desc = "Next item" },
        { "<space>k", ":<C-u>CocPrev<cr>",       desc = "Previous item" },
        { "<space>p", ":<C-u>CocListResume<cr>", desc = "Resume CocList" },
    },

    -- Both insert and nomal mode keybindings
    {
        mode = { "n", "i" },
        -- Multi-mode Coc mappings
        {
            "<C-f>",
            'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"',
            desc = "Scroll down in float window",
            expr = true,
        },
        {
            "<C-b>",
            'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"',
            desc = "Scroll up in float window",
            expr = true,
        },
        { "<C-s>", "<Plug>(coc-range-select)", desc = "Select range" },
    },

    -- Insert mode keybindings
    {
        mode = "i",
        {
            "<TAB>",
            'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()',
            desc = "Trigger completion",
            expr = true,
        },
        {
            "<S-TAB>",
            'coc#pum#visible() ? coc#pum#prev(1) : "\\<C-h>"',
            desc = "Navigate completion",
            expr = true,
        },
        {
            "<cr>",
            'coc#pum#visible() ? coc#pum#confirm() : "\\<C-g>u\\<CR>\\<c-r>=coc#on_enter()\\<CR>"',
            desc = "Accept completion",
            expr = true, -- This is important
        },
        {
            "<c-j>",
            "<Plug>(coc-snippets-expand-jump)",
            desc = "Trigger snippets",
        },
        { "<c-space>", "coc#refresh()", desc = "Trigger completion refresh" },
    },

    -- Visual mode keybindings
    {
        mode = "v",
        -- Coc selected code format
        {
            "<leader>f",
            "<Plug>(coc-format-selected)",
            desc = "Format selected code",
        },
    },
})
