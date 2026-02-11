
-- Auto-generated Neovim colorscheme
-- Vibrant LSP-semantic based theme with Material You + Catppuccin Mocha

vim.cmd("hi clear")
vim.cmd("syntax reset")

vim.o.termguicolors = true
vim.g.colors_name = "material_purple_mocha"

local colors = {
  -- Base colors
  base = "#1F1E2E",
  mantle = "#191825",
  crust = "#12111B",

  -- Surface colors
  surface0 = "#323244",
  surface1 = "#46475A",
  surface2 = "#595B70",

  -- Overlay colors
  overlay0 = "#6E7086",
  overlay1 = "#81839C",
  overlay2 = "#9598B2",

  -- Text colors
  text = "#D1D5F4",
  subtext1 = "#BEC1DE",
  subtext0 = "#AAACC8",

  -- Accent colors (VIBRANT)
  rosewater = "#FFD9FA",
  flamingo = "#EEC8FF",
  pink = "#BE9FD7",
  mauve = "#BA95ED",
  red = "#C383F1",
  maroon = "#D89CFF",
  peach = "#EB97C0",
  yellow = "#E0BFB9",
  green = "#00BDCC",
  teal = "#8BB5DB",
  sky = "#BFCEFF",
  sapphire = "#B0ABF5",
  blue = "#BBA2FC",
  lavender = "#CEB6FF",
}

local function hi(group, opts)
  local cmd = {"highlight", group}
  if opts.fg then table.insert(cmd, "guifg=" .. opts.fg) end
  if opts.bg then table.insert(cmd, "guibg=" .. opts.bg) end
  if opts.sp then table.insert(cmd, "guisp=" .. opts.sp) end
  if opts.style then table.insert(cmd, "gui=" .. opts.style) end
  if opts.link then
    vim.cmd(string.format("highlight! link %s %s", group, opts.link))
  else
    vim.cmd(table.concat(vim.tbl_flatten(cmd), " "))
  end
end

-- ============================================================================
-- BASE UI ELEMENTS
-- ============================================================================
local function setup_highlights()
    hi("Normal", { fg = colors.text, bg = "NONE" })
    hi("NormalFloat", { fg = colors.text, bg = colors.mantle })
    hi("FloatBorder", { fg = colors.lavender, bg = "NONE"})
    hi("FloatTitle", { fg = colors.mauve, bg = "NONE", style = "bold,italic" })
    hi("Folded", { fg = "NONE", bg = "NONE" })
    hi("FoldColumn", { fg = colors.red })
    hi("UfoFoldedBg", { fg = colors.lavender })
    hi("UfoFoldedFg", { fg = colors.lavender })

    hi("Cursor", { fg = "NONE", bg = colors.text })
    hi("CursorLine", { bg = "NONE" })
    hi("CursorColumn", { bg = "NONE" })
    hi("ColorColumn", { bg = "NONE" })
    hi("CursorLineNr", { fg = colors.lavender, style = "bold" })
    hi("LineNr", { fg = colors.overlay0 })
    hi("LineNrAbove", { fg = colors.mauve })
    hi("LineNrBelow", { fg = colors.mauve })
    hi("SignColumn", { bg = "NONE" })
    hi("EndOfBuffer", { fg = colors.lavender })
    hi("NonText", { fg = colors.lavender })

    hi("StatusLine", { fg = colors.text, bg = "NONE" })
    hi("StatusLineNC", { fg = colors.overlay0, bg = "NONE" })
    hi("VertSplit", { fg = colors.surface0, bg = "NONE" })
    hi("WinSeparator", { fg = colors.surface0, bg = "NONE" })

    hi("Search", { fg = colors.red, bg = colors.mantle })
    hi("IncSearch", { fg = "NONE", bg = colors.mantle })
    hi("CurSearch", { fg = "NONE", bg = colors.mantle })
    hi("Visual", { bg = colors.surface1 })
    hi("VisualNOS", { bg = colors.surface1 })

    hi("Pmenu", { fg = colors.text, bg = "NONE" })
    hi("PmenuSel", { fg = "NONE", bg = colors.surface1, style = "bold" })
    hi("PmenuSbar", { bg = "NONE"})
    hi("PmenuThumb", { bg = "NONE" })
    hi("PmenuBorder", { fg = colors.lavender, bg = "NONE" })

    -- Completion menu kind highlights (nvim-cmp)
    hi("CmpItemKindVariable", { fg = colors.text, bg = "NONE" })
    hi("CmpItemKindFunction", { fg = colors.blue, bg = "NONE" })
    hi("CmpItemKindMethod", { fg = colors.blue, bg = "NONE" })
    hi("CmpItemKindConstructor", { fg = colors.sapphire, bg = "NONE" })
    hi("CmpItemKindClass", { fg = colors.yellow, bg = "NONE" })
    hi("CmpItemKindInterface", { fg = colors.yellow, bg = "NONE" })
    hi("CmpItemKindStruct", { fg = colors.yellow, bg = "NONE" })
    hi("CmpItemKindEnum", { fg = colors.peach, bg = "NONE" })
    hi("CmpItemKindEnumMember", { fg = colors.teal, bg = "NONE" })
    hi("CmpItemKindModule", { fg = colors.sapphire, bg = "NONE" })
    hi("CmpItemKindProperty", { fg = colors.teal, bg = "NONE" })
    hi("CmpItemKindField", { fg = colors.teal, bg = "NONE" })
    hi("CmpItemKindTypeParameter", { fg = colors.flamingo, bg = "NONE" })
    hi("CmpItemKindConstant", { fg = colors.teal, bg = "NONE" })
    hi("CmpItemKindKeyword", { fg = colors.mauve, bg = "NONE" })
    hi("CmpItemKindSnippet", { fg = colors.pink, bg = "NONE" })
    hi("CmpItemKindText", { fg = colors.green, bg = "NONE" })
    hi("CmpItemKindFile", { fg = colors.blue, bg = "NONE" })
    hi("CmpItemKindFolder", { fg = colors.blue, bg = "NONE" })
    hi("CmpItemKindColor", { fg = colors.peach, bg = "NONE" })
    hi("CmpItemKindReference", { fg = colors.peach, bg = "NONE" })
    hi("CmpItemKindOperator", { fg = colors.sky, bg = "NONE" })
    hi("CmpItemKindUnit", { fg = colors.peach, bg = "NONE" })
    hi("CmpItemKindValue", { fg = colors.peach, bg = "NONE" })

    -- Completion item highlights
    hi("CmpItemAbbr", { fg = colors.text, bg = "NONE" })
    hi("CmpItemAbbrDeprecated", { fg = colors.overlay0, bg = "NONE", style = "strikethrough" })
    hi("CmpItemAbbrMatch", { fg = colors.blue, bg = "NONE", style = "bold" })
    hi("CmpItemAbbrMatchFuzzy", { fg = colors.blue, bg = "NONE" })
    hi("CmpItemMenu", { fg = colors.subtext0, bg = "NONE", style = "italic" })

    hi("TabLine", { fg = colors.subtext0, bg = colors.mantle })
    hi("TabLineFill", { bg = "NONE" })
    hi("TabLineSel", { fg = colors.mauve, bg = "NONE" })

    hi("SagaBorder", { fg = colors.lavender, bg = "NONE" })
    hi("SagaNormal", { fg = colors.text, bg = colors.mantle })
    hi("SagaTitle", { fg = colors.mauve, bg = "NONE", style = "bold" })
    hi("SagaFolder", { fg = colors.blue })
    hi("SagaCount", { fg = colors.peach, bg = colors.surface0 })
    hi("SagaBeacon", { bg = colors.red })
    hi("SagaCollapse", { fg = colors.overlay2 })
    hi("SagaExpand", { fg = colors.overlay2 })
    hi("SagaFinderFname", { fg = colors.text })
    hi("SagaDetail", { fg = colors.subtext0, style = "italic" })
    hi("SagaInCurrent", { fg = colors.yellow })
    hi("SagaOutCurrent", { fg = colors.blue })
    hi("SagaSelect", { fg = colors.mauve, style = "bold" })
    hi("SagaSep", { fg = colors.overlay0 })

    -- ============================================================================
    -- TREESITTER BASE SYNTAX (Fallbacks when LSP not available)
    -- ============================================================================
    hi("@variable", { fg = colors.text })
    hi("@variable.builtin", { fg = colors.red, style = "italic" })
    hi("@variable.parameter", { fg = colors.maroon, style = "italic" })
    hi("@variable.member", { fg = colors.teal })

    hi("@constant", { fg = colors.teal })
    hi("@constant.builtin", { fg = colors.red, style = "italic" })
    hi("@constant.macro", { fg = colors.sapphire })

    hi("@module", { fg = colors.sapphire, style = "italic" })
    hi("@label", { fg = colors.sapphire })

    hi("@string", { fg = colors.green })
    hi("@string.escape", { fg = colors.pink })
    hi("@string.regexp", { fg = colors.pink })
    hi("@character", { fg = colors.teal })
    hi("@character.special", { fg = colors.pink })

    hi("@number", { fg = colors.peach })
    hi("@number.float", { fg = colors.peach })
    hi("@boolean", { fg = colors.peach })

    hi("@function", { fg = colors.blue, style = "bold" })
    hi("@function.builtin", { fg = colors.blue, style = "italic" })
    hi("@function.macro", { fg = colors.mauve })
    hi("@function.method", { fg = colors.blue, style = "bold" })
    hi("@function.method.call", { fg = colors.blue })

    hi("@constructor", { fg = colors.sapphire })
    hi("@operator", { fg = "#00ffff" })
    hi("@operator.java", { fg = "#00ffff" })

    hi("@keyword", { fg = colors.mauve, style = "bold" })
    hi("@keyword.repeat.java", { fg = colors.mauve, style = "italic,bold"})
    hi("@keyword.conditional", { fg = colors.mauve, style = "bold,italic" })
    hi("@keyword.function", { fg = colors.mauve, style = "bold" })
    hi("@keyword.operator", { fg = colors.mauve })
    hi("@keyword.return", { fg = colors.mauve, style = "bold" })

    hi("@type", { fg = colors.yellow })
    hi("@type.builtin", { fg = colors.yellow, style = "italic" })
    hi("@type.qualifier", { fg = colors.mauve, style = "italic" })

    hi("@property", { fg = colors.teal })
    hi("@attribute", { fg = colors.yellow, style = "italic" })
    hi("@namespace", { fg = colors.sapphire, style = "italic" })

    hi("@punctuation.delimiter", { fg = colors.overlay2 })
    hi("@punctuation.bracket", { fg = colors.overlay2 })
    hi("@punctuation.special", { fg = colors.sky })

    hi("@comment", { fg = colors.pink, style = "italic" })
    hi("@comment.todo", { fg = colors.yellow, bg = "NONE", style = "bold" })
    hi("@comment.note", { fg = colors.blue, bg = colors.surface0, style = "bold" })
    hi("@comment.warning", { fg = colors.peach, bg = colors.surface0, style = "bold" })
    hi("@comment.error", { fg = colors.red, bg = colors.surface0, style = "bold" })

    hi("@tag", { fg = colors.mauve })
    hi("@tag.attribute", { fg = colors.teal, style = "italic" })
    hi("@tag.delimiter", { fg = colors.overlay2 })

    -- ============================================================================
    -- LSP SEMANTIC TOKENS (Primary highlighting - overrides Treesitter)
    -- ============================================================================

    -- Variables and Parameters
    hi("@lsp.type.variable", { fg = colors.text })
    hi("@lsp.type.parameter", { fg = colors.red, style = "italic" })
    hi("@lsp.typemod.variable.readonly", { fg = colors.teal })
    hi("@lsp.typemod.variable.declaration", { fg = colors.maroon, style = "italic" })
    hi("@lsp.typemod.variable.static", { fg = colors.flamingo })
    hi("@lsp.typemod.variable.global", { fg = colors.flamingo })

    -- Properties and Fields
    hi("@lsp.type.property", { fg = colors.text })
    hi("@lsp.typemod.property.static", { fg = colors.teal, style = "italic" })
    hi("@lsp.typemod.property.static.java", { fg = colors.teal, style = "italic,bold" })

    -- Functions and Methods
    hi("@lsp.type.function", { fg = colors.blue, style = "bold" })
    hi("@lsp.type.method.java", { fg = colors.sky, style = "italic" })
    hi("@lsp.type.method", { fg = colors.sapphire, style = "bold" })
    hi("@lsp.typemod.function.static", { fg = colors.sky, style = "bold" })
    hi("@lsp.typemod.method.static", { fg = colors.sapphire, style = "italic" })

    -- Types and Classes
    hi("@lsp.type.class", { fg = colors.yellow, style = "bold" })
    hi("@lsp.type.interface", { fg = colors.yellow, style = "italic" })
    hi("@lsp.type.struct", { fg = colors.yellow })
    hi("@lsp.type.enum", { fg = colors.peach })
    hi("@lsp.type.enumMember", { fg = colors.teal })
    hi("@lsp.type.type", { fg = colors.yellow })
    hi("@lsp.type.typeParameter", { fg = colors.flamingo, style = "italic" })

    -- Namespaces and Modules
    hi("@lsp.type.namespace", { fg = colors.sapphire, style = "italic" })
    hi("@lsp.type.namespace.java", { fg = colors.sapphire, style = "italic" })
    hi("@lsp.mod.importDeclaration", { fg = colors.yellow, style = "italic" })
    hi("@lsp.mod.importDeclaration.java", { fg = colors.yellow, style = "italic" })
    hi("@lsp.typemod.namespace.importDeclaration.java", { fg = colors.yellow, style = "italic" })

    -- Macros and Preprocessor
    hi("@lsp.type.macro", { fg = colors.sapphire })
    hi("@lsp.typemod.macro.globalScope", { fg = colors.sapphire })
    hi("@lsp.typemod.macro.globalScope.cpp", { fg = colors.sapphire })

    -- Decorators and Annotations
    hi("@lsp.type.decorator", { fg = colors.yellow, style = "italic" })
    hi("@lsp.type.annotation", { fg = colors.yellow, style = "italic" })

    -- Keywords (when LSP provides them)
    hi("@lsp.type.keyword", { fg = colors.mauve, style = "bold" })
    hi("@lsp.typemod.keyword.controlFlow", { fg = colors.pink, style = "bold" })

    -- ============================================================================
    -- DIAGNOSTIC
    -- ============================================================================
    hi("DiagnosticError", { fg = colors.red })
    hi("DiagnosticWarn", { fg = colors.yellow })
    hi("DiagnosticInfo", { fg = colors.blue })
    hi("DiagnosticHint", { fg = colors.teal })
    hi("DiagnosticOk", { fg = colors.green })

    hi("DiagnosticVirtualTextError", { fg = colors.red, bg = "NONE" })
    hi("DiagnosticVirtualTextWarn", { fg = colors.yellow, bg = "NONE" })
    hi("DiagnosticVirtualTextInfo", { fg = colors.blue, bg = "NONE" })
    hi("DiagnosticVirtualTextHint", { fg = colors.teal, bg = "NONE" })

    hi("DiagnosticUnderlineError", { sp = colors.red, style = "undercurl" })
    hi("DiagnosticUnderlineWarn", { sp = colors.yellow, style = "undercurl" })
    hi("DiagnosticUnderlineInfo", { sp = colors.blue, style = "undercurl" })
    hi("DiagnosticUnderlineHint", { sp = colors.teal, style = "undercurl" })

    -- ============================================================================
    -- LSP REFERENCES
    -- ============================================================================
    hi("LspReferenceText", { bg = colors.mantle })
    hi("LspReferenceRead", { bg = colors.mantle })
    hi("LspReferenceWrite", { bg = colors.surface0, style = "bold" })

    hi("MatchParen", { bg = colors.mantle })
    hi("MatchParenCur", { bg = colors.mantle })

    -- ============================================================================
    -- PLUGIN: TELESCOPE
    -- ============================================================================
    hi("TelescopeBorder", { fg = colors.lavender, bg = "NONE" })
    hi("TelescopePromptBorder", { fg = colors.mauve, bg = "NONE"})
    hi("TelescopeResultsBorder", { fg = colors.lavender, bg = "NONE" })
    hi("TelescopePreviewBorder", { fg = colors.lavender, bg = "NONE" })
    hi("TelescopeSelection", { fg = colors.surface0, bg = colors.mauve, style = "bold" })
    hi("TelescopeSelectionCaret", { fg = colors.mauve, bg = colors.surface0 })
    hi("TelescopeMatching", { fg = colors.blue })

    -- ============================================================================
    -- PLUGIN: NVIM-TREE / NEO-TREE
    -- ============================================================================
    hi("NvimTreeNormal", { fg = colors.text, bg = "NONE" })
    hi("NvimTreeFolderIcon", { fg = colors.mauve })
    hi("NvimTreeFolderName", { fg = colors.sapphire })
    hi("NvimTreeOpenedFolderName", { fg = colors.blue, bold = true })
    hi("NvimTreeIndentMarker", { fg = colors.overlay0 })
    hi("NvimTreeGitDirty", { fg = colors.yellow })
    hi("NvimTreeGitNew", { fg = colors.green })
    hi("NvimTreeGitDeleted", { fg = colors.red })

    hi("NeoTreeTabActive", { fg = colors.mauve, bg = "NONE" })
    hi("NeoTreeGitUntracked", { fg = colors.red })
    hi("NeoTreeTabInactive", { fg = colors.overlay0, bg = "NONE" })
    hi("NeoTreeTabSeparatorActive", { fg = colors.surface0, bg = "NONE" })
    hi("NeoTreeTabSeparatorInactive", { fg = colors.surface0, bg = "NONE" })
    hi("NeoTreeDirectoryIcon", { fg = colors.mauve })
    hi("NeoTreeDirectoryName", { fg = colors.sky })
    hi("NeoTreeCursorLine", { fg = colors.red })

    hi("DressingInput", { fg = colors.text, bg = colors.mantle })
    hi("DressingInputBorder", { fg = colors.lavender, bg = "NONE" })
    hi("DressingInputTitle", { fg = colors.mauve, bg = "NONE", style = "bold" })
    hi("DressingInputPrompt", { fg = colors.text, bg = "NONE" })  -- This is the key one!
    hi("DressingInputText", { fg = colors.text, bg = "NONE" })
    hi("Prompt", { fg = colors.text, bg = "NONE" })
    hi("Question", { fg = colors.text, bg = "NONE" })

    -- ============================================================================
    -- PLUGIN: INDENT-BLANKLINE
    -- ============================================================================
    hi("IblIndent", { fg = colors.overlay0 })
    hi("IblScope", { fg = colors.overlay0 })

    -- ============================================================================
    -- PLUGIN: WHICH-KEY
    -- ============================================================================
    hi("WhichKey", { fg = colors.mauve, bg = "NONE" })
    hi("WhichKeyGroup", { fg = colors.blue })
    hi("WhichKeyBorder", { fg = colors.red, bg = "NONE" })
    hi("WhichKeyDesc", { fg = colors.text })
    hi("WhichKeySeparator", { fg = colors.mauve })
    hi("WhichKeyFloat", { bg = "NONE" })
    hi("WhichKeyTitle", { bg = "NONE" })

    -- ============================================================================
    -- PLUGIN: NOTIFY
    -- ============================================================================
    hi("NotifyBackground", { bg = colors.base })
    hi("NotifyERRORBorder", { fg = colors.red })
    hi("NotifyWARNBorder", { fg = colors.yellow })
    hi("NotifyINFOBorder", { fg = colors.blue })
    hi("NotifyDEBUGBorder", { fg = colors.overlay0 })
    hi("NotifyTRACEBorder", { fg = colors.teal })
    hi("NotifyERRORIcon", { fg = colors.red })
    hi("NotifyWARNIcon", { fg = colors.yellow })
    hi("NotifyINFOIcon", { fg = colors.blue })
    hi("NotifyDEBUGIcon", { fg = colors.overlay0 })
    hi("NotifyTRACEIcon", { fg = colors.teal })
    hi("NotifyERRORTitle", { fg = colors.red })
    hi("NotifyWARNTitle", { fg = colors.yellow })
    hi("NotifyINFOTitle", { fg = colors.blue })
    hi("NotifyDEBUGTitle", { fg = colors.overlay0 })
    hi("NotifyTRACETitle", { fg = colors.teal })

    -- ============================================================================
    -- PLUGIN: RAINBOW DELIMITERS
    -- ============================================================================
    hi("RainbowDelimiterRed",    { fg = "#CD88FF" })
    hi("RainbowDelimiterOrange", { fg = "#F88FC5" })
    hi("RainbowDelimiterYellow", { fg = "#E6BDB6" })
    hi("RainbowDelimiterGreen",  { fg = "#00BDCC" })
    hi("RainbowDelimiterCyan",   { fg = "#78B7EB" })
    hi("RainbowDelimiterBlue",   { fg = "#BCA2FF" })
    hi("RainbowDelimiterViolet", { fg = "#BE90FF" })

    -- ============================================================================
    -- PLUGIN: RENDER-MARKDOWN
    -- ============================================================================
    hi("RenderMarkdownCode", { bg = "NONE" })

    -- ============================================================================
    -- PLUGIN: BUFFERLINE / BARBAR
    -- ============================================================================
    hi("BufferLineFill", { bg = "NONE" })
    hi("BufferLineBackground", { fg = colors.overlay0, bg = "NONE" })
    hi("BufferLineBuffer", { fg = colors.overlay0, bg = "NONE" })
    hi("BufferLineBufferVisible", { fg = colors.text, bg = "NONE" })
    hi("BufferLineBufferSelected", { fg = colors.mauve, bg = "NONE", style = "bold" })
    hi("BufferLineTab", { fg = colors.overlay0, bg = "NONE" })
    hi("BufferLineTabSelected", { fg = colors.mauve, bg = "NONE", style = "bold" })
    hi("BufferLineSeparator", { fg = colors.surface0, bg = "NONE" })
    hi("BufferLineSeparatorVisible", { fg = colors.surface0, bg = "NONE" })
    hi("BufferLineSeparatorSelected", { fg = colors.surface0, bg = "NONE" })

    -- Barbar plugin
    hi("BufferCurrent", { fg = colors.text, bg = "NONE", style = "bold" })
    hi("BufferCurrentIndex", { fg = colors.mauve, bg = "NONE" })
    hi("BufferCurrentMod", { fg = colors.yellow, bg = "NONE" })
    hi("BufferCurrentSign", { fg = colors.mauve, bg = "NONE" })
    hi("BufferCurrentTarget", { fg = colors.red, bg = "NONE" })
    hi("BufferVisible", { fg = colors.text, bg = "NONE" })
    hi("BufferVisibleIndex", { fg = colors.overlay0, bg = "NONE" })
    hi("BufferVisibleMod", { fg = colors.yellow, bg = "NONE" })
    hi("BufferVisibleSign", { fg = colors.overlay0, bg = "NONE" })
    hi("BufferVisibleTarget", { fg = colors.red, bg = "NONE" })
    hi("BufferInactive", { fg = colors.overlay0, bg = "NONE" })
    hi("BufferInactiveIndex", { fg = colors.overlay0, bg = "NONE" })
    hi("BufferInactiveMod", { fg = colors.lavender, bg = "NONE" })
    hi("BufferInactiveSign", { fg = colors.overlay0, bg = "NONE" })
    hi("BufferInactiveTarget", { fg = colors.red, bg = "NONE" })
    hi("BufferTabpages", { fg = colors.mauve, bg = "NONE", style = "bold" })
    hi("BufferTabpageFill", { bg = "NONE" })

    -- Overseer (task runner) - often appears in bufferline
    hi("OverseerTask", { fg = colors.blue, bg = "NONE" })
    hi("OverseerTaskBorder", { fg = colors.blue, bg = "NONE" })
    hi("OverseerRunning", { fg = colors.yellow, bg = "NONE" })
    hi("OverseerSuccess", { fg = colors.green, bg = "NONE" })
    hi("OverseerCanceled", { fg = colors.overlay0, bg = "NONE" })
    hi("OverseerFailure", { fg = colors.red, bg = "NONE" })
    hi("OverseerBorder", { fg = colors.lavender, bg = "NONE" })
    hi("OverseerNormal", { fg = colors.text, bg = colors.surface0 })

    -- Additional top bar highlights (in case it's something else)
    hi("WinBar", { fg = "NONE", bg = "NONE" })
    hi("SatelliteBar", { fg = "NONE", bg = "NONE" })
    hi("SatelliteCursor", { fg = "NONE", bg = "NONE" })
    hi("NeoTreeTitleBar", { fg = colors.mantle, bg = colors.teal })
    hi("NeoTreeDimmedText", { fg = colors.red })
    hi("NeoTreeMessage", { fg = colors.subtext0 })
    hi("NeoTreeFloatNormal", { fg = colors.red })
    hi("NeoTreeFloatBorder", { fg = colors.teal })
    hi("NeoTreeFloatTitle", { fg = colors.red })
    hi("NvimScrollbarHandle", { fg = "NONE", bg = "NONE" })
    hi("NvimScrollbarCursor", { fg = "NONE", bg = "NONE" })
    hi("NvimScrollbarError", { fg = "NONE", bg = "NONE" })
    hi("NvimScrollbarWarn", { fg = "NONE", bg = "NONE" })
    hi("NvimScrollbarInfo", { fg = "NONE", bg = "NONE" })
    hi("NvimScrollbarHint", {fg = "NONE", bg = "NONE" })
    hi("NeoTreeScrollbar", { fg = "NONE", bg = "NONE" })
    hi("NeoTreeScrollbarThumb", { fg = "NONE", bg = "NONE" })
    hi("WinScrollbar", { fg = "NONE", bg = "NONE" })
    hi("WinScrollbarThumb", { fg = "NONE", bg = "NONE" })
    hi("WinBarNC", { fg = "NONE", bg = "NONE" })
    hi("Title", { fg = colors.blue, bg = "NONE" })
    hi("BufferLineDevIconLua", { bg = "NONE" })
    hi("BufferLineDevIconDefault", { bg = "NONE" })


    -- ============================================================================
    -- TEXT
    -- ============================================================================
    hi("Comment", { fg = colors.pink })
    hi("Constant", { fg = colors.teal })
    -- ============================================================================
    -- PLUGIN: ALPHA (Dashboard)
    -- ============================================================================
    hi("DashboardHeader", { fg = colors.sapphire })
    hi("DashboardFooter", { fg = colors.mauve })
    hi("AlphaShortcut", { fg = colors.red })
    hi("AlphaIconNew", { fg = colors.blue })
    hi("AlphaIconRecent", { fg = colors.pink })
    hi("AlphaIconYazi", { fg = colors.peach })
    hi("AlphaIconSessions", { fg = colors.green })
    hi("AlphaIconProjects", { fg = colors.mauve })
    hi("AlphaIconQuit", { fg = colors.red })


    hi("DiffAdd", { fg = colors.green, bg = "NONE" })
    hi("DiffChange", { fg = colors.blue, bg = "NONE" })
    hi("DiffDelete", { fg = colors.red, bg = "NONE" })
    hi("DiffText", { fg = colors.yellow, bg = "NONE", style = "bold" })

    -- Git signs in the gutter
    hi("GitSignsAdd", { fg = colors.green, bg = "NONE" })
    hi("GitSignsChange", { fg = colors.blue, bg = "NONE" })
    hi("GitSignsDelete", { fg = colors.red, bg = "NONE" })

    -- For syntax highlighting of color hex codes in your editor
    -- This will make the bright red/green hex codes themselves appear in purple tones
    hi("@string.special", { fg = colors.green })  -- For color strings like "#FF0000"
    hi("@number.css", { fg = colors.peach })

-- ============================================================================
-- PLUGIN: LUALINE
-- ============================================================================
    -- Normal mode
    hi("lualine_a_normal", { fg = colors.base, bg = colors.blue, style = "bold" })
    hi("lualine_b_normal", { fg = colors.text, bg = colors.surface0 })
    hi("lualine_c_normal", { fg = colors.subtext0, bg = "NONE" })
    hi("lualine_x_normal", { fg = colors.subtext0, bg = "NONE" })
    hi("lualine_y_normal", { fg = colors.text, bg = colors.surface0 })
    hi("lualine_z_normal", { fg = colors.base, bg = colors.blue })

    -- Insert mode
    hi("lualine_a_insert", { fg = colors.base, bg = colors.teal, style = "bold" })
    hi("lualine_b_insert", { fg = colors.text, bg = colors.surface0 })
    hi("lualine_c_insert", { fg = colors.subtext0, bg = "NONE" })
    hi("lualine_x_insert", { fg = colors.subtext0, bg = "NONE" })
    hi("lualine_y_insert", { fg = colors.text, bg = colors.surface0 })
    hi("lualine_z_insert", { fg = colors.base, bg = colors.teal })

    -- Visual mode
    hi("lualine_a_visual", { fg = colors.base, bg = colors.mauve, style = "bold" })
    hi("lualine_b_visual", { fg = colors.text, bg = colors.surface0 })
    hi("lualine_c_visual", { fg = colors.subtext0, bg = "NONE" })
    hi("lualine_x_visual", { fg = colors.subtext0, bg = "NONE" })
    hi("lualine_y_visual", { fg = colors.text, bg = colors.surface0 })
    hi("lualine_z_visual", { fg = colors.base, bg = colors.mauve })

    -- Replace mode
    hi("lualine_a_replace", { fg = colors.base, bg = colors.red, style = "bold" })
    hi("lualine_b_replace", { fg = colors.text, bg = colors.surface0 })
    hi("lualine_c_replace", { fg = colors.subtext0, bg = "NONE" })
    hi("lualine_x_replace", { fg = colors.subtext0, bg = "NONE" })
    hi("lualine_y_replace", { fg = colors.text, bg = colors.surface0 })
    hi("lualine_z_replace", { fg = colors.base, bg = colors.red })

    -- Command mode
    hi("lualine_a_command", { fg = colors.base, bg = colors.peach, style = "bold" })
    hi("lualine_b_command", { fg = colors.text, bg = colors.surface0 })
    hi("lualine_c_command", { fg = colors.subtext0, bg = "NONE" })
    hi("lualine_x_command", { fg = colors.subtext0, bg = "NONE" })
    hi("lualine_y_command", { fg = colors.text, bg = colors.surface0 })
    hi("lualine_z_command", { fg = colors.base, bg = colors.peach })

    -- Inactive
    hi("lualine_a_inactive", { fg = colors.overlay0, bg = "NONE" })
    hi("lualine_b_inactive", { fg = colors.overlay0, bg = "NONE" })
    hi("lualine_c_inactive", { fg = colors.overlay0, bg = "NONE" })

    -- Additional lualine components
    --hi("lualine_transitional_lualine_a_normal_to_lualine_b_normal", { fg = colors.blue, bg = colors.surface0 })
    --hi("lualine_transitional_lualine_a_insert_to_lualine_b_insert", { fg = colors.teal, bg = colors.surface0 })
    --hi("lualine_transitional_lualine_a_visual_to_lualine_b_visual", { fg = colors.mauve, bg = colors.surface0 })
    --hi("lualine_transitional_lualine_a_replace_to_lualine_b_replace", { fg = colors.red, bg = colors.surface0 })
    --hi("lualine_transitional_lualine_a_command_to_lualine_b_command", { fg = colors.peach, bg = colors.surface0 })

-- ============================================================================
-- TRANSPARENCY REASSERTION (CRITICAL)
-- ============================================================================
    local transparent_groups = {
      -- Core editor / windows
      "Normal",
      "NormalFloat",
      "FloatBorder",
      "SignColumn",
      "EndOfBuffer",
      "VertSplit",
      "WinSeparator",
      "WinBar",
      "WinBarNC",
      "Title",

      -- Cursor / columns (IMPORTANT)
      "CursorLine",
      "CursorColumn",
      "ColorColumn",

      -- Status / tabline
      "StatusLine",
      "StatusLineNC",
      "TabLine",
      "TabLineFill",
      "TabLineSel",

      -- Popup / completion
      "Pmenu",
      "PmenuSbar",
      "PmenuThumb",
      "PmenuBorder",
      "TelescopePromptBorder",
      "TelescopeResultsBorder",
      "TelescopePreviewBorder",


      -- Completion item kinds (nvim-cmp)
      "CmpItemKindVariable",
      "CmpItemKindFunction",
      "CmpItemKindMethod",
      "CmpItemKindConstructor",
      "CmpItemKindClass",
      "CmpItemKindInterface",
      "CmpItemKindStruct",
      "CmpItemKindEnum",
      "CmpItemKindEnumMember",
      "CmpItemKindModule",
      "CmpItemKindProperty",
      "CmpItemKindField",
      "CmpItemKindTypeParameter",
      "CmpItemKindConstant",
      "CmpItemKindKeyword",
      "CmpItemKindSnippet",
      "CmpItemKindText",
      "CmpItemKindFile",
      "CmpItemKindFolder",
      "CmpItemKindColor",
      "CmpItemKindReference",
      "CmpItemKindOperator",
      "CmpItemKindUnit",
      "CmpItemKindValue",

      -- Completion text
      "CmpItemAbbr",
      "CmpItemAbbrDeprecated",
      "CmpItemAbbrMatch",
      "CmpItemAbbrMatchFuzzy",
      "CmpItemMenu",

      -- Which-key
      "WhichKey",
      "WhichKeyFloat",
      "WhichKeyTile",

      -- Neo-tree
      "NeoTreeTabActive",
      "NeoTreeTabInactive",
      "NeoTreeTabSeparatorActive",
      "NeoTreeTabSeparatorInactive",

      -- Render / markdown
      "RenderMarkdownCode",

      -- Bufferline / Barbar
      "BufferLineFill",
      "BufferLineBackground",
      "BufferLineBuffer",
      "BufferLineBufferVisible",
      "BufferLineBufferSelected",
      "BufferLineTab",
      "BufferLineTabSelected",
      "BufferLineSeparator",
      "BufferLineSeparatorVisible",
      "BufferLineSeparatorSelected",

      "BufferCurrent",
      "BufferCurrentIndex",
      "BufferCurrentMod",
      "BufferCurrentSign",
      "BufferCurrentTarget",

      "BufferVisible",
      "BufferVisibleIndex",
      "BufferVisibleMod",
      "BufferVisibleSign",
      "BufferVisibleTarget",

      "BufferInactive",
      "BufferInactiveIndex",
      "BufferInactiveMod",
      "BufferInactiveSign",
      "BufferInactiveTarget",

      "BufferTabpages",
      "BufferTabpageFill",

      -- Devicons
      "BufferLineDevIconLua",
      "BufferLineDevIconDefault",

      -- Overseer
      "OverseerTask",
      "OverseerTaskBorder",
      "OverseerRunning",
      "OverseerSuccess",
      "OverseerCanceled",
      "OverseerFailure",
      "OverseerBorder",
        }

    for _, group in ipairs(transparent_groups) do
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group })
        if ok then
            hl.bg = "NONE"
            hl.ctermbg = nil
            vim.api.nvim_set_hl(0, group, hl)
        end
    end
end

setup_highlights()
