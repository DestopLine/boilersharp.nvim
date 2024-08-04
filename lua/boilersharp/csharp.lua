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

---@param spacing boolean Add spacing after the usings (if any)
---@return string[]
function M.get_usings(spacing)
  if cfg.opts.add_usings == "never" then
    return {}
  elseif cfg.opts.add_usings == "always" then
    if spacing then
      return vim.iter({ USINGS,  "" }):flatten():totable()
    end
    return USINGS
  else
    --  TODO: Calculate auto usings
    return {}
  end
end

return M
