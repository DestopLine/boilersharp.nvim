local M = {}

function M.current_file_parent()
  return vim.fn.expand("%:p:h")
end

return M
