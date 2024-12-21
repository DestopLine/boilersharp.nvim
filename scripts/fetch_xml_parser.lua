-- This script fetches the xml from your Neovim instance and writes it
-- to deps/parser/xml.so.
-- You need to have a xml parser registered, which nvim-treesitter
-- does automatically.

if #vim.api.nvim_list_uis() == 0 then
    local parser_path = vim.api.nvim_get_runtime_file("parser/xml.so", false)[1]

    if not parser_path then
        error("Could not find parser for xml. Please install it manually or with nvim-treesitter.")
    end

    local parser = io.open(parser_path, "rb")
    if not parser then
        error("Could not open parser for xml: " .. parser_path)
    end

    local deps_parser = io.open("deps/parser/xml.so", "wb")
    if not deps_parser then
        error("Could not create/open deps/parser/xml.so")
    end

    deps_parser:write(parser:read("*a"))

    parser:close()
    deps_parser:close()
end
