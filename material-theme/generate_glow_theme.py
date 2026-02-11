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


def generate_glow_colors(material_colors: dict = None, term_colors: dict = None, darkmode: bool = True) -> dict:
    """
    Color palette matching your Neovim theme's syntax highlighting.
    Maps Neovim highlight groups to Glow/Glamour elements.

    Args:
        material_colors: Optional Material You colors (not used, for compatibility)
        term_colors: Optional terminal colors (not used, for compatibility)
        darkmode: Optional dark mode flag (not used, for compatibility)
    """
    # Use hardcoded Material Purple Mocha colors
    c = COLORS

    return {
        # Document background (transparent in nvim, but needs bg for glow)
        "bg": c["crust"],        # Darker like your terminal bg
        "bg_subtle": c["surface0"],
        "bg_strong": c["surface1"],

        # Text (matching Normal fg)
        "fg": c["text"],
        "fg_muted": c["subtext0"],
        "fg_subtle": c["overlay1"],

        # Headers - matching your LSP/treesitter class/type hierarchy
        "h1": c["yellow"],       # Like @lsp.type.class (bold)
        "h2": c["lavender"],     # Bright purple
        "h3": c["mauve"],        # Primary purple like @keyword
        "h4": c["pink"],         # Like @comment but brighter
        "h5": c["sapphire"],     # Like @lsp.type.namespace
        "h6": c["flamingo"],     # Soft accent

        # Code blocks (matching @string for inline code)
        "code_fg": c["green"],   # Like @string
        "code_bg": c["mantle"],  # Darker like your nvim floats

        # Links (matching @lsp.type.namespace and method calls)
        "link": c["sapphire"],   # Like namespace
        "link_text": c["sky"],   # Like method calls

        # Emphasis/Strong (matching your exact highlights)
        "emph": c["pink"],       # Italic like @comment
        "strong": c["mauve"],    # Bold like @keyword

        # Block quotes (matching @comment exactly)
        "quote_fg": c["pink"],   # Like @comment
        "quote_border": c["pink"],  # Matching border

        # Lists (matching @punctuation.delimiter)
        "list_marker": c["overlay2"],

        # Horizontal rules
        "hr": c["overlay0"],

        # Table headers (matching class/type highlighting)
        "th_fg": c["yellow"],    # Like @lsp.type.class
        "th_bg": c["mantle"],

        # Task items (matching diagnostics)
        "task_done": c["green"],   # Like DiagnosticOk
        "task_open": c["teal"],    # Like @property

        # Image text
        "image_text": c["sapphire"],

        # Strikethrough
        "strikethrough": c["overlay1"],

        # Additional syntax elements
        "number": c["peach"],    # Like @number
        "boolean": c["peach"],   # Like @boolean
        "property": c["teal"],   # Like @property
        "operator": "#00ffff",   # Bright cyan like your @operator
    }


def write_glow_config(glow_colors: dict = None, output_path: str = None, debug: bool = False) -> str:
    """
    Writes a Glamour JSON style file matching your Neovim theme.

    Args:
        glow_colors: Optional colors dict (not used, for compatibility)
        output_path: Optional custom output path
        debug: Whether to print debug info
    """
    glow_cfg_dir = Path.home() / ".config" / "glow"
    glow_cfg_dir.mkdir(parents=True, exist_ok=True)

    style_path = glow_cfg_dir / "material-purple-mocha.json"
    if output_path is not None:
        style_path = Path(output_path)
        style_path.parent.mkdir(parents=True, exist_ok=True)

    # Always use our generated colors, ignore passed colors
    c = generate_glow_colors()

    def bold(fg, bg=None):
        o = {"color": fg, "bold": True}
        if bg: o["background_color"] = bg
        return o

    def plain(fg, bg=None):
        o = {"color": fg}
        if bg: o["background_color"] = bg
        return o

    def italic(fg):
        return {"color": fg, "italic": True}

    glamour = {
        "document": {
            "color": c["fg"],
            "margin": 2
        },
        "block_quote": {
            "indent": 1,
            "indent_token": "│ ",
            "color": c["quote_fg"]
        },
        "paragraph": plain(c["fg"]),
        "list": plain(c["fg"]),
        "item": {"color": c["fg"], "block_prefix": "• "},
        "enumeration": {"color": c["fg"], "block_prefix": ". "},
        "task": {
            "ticked": f"[✓] ",
            "unticked": f"[ ] "
        },
        "heading": {
            "bold": True,
            "color": c["h1"]
        },
        "h1": {**bold(c["h1"]), "prefix": "# ", "suffix": " ", "margin_top": 1, "margin_bottom": 1},
        "h2": {**bold(c["h2"]), "prefix": "## ", "suffix": " ", "margin_top": 1, "margin_bottom": 1},
        "h3": {**bold(c["h3"]), "prefix": "### ", "margin_top": 1, "margin_bottom": 0},
        "h4": {**bold(c["h4"]), "prefix": "#### ", "margin_top": 1, "margin_bottom": 0},
        "h5": {**bold(c["h5"]), "prefix": "##### "},
        "h6": {**bold(c["h6"]), "prefix": "###### "},
        "strikethrough": {"color": c["strikethrough"], "crossed_out": True},
        "emph": italic(c["emph"]),
        "strong": bold(c["strong"]),
        "hr": {"color": c["hr"], "format": "\n───────────────────────────────────\n"},
        "link": {"color": c["link"], "underline": True},
        "link_text": plain(c["link_text"]),
        "image": {"color": c["link"], "underline": True},
        "image_text": italic(c["image_text"]),
        "code": plain(c["code_fg"], c["code_bg"]),
        "code_block": {
            "margin": 1,
            "chroma": {
                "text": {
                    "color": c["fg"]
                },
                "error": {
                    "color": COLORS["red"]
                },
                "comment": {
                    "color": COLORS["pink"],
                    "italic": True
                },
                "comment_preproc": {
                    "color": COLORS["sapphire"]
                },
                "keyword": {
                    "color": COLORS["mauve"],
                    "bold": True
                },
                "keyword_reserved": {
                    "color": COLORS["mauve"],
                    "bold": True
                },
                "keyword_namespace": {
                    "color": COLORS["sapphire"],
                    "italic": True
                },
                "keyword_type": {
                    "color": COLORS["yellow"],
                    "bold": True
                },
                "operator": {
                    "color": "#00ffff"
                },
                "punctuation": {
                    "color": COLORS["overlay2"]
                },
                "name": {
                    "color": c["fg"]
                },
                "name_builtin": {
                    "color": COLORS["red"],
                    "italic": True
                },
                "name_tag": {
                    "color": COLORS["mauve"]
                },
                "name_attribute": {
                    "color": COLORS["teal"],
                    "italic": True
                },
                "name_class": {
                    "color": COLORS["yellow"],
                    "bold": True
                },
                "name_constant": {
                    "color": COLORS["teal"]
                },
                "name_decorator": {
                    "color": COLORS["yellow"],
                    "italic": True
                },
                "name_exception": {
                    "color": COLORS["red"]
                },
                "name_function": {
                    "color": COLORS["blue"],
                    "bold": True
                },
                "name_function_magic": {
                    "color": COLORS["sky"],
                    "italic": True
                },
                "name_other": {
                    "color": c["fg"]
                },
                "name_variable": {
                    "color": c["fg"]
                },
                "name_variable_class": {
                    "color": COLORS["flamingo"]
                },
                "name_variable_global": {
                    "color": COLORS["flamingo"]
                },
                "name_variable_instance": {
                    "color": COLORS["teal"]
                },
                "literal": {
                    "color": COLORS["peach"]
                },
                "literal_number": {
                    "color": COLORS["peach"]
                },
                "literal_number_integer": {
                    "color": COLORS["peach"]
                },
                "literal_number_float": {
                    "color": COLORS["peach"]
                },
                "literal_date": {
                    "color": COLORS["peach"]
                },
                "literal_string": {
                    "color": COLORS["green"]
                },
                "literal_string_affix": {
                    "color": COLORS["green"]
                },
                "literal_string_char": {
                    "color": COLORS["teal"]
                },
                "literal_string_delimiter": {
                    "color": COLORS["green"]
                },
                "literal_string_doc": {
                    "color": COLORS["pink"],
                    "italic": True
                },
                "literal_string_double": {
                    "color": COLORS["green"]
                },
                "literal_string_escape": {
                    "color": COLORS["pink"]
                },
                "literal_string_heredoc": {
                    "color": COLORS["green"]
                },
                "literal_string_interpol": {
                    "color": COLORS["pink"]
                },
                "literal_string_other": {
                    "color": COLORS["green"]
                },
                "literal_string_regex": {
                    "color": COLORS["pink"]
                },
                "literal_string_single": {
                    "color": COLORS["green"]
                },
                "literal_string_symbol": {
                    "color": COLORS["teal"]
                },
                "generic": {
                    "color": c["fg"]
                },
                "generic_deleted": {
                    "color": COLORS["red"]
                },
                "generic_emph": {
                    "color": COLORS["blue"],
                    "italic": True
                },
                "generic_error": {
                    "color": COLORS["red"]
                },
                "generic_heading": {
                    "color": COLORS["lavender"],
                    "bold": True
                },
                "generic_inserted": {
                    "color": COLORS["green"]
                },
                "generic_output": {
                    "color": c["fg_muted"]
                },
                "generic_prompt": {
                    "color": COLORS["lavender"]
                },
                "generic_strong": {
                    "color": COLORS["mauve"],
                    "bold": True
                },
                "generic_subheading": {
                    "color": COLORS["lavender"]
                },
                "generic_traceback": {
                    "color": COLORS["red"]
                },
                "background": {
                    "background_color": c["code_bg"]
                }
            }
        },
        "table": {
            "color": c["fg"]
        },
        "definition_list": plain(c["fg"]),
        "definition_term": bold(c["strong"]),
        "definition_description": italic(c["fg_muted"]),
        "html_block": plain(c["fg_muted"]),
        "html_span": plain(c["fg_muted"]),
        "text": plain(c["fg"])
    }

    with open(style_path, "w") as f:
        json.dump(glamour, f, indent=2)

    # Update glow.yml to point at our style
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
        print(f"\nYou can also export the style manually:")
        print(f"  export GLAMOUR_STYLE={style_path}")

    return str(style_path)


if __name__ == "__main__":
    write_glow_config(debug=True)
    print("\n✓ Material Purple Mocha Glow theme generated!")
