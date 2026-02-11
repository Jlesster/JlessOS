
-- lua/material-transition.lua
-- Pure highlight interpolation (NO colorscheme calls)

local M = {}

local function clamp01(x)
  return math.max(0, math.min(1, x))
end

local function ease_perceptual(t)
  t = clamp01(t) ^ 1.6
  return t * (2 - t)
end

local function hex_to_rgb(hex)
  if type(hex) ~= "string" then return end
  hex = hex:gsub("#", "")
  if #hex ~= 6 then return end
  return
    tonumber(hex:sub(1, 2), 16),
    tonumber(hex:sub(3, 4), 16),
    tonumber(hex:sub(5, 6), 16)
end

local function rgb_to_hex(r, g, b)
  return string.format("#%02X%02X%02X", r, g, b)
end

function M.mix_hex(a, b, t)
  local ar, ag, ab = hex_to_rgb(a)
  local br, bg, bb = hex_to_rgb(b)
  if not ar or not br then return b end
  return rgb_to_hex(
    ar + (br - ar) * t,
    ag + (bg - ag) * t,
    ab + (bb - ab) * t
  )
end

function M.run(from, to, opts)
  opts = opts or {}
  local steps = opts.steps or 18
  local delay = opts.delay or 12
  local on_done = opts.on_done

  for i = 1, steps do
    vim.defer_fn(function()
      local t = ease_perceptual(i / steps)

      for group, a in pairs(from) do
        local b = to[group]
        if b then
          local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
          if ok and not hl.link then
            vim.api.nvim_set_hl(0, group, {
              bg = mix_hex(a.bg, b.bg, t),
              fg = a.fg and b.fg and mix_hex(a.fg, b.fg, t) or nil,
            })
          end
        end
      end

      if i == steps and on_done then on_done() end
    end, i * delay)
  end
end

return M

