local cfg = require("boilersharp.config")
local snippets = require("boilersharp.snippets")
local auto = require("boilersharp.auto")

local M = {}

---@param opts boilersharp.Opts?
function M.setup(opts)
  cfg.opts = vim.tbl_deep_extend("force", cfg.DEFAULT, opts or {})

  if cfg.opts.add_snippets then
    snippets.add_snippets()
  end

  local auto_mode = cfg.opts.auto_mode
  if auto_mode == "on_new" then
    auto.enable_auto_mode("on_new")
  elseif auto_mode == "on_empty" then
    auto.enable_auto_mode("on_empty")
  end
end

return M
