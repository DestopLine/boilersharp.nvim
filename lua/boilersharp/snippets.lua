local ls = require("luasnip")
local s = ls.snippet
-- local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
-- local c = ls.choice_node
-- local d = ls.dynamic_node
-- local r = ls.restore_node
-- local l = require("luasnip.extras").lambda
-- local rep = require("luasnip.extras").rep
-- local p = require("luasnip.extras").partial
-- local m = require("luasnip.extras").match
-- local n = require("luasnip.extras").nonempty
-- local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
-- local fmta = require("luasnip.extras.fmt").fmta
-- local types = require("luasnip.util.types")
-- local conds = require("luasnip.extras.conditions")
-- local conds_expand = require("luasnip.extras.conditions.expand")
-- local conds_show = require("luasnip.extras.conditions.show")

local cs = require("boilersharp.csharp")
local cfg = require("boilersharp.config")

local M = {}

---@param data boilersharp.SnippetData
---@return table snippet
local function make_snippet(data)
  local template

  if data.file_scoped then
    template = [[
      {usings}namespace {namespace};

      {access} {kind} {name}
      {{
      {tab}{last}
      }}
    ]]
  else
    template = [[
      {usings}namespace {namespace}
      {{
      {tab}{access} {kind} {name}
      {tab}{{
      {tab}{tab}{last}
      {tab}}}
      }}
    ]]
  end

  local format_args = {
    usings = f(function()
      return vim.iter({cs.get_usings(true), ""}):flatten():totable()
    end),
    namespace = f(cs.get_namespace),
    access = i(1, data.access),
    kind = t(data.type_kind),
    name = f(cs.get_type_name),
    last = i(0),
    tab = t("\t")
  }

  local snippet = s(data.trigger, fmt(template, format_args), {
    show_condition = function(line_to_cursor)
      return line_to_cursor:match("^%w+$") -- Only show snippet when line is empty
    end,
  })

  return snippet
end

function M.add_snippets()
  local snippets = {}

  for group, triggers in pairs(cfg.opts.snippet_triggers) do
    if triggers then
      for kind, trigger in pairs(triggers) do
        if trigger then
          ---@type boilersharp.SnippetData
          local data = {
            trigger = trigger,
            access = cfg.opts.default_access,
            type_kind = kind,
            file_scoped = group == "file_scoped",
          }
          table.insert(snippets, make_snippet(data))
        end
      end
    end
  end

  ls.add_snippets("cs", snippets)
end

return M
