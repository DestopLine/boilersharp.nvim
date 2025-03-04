local cs = require("boilersharp.csharp")
local config = require("boilersharp.config").config

local M = {}
local H = {}

---Represents boilerplate in C#
---@class boilersharp.Boilerplate
---@field usings string[] Namespaces to use for usings.
---@field namespace? boilersharp.Boilerplate.Namespace
---@field type_declaration? boilersharp.Boilerplate.TypeDeclaration 

---Information about the namespace in the boilerplate.
---@class boilersharp.Boilerplate.Namespace
---@field file_scoped boolean Whether file scoped namespace syntax will be used when writing the boilerplate.
---@field namespace string Namespace used for the boilerplate.

---Information about the type in the boilerplate.
---@class boilersharp.Boilerplate.TypeDeclaration
---@field access_modifier boilersharp.AccessModifier | false Access modifier that will be used when writing the boilerplate or `false` to not use any access modifier.
---@field type_keyword boilersharp.TypeKeyword Keyword that will be used to declare the typed when writing the boilerplate.
---@field name string Name of the type used when writing boilerplate.

---Takes a path to a file and returns a `boilersharp.Boilerplate`.
---Returns nil if the file is not within a project.
---@param path string Path to C# file.
---@return boilersharp.Boilerplate?
function M.from_file(path)
    local dir_data = cs.get_dir_data(H.file_parent(path))
    if not dir_data.csproj then
        return nil
    end
    local csproj_data = cs.get_csproj_data(dir_data.csproj)

    ---@type boilersharp.Boilerplate.Namespace?
    local namespace
    if config.namespace then
        local file_scoped
        local use_file_scoped = config.namespace.use_file_scoped
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

    ---@type boilersharp.Boilerplate.TypeDeclaration?
    local type_declaration
    if config.type_declaration then
        local cs_type = config.type_declaration.default_type_keyword
        local name = cs.get_type_name(path)

        if config.type_declaration.infer_interfaces and name:match("^I[A-Z].*$") then
            cs_type = "interface"
        end

        type_declaration = {
            access_modifier = config.type_declaration.default_access_modifier,
            type_keyword = cs_type,
            name = name,
        }
    else
        type_declaration = nil
    end

    ---@type boilersharp.Boilerplate
    return {
        usings = cs.get_usings(dir_data.csproj),
        namespace = namespace,
        type_declaration = type_declaration,
    }
end

---Takes a `boilersharp.Boilerplate` and converts it to C# code.
---@param boilerplate boilersharp.Boilerplate
---@return string
function M.to_string(boilerplate)
    ---@type string[]
    local sections = {}
    local indent_level = 0

    local function append(text)
        local indent = H.get_indentation(indent_level)
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

        if boilerplate.namespace or boilerplate.type_declaration then
            append("")
        end
    end

    if boilerplate.namespace then
        if boilerplate.namespace.file_scoped then
            append("namespace " .. boilerplate.namespace.namespace .. ";")
            if boilerplate.type_declaration then
                append("")
            end
        else
            append("namespace " .. boilerplate.namespace.namespace .. "\n{")
            indent_level = indent_level + 1
        end
    end

    if boilerplate.type_declaration then
        local access_modifier
        if boilerplate.type_declaration.access_modifier then
            access_modifier = boilerplate.type_declaration.access_modifier .. " "
        else
            access_modifier = ""
        end

        append(("%s%s %s\n{"):format(
            access_modifier,
            boilerplate.type_declaration.type_keyword,
            boilerplate.type_declaration.name
        ))
        indent_level = indent_level + 1
    end

    while indent_level > 0 do
        indent_level = indent_level - 1
        append("}")
    end

    return table.concat(sections, "\n")
end

function H.file_parent(path)
  return vim.fn.fnamemodify(path, ":p:h")
end

---@param level? integer Times to repeat the indentation. Defaults to 1.
---@return string
function H.get_indentation(level)
    level = level or 1
    local is_spaces
    local indent
    if config.indent_type == "tabs" then
        is_spaces = false
    elseif config.indent_type == "spaces" then
        is_spaces = true
    elseif config.indent_type == "auto" then
        is_spaces = vim.o.expandtab
    else
        error("Boilersharp: Invalid option for indent_type")
    end

    if is_spaces then
        -- `repeat` is a lua keyword
        ---@diagnostic disable-next-line: undefined-field
        indent = vim.fn["repeat"](" ", vim.o.shiftwidth)
    else
        indent = "\t"
    end

    return vim.fn["repeat"](indent, level)
end

return M
