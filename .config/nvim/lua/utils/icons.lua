local M = {}

M.icons = {
  -- Which-key
  Debugger = "",
  Run = "",
  Find = "",
  Session = "󰶮",
  Sort = "󱎊",
  Buffer = "",
  Terminal = "",
  UI = "",
  Test = "󰤑",
  Packages = "",
  Docs = "",
  Git = "",
  LSP = "󱇯",

  -- Heirline-components - tabline
  BufferClose = "󰅖",
  FileModified = "",
  FileReadOnly = "",
  ArrowLeft = "",
  ArrowRight = "",
  TabClose = "󰅚",

  -- Heirline-components - winbar
  CompilerPlay = "",
  CompilerStop = "",
  CompilerRedo = "",
  NeoTree = "",
  Aerial = "" ,
  ZenMode = "󰰶",
  BufWrite = "",
  BufWriteAll = "",
  Ellipsis = "…",
  BreadcrumbSeparator = "",

  -- Heirline-components - statuscolumn
  FoldClosed = "",
  FoldOpened = "",
  FoldSeparator = " ",

  -- Heirline-components - statusline
  ActiveLSP = "󱇯",
  ActiveTS = "",
  Environment = "",
  DiagnosticError = "",
  DiagnosticHint = "󰌵",
  DiagnosticInfo = "󰋼",
  DiagnosticWarn = "",
  LSPLoading1 = "",
  LSPLoading2 = "󰀚",
  LSPLoading3 = "",
  SearchCount = "",
  MacroRecording = "",
  ToggleResults = "󰑮",

  -- Heirline-components - misc
  Paste = "󰅌",
  PathSeparator = "",

  -- Neotree
  FolderClosed = "",
  FolderEmpty = "",
  FolderOpen = "󰉍",
  Diagnostic = "󰒡",
  DefaultFile = "󰈙",

  -- Git
  GitBranch = "",
  GitAdd = "",
  GitChange = "",
  GitDelete = "",
  GitConflict = "",
  GitIgnored = "◌",
  GitRenamed = "➜",
  GitSign = "▎",
  GitStaged = "",
  GitUnstaged = "",
  GitUntracked = "",

  --AI
  AI = "",

  --Java
  Java = "",

  -- DAP
  DapBreakpoint = "",
  DapBreakpointCondition = "",
  DapBreakpointRejected = "",
  DapLogPoint = ".>",
  DapStopped = "󰁕",

  -- Telescope
  PromptPrefix = "❯",

  -- Nvim-lightbulb
  Lightbulb = "",

  -- Alpha
  GreeterNew = "󰈙",
  GreeterRecent = "󰮳",
  GreeterYazi = "󰪶",
  GreeterSessions = "󰮗",
  GreeterProjects = "",
  GreeterPlug = "",

  -- Mason
  MasonInstalled = "✓",
  MasonUninstalled = "✗",
  MasonPending = "⟳",

  -- Render-markdown
  RenderMarkdown = { ' ', ' ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' }
}

function M.get_icon(name, with_space)
  local icon = M.icons[name] or ""
  if with_space and icon ~= "" then
    return icon .. " "
  end
  return icon
end

return M
