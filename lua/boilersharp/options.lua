local M = {}

---@class boilersharp.PartialOptions
---@field usings boilersharp.PartialOptions.Usings | false | nil
---@field namespace boilersharp.PartialOptions.Namespace | false | nil
---@field type_definition boilersharp.PartialOptions.TypeDefinition | false | nil
---@field indent_type "tabs" | "spaces" | "auto" | nil

---@class boilersharp.PartialOptions.Usings
---@field implicit_usings "never" | "always" | "auto" | nil
---@field usings string[] | nil

---@class boilersharp.PartialOptions.Namespace
---@field use_file_scoped "never" | "always" | "auto" | nil

---@class boilersharp.PartialOptions.TypeDefinition
---@field default_access_modifier boilersharp.AccessModifier | nil
---@field default_type boilersharp.CsharpType | nil
---@field infer_interfaces boolean | nil

---@class boilersharp.FullOptions
---@field usings boilersharp.FullOptions.Usings | false
---@field namespace boilersharp.FullOptions.Namespace | false
---@field type_definition boilersharp.FullOptions.TypeDefinition | false

M.DEFAULT = {
    ---@class boilersharp.FullOptions.Usings
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

    ---@class boilersharp.FullOptions.Namespace
    namespace = {
        ---@type "never" | "always" | "auto"
        use_file_scoped = "auto",
    },

    ---@class boilersharp.FullOptions.TypeDefinition
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

M.options = M.DEFAULT

---@param partial_opts boilersharp.PartialOptions | nil
function M.init_options(partial_opts)
    M.options = vim.tbl_deep_extend("force", M.DEFAULT, partial_opts or {})
end

return M
