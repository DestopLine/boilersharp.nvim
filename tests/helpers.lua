local M = {}

require("mini.test").setup()

---Makes and initializes a child neovim instance and a test set.
---@param opts table Table to pass to MiniTest.new_set().
---@return MiniTest.child
---@return table
function M.new_test(opts)
    local child = MiniTest.new_child_neovim()
    local default_opts = {
        hooks = {
            pre_case = function()
                child.restart({ "-u", "scripts/minimal_init.lua" })
                child.bo.readonly = false
            end,
            post_once = child.stop,
        },
    }
    local set_opts = vim.tbl_deep_extend("force", default_opts, opts or {})
    local set = MiniTest.new_set(set_opts)

    return child, set
end

return M
