vim.o.rtp = vim.o.rtp .. "," .. vim.fn.getcwd()

if #vim.api.nvim_list_uis() == 0 then
    local deps = vim.fs.joinpath(vim.fn.getcwd(), "deps")
    vim.o.rtp = vim.o.rtp .. "," .. deps
    vim.o.rtp = vim.o.rtp .. "," .. vim.fs.joinpath(deps, "mini.test")
    require("mini.test").setup()
end
