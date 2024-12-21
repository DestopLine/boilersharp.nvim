local options = require("boilersharp.options")

local M = {}

---@param opts boilersharp.PartialOptions | nil
function M.setup(opts)
    options.init_options(opts)

    -- This require is here to prevent the options from staying
    -- with the defaults.
    require("boilersharp.autocommands").add_autocommands()
    M.write_boilerplate = require("boilersharp.core").write_boilerplate
end

return M
