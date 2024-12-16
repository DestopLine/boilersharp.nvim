local core = require("boilersharp.core")

local M = {}

function M.add_autocommands()
    vim.api.nvim_create_autocmd("BufWinEnter", {
        desc = "Write C# boilerplate when entering an empty C# file",
        group = vim.api.nvim_create_augroup("Boilersharp", { clear = true }),
        pattern = "*.cs",
        callback = function() M.write_boilerplate_if_empty(0) end,
    })
end

---@param bufnr integer
function M.write_boilerplate_if_empty(bufnr)
    if vim.api.nvim_buf_line_count(bufnr) > 1 then
        return
    end

    if #vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] > 0 then
        return
    end

    core.write_boilerplate(bufnr)
end

return M
