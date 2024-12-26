local M = {}

---@class boilersharp.Config
---@field usings? boilersharp.Config.Usings | false
---@field namespace? boilersharp.Config.Namespace | false
---@field type_definition? boilersharp.Config.TypeDefinition | false
---@field add_autocommand? boolean
---@field indent_type? "tabs" | "spaces" | "auto"

---@class boilersharp.Config.Usings
---@field implicit_usings? "never" | "always" | "auto"
---@field usings? string[]

---@class boilersharp.Config.Namespace
---@field use_file_scoped? "never" | "always" | "auto"

---@class boilersharp.Config.TypeDefinition
---@field default_access_modifier? boilersharp.AccessModifier
---@field default_type? boilersharp.CsharpType
---@field infer_interfaces? boolean

---@class boilersharp.FullConfig
---@field usings boilersharp.FullConfig.Usings | false
---@field namespace boilersharp.FullConfig.Namespace | false
---@field type_definition boilersharp.FullConfig.TypeDefinition | false
---@field add_autocommand boolean
---@field indent_type "tabs" | "spaces" | "auto"

M.DEFAULT = {
    ---@class boilersharp.FullConfig.Usings
    usings = {
        ---@type "never" | "always" | "auto"
        implicit_usings = "auto",

        usings = {
            "System",
            "System.Collections.Generic",
            "System.IO",
            "System.Linq",
            "System.Net.Http",
            "System.Threading",
            "System.Threading.Tasks",
        },
    },

    ---@class boilersharp.FullConfig.Namespace
    namespace = {
        ---@type "never" | "always" | "auto"
        use_file_scoped = "auto",
    },

    ---@class boilersharp.FullConfig.TypeDefinition
    type_definition = {
        ---@type boilersharp.AccessModifier
        default_access_modifier = "public",

        ---@type boilersharp.CsharpType
        default_type = "class",

        ---@type boolean
        infer_interfaces = true,
    },

    ---@type boolean
    add_autocommand = true,

    ---@type "tabs" | "spaces" | "auto"
    indent_type = "auto",
}

---@type boilersharp.FullConfig
M.config = M.DEFAULT

---@param opts? boilersharp.Config
function M.init_config(opts)
    M.config = vim.tbl_deep_extend("force", M.DEFAULT, opts or {})
end

return M
