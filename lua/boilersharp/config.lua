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
    ---Information about the usings section of the boilerplate.
    ---This can be set to `false` to disable the section altogether.
    ---@class boilersharp.FullConfig.Usings
    usings = {
        ---When to use assume that the project uses implicit usings.
        ---Set this to "auto" to get this from the C# version infered from
        ---the csproj file of the project.
        ---@type "never" | "always" | "auto"
        implicit_usings = "auto",

        ---Usings to automatically add to the file when needed.
        ---You could set this to { "System" } to only include the System
        ---namespace.
        ---@type string[]
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

    ---Information about the namespace section of the boilerplate.
    ---This can be set to `false` to disable the section altogether.
    ---@class boilersharp.FullConfig.Namespace
    namespace = {
        ---When to use file scoped namespace syntax.
        ---Set this to "auto" to get this from the C# version infered from
        ---the csproj file of the project.
        ---@type "never" | "always" | "auto"
        use_file_scoped = "auto",
    },

    ---Information about the type declaration section of the boilerplate.
    ---This can be set to `false` to disable the section altogether.
    ---@class boilersharp.FullConfig.TypeDefinition
    type_definition = {
        ---Access modifier to use when writing boilerplate.
        ---@type boilersharp.AccessModifier
        default_access_modifier = "public",

        ---C# keyword to use when defining the type.
        ---@type boilersharp.CsharpType
        default_type = "class",

        ---Whether the plugin should use the `interface` keyword for the
        ---type declaration when the name of the type matches the C#
        ---interface naming convention, which would be equivalent to this
        ---regular expression: `^I[A-Z].*$`.
        ---@type boolean
        infer_interfaces = true,
    },

    ---Whether to add autocommands for writing boilerplate when you enter
    ---an empty C# file. Set this to `false` if you wanna be in control
    ---of when boilerplate gets written to the file through user commands
    ---or lua functions.
    ---@type boolean
    add_autocommand = true,

    ---What type of indentation to use for boilerplate generation. This is
    ---only ever used when not using file scoped namespace syntax and
    ---`type_definition` is enabled. Set this to "auto" to take this from
    ---the buffer's options. 
    ---
    ---It is recommended that you set up an "after/ftplugin/cs.lua" file
    ---in your nvim config with options for `expandtab` instead of
    ---changing this option from its default value.
    ---See `:h ftplugin` and `:h after-directory`.
    ---@type "tabs" | "spaces" | "auto"
    indent_type = "auto",
}

---@type boilersharp.FullConfig
M.config = M.DEFAULT

---Initializes the configuration for the plugin.
---@param opts? boilersharp.Config Custom configuration table.
function M.init_config(opts)
    M.config = vim.tbl_deep_extend("force", M.DEFAULT, opts or {})
end

return M
