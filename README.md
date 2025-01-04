# boilersharp.nvim
Boilersharp.nvim is a plugin that automatically generates and writes C#
boilerplate when you create a file inside a C# project. To be more specific,
boilersharp auto-generates usings, namespace and type declaration for you,
while taking into account to the best of its abilities the version of C# that
your project uses in order to generate boilerplate with modern features.

Features:
- Enable or disable boilerplate sections.
- Add usings only when project is not using implicit usings.
- Automatically detect namespace.
- Customize access modifiers (public, private, internal...).
- Customize keyword for type declaration (class, record, struct...).
- Infer whether the file is an interface from the file name.

## Requirements
- Neovim >= 0.10.0.
- Treesitter parser for xml.

## Usage
Using boilersharp is as simple as creating a file on a C# project and opening
it. The plugin will then gather information about the csproj, cache that
information, process it and write the boilerplate.

You can also generate boilerplate directly with the command `:Boilersharp` or
the lua function `require("boilersharp").write_boilerplate()` which accepts
extra parameters. See `:h boilersharp.write_boilerplate()`.

If you ever modify the `PropertyGroup` tag in your csproj file in a way that
may change the behavior of the plugin in any relevant way, you can clear the
plugin's cache by running the `:Boilersharp clear` command or the
`require("boilersharp.csharp").clear()` function.

## Examples
Namespace and type declaration are generated with modern syntax:
```
MyCoolApi
├── Controllers
│   └── WeatherController.cs
└── MyCoolApi.csproj
```
```cs
namespace MyCoolApi.Controllers;

public class WeatherController
{
}
```

Interfaces are inferred for you:
```
SomeWebApp.Shared
├── Services
│   └── ISomeService.cs
└── SomeLib.csproj
```
```cs
namespace SomeWebApp.Shared.Services;

public interface ISomeService
{
}
```

Old syntax is used in old C# versions:
```
VeryOldProject
├── Startup.cs
└── VeryOldProject.csproj
```
```cs
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;

namespace VeryOldProject
{
    public class Startup
    {
    }
}
```

## Installation
> [!NOTE]
> You must call `require("boilersharp").setup()` to enable the plugin.

<details>
  <summary>With 
    <a href="https://github.com/folke/lazy.nvim">lazy.nvim</a>
  </summary>

  ```lua
  {
    "DestopLine/boilersharp.nvim",
    opts = {
      -- Your options go here
    },
  }
  ```

</details>

<details>
  <summary>With 
    <a href="https://github.com/echasnovski/mini.deps">mini.deps</a>
  </summary>

  ```lua
  MiniDeps.add({
    source = "DestopLine/boilersharp.nvim",
  })
  require("boilersharp").setup({
    -- Your options go here
  })
  ```

</details>

<details>
  <summary>With 
    <a href="https://github.com/wbthomason/packer.nvim">packer.nvim</a>
  </summary>

  ```lua
  use({
    "DestopLine/boilersharp.nvim",
    config = function()
      require("boielrsharp").setup({
        -- Your options go here
      })
    end,
  })
  ```

</details>

<details>
  <summary>With 
    <a href="https://github.com/junegunn/vim-plug">vim-plug</a>
  </summary>

  ```vim
  Plug 'DestopLine/boilersharp.nvim'
  lua << EOF
  require("boilersharp.nvim").setup({
    -- Your options go here
  })
  EOF
  ```

</details>

## Default Configuration
```lua
---@type boilersharp.Config
{
  ---Information about the usings section of the boilerplate.
  ---This can be set to `false` to disable the section altogether.
  ---@type boilersharp.Config.Usings | false
  usings = {
    ---When to use assume that the project uses implicit usings.
    ---Set this to "auto" to get this from the C# version infered from
    ---the csproj file of the project.
    ---@type "never" | "always" | "auto"
    implicit_usings = "auto",

    ---Usings to automatically add to the file when needed.
    ---You could set this to { "System" } to only include the System
    ---namespace.
    ---@type string[]
    usings = {
      "System",
      "System.Collections.Generic",
      "System.IO",
      "System.Linq",
      "System.Net.Http",
      "System.Threading",
      "System.Threading.Tasks",
    },
  },

  ---Information about the namespace section of the boilerplate.
  ---This can be set to `false` to disable the section altogether.
  ---@type boilersharp.Config.Namespace | false
  namespace = {
    ---When to use file scoped namespace syntax.
    ---Set this to "auto" to get this from the C# version infered from
    ---the csproj file of the project.
    ---@type "never" | "always" | "auto"
    use_file_scoped = "auto",
  },

  ---Information about the type declaration section of the boilerplate.
  ---This can be set to `false` to disable the section altogether.
  ---@type boilersharp.Config.TypeDefinition
  type_definition = {
    ---Access modifier to use when writing boilerplate.
    ---@type boilersharp.AccessModifier
    default_access_modifier = "public",

    ---C# keyword to use when defining the type.
    ---@type boilersharp.CsharpType
    default_type = "class",

    ---Whether the plugin should use the `interface` keyword for the
    ---type declaration when the name of the type matches the C#
    ---interface naming convention, which would be equivalent to this
    ---regular expression: `^I[A-Z].*$`.
    ---@type boolean
    infer_interfaces = true,
  },

  ---Whether to add autocommands for writing boilerplate when you enter
  ---an empty C# file. Set this to `false` if you wanna be in control
  ---of when boilerplate gets written to the file through user commands
  ---or lua functions.
  ---@type boolean
  add_autocommand = true,

  ---What type of indentation to use for boilerplate generation. This is
  ---only ever used when not using file scoped namespace syntax and
  ---`type_definition` is enabled. Set this to "auto" to take this from
  ---the buffer's options. 
  ---
  ---It is recommended that you set up an "after/ftplugin/cs.lua" file
  ---in your nvim config with options for `expandtab` instead of
  ---changing this option from its default value.
  ---See `:h ftplugin` and `:h after-directory`.
  ---@type "tabs" | "spaces" | "auto"
  indent_type = "auto",
}
```
