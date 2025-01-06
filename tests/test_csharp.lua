local test = require("mini.test")
local helpers = require("tests.helpers")

local expect = test.expect

local child, T = helpers.new_test()

T["get_dir_data()"] = test.new_set({
    parametrize = {
        {
            "/home/user/SomeLib",
            {
                namespace = "SomeLib",
                csproj = "/home/user/SomeLib/SomeLib.csproj",
            },
            {
                { { "SomeLib.csproj", "file" } },
            },
        },
        {
            "/home/user/MyApi/Controllers",
            {
                namespace = "MyApi.Controllers",
                csproj = "/home/user/MyApi/MyApi.csproj",
            },
            -- File tree
            {
                -- Directory
                {
                    -- Item
                    { "MyController.cs", "file" },
                },
                {
                    { "Controllers", "directory" },
                    { "MyApi.csproj", "file" },
                },
            },
        },
        {
            "/home/shrek/CoolProject/This/Is/Very/Nested",
            {
                namespace = "CoolProject.This.Is.Very.Nested",
                csproj = "/home/shrek/CoolProject/CoolProject.csproj",
            },
            {
                {},
                { { "Nested", "directory" } },
                { { "Very", "directory" } },
                { { "Is", "directory" } },
                {
                    { "This", "directory" },
                    { "CoolProject.csproj", "file" },
                },
            },
        },
        {
            "/home/archbtw/Hello.World",
            {
                namespace = "Hello.World",
                csproj = "/home/archbtw/Hello.World/Hello.World.csproj",
            },
            {
                { { "Hello.World.csproj", "file" } },
            },
        },
    },
})

T["get_dir_data()"]["csproj found returns correct values"] = function(dir_path, expected_dir_data, file_tree)
    helpers.send(child, { file_tree = file_tree })

    child.lua([[
        local dir_index = 0
        vim.fs.dir = function()
            dir_index = dir_index + 1
            local directory = file_tree[dir_index]
            local i = 0
            if directory then
                return function()
                    i = i + 1
                    if i <= #directory then
                        return unpack(directory[i])
                    end
                end
            else
                return function() end
            end
        end

        require("boilersharp.csharp").get_csproj_data = function()
            return {}
        end
    ]])

    local dir_data = child.lua_get(([[require("boilersharp.csharp").get_dir_data("%s")]]):format(dir_path))

    expect.equality(dir_data, expected_dir_data)
end

T["get_dir_data()"]["csproj not found returns correct values"] = function(dir_path, expected_dir_data, file_tree)
    helpers.send(child, { file_tree = file_tree })

    child.lua([[
        vim.fs.dir = function()
            return function() end
        end

        require("boilersharp.csharp").get_csproj_data = function()
            return {}
        end
    ]])

    expected_dir_data = {
        namespace = vim.fn.fnamemodify(dir_path, ":t"),
        csproj = nil,
    }

    local dir_data = child.lua_get(([[require("boilersharp.csharp").get_dir_data("%s")]]):format(dir_path))

    expect.equality(dir_data, expected_dir_data)
end

T["get_csproj_data()"] = test.new_set({
    ---@type [string[], boilersharp.CsprojData][]
    parametrize = {
        {
            {
                [[<Project Sdk="Microsoft.NET.Sdk">]],
                [[  <PropertyGroup>]],
                [[    <TargetFramework>net8.0</TargetFramework>]],
                [[    <ImplicitUsings>enable</ImplicitUsings>]],
                [[    <Nullable>enable</Nullable>]],
                [[    <LangVersion>default</LangVersion>]],
                [[  </PropertyGroup>]],
                [[</Project>]],
            },
            {
                implicit_usings = true,
                cs_version = "default",
                target_framework = "net8.0",
                file_scoped_namespace = true,
                root_namespace = nil,
            },
        },
        {
            {
                [[<Project Sdk="Microsoft.NET.Sdk">]],
                [[  <PropertyGroup>]],
                [[    <TargetFramework>net5.0</TargetFramework>]],
                [[    <Nullable>enable</Nullable>]],
                [[  </PropertyGroup>]],
                [[</Project>]],
            },
            {
                implicit_usings = false,
                cs_version = nil,
                target_framework = "net5.0",
                file_scoped_namespace = false,
                root_namespace = nil,
            },
        },
        {
            {
                [[<Project Sdk="Microsoft.NET.Sdk">]],
                [[  <PropertyGroup>]],
                [[    <TargetFramework>netstandard2.0</TargetFramework>]],
                [[    <Nullable>enable</Nullable>]],
                [[    <RootNamespace>Hello.World</RootNamespace>]],
                [[  </PropertyGroup>]],
                [[</Project>]],
            },
            {
                implicit_usings = false,
                cs_version = nil,
                target_framework = "netstandard2.0",
                file_scoped_namespace = true,
                root_namespace = "Hello.World",
            },
        },
        {
            {
                [[<Project Sdk="Microsoft.NET.Sdk">]],
                [[  <PropertyGroup>]],
                [[    <TargetFrameworks>net5.0;net8.0</TargetFrameworks>]],
                [[    <Nullable>enable</Nullable>]],
                [[  </PropertyGroup>]],
                [[</Project>]],
            },
            {
                implicit_usings = false,
                cs_version = nil,
                target_framework = nil,
                target_frameworks = { "net5.0", "net8.0" },
                file_scoped_namespace = false,
            },
        },
        {
            {
                [[<Project Sdk="Microsoft.NET.Sdk">]],
                [[  <PropertyGroup>]],
                [[    <TargetFrameworks>net6.0;net9.0</TargetFrameworks>]],
                [[    <Nullable>enable</Nullable>]],
                [[    <ImplicitUsings>enable</ImplicitUsings>]],
                [[  </PropertyGroup>]],
                [[</Project>]],
            },
            {
                implicit_usings = true,
                cs_version = nil,
                target_framework = nil,
                target_frameworks = { "net6.0", "net9.0" },
                file_scoped_namespace = true,
            },
        }
    },
})

T["get_csproj_data()"]["retuns correct values"] = function(csproj_lines, expected_csproj)
    helpers.send(child, { csproj_lines = csproj_lines })

    child.lua([[
        vim.fn.readfile = function() return csproj_lines end
    ]])

    local csproj = child.lua_get([[require("boilersharp.csharp").get_csproj_data(".csproj")]])

    expect.equality(csproj, expected_csproj)
end

return T
