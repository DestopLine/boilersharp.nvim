vim.opt.rtp:append(vim.fn.getcwd())

if #vim.api.nvim_list_uis() == 0 then
    local deps = vim.fs.joinpath(vim.fn.getcwd(), "deps")
    vim.opt.rtp:append(deps)
    vim.opt.rtp:append(vim.fs.joinpath(deps, "mini.test"))
    require("mini.test").setup()
end
