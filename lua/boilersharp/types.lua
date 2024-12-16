---@meta

---@alias boilersharp.CsharpType
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

---{ [path/to/directory]: Dir }
---@alias boilersharp.DirCache { [string]: boilersharp.DirData }

---@class boilersharp.DirData
---@field csproj string | nil Path to csproj file
---@field namespace string Namespace of the directory

---{ [path/to/project.csproj]: Csproj }
---@alias boilersharp.CsprojCache { [string]: boilersharp.CsprojData }

---@class boilersharp.CsprojData
---@field target_framework string Version of dotnet used 
---@field cs_version string Version of C# used
---@field implicit_usings boolean Whether or not the project uses implicit usings
---@field file_scoped_namespace boolean Whether or not the project supports file scoped namespaces
---@field root_namespace string | nil The root namespace of the csproj, if applicable
