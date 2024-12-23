local M = {}

---@class boilersharp.Config
---@field usings boilersharp.Config.Usings | false | nil
---@field namespace boilersharp.Config.Namespace | false | nil
---@field type_definition boilersharp.Config.TypeDefinition | false | nil
---@field indent_type "tabs" | "spaces" | "auto" | nil

---@class boilersharp.Config.Usings
---@field implicit_usings "never" | "always" | "auto" | nil
---@field usings string[] | nil

---@class boilersharp.Config.Namespace
---@field use_file_scoped "never" | "always" | "auto" | nil

---@class boilersharp.Config.TypeDefinition
---@field default_access_modifier boilersharp.AccessModifier | nil
---@field default_type boilersharp.CsharpType | nil
---@field infer_interfaces boolean | nil

---@class boilersharp.FullConfig
---@field usings boilersharp.FullConfig.Usings | false
---@field namespace boilersharp.FullConfig.Namespace | false
---@field type_definition boilersharp.FullConfig.TypeDefinition | false

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

    ---@type "tabs" | "spaces" | "auto"
    indent_type = "auto",
}

M.config = M.DEFAULT

---@param opts boilersharp.Config | nil
function M.init_config(opts)
    M.config = vim.tbl_deep_extend("force", M.DEFAULT, opts or {})
end

return M
