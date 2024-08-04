local cfg = require("boilersharp.config")

local M = {}

---@return string
function M.get_namespace()
  ---@type string[]
  local namespace = {}

  local dir = "%:p:h" -- Current file's parent directory
  local expanded_dir
  local prev_expanded_dir
  while true do
    prev_expanded_dir = expanded_dir
    expanded_dir = vim.fn.expand(dir)

    -- This will be true when we reach the top of the filesystem
    if expanded_dir == prev_expanded_dir then
      return vim.fn.expand("%:h:t")
    end

    for file in vim.fs.dir(expanded_dir) do
      local extension = vim.fn.fnamemodify(file, ":e")
      if extension == "csproj" then
        table.insert(namespace, 1, vim.fn.fnamemodify(file, ":r"))
        return table.concat(namespace, ".")
      end
    end

    table.insert(namespace, vim.fn.expand(dir .. ":t"))
    dir = dir .. ":h"
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

---@return string
function M.get_type_name()
  -- The pattern gets the filename until the first dot, as opposed to
  -- the last dot, which is what :r does
  -- Class.razor.cs
  --   :r       ->  Class.razor
  --   pattern  ->  Class
  return vim.fn.expand([[%:t:s?\(\w\+\).*?\1?]])
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
  local use = cfg.opts.use_file_scoped_namespaces

  if use == "always" then
    return true
  elseif use == "never" then
    return false
  elseif use == "version" then
    --  TODO: Implement this
    return true
  elseif use == "csproj" then
    --  TODO: Implement this
    return true
  end
end

return M
