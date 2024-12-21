local core = require("boilersharp.core")

local M = {}

function M.add_autocommands()
    vim.api.nvim_create_autocmd("BufWinEnter", {
        desc = "Write C# boilerplate when entering an empty C# file",
        group = vim.api.nvim_create_augroup("Boilersharp", { clear = true }),
        pattern = "*.cs",
        callback = function() core.write_boilerplate(0) end,
    })
end

return M
