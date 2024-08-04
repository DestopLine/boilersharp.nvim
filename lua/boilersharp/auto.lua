local M = {}

local function write_boilerplate()
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "dingus inc.", "asdf", "123" })
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
