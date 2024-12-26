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
        boilerplate.from_file = function() end
        boilerplate.to_string = function() end
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

T["write_boilerplate()"]["does not writes to non-empty buffer"] = function(expected_lines)
    child.api.nvim_buf_set_lines(0, 0, -1, false, { "Hey" })

    mock(expected_lines)
    child.lua([[M.write_boilerplate()]])

    local lines = child.api.nvim_buf_get_lines(0, 0, -1, false)
    expect.equality(lines, { "Hey" })
end

T["write_boilerplate()"]["writes to non-empty buffer with ensure_empty = false"] = function(expected_lines)
    child.api.nvim_buf_set_lines(0, 0, -1, false, { "Hey" })

    mock(expected_lines)
    child.lua([[M.write_boilerplate({ ensure_empty = false })]])

    local lines = child.api.nvim_buf_get_lines(0, 0, -1, false)
    expect.equality(lines, expected_lines)
end

return T
