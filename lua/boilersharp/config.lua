local M = {}

---@class boilersharp.Config
---@field usings? boilersharp.Config.Usings | false
---@field namespace? boilersharp.Config.Namespace | false
---@field type_declaration? boilersharp.Config.TypeDeclaration | false
---@field add_autocommand? boolean
---@field indent_type? "tabs" | "spaces" | "auto"
---@field filter? fun(dir_data: boilersharp.DirData, csproj_data: boilersharp.CsprojData): boolean
---@field auto_install_xml_parser? boolean

---@class boilersharp.Config.Usings
---@field implicit_usings? "never" | "always" | "auto"
---@field usings? string[]

---@class boilersharp.Config.Namespace
---@field use_file_scoped? "never" | "always" | "auto"

---@class boilersharp.Config.TypeDeclaration
---@field default_access_modifier? boilersharp.AccessModifier | false
---@field default_type_keyword? boilersharp.TypeKeyword
---@field infer_interfaces? boolean

---@class boilersharp.FullConfig
---@field usings boilersharp.FullConfig.Usings | false
---@field namespace boilersharp.FullConfig.Namespace | false
---@field type_declaration boilersharp.FullConfig.TypeDeclaration | false
---@field add_autocommand boolean
---@field indent_type "tabs" | "spaces" | "auto"
---@field filter fun(dir_data: boilersharp.DirData, csproj_data: boilersharp.CsprojData): boolean
---@field auto_install_xml_parser boolean

M.DEFAULT = {
    ---Information about the usings section of the boilerplate.
    ---This can be set to `false` to disable the section altogether.
    ---@class boilersharp.FullConfig.Usings
    usings = {
        ---When to use assume that the project uses implicit usings.
        ---Set this to "auto" to get this from the C# version inferred from
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
        ---Set this to "auto" to get this from the C# version inferred from
        ---the csproj file of the project.
        ---@type "never" | "always" | "auto"
        use_file_scoped = "auto",
    },

    ---Information about the type declaration section of the boilerplate.
    ---This can be set to `false` to disable the section altogether.
    ---@class boilersharp.FullConfig.TypeDeclaration
    type_declaration = {
        ---Access modifier to use when writing boilerplate. Set this to
        ---`false` to not use any access modifier (implicitly `internal`).
        ---@type boilersharp.AccessModifier | false
        default_access_modifier = "public",

        ---C# keyword to use when declaring the type.
        ---@type boilersharp.TypeKeyword
        default_type_keyword = "class",

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
    ---`type_declaration` is enabled. Set this to "auto" to take this from
    ---the buffer's options.
    ---
    ---It is recommended that you set up an "after/ftplugin/cs.lua" file
    ---in your nvim config with options for `expandtab` instead of
    ---changing this option from its default value.
    ---See `:h ftplugin` and `:h after-directory`.
    ---@type "tabs" | "spaces" | "auto"
    indent_type = "auto",

    ---Function that returns whether or not to write boilerplate. The
    ---function takes as parameters data about the directory of the file,
    ---and data about the csproj file.
    ---@type fun(
    ---    dir_data: boilersharp.DirData,
    ---    csproj_data: boilersharp.CsprojData,
    ---): boolean
    filter = function() return true end,

    ---Whether or not to try to install the xml parser through
    ---nvim-treesitter automatically.
    ---@type boolean
    auto_install_xml_parser = true,
}

---@type boilersharp.FullConfig
M.config = M.DEFAULT

---Initializes the configuration for the plugin.
---@param opts? boilersharp.Config Custom configuration table.
function M.init_config(opts)
    M.config = vim.tbl_deep_extend("force", M.DEFAULT, opts or {})
end

return M
