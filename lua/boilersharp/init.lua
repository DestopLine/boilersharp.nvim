local M = {}
local H = {}

---Initializes and configures the plugin.
---@param opts? boilersharp.Config Configuration options.
function M.setup(opts)
    if vim.fn.has("nvim-0.10.0") == 0 then
        vim.notify(
            "boilersharp.nvim requires nvim 0.10.0 or greater",
            vim.log.levels.ERROR,
            { title = "boilersharp" }
        )
    end

    local config = require("boilersharp.config")
    config.init_config(opts)

    H.add_autocommands()
    H.add_commands()
end

---Writes boilerplate to a C# file.
---@param opts? { bufnr?: integer, ensure_empty?: boolean, behavior?: "prepend" | "append" | "replace" }
function M.write_boilerplate(opts)
    if #vim.api.nvim_get_runtime_file("parser/xml.so", false) == 0 then
        local message = "Treesitter parser for xml not found, cannot generate boilerplate"
        local nvim_ts = require("nvim-treesitter")

        if nvim_ts then
            message = message .. ". Install the parser with `:TSInstall xml`."
        else
            message = message .. ". Install the 'nvim-treesitter/nvim-treesitter' plugin to install the xml parser."
        end

        vim.notify(message, vim.log.levels.ERROR, { title = "boilersharp" })
        return
    end

    opts = opts or {}
    opts.bufnr = opts.bufnr or 0
    opts.behavior = opts.behavior or "prepend"
    if opts.ensure_empty == nil then
        opts.ensure_empty = true
    end

    local is_buffer_empty =
        vim.api.nvim_buf_line_count(opts.bufnr) <= 1
        and #vim.api.nvim_buf_get_lines(opts.bufnr, 0, 1, false)[1] == 0

    if opts.ensure_empty and not is_buffer_empty then
        return
    end

    local name, _ = vim.filetype.match({ buf = opts.bufnr })
    if name ~= "cs" then
        error("Boilersharp: You can only write boilerplate on a C# file")
    end
    local path = vim.api.nvim_buf_get_name(opts.bufnr)

    local boilerplate = require("boilersharp.boilerplate")
    local boiler = boilerplate.from_file(path)
    if not boiler then
        vim.notify("Couldn't find csproj file", vim.log.levels.WARN, { title = "boilersharp" })
        return
    end
    local lines = vim.split(boilerplate.to_string(boiler), "\n")

    ---@type number, number
    local start, stop
    if is_buffer_empty or opts.behavior == "replace" then
        start = 0
        stop = -1
    elseif opts.behavior == "prepend" then
        start = 0
        stop = 0
    elseif opts.behavior == "append" then
        start = -1
        stop = -1
    end
    vim.api.nvim_buf_set_lines(opts.bufnr, start, stop, false, lines)
end

---Clears cached directories and csproj files.
function M.clear_cache()
    require("boilersharp.csharp").clear_cache()
end

function H.add_autocommands()
    if require("boilersharp.config").config.add_autocommand then
        vim.api.nvim_create_autocmd("BufWinEnter", {
            desc = "Write C# boilerplate when entering an empty C# file",
            group = vim.api.nvim_create_augroup("Boilersharp", { clear = true }),
            pattern = "*.cs",
            -- Delay execution of M.write_boilerplate to prevent issue #1
            -- where moving a class with a language server would trigger
            -- BufWinEnter to the new file and the plugin would think
            -- that the file is empty and would write to it, resulting
            -- in duplicated boilerplate. See :h vim.schedule().
            callback = function() vim.schedule(M.write_boilerplate) end,
        })
    end
end

function H.add_commands()
    vim.api.nvim_create_user_command(
        "Boilersharp",
        function(cmd_opts)
            local subcommand = cmd_opts.fargs[1]
            if not subcommand or subcommand == "write" then
                M.write_boilerplate()
            elseif subcommand == "clear" then
                M.clear_cache()
            else
                vim.notify("Invalid subcommand", vim.log.levels.ERROR, { title = "boilersharp" })
            end
        end,
        {
            nargs = "?",
            desc = "Generate C# namespace, usings and class automatically",
            complete = function() return { "clear", "write" } end,
        }
    )
end

return M
