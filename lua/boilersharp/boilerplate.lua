local cs = require("boilersharp.csharp")
local opts = require("boilersharp.options").options

local M = {}

---@class boilersharp.Boilerplate
---@field usings string[]
---@field namespace boilersharp.Boilerplate.Namespace | nil
---@field type boilersharp.Boilerplate.Type | nil

---@class boilersharp.Boilerplate.Namespace
---@field file_scoped boolean
---@field namespace string

---@class boilersharp.Boilerplate.Type
---@field access_modifier boilersharp.AccessModifier
---@field type boilersharp.CsharpType
---@field name string

local function file_parent(path)
  return vim.fn.fnamemodify(path, ":p:h")
end

---@param path string Path to C# file
---@return boilersharp.Boilerplate
function M.from_file(path)
    local dir_data = cs.get_dir_data(file_parent(path))
    local csproj_data = cs.get_csproj_data(dir_data.csproj)

    ---@type boilersharp.Boilerplate.Namespace | nil
    local namespace
    if opts.namespace then
        local file_scoped
        local use_file_scoped = opts.namespace.use_file_scoped
        if use_file_scoped == "never" then
            file_scoped = false
        elseif use_file_scoped == "always" then
            file_scoped = true
        elseif use_file_scoped == "auto" then
            file_scoped = csproj_data.file_scoped_namespace
        else
            error("Boilersharp: Invalid option for namespace.use_file_scoped")
        end
        namespace = {
            file_scoped = file_scoped,
            namespace = dir_data.namespace,
        }
    else
        namespace = nil
    end

    ---@type boilersharp.Boilerplate.Type | nil
    local type_
    if opts.type_definition then
        local cs_type = opts.type_definition.default_type
        local name = cs.get_type_name(path)

        if opts.type_definition.infer_interfaces and name:match("^I[A-Z].*$") then
            cs_type = "interface"
        end

        type_ = {
            access_modifier = opts.type_definition.default_access_modifier,
            type = cs_type,
            name = name,
        }
    else
        type_ = nil
    end

    ---@type boilersharp.Boilerplate
    return {
        usings = cs.get_usings(dir_data.csproj),
        namespace = namespace,
        type = type_,
    }
end

---@param level integer | nil Times to repeat the indentation. Defaults to 1.
---@return string
local function get_indentation(level)
    level = level or 1
    local is_spaces
    local indent
    if opts.indent_type == "tabs" then
        is_spaces = false
    elseif opts.indent_type == "spaces" then
        is_spaces = true
    elseif opts.indent_type == "auto" then
        is_spaces = vim.opt.expandtab:get()
    else
        error("Boilersharp: Invalid option for indent_type")
    end

    if is_spaces then
        -- `repeat` is a lua keyword
        ---@diagnostic disable-next-line: undefined-field
        indent = vim.fn["repeat"](" ", vim.opt.shiftwidth:get())
    else
        indent = "\t"
    end

    return vim.fn["repeat"](indent, level)
end

---@param boilerplate boilersharp.Boilerplate
---@return string
function M.to_string(boilerplate)
    ---@type string[]
    local sections = {}
    local indent_level = 0

    local function append(text)
        local indent = get_indentation(indent_level)
        local indented = indent .. vim.fn.substitute(
            text,
            "\n" .. [[\(\s*\S\+\)]],
            "\n" .. indent .. [[\1]],
            "g"
        )
        table.insert(sections, indented)
    end

    if #boilerplate.usings > 0 then
        local usings = {}
        for _, using in ipairs(boilerplate.usings) do
            table.insert(usings, "using " .. using .. ";")
        end
        append(table.concat(usings, "\n"))

        if boilerplate.namespace or boilerplate.type then
            append("")
        end
    end

    if boilerplate.namespace then
        if boilerplate.namespace.file_scoped then
            append("namespace " .. boilerplate.namespace.namespace .. ";")
            if boilerplate.type then
                append("")
            end
        else
            append("namespace " .. boilerplate.namespace.namespace .. "\n{")
            indent_level = indent_level + 1
        end
    end

    if boilerplate.type then
        append(("%s %s %s\n{"):format(
            boilerplate.type.access_modifier,
            boilerplate.type.type,
            boilerplate.type.name
        ))
        indent_level = indent_level + 1
    end

    while indent_level > 0 do
        indent_level = indent_level - 1
        append("}")
    end

    return table.concat(sections, "\n")
end

return M
