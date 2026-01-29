-- 最简单、最可靠的方案：只保存和恢复折叠状态
-- 光标位置由跳转动作本身决定
local saved_fold_states = {}
local DEBUG = false

-- Helper to get fold information
local function get_fold_info()
    local fold_info = {}
    local lnum = 1
    local line_count = vim.fn.line("$")
    
    while lnum <= line_count do
        local fold_start = vim.fn.foldclosed(lnum)
        if fold_start > 0 then
            fold_info[fold_start] = false
            lnum = vim.fn.foldclosedend(lnum) + 1
        else
            local fold_level = vim.fn.foldlevel(lnum)
            local next_fold_level = lnum < line_count and vim.fn.foldlevel(lnum + 1) or 0
            
            if fold_level > 0 and next_fold_level <= fold_level then
                fold_info[lnum] = true
            end
            lnum = lnum + 1
        end
    end
    
    return fold_info
end

-- 保存状态
vim.api.nvim_create_autocmd({"BufLeave", "BufWinLeave"}, {
    callback = function()
        local buf = vim.api.nvim_get_current_buf()
        local name = vim.api.nvim_buf_get_name(buf)
        
        if name == "" or vim.bo.buftype ~= "" then
            return
        end
        
        local fold_states = get_fold_info()
        
        if next(fold_states) ~= nil then
            saved_fold_states[name] = {
                fold_states = fold_states,
            }
            
            if DEBUG then
                print("Saved fold states for: " .. name)
            end
        end
    end,
})

-- 恢复状态
vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        local buf = vim.api.nvim_get_current_buf()
        local name = vim.api.nvim_buf_get_name(buf)
        local saved_data = saved_fold_states[name]
        
        if not saved_data or not saved_data.fold_states then
            return
        end
        
        vim.defer_fn(function()
            local current_buf = vim.api.nvim_get_current_buf()
            local current_name = vim.api.nvim_buf_get_name(current_buf)
            
            if current_name ~= name then
                return
            end
            
            -- 保存当前光标位置
            local saved_cursor = vim.api.nvim_win_get_cursor(0)
            
            -- 恢复折叠状态
            vim.cmd("normal! zR")
            for fold_start, is_open in pairs(saved_data.fold_states) do
                if not is_open and fold_start >= 1 and fold_start <= vim.fn.line("$") then
                    vim.fn.cursor(fold_start, 1)
                    pcall(vim.cmd, "normal! zc")
                end
            end
            
            -- 恢复光标到原来的位置
            vim.api.nvim_win_set_cursor(0, saved_cursor)
            
            if DEBUG then
                print("Restored fold states for: " .. name)
            end
        end, 10)
    end,
})
