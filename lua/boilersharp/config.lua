local M = {}

---@class boilersharp.Config
M.DEFAULT = {
  ---Whether or not snippets will be added.
  ---@type boolean
  add_snippets = true,

  ---Whether or not to automatically add boilerplate when you create
  ---a new C# file.
  ---Possible values
  ---  disable: Never add boilerplate automatically
  ---  on_new: Add boilerplate when entering a new (not yet written
  ---          to memory) C# file. Depending on how you create files,
  ---          this may not work. Plugins that create and save files
  ---          for you (like oil.nvim) don't work here.
  ---  on_empty: Add boilerplate when entering an empty C# file.
  ---            This works better with the aforementioned plugins.
  ---@type "disabled"|"on_new"|"on_empty"
  auto_mode = "disabled",

  ---Groups of triggers for each snippet, you can disable each group
  ---or each individual snippet by setting it to false.
  snippet_triggers = {
    ---@type boilersharp.SnippetOption|false
    file_scoped = {
      class = "classf",
      struct = "structf",
      interface = "interfacef",
      enum = "enumf",
      record = "recordf",
      ["record struct"] = "recstructf",
    },
    ---@type boilersharp.SnippetOption|false
    non_file_scoped = {
      class = "classnf",
      struct = "structnf",
      interface = "interfacenf",
      enum = "enumnf",
      record = "recordnf",
      ["record struct"] = "recstructnf",
    },
  },

  ---The default access modifier used.
  ---@type boilersharp.AccessModifier
  default_access = "public",

  ---The default kind of C# type to use when creating a file.
  ---This only applies to auto mode
  ---@type boilersharp.TypeKind
  default_kind = "class",

  ---Whether or not to add common usings at the top of the file.
  ---Possible values:
  ---  always: Usings are always generated.
  ---  never: Usings are never generated.
  ---  version: Usings are generated if your dotnet version is less than 6.0.
  ---           dotnet executable in PATH is needed for this to work
  ---  csproj: Usings are generated if your csproj contains
  ---          <ImplicitUsings>enable</ImplicitUsings>
  ---          This is the most accurate metric but may be unreliable.
  ---@type "always"|"never"|"version"|"csproj"
  add_usings = "version",

  ---Whether or not to use file scoped namespaces.
  ---Possible values:
  ---  always: File scoped namespaces are always used
  ---  never: File scoped namespaces are never used
  ---  version: File scoped namespaces are used if your dotnet version
  ---           is 6.0 or higher. dotnet executable in PATH is needed
  ---           for this to work.
  ---  csproj: File scoped namespaces are used if your csproj contains
  ---          a <LangVersion>...</LangVersion> tag that points to C# 10
  ---          or higher. For more information, read
  ---          https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/language-versioning
  ---          This is the most accurate metric but may be unreliable.
  ---@type "always"|"never"|"version"|"csproj"
  use_file_scoped_namespaces = "version",
}

M.opts = M.DEFAULT

return M
