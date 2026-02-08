#!/usr/bin/env python3
"""
Wofi Theme Generator (Material You)
Generates ~/.config/wofi/style.css using Material You + harmonized terminal colors.

Expected config shape (from your config.json):
{
  "applications": {
    "wofi": {
      "enabled": true,
      "background_alpha_dark": 0.60,
      "background_alpha_light": 0.62,
      "input_alpha": 0.46
    }
  }
}
"""

from __future__ import annotations

from pathlib import Path
from typing import Dict, Optional


def hex_to_rgba(hex_color: str, alpha: float) -> str:
    hex_color = hex_color.strip().lstrip("#")
    if len(hex_color) != 6:
        # fallback to opaque if malformed
        return f"rgba(0, 0, 0, {alpha})"
    r = int(hex_color[0:2], 16)
    g = int(hex_color[2:4], 16)
    b = int(hex_color[4:6], 16)
    return f"rgba({r}, {g}, {b}, {alpha})"


def _pick(d: Dict[str, str], *keys: str, fallback: str) -> str:
    """Pick the first existing key from dict; else fallback."""
    for k in keys:
        v = d.get(k)
        if isinstance(v, str) and v.strip():
            return v.strip()
    return fallback


def generate_wofi_colors(
    material_colors: dict,
    term_colors: dict,
    darkmode: bool,
    wofi_config: Optional[dict] = None,
) -> dict:
    """
    Build a semantic palette for Wofi using Material + terminal colors.
    Supports transparency via rgba() and reads alpha from wofi_config.
    """
    wofi_config = wofi_config or {}

    # Read alpha knobs (floats)
    alpha_dark = float(wofi_config.get("background_alpha_dark", 0.85))
    alpha_light = float(wofi_config.get("background_alpha_light", 0.92))
    input_alpha = float(wofi_config.get("input_alpha", 0.95))

    # Background/foreground base
    base_bg = _pick(term_colors, "term0", fallback="#1e1e2e")
    fg = _pick(term_colors, "term7", fallback="#cdd6f4")

    # Transparent background (rgba)
    bg = hex_to_rgba(base_bg, alpha_dark if darkmode else alpha_light)

    # Input box: slightly more solid so text is readable
    input_base = _pick(
        material_colors,
        "surfaceContainerLow",
        "surfaceContainer",
        "surface",
        fallback=base_bg,
    )
    input_bg = hex_to_rgba(input_base, input_alpha)
    input_fg = _pick(material_colors, "onSurface", fallback=fg)

    # Accent (purple vibe): primary; fallback to term13
    accent = _pick(
        material_colors,
        "primary",
        "primary_paletteKeyColor",
        fallback=_pick(term_colors, "term13", fallback="#cba6f7"),
    )
    accent2 = _pick(
        material_colors,
        "secondary",
        "secondary_paletteKeyColor",
        fallback=_pick(term_colors, "term12", fallback="#89b4fa"),
    )

    # Hover/selection surfaces
    hover_bg = _pick(
        material_colors,
        "surfaceContainerHigh",
        "surfaceContainer",
        fallback=_pick(term_colors, "term8", fallback="#313244"),
    )
    entry_fg = _pick(
        material_colors,
        "onSurfaceVariant",
        "onSurface",
        fallback=_pick(term_colors, "term15", fallback="#a6adc8"),
    )

    selected_bg = accent
    selected_fg = _pick(material_colors, "onPrimary", fallback=base_bg)

    return {
        "bg": bg,
        "fg": fg,
        "border": accent,
        "input_bg": input_bg,
        "input_fg": input_fg,
        "input_border": accent2,
        "entry_fg": entry_fg,
        "hover_bg": hover_bg,
        "hover_fg": fg,
        "selected_bg": selected_bg,
        "selected_fg": selected_fg,
    }


def write_wofi_theme(wofi_colors: dict, output_path: str = None, debug: bool = False) -> str:
    """
    Write ~/.config/wofi/style.css (or custom output path).
    """
    if output_path is None:
        wofi_dir = Path.home() / ".config" / "wofi"
        wofi_dir.mkdir(parents=True, exist_ok=True)
        output_path = str(wofi_dir / "style.css")

    css = f"""/* Auto-generated Wofi style (Material You) */

* {{
  font-family: Iosevka;
  font-size: 18px;
}}

window {{
  background-color: {wofi_colors["bg"]};
  border: 2px solid {wofi_colors["border"]};
  padding: 10px;
}}

#input {{
  background-color: {wofi_colors["input_bg"]};
  color: {wofi_colors["input_fg"]};
  border: 2px solid {wofi_colors["input_border"]};
  padding: 6px 10px;
  margin-bottom: 10px;
}}

#entry {{
  padding: 6px 10px;
  color: {wofi_colors["entry_fg"]};
}}

#entry:selected {{
  background-color: {wofi_colors["selected_bg"]};
  color: {wofi_colors["selected_fg"]};
  font-weight: bold;
}}

#entry:hover {{
  background-color: {wofi_colors["hover_bg"]};
  color: {wofi_colors["hover_fg"]};
}}
"""

    Path(output_path).write_text(css)

    if debug:
        print(f"Wofi theme written to: {output_path}")
        # Helpful: show the final bg line so you can confirm alpha
        print(f"Wofi window bg: {wofi_colors['bg']}")

    return output_path


if __name__ == "__main__":
    print("Import this module from generate_material_theme.py")

