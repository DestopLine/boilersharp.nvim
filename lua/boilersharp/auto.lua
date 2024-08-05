local cfg = require("boilersharp.config")
local cs = require("boilersharp.csharp")
local utils = require("boilersharp.utils")

local M = {}

local function write_boilerplate()
  local lines = {}

  local function insert(obj)
    if type(obj) == "table" then
      for _, elem in pairs(obj) do
        table.insert(lines, elem)
      end
    else
      table.insert(lines, obj)
    end
  end

  local usings = cs.get_usings()
  if #usings > 0 then
    insert(usings)
    insert("")
  end

  local tab
  if vim.bo.expandtab then
    tab = string.rep(" ", vim.bo.shiftwidth)
  else
    tab = "\t"
  end

  local dir_data = cs.get_dir_data(utils.current_file_parent())

  if cs.uses_file_scoped_namespaces(dir_data.csproj) then
    insert({
      ("namespace %s;"):format(dir_data.namespace),
      "",
      ("%s %s %s"):format(cfg.opts.default_access, cfg.opts.default_kind, cs.get_type_name()),
      "{",
      tab,
      "}",
    })
  else
    insert({
      ("namespace %s"):format(dir_data.namespace),
      "{",
      ("%s%s %s %s"):format(tab, cfg.opts.default_access, cfg.opts.default_kind, cs.get_type_name()),
      tab .. "{",
      tab .. tab,
      tab .. "}",
      "}"
    })
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

local function write_boilerplate_on_empty()
  if vim.api.nvim_buf_line_count(0) > 1 then
    return
  end

  if #vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] > 0 then
    return
  end

  write_boilerplate()
end

---@param mode "on_new"|"on_empty"
function M.enable_auto_mode(mode)
  if mode == "on_new" then
    vim.api.nvim_create_autocmd("BufNewFile", {
      desc = "Write C# boilerplate on new file creation",
      group = vim.api.nvim_create_augroup("BoilersharpAutoMode", { clear = true }),
      pattern = "*.cs",
      callback = write_boilerplate,
    })
  elseif mode == "on_empty" then
    vim.api.nvim_create_autocmd("BufWinEnter", {
      desc = "Write C# boilerplate on empty file enter",
      group = vim.api.nvim_create_augroup("BoilersharpAutoMode", { clear = true }),
      pattern = "*.cs",
      callback = write_boilerplate_on_empty,
    })
  end
end

return M
