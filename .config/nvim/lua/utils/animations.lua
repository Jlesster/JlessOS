-- lua/ui/animations.lua
-- Handles UI animations (lualine mode transitions, etc.)

local M = {}
local current_palette = nil
local current = nil

-- -------------------------
-- Helper functions (defined first so they're available to set_palette)
-- -------------------------

-- Helper function to get normal_fg from palette
local function get_normal_fg()
  if not current_palette then
    return "#000000" -- fallback
  end
  -- Use a dark color from the palette for text on colored backgrounds
  return current_palette.crust or current_palette.base or current_palette.mantle or "#11111b"
end

-- Helper function to get lualine mode suffix
local function get_mode_suffix(mode)
  if mode == "n" then
    return "normal"
  elseif mode:match("[vV]") or mode == "\22" then -- \22 is CTRL-V
    return "visual"
  elseif mode == "i" then
    return "insert"
  elseif mode == "R" then
    return "replace"
  elseif mode == "c" then
    return "command"
  else
    return "normal"
  end
end

-- Helper function to get color for current mode
local function get_mode_color(mode)
  if not current_palette then return nil end

  if mode == "n" then
    return current_palette.blue  -- From lualine_z_normal
  elseif mode:match("[vV]") or mode == "\22" then -- Visual modes
    return current_palette.mauve  -- From lualine_z_visual
  elseif mode == "i" then
    return current_palette.teal  -- From lualine_z_insert
  elseif mode == "R" then
    return current_palette.red  -- From lualine_z_replace
  elseif mode == "c" then
    return current_palette.peach  -- From lualine_z_command
  else
    return current_palette.blue
  end
end

-- Helper function to set lualine color immediately
local function set_lualine_color(color, mode_suffix)
  mode_suffix = mode_suffix or "normal"

  local fg = get_normal_fg()

  -- Set section A (mode indicator - left side)
  vim.api.nvim_set_hl(0, "lualine_a_" .. mode_suffix, {
    bg = color,
    fg = fg,
    bold = true,
  })

  -- Set section Z (location indicator - right side)
  vim.api.nvim_set_hl(0, "lualine_z_" .. mode_suffix, {
    bg = color,
    fg = fg,
    bold = true,
  })

  -- FORCE section Z to use mode color - override theme
  vim.schedule(function()
    vim.api.nvim_set_hl(0, "lualine_z_" .. mode_suffix, {
      bg = color,
      fg = fg,
      bold = true,
    })
  end)

  -- Get section B background (git section)
  local b_bg = "NONE"
  local b_hl = vim.api.nvim_get_hl(0, { name = "lualine_b_" .. mode_suffix, link = false })
  if b_hl.bg then
    b_bg = string.format("#%06x", b_hl.bg)
  end

  -- Get section Y background - use palette for dynamic updates
  local y_bg = current_palette and current_palette.surface0 or "#323244"

  -- Set separator from A to B (left side) - uses mode color as fg, B's bg as bg
  vim.api.nvim_set_hl(0, "lualine_transitional_lualine_a_" .. mode_suffix .. "_to_lualine_b_" .. mode_suffix, {
    fg = color,
    bg = b_bg,
  })

  -- Set separator from Y to Z (right side) - uses Y's bg as fg, mode color as bg
  vim.api.nvim_set_hl(0, "lualine_transitional_lualine_y_" .. mode_suffix .. "_to_lualine_z_" .. mode_suffix, {
    fg = y_bg,
    bg = color,
  })

  -- Also set the reverse separator (Z to Y) for completeness
  vim.api.nvim_set_hl(0, "lualine_transitional_lualine_z_" .. mode_suffix .. "_to_lualine_y_" .. mode_suffix, {
    fg = color,
    bg = y_bg,
  })

  pcall(require("lualine").refresh)
end

-- -------------------------
-- Color helpers
-- -------------------------
function M.set_palette(colors)
  current_palette = colors

  -- When palette updates, immediately refresh all mode colors
  vim.schedule(function()
    if not current_palette then return end

    -- Re-initialize all mode colors with new palette
    local modes = {
      { suffix = "normal", color = colors.blue },
      { suffix = "insert", color = colors.teal },
      { suffix = "visual", color = colors.mauve },
      { suffix = "replace", color = colors.red },
      { suffix = "command", color = colors.peach },
      { suffix = "terminal", color = colors.teal },
      { suffix = "inactive", color = colors.overlay0 },
    }

    for _, m in ipairs(modes) do
      if m.color then
        set_lualine_color(m.color, m.suffix)
      end
    end

    -- Update current mode
    local mode = vim.api.nvim_get_mode().mode
    local target = get_mode_color(mode)
    if target then
      current = target
    end
  end)
end

-- -------------------------
-- Mode animation
-- -------------------------

function M.animate_lualine_mode(opts)
  opts = opts or {}

  local steps = opts.steps or 15
  local delay = opts.delay or 16

  -- Initialize all mode colors helper function (defined INSIDE animate_lualine_mode)
  local function init_all_mode_colors()
    if not current_palette then return end

    local modes = {
      { suffix = "normal", color = current_palette.blue },
      { suffix = "insert", color = current_palette.teal },
      { suffix = "visual", color = current_palette.mauve },
      { suffix = "replace", color = current_palette.red },
      { suffix = "command", color = current_palette.peach },
      { suffix = "terminal", color = current_palette.teal },
      { suffix = "inactive", color = current_palette.overlay0 },
    }

    for _, m in ipairs(modes) do
      if m.color then
        set_lualine_color(m.color, m.suffix)
      end
    end
  end

  -- Reset on buffer enter AND set initial color
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("LualineModeAnimationReset", { clear = true }),
    callback = function()
      -- Small delay to ensure palette is loaded
      vim.defer_fn(function()
        init_all_mode_colors()

        local mode = vim.api.nvim_get_mode().mode
        local target = get_mode_color(mode)

        if target then
          current = target
        end
      end, 10)
    end,
  })

  vim.api.nvim_create_autocmd("ModeChanged", {
    group = vim.api.nvim_create_augroup("LualineModeAnimation", { clear = true }),
    callback = function()
      if not current_palette then return end

      local mode = vim.api.nvim_get_mode().mode
      local target = get_mode_color(mode)
      local mode_suffix = get_mode_suffix(mode)

      if not target then return end

      -- Initialize current if nil
      if current == nil then
        current = target
        set_lualine_color(target, mode_suffix)
        return
      end

      -- Don't animate if already at target
      if current == target then return end

      pcall(require("lualine").refresh)

      -- Store the start color
      local start = current

      -- Animate transition
      for i = 0, steps do
        vim.defer_fn(function()
          local t = i / steps
          local col = require("utils.material-transition").mix_hex(start, target, t)

          local fg = get_normal_fg()

          -- Animate ALL modes to keep them in sync
          local all_modes = { "normal", "insert", "visual", "replace", "command", "terminal", "inactive" }

          for _, m in ipairs(all_modes) do
            -- Set section A
            vim.api.nvim_set_hl(0, "lualine_a_" .. m, {
              bg = col,
              fg = fg,
              bold = true,
            })

            -- Set section Z
            vim.api.nvim_set_hl(0, "lualine_z_" .. m, {
              bg = col,
              fg = fg,
              bold = true,
            })

            -- Get section B background
            local b_bg = "NONE"
            local b_hl = vim.api.nvim_get_hl(0, { name = "lualine_b_" .. m, link = false })
            if b_hl.bg then
              b_bg = string.format("#%06x", b_hl.bg)
            end

            -- Set left separator (A to B)
            vim.api.nvim_set_hl(0, "lualine_transitional_lualine_a_" .. m .. "_to_lualine_b_" .. m, {
              fg = col,
              bg = b_bg,
            })

            -- Get section Y background - use palette directly for dynamic theming
            local y_bg = current_palette and current_palette.surface0 or "#323244"

            -- Set right separator (Y to Z) - uses Y's bg as fg, animated color as bg
            vim.api.nvim_set_hl(0, "lualine_transitional_lualine_y_" .. m .. "_to_lualine_z_" .. m, {
              fg = y_bg,
              bg = col,
            })

            -- Also set Z to Y separator for reverse transition
            vim.api.nvim_set_hl(0, "lualine_transitional_lualine_z_" .. m .. "_to_lualine_y_" .. m, {
              fg = col,
              bg = y_bg,
            })
          end

          -- Refresh on every step to see animation
          pcall(require("lualine").refresh)
        end, i * delay)
      end

      current = target
    end,
  })

  -- Set initial color immediately
  vim.defer_fn(function()
    init_all_mode_colors()

    local mode = vim.api.nvim_get_mode().mode
    local target = get_mode_color(mode)

    if target then
      current = target
    end
  end, 50)
end

return M
