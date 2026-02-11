#!/usr/bin/env python3
"""
Neovim Theme Generator - Refactored Version
All background transparency handled through transparent_groups at the end
"""

import os
import json
from pathlib import Path
from materialyoucolor.hct import Hct
from materialyoucolor.utils.color_utils import rgba_from_argb, argb_from_rgb


# Embedded Catppuccin Mocha palette as fallback
CATPPUCCIN_MOCHA = {
    "rosewater": "#f5e0dc",
    "flamingo": "#f2cdcd",
    "pink": "#f5c2e7",
    "mauve": "#cba6f7",
    "red": "#f38ba8",
    "maroon": "#eba0ac",
    "peach": "#fab387",
    "yellow": "#f9e2af",
    "green": "#a6e3a1",
    "teal": "#94e2d5",
    "sky": "#89dceb",
    "sapphire": "#74c7ec",
    "blue": "#89b4fa",
    "lavender": "#b4befe",
    "text": "#cdd6f4",
    "subtext1": "#bac2de",
    "subtext0": "#a6adc8",
    "overlay2": "#9399b2",
    "overlay1": "#7f849c",
    "overlay0": "#6c7086",
    "surface2": "#585b70",
    "surface1": "#45475a",
    "surface0": "#313244",
    "base": "#1e1e2e",
    "mantle": "#181825",
    "crust": "#11111b"
}


def load_catppuccin_palette(path: str = None) -> dict:
    """
    Load Catppuccin color palette from JSON file or use embedded palette

    Args:
        path: Optional path to Colors.json file

    Returns:
        Dict of Catppuccin colors
    """
    if path and os.path.exists(path):
        try:
            with open(path, "r") as f:
                return json.load(f)
        except Exception as e:
            print(f"Warning: Could not load Catppuccin palette from {path}: {e}")
            print("Using embedded Catppuccin Mocha palette")
            return CATPPUCCIN_MOCHA
    else:
        return CATPPUCCIN_MOCHA


def hex_to_argb(hex_code: str) -> int:
    """Convert hex color to ARGB integer"""
    return argb_from_rgb(
        int(hex_code[1:3], 16), int(hex_code[3:5], 16), int(hex_code[5:], 16)
    )


def argb_to_hex(argb: int) -> str:
    """Convert ARGB integer to hex color"""
    rgba = rgba_from_argb(argb)
    return "#{:02X}{:02X}{:02X}".format(*map(round, rgba))


def harmonize_hex(
    hex_color: str, accent_argb: int, harmony_amt: float, threshold: float
) -> str:
    """
    Harmonize a hex color toward accent color
    Preserves Catppuccin tone & chroma, only nudges hue toward accent
    """
    from materialyoucolor.utils.math_utils import (
        sanitize_degrees_double,
        difference_degrees,
        rotation_direction,
    )

    base_argb = hex_to_argb(hex_color)
    from_hct = Hct.from_int(base_argb)
    to_hct = Hct.from_int(accent_argb)

    difference_degrees_ = difference_degrees(from_hct.hue, to_hct.hue)
    rotation_degrees = min(difference_degrees_ * harmony_amt, threshold)
    output_hue = sanitize_degrees_double(
        from_hct.hue + rotation_degrees * rotation_direction(from_hct.hue, to_hct.hue)
    )

    out_argb = Hct.from_hct(output_hue, from_hct.chroma, from_hct.tone).to_int()
    return argb_to_hex(out_argb)


def clamp_chroma(argb: int, max_chroma: float) -> int:
    """Limit the chroma of a color"""
    hct = Hct.from_int(argb)
    return Hct.from_hct(hct.hue, min(hct.chroma, max_chroma), hct.tone).to_int()


def force_tone(argb: int, tone: float) -> int:
    """Force a specific tone value"""
    hct = Hct.from_int(argb)
    return Hct.from_hct(hct.hue, hct.chroma, tone).to_int()


def lift_tone(argb: int, delta: float) -> int:
    """
    Increase brightness ONLY.
    Preserves hue and chroma.
    """
    hct = Hct.from_int(argb)
    return Hct.from_hct(hct.hue, hct.chroma, min(hct.tone + delta, 100)).to_int()


def generate_neovim_theme(
    material_colors: dict,
    term_colors: dict,
    transparent: bool = False,
    catppuccin_path: str = None,
    debug: bool = False,
) -> dict:
    """
    Generate Neovim colorscheme harmonized with Material You

    Args:
        material_colors: Dict of Material You colors
        term_colors: Dict of terminal colors
        transparent: Whether to use transparent background
        catppuccin_path: Optional path to Catppuccin colors JSON file
        debug: Enable debug output

    Returns:
        Dict of Neovim color scheme
    """
    neovim_colors = {}

    # Load Catppuccin palette (embedded or from file)
    cat = load_catppuccin_palette(catppuccin_path)
    accent_argb = hex_to_argb(material_colors["primary_paletteKeyColor"])

    # Harmonization parameters - INCREASED for more vibrant, purple-harmonized colors
    BG_HARMONY = 0.88
    UI_HARMONY = 0.15
    SYNTAX_HARMONY = 0.85
    TEXT_HARMONY = 0.46

    BG_THRESH = 5.0
    UI_THRESH = 10.0
    SYNTAX_THRESH = 60.0
    TEXT_THRESH = 8.0

    # Background / surfaces (keep Mocha depth)
    neovim_colors["base"] = (
        "NONE"
        if transparent
        else harmonize_hex(cat["base"], accent_argb, BG_HARMONY, BG_THRESH)
    )

    for k in [
        "mantle",
        "crust",
        "surface0",
        "surface1",
        "surface2",
        "overlay0",
        "overlay1",
        "overlay2",
    ]:
        neovim_colors[k] = harmonize_hex(cat[k], accent_argb, UI_HARMONY, UI_THRESH)

    # Text
    for k in ["text", "subtext0", "subtext1"]:
        neovim_colors[k] = harmonize_hex(cat[k], accent_argb, TEXT_HARMONY, TEXT_THRESH)

    # Syntax accents - VIBRANT, highly saturated
    syntax_colors = {
        "rosewater": (SYNTAX_HARMONY, SYNTAX_THRESH, 90),
        "flamingo": (SYNTAX_HARMONY, SYNTAX_THRESH, 90),
        "pink": (SYNTAX_HARMONY, SYNTAX_THRESH, 92),
        "mauve": (SYNTAX_HARMONY, SYNTAX_THRESH, 95),
        "red": (SYNTAX_HARMONY, SYNTAX_THRESH, 90),
        "maroon": (SYNTAX_HARMONY, SYNTAX_THRESH, 88),
        "peach": (SYNTAX_HARMONY, SYNTAX_THRESH, 90),
        "yellow": (SYNTAX_HARMONY, SYNTAX_THRESH, 92),
        "green": (SYNTAX_HARMONY, SYNTAX_THRESH, 95),
        "teal": (SYNTAX_HARMONY, SYNTAX_THRESH, 95),
        "sky": (SYNTAX_HARMONY, SYNTAX_THRESH, 95),
        "sapphire": (SYNTAX_HARMONY, SYNTAX_THRESH, 95),
        "blue": (SYNTAX_HARMONY, SYNTAX_THRESH, 95),
        "lavender": (SYNTAX_HARMONY, SYNTAX_THRESH, 95),
    }

    for k, (harmony, thresh, target_chroma) in syntax_colors.items():
        raw = harmonize_hex(cat[k], accent_argb, harmony, thresh)
        raw_argb = hex_to_argb(raw)
        raw_hct = Hct.from_int(raw_argb)
        neovim_colors[k] = argb_to_hex(
            Hct.from_hct(raw_hct.hue, target_chroma, raw_hct.tone).to_int()
        )

    # Force specific tones for better contrast and vibrancy
    TONE_MAP = {
        "mauve": 68,
        "blue": 72,
        "green": 70,
        "teal": 72,
        "yellow": 80,
        "pink": 70,
        "sapphire": 73,
        "red": 65,
        "peach": 72,
    }

    for k, tone in TONE_MAP.items():
        neovim_colors[k] = argb_to_hex(force_tone(hex_to_argb(neovim_colors[k]), tone))

    return neovim_colors


def write_neovim_colorscheme(
    neovim_colors: dict, output_path: str = None, debug: bool = False
):
    """
    Write Neovim colorscheme Lua file

    Args:
        neovim_colors: Dict of color definitions
        output_path: Optional custom output path
        debug: Enable debug output
    """
    if output_path is None:
        nvim_colors_dir = Path.home() / ".config" / "nvim" / "colors"
        nvim_colors_dir.mkdir(parents=True, exist_ok=True)
        output_path = str(nvim_colors_dir / "material_purple_mocha.lua")

    # Generate rainbow delimiter colors
    def boost_for_rainbow(argb: int, chroma_boost=1.4, min_tone=70) -> str:
        hct = Hct.from_int(argb)
        return argb_to_hex(
            Hct.from_hct(
                hct.hue, min(hct.chroma * chroma_boost, 90), max(hct.tone, min_tone)
            ).to_int()
        )

    rainbow_colors = {
        "red": boost_for_rainbow(hex_to_argb(neovim_colors["red"]), 1.3, 68),
        "orange": boost_for_rainbow(hex_to_argb(neovim_colors["peach"]), 1.25, 72),
        "yellow": boost_for_rainbow(hex_to_argb(neovim_colors["yellow"]), 1.25, 75),
        "green": boost_for_rainbow(hex_to_argb(neovim_colors["green"]), 1.3, 70),
        "cyan": boost_for_rainbow(hex_to_argb(neovim_colors["teal"]), 1.3, 70),
        "blue": boost_for_rainbow(hex_to_argb(neovim_colors["blue"]), 1.3, 72),
        "violet": boost_for_rainbow(hex_to_argb(neovim_colors["mauve"]), 1.4, 68),
        "purple": boost_for_rainbow(hex_to_argb(neovim_colors["mauve"]), 1.4, 68),
        "pink": boost_for_rainbow(hex_to_argb(neovim_colors["pink"]), 1.3, 70),
    }

    nvim_theme_content = f'''
-- Auto-generated Neovim colorscheme
-- Vibrant LSP-semantic based theme with Material You + Catppuccin Mocha

vim.cmd("hi clear")
vim.cmd("syntax reset")

vim.o.termguicolors = true
vim.g.colors_name = "material_purple_mocha"

local colors = {{
  -- Base colors
  base = "{neovim_colors['base']}",
  mantle = "{neovim_colors['mantle']}",
  crust = "{neovim_colors['crust']}",

  -- Surface colors
  surface0 = "{neovim_colors['surface0']}",
  surface1 = "{neovim_colors['surface1']}",
  surface2 = "{neovim_colors['surface2']}",

  -- Overlay colors
  overlay0 = "{neovim_colors['overlay0']}",
  overlay1 = "{neovim_colors['overlay1']}",
  overlay2 = "{neovim_colors['overlay2']}",

  -- Text colors
  text = "{neovim_colors['text']}",
  subtext1 = "{neovim_colors['subtext1']}",
  subtext0 = "{neovim_colors['subtext0']}",

  -- Accent colors (VIBRANT)
  rosewater = "{neovim_colors['rosewater']}",
  flamingo = "{neovim_colors['flamingo']}",
  pink = "{neovim_colors['pink']}",
  mauve = "{neovim_colors['mauve']}",
  red = "{neovim_colors['red']}",
  maroon = "{neovim_colors['maroon']}",
  peach = "{neovim_colors['peach']}",
  yellow = "{neovim_colors['yellow']}",
  green = "{neovim_colors['green']}",
  teal = "{neovim_colors['teal']}",
  sky = "{neovim_colors['sky']}",
  sapphire = "{neovim_colors['sapphire']}",
  blue = "{neovim_colors['blue']}",
  lavender = "{neovim_colors['lavender']}",
}}

local function hi(group, opts)
  local cmd = {{"highlight", group}}
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
    hi("Normal", {{ fg = colors.text, bg = "NONE" }})
    hi("NormalFloat", {{ fg = colors.text, bg = colors.mantle }})
    hi("FloatBorder", {{ fg = colors.lavender, bg = "NONE"}})
    hi("FloatTitle", {{ fg = colors.mauve, bg = "NONE", style = "bold,italic" }})
    hi("Folded", {{ fg = "NONE", bg = "NONE" }})
    hi("FoldColumn", {{ fg = colors.red }})
    hi("UfoFoldedBg", {{ fg = colors.lavender }})
    hi("UfoFoldedFg", {{ fg = colors.lavender }})

    hi("Cursor", {{ fg = "NONE", bg = colors.text }})
    hi("CursorLine", {{ bg = "NONE" }})
    hi("CursorColumn", {{ bg = "NONE" }})
    hi("ColorColumn", {{ bg = "NONE" }})
    hi("CursorLineNr", {{ fg = colors.lavender, style = "bold" }})
    hi("LineNr", {{ fg = colors.overlay0 }})
    hi("LineNrAbove", {{ fg = colors.mauve }})
    hi("LineNrBelow", {{ fg = colors.mauve }})
    hi("SignColumn", {{ bg = "NONE" }})
    hi("EndOfBuffer", {{ fg = colors.lavender }})
    hi("NonText", {{ fg = colors.lavender }})

    hi("StatusLine", {{ fg = colors.text, bg = "NONE" }})
    hi("StatusLineNC", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("VertSplit", {{ fg = colors.surface0, bg = "NONE" }})
    hi("WinSeparator", {{ fg = colors.surface0, bg = "NONE" }})

    hi("Search", {{ fg = colors.red, bg = colors.mantle }})
    hi("IncSearch", {{ fg = "NONE", bg = colors.mantle }})
    hi("CurSearch", {{ fg = "NONE", bg = colors.mantle }})
    hi("Visual", {{ bg = colors.surface1 }})
    hi("VisualNOS", {{ bg = colors.surface1 }})

    hi("Pmenu", {{ fg = colors.text, bg = "NONE" }})
    hi("PmenuSel", {{ fg = "NONE", bg = colors.surface1, style = "bold" }})
    hi("PmenuSbar", {{ bg = "NONE"}})
    hi("PmenuThumb", {{ bg = "NONE" }})
    hi("PmenuBorder", {{ fg = colors.lavender, bg = "NONE" }})

    -- Completion menu kind highlights (nvim-cmp)
    hi("CmpItemKindVariable", {{ fg = colors.text, bg = "NONE" }})
    hi("CmpItemKindFunction", {{ fg = colors.blue, bg = "NONE" }})
    hi("CmpItemKindMethod", {{ fg = colors.blue, bg = "NONE" }})
    hi("CmpItemKindConstructor", {{ fg = colors.sapphire, bg = "NONE" }})
    hi("CmpItemKindClass", {{ fg = colors.yellow, bg = "NONE" }})
    hi("CmpItemKindInterface", {{ fg = colors.yellow, bg = "NONE" }})
    hi("CmpItemKindStruct", {{ fg = colors.yellow, bg = "NONE" }})
    hi("CmpItemKindEnum", {{ fg = colors.peach, bg = "NONE" }})
    hi("CmpItemKindEnumMember", {{ fg = colors.teal, bg = "NONE" }})
    hi("CmpItemKindModule", {{ fg = colors.sapphire, bg = "NONE" }})
    hi("CmpItemKindProperty", {{ fg = colors.teal, bg = "NONE" }})
    hi("CmpItemKindField", {{ fg = colors.teal, bg = "NONE" }})
    hi("CmpItemKindTypeParameter", {{ fg = colors.flamingo, bg = "NONE" }})
    hi("CmpItemKindConstant", {{ fg = colors.teal, bg = "NONE" }})
    hi("CmpItemKindKeyword", {{ fg = colors.mauve, bg = "NONE" }})
    hi("CmpItemKindSnippet", {{ fg = colors.pink, bg = "NONE" }})
    hi("CmpItemKindText", {{ fg = colors.green, bg = "NONE" }})
    hi("CmpItemKindFile", {{ fg = colors.blue, bg = "NONE" }})
    hi("CmpItemKindFolder", {{ fg = colors.blue, bg = "NONE" }})
    hi("CmpItemKindColor", {{ fg = colors.peach, bg = "NONE" }})
    hi("CmpItemKindReference", {{ fg = colors.peach, bg = "NONE" }})
    hi("CmpItemKindOperator", {{ fg = colors.sky, bg = "NONE" }})
    hi("CmpItemKindUnit", {{ fg = colors.peach, bg = "NONE" }})
    hi("CmpItemKindValue", {{ fg = colors.peach, bg = "NONE" }})

    -- Completion item highlights
    hi("CmpItemAbbr", {{ fg = colors.text, bg = "NONE" }})
    hi("CmpItemAbbrDeprecated", {{ fg = colors.overlay0, bg = "NONE", style = "strikethrough" }})
    hi("CmpItemAbbrMatch", {{ fg = colors.blue, bg = "NONE", style = "bold" }})
    hi("CmpItemAbbrMatchFuzzy", {{ fg = colors.blue, bg = "NONE" }})
    hi("CmpItemMenu", {{ fg = colors.subtext0, bg = "NONE", style = "italic" }})

    hi("TabLine", {{ fg = colors.subtext0, bg = colors.mantle }})
    hi("TabLineFill", {{ bg = "NONE" }})
    hi("TabLineSel", {{ fg = colors.mauve, bg = "NONE" }})

    hi("SagaBorder", {{ fg = colors.lavender, bg = "NONE" }})
    hi("SagaNormal", {{ fg = colors.text, bg = colors.mantle }})
    hi("SagaTitle", {{ fg = colors.mauve, bg = "NONE", style = "bold" }})
    hi("SagaFolder", {{ fg = colors.blue }})
    hi("SagaCount", {{ fg = colors.peach, bg = colors.surface0 }})
    hi("SagaBeacon", {{ bg = colors.red }})
    hi("SagaCollapse", {{ fg = colors.overlay2 }})
    hi("SagaExpand", {{ fg = colors.overlay2 }})
    hi("SagaFinderFname", {{ fg = colors.text }})
    hi("SagaDetail", {{ fg = colors.subtext0, style = "italic" }})
    hi("SagaInCurrent", {{ fg = colors.yellow }})
    hi("SagaOutCurrent", {{ fg = colors.blue }})
    hi("SagaSelect", {{ fg = colors.mauve, style = "bold" }})
    hi("SagaSep", {{ fg = colors.overlay0 }})

    -- ============================================================================
    -- TREESITTER BASE SYNTAX (Fallbacks when LSP not available)
    -- ============================================================================
    hi("@variable", {{ fg = colors.text }})
    hi("@variable.builtin", {{ fg = colors.red, style = "italic" }})
    hi("@variable.parameter", {{ fg = colors.maroon, style = "italic" }})
    hi("@variable.member", {{ fg = colors.teal }})

    hi("@constant", {{ fg = colors.teal }})
    hi("@constant.builtin", {{ fg = colors.red, style = "italic" }})
    hi("@constant.macro", {{ fg = colors.sapphire }})

    hi("@module", {{ fg = colors.sapphire, style = "italic" }})
    hi("@label", {{ fg = colors.sapphire }})

    hi("@string", {{ fg = colors.green }})
    hi("@string.escape", {{ fg = colors.pink }})
    hi("@string.regexp", {{ fg = colors.pink }})
    hi("@character", {{ fg = colors.teal }})
    hi("@character.special", {{ fg = colors.pink }})

    hi("@number", {{ fg = colors.peach }})
    hi("@number.float", {{ fg = colors.peach }})
    hi("@boolean", {{ fg = colors.peach }})

    hi("@function", {{ fg = colors.blue, style = "bold" }})
    hi("@function.builtin", {{ fg = colors.blue, style = "italic" }})
    hi("@function.macro", {{ fg = colors.mauve }})
    hi("@function.method", {{ fg = colors.blue, style = "bold" }})
    hi("@function.method.call", {{ fg = colors.blue }})

    hi("@constructor", {{ fg = colors.sapphire }})
    hi("@operator", {{ fg = "#00ffff" }})
    hi("@operator.java", {{ fg = "#00ffff" }})

    hi("@keyword", {{ fg = colors.mauve, style = "bold" }})
    hi("@keyword.repeat.java", {{ fg = colors.mauve, style = "italic,bold"}})
    hi("@keyword.conditional", {{ fg = colors.mauve, style = "bold,italic" }})
    hi("@keyword.function", {{ fg = colors.mauve, style = "bold" }})
    hi("@keyword.operator", {{ fg = colors.mauve }})
    hi("@keyword.return", {{ fg = colors.mauve, style = "bold" }})

    hi("@type", {{ fg = colors.yellow }})
    hi("@type.builtin", {{ fg = colors.yellow, style = "italic" }})
    hi("@type.qualifier", {{ fg = colors.mauve, style = "italic" }})

    hi("@property", {{ fg = colors.teal }})
    hi("@attribute", {{ fg = colors.yellow, style = "italic" }})
    hi("@namespace", {{ fg = colors.sapphire, style = "italic" }})

    hi("@punctuation.delimiter", {{ fg = colors.overlay2 }})
    hi("@punctuation.bracket", {{ fg = colors.overlay2 }})
    hi("@punctuation.special", {{ fg = colors.sky }})

    hi("@comment", {{ fg = colors.pink, style = "italic" }})
    hi("@comment.todo", {{ fg = colors.yellow, bg = "NONE", style = "bold" }})
    hi("@comment.note", {{ fg = colors.blue, bg = colors.surface0, style = "bold" }})
    hi("@comment.warning", {{ fg = colors.peach, bg = colors.surface0, style = "bold" }})
    hi("@comment.error", {{ fg = colors.red, bg = colors.surface0, style = "bold" }})

    hi("@tag", {{ fg = colors.mauve }})
    hi("@tag.attribute", {{ fg = colors.teal, style = "italic" }})
    hi("@tag.delimiter", {{ fg = colors.overlay2 }})

    -- ============================================================================
    -- LSP SEMANTIC TOKENS (Primary highlighting - overrides Treesitter)
    -- ============================================================================

    -- Variables and Parameters
    hi("@lsp.type.variable", {{ fg = colors.text }})
    hi("@lsp.type.parameter", {{ fg = colors.red, style = "italic" }})
    hi("@lsp.typemod.variable.readonly", {{ fg = colors.teal }})
    hi("@lsp.typemod.variable.declaration", {{ fg = colors.maroon, style = "italic" }})
    hi("@lsp.typemod.variable.static", {{ fg = colors.flamingo }})
    hi("@lsp.typemod.variable.global", {{ fg = colors.flamingo }})

    -- Properties and Fields
    hi("@lsp.type.property", {{ fg = colors.text }})
    hi("@lsp.typemod.property.static", {{ fg = colors.teal, style = "italic" }})
    hi("@lsp.typemod.property.static.java", {{ fg = colors.teal, style = "italic,bold" }})

    -- Functions and Methods
    hi("@lsp.type.function", {{ fg = colors.blue, style = "bold" }})
    hi("@lsp.type.method.java", {{ fg = colors.sky, style = "italic" }})
    hi("@lsp.type.method", {{ fg = colors.sapphire, style = "bold" }})
    hi("@lsp.typemod.function.static", {{ fg = colors.sky, style = "bold" }})
    hi("@lsp.typemod.method.static", {{ fg = colors.sapphire, style = "italic" }})

    -- Types and Classes
    hi("@lsp.type.class", {{ fg = colors.yellow, style = "bold" }})
    hi("@lsp.type.interface", {{ fg = colors.yellow, style = "italic" }})
    hi("@lsp.type.struct", {{ fg = colors.yellow }})
    hi("@lsp.type.enum", {{ fg = colors.peach }})
    hi("@lsp.type.enumMember", {{ fg = colors.teal }})
    hi("@lsp.type.type", {{ fg = colors.yellow }})
    hi("@lsp.type.typeParameter", {{ fg = colors.flamingo, style = "italic" }})

    -- Namespaces and Modules
    hi("@lsp.type.namespace", {{ fg = colors.sapphire, style = "italic" }})
    hi("@lsp.type.namespace.java", {{ fg = colors.sapphire, style = "italic" }})
    hi("@lsp.mod.importDeclaration", {{ fg = colors.yellow, style = "italic" }})
    hi("@lsp.mod.importDeclaration.java", {{ fg = colors.yellow, style = "italic" }})
    hi("@lsp.typemod.namespace.importDeclaration.java", {{ fg = colors.yellow, style = "italic" }})

    -- Macros and Preprocessor
    hi("@lsp.type.macro", {{ fg = colors.sapphire }})
    hi("@lsp.typemod.macro.globalScope", {{ fg = colors.sapphire }})
    hi("@lsp.typemod.macro.globalScope.cpp", {{ fg = colors.sapphire }})

    -- Decorators and Annotations
    hi("@lsp.type.decorator", {{ fg = colors.yellow, style = "italic" }})
    hi("@lsp.type.annotation", {{ fg = colors.yellow, style = "italic" }})

    -- Keywords (when LSP provides them)
    hi("@lsp.type.keyword", {{ fg = colors.mauve, style = "bold" }})
    hi("@lsp.typemod.keyword.controlFlow", {{ fg = colors.pink, style = "bold" }})

    -- ============================================================================
    -- DIAGNOSTIC
    -- ============================================================================
    hi("DiagnosticError", {{ fg = colors.red }})
    hi("DiagnosticWarn", {{ fg = colors.yellow }})
    hi("DiagnosticInfo", {{ fg = colors.blue }})
    hi("DiagnosticHint", {{ fg = colors.teal }})
    hi("DiagnosticOk", {{ fg = colors.green }})

    hi("DiagnosticVirtualTextError", {{ fg = colors.red, bg = "NONE" }})
    hi("DiagnosticVirtualTextWarn", {{ fg = colors.yellow, bg = "NONE" }})
    hi("DiagnosticVirtualTextInfo", {{ fg = colors.blue, bg = "NONE" }})
    hi("DiagnosticVirtualTextHint", {{ fg = colors.teal, bg = "NONE" }})

    hi("DiagnosticUnderlineError", {{ sp = colors.red, style = "undercurl" }})
    hi("DiagnosticUnderlineWarn", {{ sp = colors.yellow, style = "undercurl" }})
    hi("DiagnosticUnderlineInfo", {{ sp = colors.blue, style = "undercurl" }})
    hi("DiagnosticUnderlineHint", {{ sp = colors.teal, style = "undercurl" }})

    -- ============================================================================
    -- LSP REFERENCES
    -- ============================================================================
    hi("LspReferenceText", {{ bg = colors.mantle }})
    hi("LspReferenceRead", {{ bg = colors.mantle }})
    hi("LspReferenceWrite", {{ bg = colors.surface0, style = "bold" }})

    hi("MatchParen", {{ bg = colors.mantle }})
    hi("MatchParenCur", {{ bg = colors.mantle }})

    -- ============================================================================
    -- PLUGIN: TELESCOPE
    -- ============================================================================
    hi("TelescopeBorder", {{ fg = colors.lavender, bg = "NONE" }})
    hi("TelescopePromptBorder", {{ fg = colors.mauve, bg = "NONE"}})
    hi("TelescopeResultsBorder", {{ fg = colors.lavender, bg = "NONE" }})
    hi("TelescopePreviewBorder", {{ fg = colors.lavender, bg = "NONE" }})
    hi("TelescopeSelection", {{ fg = colors.surface0, bg = colors.mauve, style = "bold" }})
    hi("TelescopeSelectionCaret", {{ fg = colors.mauve, bg = colors.surface0 }})
    hi("TelescopeMatching", {{ fg = colors.blue }})

    -- ============================================================================
    -- PLUGIN: NVIM-TREE / NEO-TREE
    -- ============================================================================
    hi("NvimTreeNormal", {{ fg = colors.text, bg = "NONE" }})
    hi("NvimTreeFolderIcon", {{ fg = colors.mauve }})
    hi("NvimTreeFolderName", {{ fg = colors.sapphire }})
    hi("NvimTreeOpenedFolderName", {{ fg = colors.blue, bold = true }})
    hi("NvimTreeIndentMarker", {{ fg = colors.overlay0 }})
    hi("NvimTreeGitDirty", {{ fg = colors.yellow }})
    hi("NvimTreeGitNew", {{ fg = colors.green }})
    hi("NvimTreeGitDeleted", {{ fg = colors.red }})

    hi("NeoTreeTabActive", {{ fg = colors.mauve, bg = "NONE" }})
    hi("NeoTreeGitUntracked", {{ fg = colors.red }})
    hi("NeoTreeTabInactive", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("NeoTreeTabSeparatorActive", {{ fg = colors.surface0, bg = "NONE" }})
    hi("NeoTreeTabSeparatorInactive", {{ fg = colors.surface0, bg = "NONE" }})
    hi("NeoTreeDirectoryIcon", {{ fg = colors.mauve }})
    hi("NeoTreeDirectoryName", {{ fg = colors.sky }})
    hi("NeoTreeCursorLine", {{ fg = colors.red }})

    hi("DressingInput", {{ fg = colors.text, bg = colors.mantle }})
    hi("DressingInputBorder", {{ fg = colors.lavender, bg = "NONE" }})
    hi("DressingInputTitle", {{ fg = colors.mauve, bg = "NONE", style = "bold" }})
    hi("DressingInputPrompt", {{ fg = colors.text, bg = "NONE" }})  -- This is the key one!
    hi("DressingInputText", {{ fg = colors.text, bg = "NONE" }})
    hi("Prompt", {{ fg = colors.text, bg = "NONE" }})
    hi("Question", {{ fg = colors.text, bg = "NONE" }})

    -- ============================================================================
    -- PLUGIN: INDENT-BLANKLINE
    -- ============================================================================
    hi("IblIndent", {{ fg = colors.overlay0 }})
    hi("IblScope", {{ fg = colors.overlay0 }})

    -- ============================================================================
    -- PLUGIN: WHICH-KEY
    -- ============================================================================
    hi("WhichKey", {{ fg = colors.mauve, bg = "NONE" }})
    hi("WhichKeyGroup", {{ fg = colors.blue }})
    hi("WhichKeyBorder", {{ fg = colors.red, bg = "NONE" }})
    hi("WhichKeyDesc", {{ fg = colors.text }})
    hi("WhichKeySeparator", {{ fg = colors.mauve }})
    hi("WhichKeyFloat", {{ bg = "NONE" }})
    hi("WhichKeyTitle", {{ bg = "NONE" }})

    -- ============================================================================
    -- PLUGIN: NOTIFY
    -- ============================================================================
    hi("NotifyBackground", {{ bg = colors.base }})
    hi("NotifyERRORBorder", {{ fg = colors.red }})
    hi("NotifyWARNBorder", {{ fg = colors.yellow }})
    hi("NotifyINFOBorder", {{ fg = colors.blue }})
    hi("NotifyDEBUGBorder", {{ fg = colors.overlay0 }})
    hi("NotifyTRACEBorder", {{ fg = colors.teal }})
    hi("NotifyERRORIcon", {{ fg = colors.red }})
    hi("NotifyWARNIcon", {{ fg = colors.yellow }})
    hi("NotifyINFOIcon", {{ fg = colors.blue }})
    hi("NotifyDEBUGIcon", {{ fg = colors.overlay0 }})
    hi("NotifyTRACEIcon", {{ fg = colors.teal }})
    hi("NotifyERRORTitle", {{ fg = colors.red }})
    hi("NotifyWARNTitle", {{ fg = colors.yellow }})
    hi("NotifyINFOTitle", {{ fg = colors.blue }})
    hi("NotifyDEBUGTitle", {{ fg = colors.overlay0 }})
    hi("NotifyTRACETitle", {{ fg = colors.teal }})

    -- ============================================================================
    -- PLUGIN: RAINBOW DELIMITERS
    -- ============================================================================
    hi("RainbowDelimiterRed",    {{ fg = "{rainbow_colors['red']}" }})
    hi("RainbowDelimiterOrange", {{ fg = "{rainbow_colors['orange']}" }})
    hi("RainbowDelimiterYellow", {{ fg = "{rainbow_colors['yellow']}" }})
    hi("RainbowDelimiterGreen",  {{ fg = "{rainbow_colors['green']}" }})
    hi("RainbowDelimiterCyan",   {{ fg = "{rainbow_colors['cyan']}" }})
    hi("RainbowDelimiterBlue",   {{ fg = "{rainbow_colors['blue']}" }})
    hi("RainbowDelimiterViolet", {{ fg = "{rainbow_colors['violet']}" }})

    -- ============================================================================
    -- PLUGIN: RENDER-MARKDOWN
    -- ============================================================================
    hi("RenderMarkdownCode", {{ bg = "NONE" }})

    -- ============================================================================
    -- PLUGIN: BUFFERLINE / BARBAR
    -- ============================================================================
    hi("BufferLineFill", {{ bg = "NONE" }})
    hi("BufferLineBackground", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("BufferLineBuffer", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("BufferLineBufferVisible", {{ fg = colors.text, bg = "NONE" }})
    hi("BufferLineBufferSelected", {{ fg = colors.mauve, bg = "NONE", style = "bold" }})
    hi("BufferLineTab", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("BufferLineTabSelected", {{ fg = colors.mauve, bg = "NONE", style = "bold" }})
    hi("BufferLineSeparator", {{ fg = colors.surface0, bg = "NONE" }})
    hi("BufferLineSeparatorVisible", {{ fg = colors.surface0, bg = "NONE" }})
    hi("BufferLineSeparatorSelected", {{ fg = colors.surface0, bg = "NONE" }})

    -- Barbar plugin
    hi("BufferCurrent", {{ fg = colors.text, bg = "NONE", style = "bold" }})
    hi("BufferCurrentIndex", {{ fg = colors.mauve, bg = "NONE" }})
    hi("BufferCurrentMod", {{ fg = colors.yellow, bg = "NONE" }})
    hi("BufferCurrentSign", {{ fg = colors.mauve, bg = "NONE" }})
    hi("BufferCurrentTarget", {{ fg = colors.red, bg = "NONE" }})
    hi("BufferVisible", {{ fg = colors.text, bg = "NONE" }})
    hi("BufferVisibleIndex", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("BufferVisibleMod", {{ fg = colors.yellow, bg = "NONE" }})
    hi("BufferVisibleSign", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("BufferVisibleTarget", {{ fg = colors.red, bg = "NONE" }})
    hi("BufferInactive", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("BufferInactiveIndex", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("BufferInactiveMod", {{ fg = colors.lavender, bg = "NONE" }})
    hi("BufferInactiveSign", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("BufferInactiveTarget", {{ fg = colors.red, bg = "NONE" }})
    hi("BufferTabpages", {{ fg = colors.mauve, bg = "NONE", style = "bold" }})
    hi("BufferTabpageFill", {{ bg = "NONE" }})

    -- Overseer (task runner) - often appears in bufferline
    hi("OverseerTask", {{ fg = colors.blue, bg = "NONE" }})
    hi("OverseerTaskBorder", {{ fg = colors.blue, bg = "NONE" }})
    hi("OverseerRunning", {{ fg = colors.yellow, bg = "NONE" }})
    hi("OverseerSuccess", {{ fg = colors.green, bg = "NONE" }})
    hi("OverseerCanceled", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("OverseerFailure", {{ fg = colors.red, bg = "NONE" }})
    hi("OverseerBorder", {{ fg = colors.lavender, bg = "NONE" }})
    hi("OverseerNormal", {{ fg = colors.text, bg = colors.surface0 }})

    -- Additional top bar highlights (in case it's something else)
    hi("WinBar", {{ fg = "NONE", bg = "NONE" }})
    hi("SatelliteBar", {{ fg = "NONE", bg = "NONE" }})
    hi("SatelliteCursor", {{ fg = "NONE", bg = "NONE" }})
    hi("NeoTreeTitleBar", {{ fg = colors.mantle, bg = colors.teal }})
    hi("NeoTreeDimmedText", {{ fg = colors.red }})
    hi("NeoTreeMessage", {{ fg = colors.subtext0 }})
    hi("NeoTreeFloatNormal", {{ fg = colors.red }})
    hi("NeoTreeFloatBorder", {{ fg = colors.teal }})
    hi("NeoTreeFloatTitle", {{ fg = colors.red }})
    hi("NvimScrollbarHandle", {{ fg = "NONE", bg = "NONE" }})
    hi("NvimScrollbarCursor", {{ fg = "NONE", bg = "NONE" }})
    hi("NvimScrollbarError", {{ fg = "NONE", bg = "NONE" }})
    hi("NvimScrollbarWarn", {{ fg = "NONE", bg = "NONE" }})
    hi("NvimScrollbarInfo", {{ fg = "NONE", bg = "NONE" }})
    hi("NvimScrollbarHint", {{fg = "NONE", bg = "NONE" }})
    hi("NeoTreeScrollbar", {{ fg = "NONE", bg = "NONE" }})
    hi("NeoTreeScrollbarThumb", {{ fg = "NONE", bg = "NONE" }})
    hi("WinScrollbar", {{ fg = "NONE", bg = "NONE" }})
    hi("WinScrollbarThumb", {{ fg = "NONE", bg = "NONE" }})
    hi("WinBarNC", {{ fg = "NONE", bg = "NONE" }})
    hi("Title", {{ fg = colors.blue, bg = "NONE" }})
    hi("BufferLineDevIconLua", {{ bg = "NONE" }})
    hi("BufferLineDevIconDefault", {{ bg = "NONE" }})


    -- ============================================================================
    -- TEXT
    -- ============================================================================
    hi("Comment", {{ fg = colors.pink }})
    hi("Constant", {{ fg = colors.teal }})
    -- ============================================================================
    -- PLUGIN: ALPHA (Dashboard)
    -- ============================================================================
    hi("DashboardHeader", {{ fg = colors.sapphire }})
    hi("DashboardFooter", {{ fg = colors.mauve }})
    hi("AlphaShortcut", {{ fg = colors.red }})
    hi("AlphaIconNew", {{ fg = colors.blue }})
    hi("AlphaIconRecent", {{ fg = colors.pink }})
    hi("AlphaIconYazi", {{ fg = colors.peach }})
    hi("AlphaIconSessions", {{ fg = colors.green }})
    hi("AlphaIconProjects", {{ fg = colors.mauve }})
    hi("AlphaIconQuit", {{ fg = colors.red }})


    hi("DiffAdd", {{ fg = colors.green, bg = "NONE" }})
    hi("DiffChange", {{ fg = colors.blue, bg = "NONE" }})
    hi("DiffDelete", {{ fg = colors.red, bg = "NONE" }})
    hi("DiffText", {{ fg = colors.yellow, bg = "NONE", style = "bold" }})

    -- Git signs in the gutter
    hi("GitSignsAdd", {{ fg = colors.green, bg = "NONE" }})
    hi("GitSignsChange", {{ fg = colors.blue, bg = "NONE" }})
    hi("GitSignsDelete", {{ fg = colors.red, bg = "NONE" }})

    -- For syntax highlighting of color hex codes in your editor
    -- This will make the bright red/green hex codes themselves appear in purple tones
    hi("@string.special", {{ fg = colors.green }})  -- For color strings like "#FF0000"
    hi("@number.css", {{ fg = colors.peach }})

-- ============================================================================
-- PLUGIN: LUALINE
-- ============================================================================
    -- Normal mode
    hi("lualine_a_normal", {{ fg = colors.base, bg = colors.blue, style = "bold" }})
    hi("lualine_b_normal", {{ fg = colors.text, bg = colors.surface0 }})
    hi("lualine_c_normal", {{ fg = colors.subtext0, bg = "NONE" }})
    hi("lualine_x_normal", {{ fg = colors.subtext0, bg = "NONE" }})
    hi("lualine_y_normal", {{ fg = colors.text, bg = colors.surface0 }})
    hi("lualine_z_normal", {{ fg = colors.base, bg = colors.blue }})

    -- Insert mode
    hi("lualine_a_insert", {{ fg = colors.base, bg = colors.teal, style = "bold" }})
    hi("lualine_b_insert", {{ fg = colors.text, bg = colors.surface0 }})
    hi("lualine_c_insert", {{ fg = colors.subtext0, bg = "NONE" }})
    hi("lualine_x_insert", {{ fg = colors.subtext0, bg = "NONE" }})
    hi("lualine_y_insert", {{ fg = colors.text, bg = colors.surface0 }})
    hi("lualine_z_insert", {{ fg = colors.base, bg = colors.teal }})

    -- Visual mode
    hi("lualine_a_visual", {{ fg = colors.base, bg = colors.mauve, style = "bold" }})
    hi("lualine_b_visual", {{ fg = colors.text, bg = colors.surface0 }})
    hi("lualine_c_visual", {{ fg = colors.subtext0, bg = "NONE" }})
    hi("lualine_x_visual", {{ fg = colors.subtext0, bg = "NONE" }})
    hi("lualine_y_visual", {{ fg = colors.text, bg = colors.surface0 }})
    hi("lualine_z_visual", {{ fg = colors.base, bg = colors.mauve }})

    -- Replace mode
    hi("lualine_a_replace", {{ fg = colors.base, bg = colors.red, style = "bold" }})
    hi("lualine_b_replace", {{ fg = colors.text, bg = colors.surface0 }})
    hi("lualine_c_replace", {{ fg = colors.subtext0, bg = "NONE" }})
    hi("lualine_x_replace", {{ fg = colors.subtext0, bg = "NONE" }})
    hi("lualine_y_replace", {{ fg = colors.text, bg = colors.surface0 }})
    hi("lualine_z_replace", {{ fg = colors.base, bg = colors.red }})

    -- Command mode
    hi("lualine_a_command", {{ fg = colors.base, bg = colors.peach, style = "bold" }})
    hi("lualine_b_command", {{ fg = colors.text, bg = colors.surface0 }})
    hi("lualine_c_command", {{ fg = colors.subtext0, bg = "NONE" }})
    hi("lualine_x_command", {{ fg = colors.subtext0, bg = "NONE" }})
    hi("lualine_y_command", {{ fg = colors.text, bg = colors.surface0 }})
    hi("lualine_z_command", {{ fg = colors.base, bg = colors.peach }})

    -- Inactive
    hi("lualine_a_inactive", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("lualine_b_inactive", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("lualine_c_inactive", {{ fg = colors.overlay0, bg = "NONE" }})

    -- Additional lualine components
    --hi("lualine_transitional_lualine_a_normal_to_lualine_b_normal", {{ fg = colors.blue, bg = colors.surface0 }})
    --hi("lualine_transitional_lualine_a_insert_to_lualine_b_insert", {{ fg = colors.teal, bg = colors.surface0 }})
    --hi("lualine_transitional_lualine_a_visual_to_lualine_b_visual", {{ fg = colors.mauve, bg = colors.surface0 }})
    --hi("lualine_transitional_lualine_a_replace_to_lualine_b_replace", {{ fg = colors.red, bg = colors.surface0 }})
    --hi("lualine_transitional_lualine_a_command_to_lualine_b_command", {{ fg = colors.peach, bg = colors.surface0 }})

-- ============================================================================
-- TRANSPARENCY REASSERTION (CRITICAL)
-- ============================================================================
    local transparent_groups = {{
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
        }}

    for _, group in ipairs(transparent_groups) do
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, {{ name = group }})
        if ok then
            hl.bg = "NONE"
            hl.ctermbg = nil
            vim.api.nvim_set_hl(0, group, hl)
        end
    end
end

setup_highlights()
'''

    with open(output_path, "w") as f:
        f.write(nvim_theme_content)

    if debug:
        print(f"\nNeovim colorscheme written to: {output_path}")

    return output_path


if __name__ == "__main__":
    print("This module should be imported, not run directly.")
    print(
        "Use: from generate_nvim_theme import generate_neovim_theme, write_neovim_colorscheme"
    )
