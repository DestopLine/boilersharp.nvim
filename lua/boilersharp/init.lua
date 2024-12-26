local M = {}

---@param opts? boilersharp.Config
function M.setup(opts)
    require("boilersharp.config").init_config(opts)

    vim.api.nvim_create_autocmd("BufWinEnter", {
        desc = "Write C# boilerplate when entering an empty C# file",
        group = vim.api.nvim_create_augroup("Boilersharp", { clear = true }),
        pattern = "*.cs",
        callback = function() M.write_boilerplate() end,
    })

    vim.api.nvim_create_user_command(
        "Boilersharp",
        function(cmd_opts)
            local subcommand = cmd_opts.fargs[1]
            if not subcommand or subcommand == "write" then
                M.write_boilerplate()
            elseif subcommand == "clear" then
                require("boilersharp.csharp").clear_cache()
            end
        end,
        {
            nargs = "?",
            desc = "Generate C# namespace, usings and class automatically",
            complete = function() return { "clear", "write" } end,
        }
    )
end

---@param opts? { bufnr: integer, ensure_empty: boolean }
function M.write_boilerplate(opts)
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
    local lines = vim.split(boilerplate.to_string(boiler), "\n")
    vim.api.nvim_buf_set_lines(opts.bufnr, 0, -1, false, lines)
end

return M
