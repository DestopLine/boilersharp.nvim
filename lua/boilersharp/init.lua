local options = require("boilersharp.options")

local M = {}

---@param opts boilersharp.PartialOptions | nil
function M.setup(opts)
    options.init_options(opts)

    -- This require is here to prevent the options from staying
    -- with the defaults.
    local autocmds = require("boilersharp.autocommands")
    autocmds.add_autocommands()
end

return M
