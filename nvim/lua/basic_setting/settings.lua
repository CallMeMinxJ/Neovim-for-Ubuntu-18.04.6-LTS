-- Dynamic settings module with JSON configuration
-- File: lua/settings.lua

local config_path = vim.fn.stdpath("config") .. "/nvim-settings.json"
local config = {}
local func = {}

-- Load configuration from JSON file
local function load_config()
    local ok, json_data = pcall(vim.fn.readfile, config_path)
    if not ok then
        print("Config file not found or error reading: " .. json_data)
        return
    end

    local ok_parse, parsed = pcall(
        vim.fn.json_decode,
        table.concat(json_data, "\n")
    )
    if not ok_parse then
        print("Error parsing config file: " .. parsed)
        return
    end

    config = parsed or {}
    vim.notify("Config loaded successfully") -- Debug: Check if config is loaded

    -- Apply Neovim options
    if config.options then
        for key, value in pairs(config.options) do
            pcall(function()
                vim.opt[key] = value
            end)
        end
    end
end

-- Set configuration value and save to file
function func.set_config(key, value, category)
    category = category or "options"

    if not config[category] then
        config[category] = {}
    end

    config[category][key] = value

    -- Apply immediately if it's a Neovim option
    if category == "options" then
        pcall(function()
            vim.opt[key] = value
        end)
    end

    -- Save to file
    local ok, json_str = pcall(vim.fn.json_encode, config)
    if ok then
        pcall(function()
            vim.fn.writefile(vim.fn.split(json_str, "\n"), config_path)
        end)
    else
        print("Error encoding config: " .. json_str)
    end
end

-- Get configuration value
function func.get_config(key, category)
    category = category or "options"
    -- print("Get config " .. category .. "." .. key ..
    -- 	" "..(tostring(config[category][key])))
    return config[category] and config[category][key] or nil
end

-- Create new command
vim.api.nvim_create_user_command("SetConfig", function(opts)
    local key, value, category = opts.fargs[1], opts.fargs[2], opts.fargs[3]
    func.set_config(key, value, category)
end, { nargs = "*", desc = "Set configuration value" })

vim.api.nvim_create_user_command("GetConfig", function(opts)
    local key, category = opts.fargs[1], opts.fargs[2]
    func.get_config(key, category)
end, { nargs = "*", desc = "Get configuration value" })

-- Call load_config function to load settings immediately
load_config()

return {
    config = config,
    set_config = func.set_config,
    get_config = func.get_config,
}
