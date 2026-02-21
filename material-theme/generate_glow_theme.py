#!/usr/bin/env python3
"""
Glow / Glamour Theme Generator - Material Purple Mocha Edition
Generates Glamour JSON matching your Neovim colorscheme's vibrant purple aesthetic.
Reference: https://github.com/charmbracelet/glamour/tree/master/styles
"""
import json
from pathlib import Path

# Material Purple Mocha colors (from your Neovim theme)
COLORS = {
    # Base colors
    "base": "#1F1E2E",
    "mantle": "#191825",
    "crust": "#12111B",
    "transparent": "#000000",
    # Surface colors
    "surface0": "#323244",
    "surface1": "#46475A",
    "surface2": "#595B70",
    # Overlay colors
    "overlay0": "#6E7086",
    "overlay1": "#81839C",
    "overlay2": "#9598B2",
    # Text colors
    "text": "#D1D5F4",
    "subtext1": "#BEC1DE",
    "subtext0": "#AAACC8",
    # Accent colors (VIBRANT)
    "rosewater": "#FFD9FA",
    "flamingo": "#EEC8FF",
    "pink": "#BE9FD7",
    "mauve": "#BA95ED",
    "red": "#C383F1",
    "maroon": "#D89CFF",
    "peach": "#EB97C0",
    "yellow": "#E0BFB9",
    "green": "#00BDCC",
    "teal": "#8BB5DB",
    "sky": "#BFCEFF",
    "sapphire": "#B0ABF5",
    "blue": "#BBA2FC",
    "lavender": "#CEB6FF",
}


def generate_glow_colors(
    material_colors: dict = None, term_colors: dict = None, darkmode: bool = True
) -> dict:
    """
    Color palette matching your Neovim theme's syntax highlighting.
    """
    c = COLORS

    return {
        # Text
        "fg": c["text"],
        "fg_muted": c["subtext0"],
        "fg_subtle": c["overlay1"],
        # Headers - vibrant color hierarchy
        "h1": c["red"],  # Bright purple (#C383F1)
        "h2": c["mauve"],  # Medium purple (#BA95ED)
        "h3": c["teal"],  # Blue (#8BB5DB)
        "h4": "#7DD3C0",  # Teal
        "h5": "#FACC15",  # Yellow
        "h6": "#FB923C",  # Orange
        # Code blocks
        "code_fg": "#FACC15",
        "code_bg": "#2A2438",
        # Links
        "link": "#38BDF8",
        "link_text": "#A5B4FC",
        # Emphasis/Strong
        "emph": c["flamingo"],
        "strong": "#4ADE80",
        # Block quotes
        "quote_fg": "#7DD3C0",
        # Lists
        "list_marker": "#F472B6",
        "list_enum": "#FB923C",
        # Other
        "hr": c["overlay0"],
        "task_done": "#4ADE80",
        "image_text": "#F5A0BF",
        "strikethrough": "#FB7185",
    }


def write_glow_config(
    glow_colors: dict = None, output_path: str = None, debug: bool = False
) -> str:
    """Writes a Glamour JSON style file matching your Neovim theme."""
    glow_cfg_dir = Path.home() / ".config" / "glow"
    glow_cfg_dir.mkdir(parents=True, exist_ok=True)

    style_path = glow_cfg_dir / "material-purple-mocha.json"
    if output_path is not None:
        style_path = Path(output_path)
        style_path.parent.mkdir(parents=True, exist_ok=True)

    c = generate_glow_colors()

    glamour = {
        "document": {"block_prefix": "\n", "block_suffix": "\n", "color": c["fg"], "margin": 2},
        "block_quote": {"indent": 1, "indent_token": "│ ", "color": c["quote_fg"], "italic": True},
        "paragraph": {},
        "list": {"level_indent": 2, "color": c["fg"]},
        "heading": {"block_suffix": "\n", "color": c["h1"], "bold": True},
        "h1": {"prefix": "█ ", "suffix": " █", "color": c["h1"], "bold": True},
        "h2": {"prefix": "▓▓ ", "color": c["h2"], "bold": True},
        "h3": {"prefix": "▒▒▒ ", "color": c["h3"], "bold": True},
        "h4": {"prefix": "░░░░ ", "color": c["h4"], "bold": True},
        "h5": {"prefix": "▸▸▸▸▸ ", "color": c["h5"], "bold": True},
        "h6": {"prefix": "▹▹▹▹▹▹ ", "color": c["h6"], "bold": True},
        "text": {},
        "strikethrough": {"crossed_out": True, "color": c["strikethrough"]},
        "emph": {"italic": True, "color": c["emph"]},
        "strong": {"bold": True, "color": c["strong"]},
        "hr": {"color": c["hr"], "format": "\n────────────────────────────────────\n"},
        "item": {"block_prefix": "• ", "color": c["list_marker"], "bold": True},
        "enumeration": {"block_prefix": ". ", "color": c["list_enum"], "bold": True},
        "task": {"ticked": "[✓] ", "unticked": "[ ] ", "color": c["task_done"]},
        "link": {"color": c["link"], "underline": True},
        "link_text": {"color": c["link_text"], "bold": True},
        "image": {"color": "#F472B6", "underline": True},
        "image_text": {"color": c["image_text"], "format": "Image: {{.text}} →"},
        "code": {
            "prefix": " ",
            "suffix": " ",
            "color": c["code_fg"],
            "background_color": c["code_bg"],
        },
        "code_block": {
            "color": c["code_bg"],
            "margin": 2,
            "chroma": {
                "text": {"color": c["fg"]},
                "error": {"color": "#FB7185"},
                "comment": {"color": COLORS["overlay2"]},
                "comment_preproc": {"color": "#A5B4FC"},
                "keyword": {"color": COLORS["red"]},
                "keyword_reserved": {"color": COLORS["mauve"]},
                "keyword_namespace": {"color": COLORS["sapphire"]},
                "keyword_type": {"color": COLORS["teal"]},
                "operator": {"color": "#7DD3C0"},
                "punctuation": {"color": COLORS["overlay2"]},
                "name": {"color": c["fg"]},
                "name_builtin": {"color": COLORS["blue"]},
                "name_tag": {"color": COLORS["mauve"]},
                "name_attribute": {"color": COLORS["teal"]},
                "name_class": {"color": COLORS["yellow"]},
                "name_constant": {"color": "#FACC15"},
                "name_decorator": {"color": "#F472B6"},
                "name_exception": {},
                "name_function": {"color": "#A5B4FC"},
                "name_other": {},
                "literal": {},
                "literal_number": {"color": COLORS["peach"]},
                "literal_date": {},
                "literal_string": {"color": COLORS["green"]},
                "literal_string_escape": {"color": COLORS["pink"]},
                "generic_deleted": {"color": "#FB7185"},
                "generic_emph": {"color": COLORS["flamingo"], "italic": True},
                "generic_inserted": {"color": "#4ADE80"},
                "generic_strong": {"color": "#4ADE80", "bold": True},
                "generic_subheading": {"color": COLORS["mauve"]},
                "background": {"background_color": c["code_bg"]},
            },
        },
        "table": {
            "center_separator": "┼",
            "column_separator": "│",
            "row_separator": "─",
            "color": "#A5B4FC",
        },
        "definition_list": {},
        "definition_term": {"color": "#FACC15", "bold": True},
        "definition_description": {"block_prefix": "\n🠶 ", "color": "#A5B4FC"},
        "html_block": {},
        "html_span": {},
    }

    with open(style_path, "w") as f:
        json.dump(glamour, f, indent=2)

    # Update glow.yml
    glow_yml_path = glow_cfg_dir / "glow.yml"
    glow_yml = f"""# Auto-generated - Material Purple Mocha theme
style: "{style_path}"
mouse: false
pager: false
width: 100
"""
    with open(glow_yml_path, "w") as f:
        f.write(glow_yml)

    if debug:
        print(f"\n✓ Glamour style written to: {style_path}")
        print(f"✓ Glow config updated: {glow_yml_path}")

    return str(style_path)


if __name__ == "__main__":
    write_glow_config(debug=True)
    print("\n✓ Material Purple Mocha Glow theme generated!")
