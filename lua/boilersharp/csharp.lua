local cfg = require("boilersharp.config")
local cache = require("boilersharp.cache")
local utils = require("boilersharp.utils")

local M = {}

local TSLANG = "xml"

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

    for file in vim.fs.dir(curr_path) do
      local extension = vim.fn.fnamemodify(file, ":e")
      if extension == "csproj" then
        table.insert(namespace, 1, vim.fn.fnamemodify(file, ":r"))
        local joined_namespace = table.concat(namespace, ".")
        return {
          namespace = joined_namespace,
          csproj = file,
        }
      end
    end

    table.insert(namespace, vim.fn.fnamemodify(curr_path, ":t"))
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
    if capture == "key" then key_id = id
    elseif capture == "value" then value_id = id
    end
  end

  ---@type boilersharp.CsprojData
  local csproj_data = {
    implicit_usings = false,
    cs_version = "",
    target_framework = "default",
    file_scoped_namespace = false,
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
    csproj_data.file_scoped_namespace = M.target_framework_supports_file_scoped_namespaces(csproj_data.target_framework)
  else
    csproj_data.file_scoped_namespace = M.cs_version_supports_file_scoped_namespaces(csproj_data.cs_version)
  end

  return csproj_data
end

---@return string?
function M.get_dotnet_version()
  local ok, result = pcall(function()
    return vim.system({ "dotnet", "--version" }, { text = true }):wait()
  end)
  if ok then
    if result.stdout == nil or result.code ~= 0 then
      print("Boilersharp: dotnet cli returned a bad result")
      return nil
    end
    return vim.trim(result.stdout)
  end
  print("Boilersharp: dotnet executable not found")
  return nil
end

---@param version string
---@return number?
function M.parse_major_dotnet_version(version)
  return tonumber(string.match(version, "%d+"))
end

---@param version string
---@return boolean
function M.cs_version_supports_file_scoped_namespaces(version)
  return not vim.tbl_contains(
    { "9.0", "8.0", "7.3", "7.2", "7.1", "7", "6", "5", "4", "3", "2", "1", "ISO-2", "ISO-1" },
    version
  )
end

---@param tfm string
---@return boolean
function M.target_framework_supports_file_scoped_namespaces(tfm)
  local version = tfm:match("^net(%d+)%.0")
  if version == nil then
    return tfm:match("^netstandard%d+%.%d+$")
  end
  return tonumber(version) >= 6
end

---@param path string? Path of the C# file
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

local USINGS = {
  "using System;",
  "using System.Collections.Generic;",
  "using System.IO;",
  "using System.Linq;",
  "using System.Net.Http;",
  "using System.Threading;",
  "using System.Threading.Tasks;",
}

---@return string[]
function M.get_usings()
  local use

  if cfg.opts.add_usings == "never" then
    use = true

  elseif cfg.opts.add_usings == "always" then
    use = false

  elseif cfg.opts.add_usings == "version" then
    local version = M.get_dotnet_version()
    if version == nil then
      use = true
    else
      local major = M.parse_major_dotnet_version(version)
      if major == nil then
        print("Boilersharp: unable to parse dotnet version")
        use = true
      else
        use = major < 6
      end
    end

  elseif cfg.opts.add_usings == "csproj" then
    local dir_data = M.get_dir_data(utils.current_file_parent())
    local csproj_data = M.get_csproj_data(dir_data.csproj)
    use = not csproj_data.implicit_usings
  end

  if use then return USINGS else return {} end
end

---@param csproj string? Path to the csproj file
---@param method "always"|"never"|"version"|"csproj"
---@return boolean
function M.uses_file_scoped_namespaces(csproj, method)
  local opt = method or cfg.opts.use_file_scoped_namespaces
  local use = false

  if opt == "always" then
    use = true

  elseif opt == "never" then
    use = false

  elseif opt == "version" then
    local version = M.get_dotnet_version()
    if version ~= nil then
      local major = M.parse_major_dotnet_version(version)
      if major == nil then
        print("Boilersharp: unable to parse dotnet version")
      else
        use = major >= 6
      end
    end

  elseif opt == "csproj" then
    if csproj == nil then
      M.uses_file_scoped_namespaces(csproj, "version")
    else
      local csproj_data = M.get_csproj_data(csproj)
      return csproj_data.file_scoped_namespace
    end
  end

  return use
end

---@param path string Path to directory
---@return boilersharp.DirData
function M.get_dir_data(path)
  local dir_data = cache._dir_cache[path]

  if not dir_data then
    dir_data = inspect_dir(path)
    cache._dir_cache[path] = dir_data
  end

  return dir_data
end

---@param path string Path to csproj file
---@return boilersharp.CsprojData
function M.get_csproj_data(path)
  if not path:match(".csproj$") then
    error("Invalid argument. Path must be a path to a file ending in .csproj")
  end

  local csproj_data = cache._csproj_cache[path]

  if not csproj_data then
    csproj_data = inspect_csproj(path)
    print(vim.inspect(csproj_data))
    cache._csproj_cache[path] = csproj_data
  end

  return csproj_data
end

return M
