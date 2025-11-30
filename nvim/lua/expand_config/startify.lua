-- 简单配置 Startify，不改变工作目录
vim.g.startify_change_to_dir = 0
vim.g.startify_change_to_vcs_root = 0
vim.g.startify_padding_left = 20

-- 自定义启动页面图画
vim.g.startify_custom_header = {
    '                .o.        .oooooo..o ooooooooooooo   .oooooo.   ooooooooo.   ',
    '               .888.      d8P\'    `Y8 8\'   888   `8  d8P\'  `Y8b  `888   `Y88. ',
    '              .8"888.     Y88bo.           888      888      888  888   .d88\' ',
    '             .8\' `888.     `"Y8888o.       888      888      888  888ooo88P\'  ',
    '            .88ooo8888.        `"Y88b      888      888      888  888`88b.    ',
    '           .8\'     `888.  oo     .d8P      888      `88b    d88\'  888  `88b.  ',
    '          o88o     o8888o 8""88888P\'      o888o      `Y8bood8P\'  o888o  o888o ',
    '',
    '                                   [' .. os.date('%Y.%m.%d %H:%M') .. ']',
    '',
}
