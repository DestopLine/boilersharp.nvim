vim.opt.rtp:append(vim.fn.getcwd())

if #vim.api.nvim_list_uis() == 0 then
    local minitest_path = vim.fs.joinpath(vim.fn.getcwd(), "deps/mini.test")
    vim.opt.rtp:append(minitest_path)
    require("mini.test").setup()
end
