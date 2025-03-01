local M = {}
local H = {}

---Initializes and configures the plugin.
---@param opts? boilersharp.Config Configuration options.
function M.setup(opts)
    if vim.fn.has("nvim-0.10.0") == 0 then
        vim.notify(
            "boilersharp.nvim requires nvim 0.10.0 or greater",
            vim.log.levels.ERROR,
            { title = "boilersharp.nvim" }
        )
    end

    local config = require("boilersharp.config")
    config.init_config(opts)

    H.add_autocommands()
    H.add_commands()

    if config.config.auto_install_xml_parser then
        H.ensure_xml_parser_is_installed()
    end
end

---@class boilersharp.WriteBoilerplateOpts
---@field bufnr? integer,
---@field ensure_empty? boolean,
---@field behavior? "prepend" | "append" | "replace",
---@field filter? fun(
---    dir_data: boilersharp.DirData,
---    csproj_data: boilersharp.CsprojData,
---): boolean

---Writes boilerplate to a C# file.
---@param opts? boilersharp.WriteBoilerplateOpts
function M.write_boilerplate(opts)
    opts = opts or {}
    opts.bufnr = opts.bufnr or 0
    opts.behavior = opts.behavior or "prepend"
    if opts.ensure_empty == nil then
        opts.ensure_empty = true
    end
    opts.filter = opts.filter or require("boilersharp.config").config.filter

    if not H.check_write_boilerplate(opts) then
        return
    end

    local boilerplate = require("boilersharp.boilerplate")
    local path = vim.api.nvim_buf_get_name(opts.bufnr)
    local boiler = boilerplate.from_file(path)
    if not boiler then
        vim.notify("Couldn't find csproj file", vim.log.levels.WARN, { title = "boilersharp.nvim" })
        return
    end
    local lines = vim.split(boilerplate.to_string(boiler), "\n")

    ---@type number, number
    local start, stop
    if H.is_buffer_empty(opts.bufnr) or opts.behavior == "replace" then
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
            callback = function()
                -- We get the current buffer now to ensure that we are
                -- actually dealing with the buffer that triggered the event.
                -- Otherwise, stuff like Snacks.picker.diagnostics() will
                -- throw some nasty errors.
                local bufnr = vim.api.nvim_get_current_buf()

                -- Delay execution of M.write_boilerplate to prevent issue #1
                -- where moving a class with a language server would trigger
                -- BufWinEnter to the new file and the plugin would think
                -- that the file is empty and would write to it, resulting
                -- in duplicated boilerplate. See :h vim.schedule().
                vim.schedule(function() M.write_boilerplate({ bufnr = bufnr }) end)
            end,
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
                vim.notify("Invalid subcommand", vim.log.levels.ERROR, { title = "boilersharp.nvim" })
            end
        end,
        {
            nargs = "?",
            desc = "Generate C# namespace, usings and class automatically",
            complete = function() return { "clear", "write" } end,
        }
    )
end

function H.ensure_xml_parser_is_installed()
    local health = require("boilersharp.health")
    if health.is_nvim_treesitter_installed() and not health.is_xml_parser_found() then
        vim.notify(
            "Installing XML parser through nvim-treesitter...",
            vim.log.levels.INFO,
            { title = "boilersharp.nvim" }
        )
        vim.cmd(":TSInstall xml")
    end
end

---@param opts boilersharp.WriteBoilerplateOpts
---@return boolean
function H.check_write_boilerplate(opts)
    if opts.ensure_empty and not H.is_buffer_empty(opts.bufnr) then
        return false
    end

    local path = vim.api.nvim_buf_get_name(opts.bufnr)
    local csharp = require("boilersharp.csharp")
    local dir_data = csharp.get_dir_data(H.file_parent(path))
    local csproj_data = csharp.get_csproj_data(dir_data.csproj)

    if not opts.filter(dir_data, csproj_data) then
        return false
    end

    local health = require("boilersharp.health")
    if not health.is_xml_parser_found() then
        local message = "Treesitter parser for xml not found, cannot generate boilerplate"

        if health.is_nvim_treesitter_installed() then
            message = message .. ". Install the parser with `:TSInstall xml`."
        else
            message = message .. ". Install the 'nvim-treesitter/nvim-treesitter' plugin to install the xml parser."
        end

        vim.notify(message, vim.log.levels.ERROR, { title = "boilersharp.nvim" })
        return false
    end

    local name, _ = vim.filetype.match({ buf = opts.bufnr })
    if name ~= "cs" then
        error("Boilersharp: You can only write boilerplate on a C# file")
    end

    return true
end

---@param bufnr number
function H.is_buffer_empty(bufnr)
    return (
        vim.api.nvim_buf_line_count(bufnr) <= 1
        and #vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] == 0
    )
end

---@param path string
function H.file_parent(path)
  return vim.fn.fnamemodify(path, ":p:h")
end

return M
