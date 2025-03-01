local test = require("mini.test")
local helpers = require("tests.helpers")

local expect = test.expect

local child, T = helpers.new_test()

T["write_boilerplate()"] = test.new_set({
    ---Boilerplate as lines
    ---@type [string[]][]
    parametrize = {
        {
            {
                "namespace Something;",
                "",
                "public class SomeClass",
                "{",
                "}",
            },
        },
    },
})

---@param expected_lines string[]
local function mock(expected_lines)
    helpers.send(child, { expected_lines = expected_lines })

    child.lua([[
        M.setup()

        local boilerplate = require("boilersharp.boilerplate")
        boilerplate.from_file = function() return {} end
        boilerplate.to_string = function() return "" end

        local csharp = require("boilersharp.csharp")
        csharp.get_dir_data = function() return {} end
        csharp.get_csproj_data = function() return {} end

        vim.filetype.match = function() return "cs" end
        vim.split = function() return expected_lines end
    ]])
end

T["write_boilerplate()"]["writes to empty buffer"] = function(expected_lines)
    mock(expected_lines)
    child.lua([[M.write_boilerplate()]])

    local lines = child.api.nvim_buf_get_lines(0, 0, -1, false)
    expect.equality(lines, expected_lines)
end

T["write_boilerplate()"]["does not write to non-empty buffer"] = function(expected_lines)
    child.api.nvim_buf_set_lines(0, 0, -1, false, { "Hey" })

    mock(expected_lines)
    child.lua([[M.write_boilerplate()]])

    local lines = child.api.nvim_buf_get_lines(0, 0, -1, false)
    expect.equality(lines, { "Hey" })
end

T["write_boilerplate()"]["prepends to non-empty buffer with ensure_empty = false"] = function(expected_lines)
    child.api.nvim_buf_set_lines(0, 0, -1, false, { "Hey" })

    mock(expected_lines)
    child.lua([[M.write_boilerplate({ ensure_empty = false })]])

    local lines = child.api.nvim_buf_get_lines(0, 0, -1, false)
    table.insert(expected_lines, "Hey")
    expect.equality(lines, expected_lines)
end

T["write_boilerplate()"]["appends to non-empty buffer"] = function(expected_lines)
    child.api.nvim_buf_set_lines(0, 0, -1, false, { "Hey" })

    mock(expected_lines)
    child.lua([[M.write_boilerplate({ ensure_empty = false, behavior = "append" })]])

    local lines = child.api.nvim_buf_get_lines(0, 0, -1, false)
    table.insert(expected_lines, 1, "Hey")
    expect.equality(lines, expected_lines)
end

T["write_boilerplate()"]["replaces non-empty buffer"] = function(expected_lines)
    child.api.nvim_buf_set_lines(0, 0, -1, false, { "Hey" })

    mock(expected_lines)
    child.lua([[M.write_boilerplate({ ensure_empty = false, behavior = "replace" })]])

    local lines = child.api.nvim_buf_get_lines(0, 0, -1, false)
    expect.equality(lines, expected_lines)
end

T["write_boilerplate()"]["writes when filter returns true"] = function(expected_lines)
    mock(expected_lines)
    child.lua([[
        M.write_boilerplate({
            filter = function(dir_data, csproj_data)
                return dir_data ~= nil and csproj_data ~= nil
            end
        })
    ]])

    local lines = child.api.nvim_buf_get_lines(0, 0, -1, false)
    expect.equality(lines, expected_lines)
end

T["write_boilerplate()"]["does not write when filter returns false"] = function(expected_lines)
    mock(expected_lines)
    child.lua([[
        M.write_boilerplate({
            filter = function(dir_data, csproj_data)
                return dir_data == nil or csproj_data == nil
            end
        })
    ]])

    local lines = child.api.nvim_buf_get_lines(0, 0, -1, false)
    expect.equality(lines, { "" })
end

return T
