local boilerplate = require("boilersharp.boilerplate")

local M = {}

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

    local boiler = boilerplate.from_file(path)
    local lines = vim.split(boilerplate.to_string(boiler), "\n")
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

return M
