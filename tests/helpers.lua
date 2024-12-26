local M = {}

require("mini.test").setup()

---Makes and initializes a child neovim instance and a test set.
---@param opts? table Table to pass to MiniTest.new_set().
---@return MiniTest.child
---@return table
function M.new_test(opts)
    local child = MiniTest.new_child_neovim()
    local default_opts = {
        hooks = {
            pre_case = function()
                child.restart({ "-u", "scripts/minimal_init.lua" })
                child.bo.readonly = false
                child.lua([[M = require("boilersharp")]])
            end,
            post_once = child.stop,
        },
    }
    local set_opts = vim.tbl_deep_extend("force", default_opts, opts or {})
    local set = MiniTest.new_set(set_opts)

    return child, set
end

---Send non-function values into a child Neovim instance
---@param child MiniTest.child Child Neovim instance
---@param values { [string]: boolean | string | number| table } Values to send
function M.send(child, values)
    for name, value in pairs(values) do
        child.lua(([[%s = %s]]):format(name, vim.inspect(value)))
    end
end

return M
