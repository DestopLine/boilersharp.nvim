local M = {}

---@param opts boilersharp.Config | nil
function M.setup(opts)
    require("boilersharp.config").init_config(opts)

    -- This require is here to prevent the config from staying
    -- with the defaults.
    require("boilersharp.autocommands").add_autocommands()
    M.write_boilerplate = require("boilersharp.core").write_boilerplate
end

return M
