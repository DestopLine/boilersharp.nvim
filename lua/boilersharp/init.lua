local M = {}

---@param opts boilersharp.Config | nil
function M.setup(opts)
    require("boilersharp.config").init_config(opts)

    vim.api.nvim_create_autocmd("BufWinEnter", {
        desc = "Write C# boilerplate when entering an empty C# file",
        group = vim.api.nvim_create_augroup("Boilersharp", { clear = true }),
        pattern = "*.cs",
        callback = M.write_boilerplate,
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

---@param bufnr integer | nil
---@param ensure_empty boolean | nil
function M.write_boilerplate(bufnr, ensure_empty)
    bufnr = bufnr or 0
    if ensure_empty == nil then
        ensure_empty = true
    end

    if ensure_empty then
        if vim.api.nvim_buf_line_count(bufnr) > 1 then
            return
        end

        if #vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] > 0 then
            return
        end
    end

    local name, _ = vim.filetype.match({ buf = bufnr })
    if name ~= "cs" then
        error("Boilersharp: You can only write boilerplate on a C# file")
    end
    local path = vim.api.nvim_buf_get_name(bufnr)

    local boilerplate = require("boilersharp.boilerplate")
    local boiler = boilerplate.from_file(path)
    local lines = vim.split(boilerplate.to_string(boiler), "\n")
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

return M
