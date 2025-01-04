local test = require("mini.test")
local helpers = require("tests.helpers")

local expect = test.expect

local child, T = helpers.new_test()

---@type boilersharp.CsprojData
local modern_project = {
    implicit_usings = true,
    cs_version = "default",
    target_framework = "net8.0",
    file_scoped_namespace = true,
}

---@type boilersharp.CsprojData
local old_project = {
    implicit_usings = false,
    cs_version = "8.0",
    target_framework = "netcoreapp3.1",
    file_scoped_namespace = false,
}

T["to_string()"] = test.new_set({
    ---@type [boilersharp.Config, string, boilersharp.CsprojData, boilersharp.DirData, string][]
    parametrize = {
        -- Implicit usings & file scoped namespaces
        {
            {
                usings = {
                    implicit_usings = "always",
                },
                namespace = {
                    use_file_scoped = "always",
                },
                indent_type = "spaces",
            },
            "/MyApi/Controllers/WeatherController.cs",
            modern_project,
            { namespace = "MyApi.Controllers" },
            table.concat({
                "namespace MyApi.Controllers;",
                "",
                "public class WeatherController",
                "{",
                "}",
            }, "\n"),
        },
        {
            {
                usings = {
                    implicit_usings = "never",
                    usings = {
                        "First.Using",
                        "Second.Using",
                        "Third.Using",
                    },
                },
                namespace = {
                    use_file_scoped = "always",
                },
                indent_type = "spaces",
            },
            "/MyApi/Controllers/WeatherController.cs",
            modern_project,
            { namespace = "MyApi.Controllers" },
            table.concat({
                "using First.Using;",
                "using Second.Using;",
                "using Third.Using;",
                "",
                "namespace MyApi.Controllers;",
                "",
                "public class WeatherController",
                "{",
                "}",
            }, "\n"),
        },
        {
            {
                usings = {
                    implicit_usings = "always",
                },
                namespace = {
                    use_file_scoped = "never",
                },
                indent_type = "spaces",
            },
            "/MyApi/Controllers/WeatherController.cs",
            modern_project,
            { namespace = "MyApi.Controllers" },
            table.concat({
                "namespace MyApi.Controllers",
                "{",
                "    public class WeatherController",
                "    {",
                "    }",
                "}",
            }, "\n"),
        },
        -- Disabling sections
        {
            {
                usings = {
                    implicit_usings = "auto",
                },
                namespace = {
                    use_file_scoped = "auto",
                },
                type_declaration = false,
                indent_type = "spaces",
            },
            "/MyApi/Controllers/WeatherController.cs",
            old_project,
            { namespace = "MyApi.Controllers" },
            table.concat({
                "using System;",
                "using System.Collections.Generic;",
                "using System.IO;",
                "using System.Linq;",
                "using System.Net.Http;",
                "using System.Threading;",
                "using System.Threading.Tasks;",
                "",
                "namespace MyApi.Controllers",
                "{",
                "}",
            }, "\n"),
        },
        {
            {
                usings = false,
                namespace = {
                    use_file_scoped = "auto",
                },
                type_declaration = false,
                indent_type = "spaces",
            },
            "/MyApi/Controllers/WeatherController.cs",
            old_project,
            { namespace = "MyApi.Controllers" },
            table.concat({
                "namespace MyApi.Controllers",
                "{",
                "}",
            }, "\n"),
        },
        {
            {
                usings = {
                    implicit_usings = "auto",
                },
                namespace = false,
                type_declaration = false,
                indent_type = "spaces",
            },
            "/MyApi/Controllers/WeatherController.cs",
            old_project,
            { namespace = "MyApi.Controllers" },
            table.concat({
                "using System;",
                "using System.Collections.Generic;",
                "using System.IO;",
                "using System.Linq;",
                "using System.Net.Http;",
                "using System.Threading;",
                "using System.Threading.Tasks;",
            }, "\n"),
        },
        {
            {
                usings = false,
                namespace = false,
                type_declaration = false,
                indent_type = "spaces",
            },
            "/MyApi/Controllers/WeatherController.cs",
            old_project,
            { namespace = "MyApi.Controllers" },
            "",
        },
        {
            {
                usings = false,
                namespace = false,
                type_declaration = {},
                indent_type = "spaces",
            },
            "/MyApi/Controllers/WeatherController.cs",
            old_project,
            { namespace = "MyApi.Controllers" },
            table.concat({
                "public class WeatherController",
                "{",
                "}",
            }, "\n"),
        },
        -- Infer interfaces
        {
            {
                usings = {
                    implicit_usings = "always",
                },
                namespace = {
                    use_file_scoped = "always",
                },
                type_declaration = {
                    infer_interfaces = true,
                },
                indent_type = "spaces",
            },
            "/MyApi/Services/IDateTimeProvider.cs",
            modern_project,
            { namespace = "MyApi.Services" },
            table.concat({
                "namespace MyApi.Services;",
                "",
                "public interface IDateTimeProvider",
                "{",
                "}",
            }, "\n"),
        },
        {
            {
                usings = {
                    implicit_usings = "always",
                },
                namespace = {
                    use_file_scoped = "always",
                },
                type_declaration = {
                    infer_interfaces = true,
                },
                indent_type = "spaces",
            },
            "/MyApi/Services/Interface.cs",
            modern_project,
            { namespace = "MyApi.Services" },
            table.concat({
                "namespace MyApi.Services;",
                "",
                "public class Interface",
                "{",
                "}",
            }, "\n"),
        },
        {
            {
                usings = {
                    implicit_usings = "always",
                },
                namespace = {
                    use_file_scoped = "always",
                },
                type_declaration = {
                    default_access_modifier = "internal",
                },
                indent_type = "spaces",
            },
            "/MyApi/Controllers/WeatherController.cs",
            modern_project,
            { namespace = "MyApi.Controllers" },
            table.concat({
                "namespace MyApi.Controllers;",
                "",
                "internal class WeatherController",
                "{",
                "}",
            }, "\n"),
        },
        -- Access modifiers & type keywords
        {
            {
                usings = {
                    implicit_usings = "always",
                },
                namespace = {
                    use_file_scoped = "always",
                },
                type_declaration = {
                    default_type_keyword = "record",
                },
                indent_type = "spaces",
            },
            "/MyApi/Controllers/WeatherController.cs",
            modern_project,
            { namespace = "MyApi.Controllers" },
            table.concat({
                "namespace MyApi.Controllers;",
                "",
                "public record WeatherController",
                "{",
                "}",
            }, "\n"),
        },
        {
            {
                usings = {
                    implicit_usings = "always",
                },
                namespace = {
                    use_file_scoped = "always",
                },
                type_declaration = {
                    default_access_modifier = "file",
                    default_type_keyword = "record struct",
                },
                indent_type = "spaces",
            },
            "/MyApi/Controllers/WeatherController.cs",
            modern_project,
            { namespace = "MyApi.Controllers" },
            table.concat({
                "namespace MyApi.Controllers;",
                "",
                "file record struct WeatherController",
                "{",
                "}",
            }, "\n"),
        },
        {
            {
                usings = {
                    implicit_usings = "always",
                },
                namespace = {
                    use_file_scoped = "always",
                },
                type_declaration = {
                    default_access_modifier = false,
                    default_type_keyword = "class",
                },
                indent_type = "spaces",
            },
            "/MyApi/Controllers/WeatherController.cs",
            modern_project,
            { namespace = "MyApi.Controllers" },
            table.concat({
                "namespace MyApi.Controllers;",
                "",
                "class WeatherController",
                "{",
                "}",
            }, "\n"),
        },
    },
})

T["to_string()"]["converts boilerplate correctly"] = function(
    config,
    file_path,
    csproj_data,
    dir_data,
    expected_boilerplate
)
    helpers.send(child, {
        config = config,
        file_path = file_path,
        csproj_data = csproj_data,
        dir_data = dir_data,
    })

    child.bo.shiftwidth = 4
    local boilerplate = child.lua([[
        M.setup(config)

        local boilerplate = require("boilersharp.boilerplate")
        local csharp = require("boilersharp.csharp")

        csharp.get_csproj_data = function() return csproj_data end
        csharp.get_dir_data = function() return dir_data end

        local boiler = boilerplate.from_file(file_path)
        return boilerplate.to_string(boiler)
    ]])

    expect.equality(boilerplate, expected_boilerplate)
end

return T
