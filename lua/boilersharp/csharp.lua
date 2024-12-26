local config = require("boilersharp.config").config

local M = {}

---@alias boilersharp.AccessModifier
---| "public"
---| "protected"
---| "private"
---| "internal"
---| "protected internal"
---| "private protected"
---| "file"

---@alias boilersharp.CsharpType
---| "class"
---| "struct"
---| "interface"
---| "enum"
---| "record"
---| "record struct"

---@class boilersharp.DirData
---@field csproj? string Path to csproj file
---@field namespace string Namespace of the directory

---@class boilersharp.CsprojData
---@field target_framework string Version of dotnet used 
---@field cs_version string Version of C# used
---@field implicit_usings boolean Whether or not the project uses implicit usings
---@field file_scoped_namespace boolean Whether or not the project supports file scoped namespaces
---@field root_namespace? string The root namespace of the csproj, if applicable

local TSLANG = "xml"

---{ [path/to/directory]: Dir }
---@type { [string]: boilersharp.DirData }
local dir_cache = {}

---{ [path/to/project.csproj]: Csproj }
---@type { [string]: boilersharp.CsprojData }
local csproj_cache = {}

---Clears cached directories and csproj files
function M.clear_cache()
    dir_cache = {}
    csproj_cache = {}
end

---@param path string
---@return boilersharp.DirData
local function inspect_dir(path)
    ---@type string[]
    local namespace = {}

    local curr_path = path
    local prev_path
    while true do
        -- This will be true when we reach the top of the filesystem
        if curr_path == prev_path then
            return { namespace = vim.fn.fnamemodify(path, ":t") }
        end

        for item, kind in vim.fs.dir(curr_path) do
            if kind == "file" and vim.fn.fnamemodify(item, ":e") == "csproj" then
                table.insert(namespace, 1, vim.fn.fnamemodify(item, ":r"))
                local joined_namespace = table.concat(namespace, ".")
                local csproj_path = vim.fs.joinpath(curr_path, item)
                local csproj_data = M.get_csproj_data(csproj_path)
                return {
                    namespace = csproj_data.root_namespace or joined_namespace,
                    csproj = csproj_path,
                }
            end
        end

        table.insert(namespace, 1, vim.fn.fnamemodify(curr_path, ":t"))
        prev_path = curr_path
        curr_path = vim.fn.fnamemodify(curr_path, ":h")
    end
end

---@param path string Path to the csproj file
---@return boilersharp.CsprojData
local function inspect_csproj(path)
    ---@type string[]
    local lines = vim.fn.readfile(path)
    local source = table.concat(lines, "\n")
    local query = vim.treesitter.query.get(TSLANG, "boilersharp")
    if query == nil then
        error("Boilersharp: could not load query")
    end

    local parser = vim.treesitter.get_string_parser(source, TSLANG)
    local tree = parser:parse()
    local root = tree[1]:root()

    ---@type number, number
    local key_id, value_id
    for id, capture in pairs(query.captures) do
        if capture == "key" then
            key_id = id
        elseif capture == "value" then
            value_id = id
        end
    end

    ---@type boilersharp.CsprojData
    local csproj_data = {
        implicit_usings = false,
        cs_version = "",
        target_framework = "default",
        file_scoped_namespace = false,
        root_namespace = nil,
    }

    -- pattern, captures, metadata
    for _, captures, _ in query:iter_matches(root, source) do
        local key = vim.treesitter.get_node_text(captures[key_id], source)
        local value = vim.treesitter.get_node_text(captures[value_id], source)
        if key == "ImplicitUsings" and value == "enable" then
            csproj_data.implicit_usings = true
        elseif key == "LangVersion" then
            csproj_data.cs_version = value
        elseif key == "RootNamespace" then
            csproj_data.root_namespace = value
        elseif key == "TargetFramework" then
            csproj_data.target_framework = value
        end
    end

    if csproj_data.cs_version == "" then
        csproj_data.file_scoped_namespace = M.tfm_supports_file_scoped_namespaces(csproj_data.target_framework)
    else
        csproj_data.file_scoped_namespace = M.cs_version_supports_file_scoped_namespaces(csproj_data.cs_version)
    end

    return csproj_data
end

function M.get_usings(csproj_path)
    if config.usings == false then
        return {}
    end

    local implicit = config.usings.implicit_usings
    local add_usings

    if implicit == "never" then
        add_usings = true
    elseif implicit == "always" then
        add_usings = false
    elseif implicit == "auto" then
        local csproj_data = M.get_csproj_data(csproj_path)
        add_usings = not csproj_data.implicit_usings
    else
        error("Boilersharp: Invalid option for usings.implicit_usings")
    end

    if add_usings then
        return config.usings.usings
    else
        return {}
    end
end

---@param version string C# version as specified by [C# language version reference](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/language-versioning#c-language-version-reference)
---@return boolean
function M.cs_version_supports_file_scoped_namespaces(version)
    return not vim.tbl_contains(
        -- These C# versions don't support file scoped namespaces
        { "9.0", "8.0", "7.3", "7.2", "7.1", "7", "6", "5", "4", "3", "2", "1", "ISO-2", "ISO-1" },
        version
    )
end

---@param tfm string [Target Framework](https://learn.microsoft.com/en-us/dotnet/standard/frameworks)
---@return boolean
function M.tfm_supports_file_scoped_namespaces(tfm)
    local version = tfm:match("^net(%d+)%.0")
    if version == nil then
        return tfm:match("^netstandard%d+%.%d+$") ~= nil
    end
    return tonumber(version) >= 6
end

---@param path? string Path of the C# file
---@return string
function M.get_type_name(path)
  -- The pattern gets the filename until the first dot, as opposed to
  -- the last dot, which is what :r does
  -- Class.razor.cs
  --   :r       ->  Class.razor
  --   pattern  ->  Class
  local pattern = [[:t:s?\(\w\+\).*?\1?]]
  if path then
    return vim.fn.fnamemodify(path, pattern)
  end
  return vim.fn.expand("%" .. pattern)
end

---@param path string Path to directory
---@return boilersharp.DirData
function M.get_dir_data(path)
    local dir_data = dir_cache[path]

    if not dir_data then
        dir_data = inspect_dir(path)
        dir_cache[path] = dir_data
    end

    return dir_data
end

---@param path string Path to csproj file
---@return boilersharp.CsprojData
function M.get_csproj_data(path)
    if not path:match(".csproj$") then
        error("Invalid argument. Path must be a path to a file ending in .csproj")
    end

    local csproj_data = csproj_cache[path]

    if not csproj_data then
        csproj_data = inspect_csproj(path)
        csproj_cache[path] = csproj_data
    end

    return csproj_data
end

return M
