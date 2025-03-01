local M = {}

function M.check()
    vim.health.start("boilersharp")

    local parser_found = #vim.api.nvim_get_runtime_file("parser/xml.so", false) > 0
    if parser_found then
        vim.health.ok("Treesitter parser for xml found")
    else
        vim.health.error("Treesitter parser for xml not found")
    end

    local nvim_ts_found = pcall(function() require("nvim-treesitter") end)
    if nvim_ts_found then
        vim.health.ok("Nvim-treesitter plugin found")
    elseif parser_found then
        vim.health.warn("Nvim-treesitter plugin not found, your parser might not be supported/compatible")
    else
        vim.health.warn("Nvim-treesitter plugin not found")
    end
end

return M
