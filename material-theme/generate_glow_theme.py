#!/usr/bin/env python3
"""
Glow / Glamour Theme Generator
Generates a proper Glamour JSON style file from Material You colors.
Reference: https://github.com/charmbracelet/glamour/tree/master/styles
"""
import json
from pathlib import Path
from materialyoucolor.hct import Hct
from materialyoucolor.utils.color_utils import rgba_from_argb, argb_from_rgb


def hex_to_argb(hex_code: str) -> int:
    return argb_from_rgb(int(hex_code[1:3], 16), int(hex_code[3:5], 16), int(hex_code[5:], 16))


def argb_to_hex(argb: int) -> str:
    rgba = rgba_from_argb(argb)
    return "#{:02X}{:02X}{:02X}".format(*map(round, rgba))


def _hct(base_hue: float, chroma: float, tone: float) -> str:
    return argb_to_hex(Hct.from_hct(base_hue, chroma, tone).to_int())


def generate_glow_colors(material_colors: dict, term_colors: dict, darkmode: bool = True) -> dict:
    """
    Derives a palette of named roles from Material You + terminal colors.
    This is kept as a simple dict so callers can inspect/override values.
    """
    primary_hct = Hct.from_int(hex_to_argb(material_colors["primary_paletteKeyColor"]))
    h  = primary_hct.hue
    c  = primary_hct.chroma

    # Clamp helpers
    def vc(x): return min(x, 90)   # vibrant chroma cap
    def mc(x): return min(x, 60)   # muted chroma cap

    dk = darkmode
    p = {
        # backgrounds
        "bg":           material_colors["surface"],
        "bg_subtle":    material_colors["surfaceContainer"],
        "bg_strong":    material_colors["surfaceContainerHigh"],

        # text
        "fg":           material_colors["onSurface"],
        "fg_muted":     material_colors["onSurfaceVariant"],
        "fg_subtle":    _hct(h, mc(c * 0.35), 55 if dk else 50),

        # headers – primary hue, progressively dimmer
        "h1":           _hct(h,       vc(c * 1.5), 82 if dk else 35),
        "h2":           _hct(h - 5,   vc(c * 1.4), 78 if dk else 38),
        "h3":           _hct(h - 10,  vc(c * 1.3), 74 if dk else 41),
        "h4":           _hct(h - 15,  vc(c * 1.2), 71 if dk else 44),
        "h5":           _hct(h - 20,  vc(c * 1.1), 68 if dk else 47),
        "h6":           _hct(h - 25,  vc(c * 1.0), 65 if dk else 50),

        # inline code / code blocks
        "code_fg":      _hct(h + 25,  vc(c * 1.3), 75 if dk else 40),
        "code_bg":      _hct(h,       mc(c * 0.25), 18 if dk else 92),

        # links
        "link":         _hct(h + 150, vc(c * 1.3), 75 if dk else 40),
        "link_text":    _hct(h + 145, vc(c * 1.1), 70 if dk else 44),

        # emphasis / strong
        "emph":         _hct(h + 15,  vc(c * 1.3), 76 if dk else 40),
        "strong":       _hct(h - 5,   vc(c * 1.4), 78 if dk else 38),

        # block quotes
        "quote_fg":     _hct(h + 20,  mc(c * 0.9), 70 if dk else 44),
        "quote_border": _hct(h,       vc(c * 1.2), 55 if dk else 52),

        # lists / enumerations
        "list_marker":  _hct(h + 5,   vc(c * 1.2), 72 if dk else 43),

        # horizontal rules
        "hr":           _hct(h,       mc(c * 0.5), 42 if dk else 62),

        # table header
        "th_fg":        _hct(h,       vc(c * 1.3), 78 if dk else 38),
        "th_bg":        _hct(h,       mc(c * 0.3), 22 if dk else 88),

        # task items
        "task_done":    _hct(h + 140, vc(c * 1.3), 72 if dk else 43),
        "task_open":    _hct(h + 30,  vc(c * 1.1), 68 if dk else 47),

        # image / definition text
        "image_text":   _hct(h - 10,  mc(c * 0.9), 65 if dk else 50),

        # strikethrough
        "strikethrough":_hct(h,       mc(c * 0.4), 52 if dk else 58),
    }
    return p


def write_glow_config(glow_colors: dict, output_path: str = None, debug: bool = False) -> str:
    """
    Writes a Glamour JSON style file and points glow.yml at it.
    Glow reads GLAMOUR_STYLE or the 'style' key in glow.yml.
    """
    glow_cfg_dir = Path.home() / ".config" / "glow"
    glow_cfg_dir.mkdir(parents=True, exist_ok=True)

    style_path = glow_cfg_dir / "material-you.json"
    if output_path is not None:
        style_path = Path(output_path)
        style_path.parent.mkdir(parents=True, exist_ok=True)

    c = glow_colors  # shorthand

    def bold(fg, bg=None):
        o = {"color": fg, "bold": True}
        if bg: o["backgroundColor"] = bg
        return o

    def plain(fg, bg=None):
        o = {"color": fg}
        if bg: o["backgroundColor"] = bg
        return o

    def italic(fg):
        return {"color": fg, "italic": True}

    glamour = {
        "document": {
            "color":           c["fg"],
            "backgroundColor": c["bg"],
            "margin": 2
        },
        "block_quote": {
            "indent": 1,
            "indent_token": "│ ",
            "color":  c["quote_fg"]
        },
        "paragraph":    plain(c["fg"]),
        "list":         plain(c["fg"]),
        "item":         {"color": c["fg"], "block_prefix": "• "},
        "enumeration":  {"color": c["fg"], "block_prefix": ". "},
        "task_list_marker_checked":   {"color": c["task_done"]},
        "task_list_marker_unchecked": {"color": c["task_open"]},
        "heading": {
            "bold": True,
            "color": c["h1"]
        },
        "h1": {**bold(c["h1"]), "prefix": "# ",  "suffix": " #",  "margin_top": 1, "margin_bottom": 1},
        "h2": {**bold(c["h2"]), "prefix": "## ", "suffix": " ##", "margin_top": 1, "margin_bottom": 1},
        "h3": {**bold(c["h3"]), "prefix": "### ",                  "margin_top": 1, "margin_bottom": 0},
        "h4": {**bold(c["h4"]), "prefix": "#### ",                 "margin_top": 1, "margin_bottom": 0},
        "h5": {**bold(c["h5"]), "prefix": "##### "},
        "h6": {**bold(c["h6"]), "prefix": "###### "},
        "strikethrough":    {"color": c["strikethrough"], "strikethrough": True},
        "emph":             italic(c["emph"]),
        "strong":           bold(c["strong"]),
        "hr":               {"color": c["hr"]},
        "link":             {"color": c["link"], "underline": True},
        "link_text":        plain(c["link_text"]),
        "image":            {"color": c["link"], "underline": True},
        "image_text":       italic(c["image_text"]),
        "code":             plain(c["code_fg"], c["code_bg"]),
        "code_block": {
            "color":           c["code_fg"],
            "backgroundColor": c["code_bg"],
            "margin": 1,
            "chroma_formatter": "terminal256"
        },
        "table": {
            "color": c["fg"]
        },
        "definition_list":  plain(c["fg"]),
        "definition_term":  bold(c["strong"]),
        "definition_description": italic(c["fg_muted"]),
        "html_block":       plain(c["fg_muted"]),
        "html_span":        plain(c["fg_muted"]),
        "text":             plain(c["fg"]),
        "softbreak":        {"chars": "\n"},
        "hardbreak":        {"chars": "\n\n"},
    }

    with open(style_path, "w") as f:
        json.dump(glamour, f, indent=2)

    # Update glow.yml to point at our style
    glow_yml_path = glow_cfg_dir / "glow.yml"
    glow_yml = f"""# Auto-generated by material-theme generator
style: "{style_path}"
mouse: false
pager: false
width: 100
all: false
"""
    with open(glow_yml_path, "w") as f:
        f.write(glow_yml)

    if debug:
        print(f"\nGlamour style written to: {style_path}")
        print(f"Glow config updated:       {glow_yml_path}")
        print("\nYou can also export the style manually:")
        print(f"  export GLAMOUR_STYLE={style_path}")

    # Return the style JSON path (most useful for callers / GLAMOUR_STYLE)
    return str(style_path)


if __name__ == "__main__":
    print("This module should be imported, not run directly.")
    print("Use: from generate_glow_theme import generate_glow_colors, write_glow_config")
