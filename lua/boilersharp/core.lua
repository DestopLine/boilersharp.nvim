local boilerplate = require("boilersharp.boilerplate")

local M = {}

---@param bufnr integer
function M.write_boilerplate(bufnr)
    local name, _ = vim.filetype.match({ buf = bufnr })
    if name ~= "cs" then
        error("Boilersharp: You can only write boilerplate on a C# file")
    end
    local path = vim.api.nvim_buf_get_name(bufnr)

    local boiler = boilerplate.from_file(path)
    local lines = vim.split(boilerplate.to_string(boiler), "\n")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

return M
