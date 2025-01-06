local M = {}
local H = {}

---Initializes and configures the plugin.
---@param opts? boilersharp.Config Configuration options.
function M.setup(opts)
    local config = require("boilersharp.config")
    config.init_config(opts)

    H.add_autocommands()
    H.add_commands()
end

---Writes boilerplate to a C# file.
---@param opts? { bufnr?: integer, ensure_empty?: boolean }
function M.write_boilerplate(opts)
    if #vim.api.nvim_get_runtime_file("parser/xml.so", false) == 0 then
        vim.notify(
            "boilersharp: Treesitter parser for xml not found. Cannot generate boilerplate.",
            vim.log.levels.ERROR
        )
        return
    end

    opts = opts or {}
    opts.bufnr = opts.bufnr or 0
    if opts.ensure_empty == nil then
        opts.ensure_empty = true
    end

    if opts.ensure_empty then
        if vim.api.nvim_buf_line_count(opts.bufnr) > 1 then
            return
        end

        if #vim.api.nvim_buf_get_lines(opts.bufnr, 0, 1, false)[1] > 0 then
            return
        end
    end

    local name, _ = vim.filetype.match({ buf = opts.bufnr })
    if name ~= "cs" then
        error("Boilersharp: You can only write boilerplate on a C# file")
    end
    local path = vim.api.nvim_buf_get_name(opts.bufnr)

    local boilerplate = require("boilersharp.boilerplate")
    local boiler = boilerplate.from_file(path)
    if not boiler then
        vim.notify("boilersharp: Couldn't find csproj file.", vim.log.levels.WARN)
        return
    end
    local lines = vim.split(boilerplate.to_string(boiler), "\n")
    vim.api.nvim_buf_set_lines(opts.bufnr, 0, -1, false, lines)
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
            callback = function() M.write_boilerplate() end,
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
                vim.notify("boilersharp: Invalid subcommand.", vim.log.levels.ERROR)
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
