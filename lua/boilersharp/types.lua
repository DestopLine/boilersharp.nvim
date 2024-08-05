---@meta

---@class boilersharp.Opts
---@field add_snippets boolean? Whether or not to add snippets
---@field auto_mode ("disabled"|"on_new"|"on_empty")? Whether or not to add boilerplate on new file creation
---@field snippet_triggers boilersharp.SnippetSpec? The type name and its trigger
---@field default_access boilersharp.AccessModifier? The default access modifier to use
---@field default_kind boilersharp.TypeKind? What type kind to use on new file creation
---@field add_usings ("never"|"always"|"version"|"csproj")? When to add implicit usings
---@field use_file_scoped_namespaces ("never"|"always"|"version"|"csproj")? When to use file scoped namespaces

---@class boilersharp.SnippetSpec
---@field file_scoped (boilersharp.SnippetOption|false)?
---@field non_file_scoped (boilersharp.SnippetOption|false)?

---@alias boilersharp.SnippetOption { [boilersharp.TypeKind]: string|false }

---@alias boilersharp.TypeKind
---| "class"
---| "struct"
---| "interface"
---| "enum"
---| "record"
---| "record struct"

---@alias boilersharp.AccessModifier
---| "public"
---| "protected"
---| "private"
---| "internal"
---| "protected internal"
---| "private protected"
---| "file"

---@class boilersharp.SnippetData
---@field trigger string String that triggers the snippet
---@field access boilersharp.AccessModifier Default access modifier
---@field type_kind boilersharp.TypeKind Kind of the C# type ("class", "interface", etc)
---@field file_scoped boolean Whether or not the snippet uses a file scoped namespace

---{ [path/to/directory]: Dir }
---@alias boilersharp.DirCache { [string]: boilersharp.DirData }

---@class boilersharp.DirData
---@field csproj string? Path to csproj file
---@field namespace string Namespace of the directory

---{ [path/to/project.csproj]: Csproj }
---@alias boilersharp.CsprojCache { [string]: boilersharp.CsprojData }

---@class boilersharp.CsprojData
---@field target_framework string Version of dotnet used 
---@field cs_version string Version of C# used
---@field implicit_usings boolean Whether or not the project uses implicit usings
---@field file_scoped_namespace boolean Whether or not the project supports file scoped namespaces
---@field root_namespace string? The root namespace of the csproj, if applicable
