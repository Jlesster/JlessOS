-- lua/ui/dynamic-colors.lua
-- ZERO-FLASH dynamic theme loader with FIXED file watcher

local M = {}
local transition = require("utils.material-transition")
local subscribers = {}

function M.subscribe(fn)
  table.insert(subscribers,fn)
end

local theme_file = vim.fn.stdpath("config")
  .. "/colors/material_purple_mocha.lua"

local is_transitioning = false
local fs_event = nil
local debounce_timer = nil

-- Cursorline indent highlighting
local cursorline_ns = vim.api.nvim_create_namespace("cursorline_indent")

-- Filetypes to exclude from cursorline indent highlighting
local excluded_filetypes = {
  "alpha",
  "dashboard",
  "neo-tree",
  "aerial",
  "NvimTree",
  "help",
  "Trouble",
  "lazy",
  "mason",
  "notify",
  "toggleterm",
  "lazyterm",
  "starter",
}

-- Transparency invariants
local transparent_groups = {
  "Normal", "NormalFloat", "FloatBorder", "SignColumn", "EndOfBuffer",
  "VertSplit", "WinSeparator", "WinBar", "WinBarNC", "Title",
  "CursorLine", "CursorColumn", "ColorColumn", "StatusLine", "StatusLineNC",
  "TabLine", "TabLineFill", "TabLineSel", "Pmenu", "PmenuSbar", "PmenuThumb",
  "PmenuBorder", "TelescopePromptBorder", "TelescopeResultsBorder",
  "TelescopePreviewBorder", "CmpItemKindVariable", "CmpItemKindFunction",
  "CmpItemKindMethod", "CmpItemKindConstructor", "CmpItemKindClass",
  "CmpItemKindInterface", "CmpItemKindStruct", "CmpItemKindEnum",
  "CmpItemKindEnumMember", "CmpItemKindModule", "CmpItemKindProperty",
  "CmpItemKindField", "CmpItemKindTypeParameter", "CmpItemKindConstant",
  "CmpItemKindKeyword", "CmpItemKindSnippet", "CmpItemKindText",
  "CmpItemKindFile", "CmpItemKindFolder", "CmpItemKindColor",
  "CmpItemKindReference", "CmpItemKindOperator", "CmpItemKindUnit",
  "CmpItemKindValue", "CmpItemAbbr", "CmpItemAbbrDeprecated",
  "CmpItemAbbrMatch", "CmpItemAbbrMatchFuzzy", "CmpItemMenu",
  "WhichKey", "WhichKeyFloat", "WhichKeyTitle", "NeoTreeTabActive",
  "NeoTreeTabInactive", "NeoTreeTabSeparatorActive", "NeoTreeTabSeparatorInactive",
  "RenderMarkdownCode", "BufferLineFill", "BufferLineBackground",
  "BufferLineBuffer", "BufferLineBufferVisible", "BufferLineBufferSelected",
  "BufferLineTab", "BufferLineTabSelected", "BufferLineSeparator",
  "BufferLineSeparatorVisible", "BufferLineSeparatorSelected",
  "BufferCurrent", "BufferCurrentIndex", "BufferCurrentMod",
  "BufferCurrentSign", "BufferCurrentTarget", "BufferVisible",
  "BufferVisibleIndex", "BufferVisibleMod", "BufferVisibleSign",
  "BufferVisibleTarget", "BufferInactive", "BufferInactiveIndex",
  "BufferInactiveMod", "BufferInactiveSign", "BufferInactiveTarget",
  "BufferTabpages", "BufferTabpageFill", "BufferLineDevIconLua",
  "BufferLineDevIconDefault", "OverseerTask", "OverseerTaskBorder",
  "OverseerRunning", "OverseerSuccess", "OverseerCanceled", "OverseerFailure",
}

local function enforce_transparency()
  for _, g in ipairs(transparent_groups) do
    pcall(function()
      local hl = vim.api.nvim_get_hl(0, { name = g })
      hl.bg = "NONE"
      hl.ctermbg = nil
      vim.api.nvim_set_hl(0, g, hl)
    end)
  end
end

-- Check if current buffer should be excluded
local function should_exclude_buffer()
  local ft = vim.bo.filetype
  for _, excluded_ft in ipairs(excluded_filetypes) do
    if ft == excluded_ft then
      return true
    end
  end
  return false
end

-- Add this function after your enforce_transparency function
local function reload_heirline_colors(colors)
  -- Check if heirline is available
  local ok, heirline = pcall(require, "heirline")
  if not ok then
    return
  end

  local ok2, heirline_components = pcall(require, "heirline-components.all")
  if not ok2 then
    return
  end

  -- Get base colors from heirline-components
  local hl_colors = heirline_components.hl.get_colors()

  -- Override buffer colors with your theme colors
  hl_colors.buffer_fg = colors.overlay0 or "#706F86"  -- Inactive tab text
  hl_colors.buffer_bg = "NONE"                         -- Inactive tab background
  hl_colors.buffer_visible_fg = colors.text or "#D1D5F4"  -- Visible but not active
  hl_colors.buffer_active_fg = colors.mauve or "#F493B5"  -- Active tab text
  hl_colors.tabline_bg = "NONE"                        -- Background of entire tabline

  -- Reload heirline with new colors
  heirline.load_colors(hl_colors)

  -- Force heirline to redraw
  vim.schedule(function()
    vim.cmd("redrawstatus!")
    vim.cmd("redrawtabline")
  end)
end

-- Parse theme file as DATA (IMPROVED)
local function load_theme()
  local f = io.open(theme_file, "r")
  if not f then
    vim.notify("Dynamic colors: theme file not found at " .. theme_file, vim.log.levels.WARN)
    return
  end
  local lines = {}
  for l in f:lines() do table.insert(lines, l) end
  f:close()

  local colors, highlights = {}, {}

  for _, l in ipairs(lines) do
    -- Parse color definitions
    local k, v = l:match("^%s*([%w_]+)%s*=%s*\"(#[%x]+)\"")
    if k and v then colors[k] = v end

    -- Parse highlight definitions
    local g, body = l:match('hi%("([^"]+)",%s*{(.-)}')
    if g then
      local spec = {}

      -- Handle fg - can be colors.xxx or literal hex
      local fg_color = body:match("fg%s*=%s*colors%.([%w_]+)")
      local fg_literal = body:match('fg%s*=%s*"(#[%x]+)"')
      if fg_color then
        spec.fg = fg_color
      elseif fg_literal then
        spec.fg_literal = fg_literal
      end

      -- Handle bg - can be colors.xxx or literal hex or "NONE"
      local bg_color = body:match("bg%s*=%s*colors%.([%w_]+)")
      local bg_literal = body:match('bg%s*=%s*"(#[%x]+)"')
      local bg_none = body:match('bg%s*=%s*"NONE"')
      if bg_color then
        spec.bg = bg_color
      elseif bg_literal then
        spec.bg_literal = bg_literal
      elseif bg_none then
        spec.bg_literal = "NONE"
      end

      spec.style = body:match('style%s*=%s*"([^"]+)"')
      highlights[g] = spec
    end
  end

  return colors, highlights
end

local function apply_highlights(colors, highlights)
  for group, spec in pairs(highlights) do
    local hl = {}

    -- Handle foreground
    if spec.fg then
      hl.fg = colors[spec.fg]
    elseif spec.fg_literal then
      hl.fg = spec.fg_literal
    end

    -- Handle background
    if spec.bg then
      hl.bg = colors[spec.bg]
    elseif spec.bg_literal then
      hl.bg = spec.bg_literal
    end

    -- Handle style
    if spec.style then
      for f in spec.style:gmatch("[^,]+") do
        hl[vim.trim(f)] = true
      end
    end

    vim.api.nvim_set_hl(0, group, hl)
  end
  -- notify subscribers (animations, etc.)
  for _, fn in ipairs(subscribers) do
    pcall(fn, colors)
  end

  -- reload_lualine_colors(colors)
  reload_heirline_colors(colors)
end

-- Reload (NO :colorscheme)
function M.reload()
  if is_transitioning then return end
  is_transitioning = true

  local colors, highlights = load_theme()
  if not colors then
    is_transitioning = false
    return
  end

  local from = {}
  for _, g in ipairs({ "Normal", "StatusLine", "TabLine" }) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = g })
    if ok and hl.bg then
      from[g] = { bg = string.format("#%06X", hl.bg) }
    end
  end

  apply_highlights(colors, highlights)
  enforce_transparency()

  local to = {}
  for g, _ in pairs(from) do
    local spec = highlights[g]
    if spec then
      if spec.bg then
        to[g] = { bg = colors[spec.bg] }
      elseif spec.bg_literal then
        to[g] = { bg = spec.bg_literal }
      end
    end
  end

  is_transitioning = false
end

function M.setup()
  -- FIX: Watch the THEME FILE (Lua), not the SCSS file
  -- The theme file is what actually changes and contains the colors
  local watch_file = theme_file

  local f = io.open(watch_file, "r")
  local animations = require("utils.animations")

  if not f then
    vim.notify("Dynamic colors: Theme file not found at " .. watch_file, vim.log.levels.WARN)
    return
  end
  f:close()

  M.subscribe(function(colors)
    animations.set_palette(colors)
  end)

  -- Clear highlights when leaving buffer
  vim.api.nvim_create_autocmd("BufLeave", {
    callback = function()
      pcall(function()
        vim.api.nvim_buf_clear_namespace(0, cursorline_ns, 0, -1)
      end)
    end,
  })

  -- Initial load with delay to ensure plugins are ready
  vim.defer_fn(function()
    M.reload()
  end, 100)

  -- File watcher using vim.loop (compatible with older Neovim)
  local uv = vim.loop or vim.uv

  -- Clean up existing watchers
  if fs_event then
    pcall(fs_event.stop, fs_event)
  end
  if debounce_timer then
    pcall(debounce_timer.stop, debounce_timer)
  end

  fs_event = uv.new_fs_event()
  debounce_timer = uv.new_timer()

  local ok, err = pcall(function()
    -- FIX: Watch the theme file (Lua) instead of SCSS
    uv.fs_event_start(fs_event, watch_file, {}, function(err, filename, events)
      if err then
        vim.schedule(function()
          vim.notify("File watcher error: " .. tostring(err), vim.log.levels.ERROR)
        end)
        return
      end

      -- Debounce the reload
      debounce_timer:stop()
      debounce_timer:start(200, 0, vim.schedule_wrap(function()
        vim.notify("Theme changed - reloading colors", vim.log.levels.INFO)
        M.reload()
      end))
    end)
  end)

  if not ok then
    vim.notify("Dynamic colors: Failed to start file watcher - " .. tostring(err), vim.log.levels.ERROR)
  else
    vim.notify("Dynamic colors loaded", vim.log.levels.INFO)
  end

  -- Add autocmd to reapply on Neo-tree open
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "neo-tree",
    callback = function()
      vim.defer_fn(enforce_transparency, 50)
    end,
  })
end

return M
