local M = {}

function M.check()
    vim.health.start("boilersharp")

    local parser_found = M.is_xml_parser_found()
    if parser_found then
        vim.health.ok("Treesitter parser for xml found")
    else
        vim.health.error("Treesitter parser for xml not found")
    end

    local nvim_ts_found = M.is_nvim_treesitter_installed()
    if nvim_ts_found then
        vim.health.ok("Nvim-treesitter plugin found")
    elseif parser_found then
        vim.health.warn("Nvim-treesitter plugin not found, your parser might not be supported/compatible")
    else
        vim.health.warn("Nvim-treesitter plugin not found")
    end
end

---Checks if there is an xml parser in the runtime path.
---@return boolean
function M.is_xml_parser_found()
    return #vim.api.nvim_get_runtime_file("parser/xml.so", false) > 0
end

---Checks if nvim-treesitter/nvim-treesitter is installed.
---@return boolean
function M.is_nvim_treesitter_installed()
    return pcall(function() require("nvim-treesitter") end)
end

return M
