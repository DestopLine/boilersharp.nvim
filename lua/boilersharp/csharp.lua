local cfg = require("boilersharp.config")
local cache = require("boilersharp.cache")

local M = {}

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
    --  TODO: Calculate csproj usings
  end

  if use then return USINGS else return {} end
end

---@return boolean
function M.uses_file_scoped_namespaces()
  local opt = cfg.opts.use_file_scoped_namespaces
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
    --  TODO: Implement this
    return true
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

return M
