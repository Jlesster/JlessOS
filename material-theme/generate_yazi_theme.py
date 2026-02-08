#!/usr/bin/env python3
"""
Yazi File Manager Theme Generator - Fixed Version
Generates colorful file type themes harmonized with Material You colors
with proper tone/chroma adjustments for dark/light modes
"""
from pathlib import Path
from materialyoucolor.hct import Hct
from materialyoucolor.utils.color_utils import rgba_from_argb, argb_from_rgb


def hex_to_argb(hex_code: str) -> int:
    """Convert hex color to ARGB integer"""
    return argb_from_rgb(int(hex_code[1:3], 16), int(hex_code[3:5], 16), int(hex_code[5:], 16))


def argb_to_hex(argb: int) -> str:
    """Convert ARGB integer to hex color"""
    rgba = rgba_from_argb(argb)
    return "#{:02X}{:02X}{:02X}".format(*map(round, rgba))


def generate_yazi_colors(material_colors: dict, term_colors: dict, darkmode: bool = True) -> dict:
    """
    Generate Yazi theme with vibrant file type colors

    Args:
        material_colors: Dict of Material You colors
        term_colors: Dict of terminal colors
        darkmode: Whether in dark mode

    Returns:
        Dict of Yazi color definitions
    """
    # Get the accent for harmonization
    accent_argb = hex_to_argb(material_colors['primary_paletteKeyColor'])
    accent_hct = Hct.from_int(accent_argb)
    base_hue = accent_hct.hue
    base_chroma = accent_hct.chroma

    # Tone values adjusted for dark/light mode
    # In dark mode: lighter tones (70-85) for visibility on dark background
    # In light mode: darker tones (40-60) for visibility on light background
    if darkmode:
        base_tone = 78
        tone_range = (70, 85)
        chroma_multiplier = 1.2
    else:
        base_tone = 50
        tone_range = (40, 60)
        chroma_multiplier = 1.0

    # Use higher chroma for more vibrant colors
    min_chroma = max(base_chroma * 0.9, 55)
    max_chroma = min(base_chroma * chroma_multiplier, 90)

    # Create diverse, vibrant colors for different file types
    yazi_colors = {}

    # Directories - use primary color but boost it
    dir_hct = Hct.from_int(hex_to_argb(material_colors.get('primary', term_colors.get('term4', '#89b4fa'))))
    yazi_colors['dir_fg'] = argb_to_hex(Hct.from_hct(dir_hct.hue, max(dir_hct.chroma, 65), base_tone + 2).to_int())

    # Code files - stay very close to base purple (just slightly shifted)
    code_hue = (base_hue + 10) % 360  # Very close to purple
    code_hct = Hct.from_hct(code_hue, min(max_chroma, 70), base_tone + 3)
    yazi_colors['code_fg'] = argb_to_hex(code_hct.to_int())

    # Executables - slightly warmer than code files
    exec_hue = (base_hue + 30) % 360
    exec_hct = Hct.from_hct(exec_hue, min(max_chroma, 75), tone_range[1])
    yazi_colors['exec_fg'] = argb_to_hex(exec_hct.to_int())

    # Archives - warm amber (but not too far)
    archive_hue = (base_hue + 50) % 360
    archive_hct = Hct.from_hct(archive_hue, min(max_chroma, 80), tone_range[1] - 2)
    yazi_colors['archive_fg'] = argb_to_hex(archive_hct.to_int())

    # Images - pink/magenta side
    image_hue = (base_hue - 30) % 360
    image_hct = Hct.from_hct(image_hue, min(max_chroma, 75), base_tone)
    yazi_colors['image_fg'] = argb_to_hex(image_hct.to_int())

    # Audio - warm peachy
    audio_hue = (base_hue + 40) % 360
    audio_hct = Hct.from_hct(audio_hue, min(max_chroma, 75), tone_range[1])
    yazi_colors['audio_fg'] = argb_to_hex(audio_hct.to_int())

    # Documents - cooler blue-purple
    doc_hue = (base_hue - 20) % 360
    doc_hct = Hct.from_hct(doc_hue, min(min_chroma, 65), tone_range[1] + 2)
    yazi_colors['doc_fg'] = argb_to_hex(doc_hct.to_int())

    # Video - cyan/teal
    video_hue = (base_hue + 140) % 360
    video_hct = Hct.from_hct(video_hue, min(max_chroma, 70), tone_range[1] - 3)
    yazi_colors['video_fg'] = argb_to_hex(video_hct.to_int())

    # Links - bright cyan
    link_hue = (base_hue + 150) % 360
    link_hct = Hct.from_hct(link_hue, min(max_chroma, 78), tone_range[1] + 3)
    yazi_colors['link_fg'] = argb_to_hex(link_hct.to_int())

    # Special files - reddish (for warnings/errors)
    special_hue = (base_hue + 200) % 360
    special_hct = Hct.from_hct(special_hue, min(max_chroma, 75), tone_range[0] + 2)
    yazi_colors['special_fg'] = argb_to_hex(special_hct.to_int())

    # UI colors - use material colors but ensure they're visible
    outline_hct = Hct.from_int(hex_to_argb(material_colors.get('outline', term_colors.get('term7', '#cdd6f4'))))
    yazi_colors['border_fg'] = argb_to_hex(Hct.from_hct(outline_hct.hue, outline_hct.chroma, 65 if darkmode else 50).to_int())

    # Selected background - use primary container but adjust tone
    primary_container_hct = Hct.from_int(hex_to_argb(material_colors.get('primaryContainer', term_colors.get('term0', '#1e1e2e'))))
    yazi_colors['selected_bg'] = argb_to_hex(Hct.from_hct(primary_container_hct.hue, max(primary_container_hct.chroma, 40), 25 if darkmode else 85).to_int())

    # Hovered background - slightly lighter/darker than selected
    yazi_colors['hovered_bg'] = argb_to_hex(Hct.from_hct(primary_container_hct.hue, max(primary_container_hct.chroma, 35), 20 if darkmode else 90).to_int())

    return yazi_colors


def write_yazi_theme(yazi_colors: dict, output_path: str = None, debug: bool = False) -> str:
    """
    Write Yazi theme configuration file

    Args:
        yazi_colors: Dict of color definitions
        output_path: Optional custom output path
        debug: Enable debug output

    Returns:
        Path to written config file
    """
    if output_path is None:
        yazi_config_dir = Path.home() / '.config' / 'yazi'
        yazi_config_dir.mkdir(parents=True, exist_ok=True)
        output_path = str(yazi_config_dir / 'theme.toml')

    theme_content = f'''# Auto-generated Yazi theme (Material You - Improved)

[filetype]

rules = [
    # Images
    {{ mime = "image/*", fg = "{yazi_colors['image_fg']}" }},

    # Videos
    {{ mime = "video/*", fg = "{yazi_colors['video_fg']}" }},

    # Audio
    {{ mime = "audio/*", fg = "{yazi_colors['audio_fg']}" }},

    # Archives
    {{ mime = "application/*zip", fg = "{yazi_colors['archive_fg']}" }},
    {{ mime = "application/*tar", fg = "{yazi_colors['archive_fg']}" }},
    {{ mime = "application/*rar", fg = "{yazi_colors['archive_fg']}" }},
    {{ mime = "application/x-7z-compressed", fg = "{yazi_colors['archive_fg']}" }},
    {{ mime = "application/gzip", fg = "{yazi_colors['archive_fg']}" }},

    # Documents
    {{ mime = "application/pdf", fg = "{yazi_colors['doc_fg']}" }},
    {{ mime = "text/*", fg = "{yazi_colors['doc_fg']}" }},

    # Code files - explicit rules for common extensions
    {{ name = "*.py", fg = "{yazi_colors['code_fg']}" }},
    {{ name = "*.js", fg = "{yazi_colors['code_fg']}" }},
    {{ name = "*.ts", fg = "{yazi_colors['code_fg']}" }},
    {{ name = "*.jsx", fg = "{yazi_colors['code_fg']}" }},
    {{ name = "*.tsx", fg = "{yazi_colors['code_fg']}" }},
    {{ name = "*.rs", fg = "{yazi_colors['code_fg']}" }},
    {{ name = "*.go", fg = "{yazi_colors['code_fg']}" }},
    {{ name = "*.c", fg = "{yazi_colors['code_fg']}" }},
    {{ name = "*.cpp", fg = "{yazi_colors['code_fg']}" }},
    {{ name = "*.h", fg = "{yazi_colors['code_fg']}" }},
    {{ name = "*.hpp", fg = "{yazi_colors['code_fg']}" }},
    {{ name = "*.java", fg = "{yazi_colors['code_fg']}" }},
    {{ name = "*.rb", fg = "{yazi_colors['code_fg']}" }},
    {{ name = "*.sh", fg = "{yazi_colors['code_fg']}" }},
    {{ name = "*.bash", fg = "{yazi_colors['code_fg']}" }},
    {{ name = "*.zsh", fg = "{yazi_colors['code_fg']}" }},
    {{ name = "*.vim", fg = "{yazi_colors['code_fg']}" }},
    {{ name = "*.lua", fg = "{yazi_colors['code_fg']}" }},

    # Markup/Config files
    {{ name = "*.html", fg = "{yazi_colors['doc_fg']}" }},
    {{ name = "*.css", fg = "{yazi_colors['code_fg']}" }},
    {{ name = "*.scss", fg = "{yazi_colors['code_fg']}" }},
    {{ name = "*.json", fg = "{yazi_colors['archive_fg']}" }},
    {{ name = "*.yaml", fg = "{yazi_colors['archive_fg']}" }},
    {{ name = "*.yml", fg = "{yazi_colors['archive_fg']}" }},
    {{ name = "*.toml", fg = "{yazi_colors['archive_fg']}" }},
    {{ name = "*.xml", fg = "{yazi_colors['doc_fg']}" }},
    {{ name = "*.md", fg = "{yazi_colors['doc_fg']}" }},

    # Fallback
    {{ name = "*", fg = "{yazi_colors['border_fg']}" }},
    {{ name = "*/", fg = "{yazi_colors['dir_fg']}" }},
]

[manager]
cwd = {{ fg = "{yazi_colors['dir_fg']}" }}

# Hovered
hovered = {{ fg = "black", bg = "{yazi_colors['dir_fg']}" }}
preview_hovered = {{ underline = true }}

# Find
find_keyword  = {{ fg = "{yazi_colors['archive_fg']}", bold = true }}
find_position = {{ fg = "{yazi_colors['image_fg']}", bg = "reset", bold = true }}

# Marker
marker_selected = {{ fg = "{yazi_colors['dir_fg']}", bg = "{yazi_colors['dir_fg']}" }}
marker_copied   = {{ fg = "{yazi_colors['code_fg']}", bg = "{yazi_colors['code_fg']}" }}
marker_cut      = {{ fg = "{yazi_colors['special_fg']}", bg = "{yazi_colors['special_fg']}" }}

# Tab
tab_active   = {{ fg = "black", bg = "{yazi_colors['dir_fg']}" }}
tab_inactive = {{ fg = "{yazi_colors['border_fg']}", bg = "reset" }}
tab_width    = 1

# Border
border_symbol = "│"
border_style  = {{ fg = "{yazi_colors['border_fg']}" }}

# Highlighting
syntect_theme = ""

[status]
separator_open  = ""
separator_close = ""
separator_style = {{ fg = "{yazi_colors['border_fg']}", bg = "{yazi_colors['border_fg']}" }}

# Mode
mode_normal = {{ fg = "black", bg = "{yazi_colors['dir_fg']}", bold = true }}
mode_select = {{ fg = "black", bg = "{yazi_colors['code_fg']}", bold = true }}
mode_unset  = {{ fg = "black", bg = "{yazi_colors['archive_fg']}", bold = true }}

# Progress
progress_label  = {{ fg = "{yazi_colors['border_fg']}", bold = true }}
progress_normal = {{ fg = "{yazi_colors['dir_fg']}", bg = "reset" }}
progress_error  = {{ fg = "{yazi_colors['special_fg']}", bg = "reset" }}

# Permissions
permissions_t = {{ fg = "{yazi_colors['exec_fg']}" }}
permissions_r = {{ fg = "{yazi_colors['doc_fg']}" }}
permissions_w = {{ fg = "{yazi_colors['archive_fg']}" }}
permissions_x = {{ fg = "{yazi_colors['exec_fg']}" }}
permissions_s = {{ fg = "{yazi_colors['border_fg']}" }}

[input]
border   = {{ fg = "{yazi_colors['dir_fg']}" }}
title    = {{}}
value    = {{}}
selected = {{ reversed = true }}

[select]
border   = {{ fg = "{yazi_colors['dir_fg']}" }}
active   = {{ fg = "{yazi_colors['dir_fg']}" }}
inactive = {{}}

[tasks]
border  = {{ fg = "{yazi_colors['dir_fg']}" }}
title   = {{}}
hovered = {{ underline = true }}

[which]
mask            = {{ bg = "black" }}
cand            = {{ fg = "{yazi_colors['code_fg']}" }}
rest            = {{ fg = "{yazi_colors['border_fg']}" }}
desc            = {{ fg = "{yazi_colors['doc_fg']}" }}
separator       = "  "
separator_style = {{ fg = "{yazi_colors['border_fg']}" }}

[help]
on      = {{ fg = "{yazi_colors['dir_fg']}" }}
exec    = {{ fg = "{yazi_colors['exec_fg']}" }}
desc    = {{ fg = "{yazi_colors['border_fg']}" }}
hovered = {{ bg = "{yazi_colors['hovered_bg']}", bold = true }}
footer  = {{ fg = "black", bg = "{yazi_colors['border_fg']}" }}

[completion]
border   = {{ fg = "{yazi_colors['dir_fg']}" }}
active   = {{ bg = "{yazi_colors['hovered_bg']}" }}
inactive = {{}}
'''

    with open(output_path, 'w') as f:
        f.write(theme_content)

    if debug:
        print(f"Yazi theme written to: {output_path}")

    return output_path


if __name__ == "__main__":
    print("This module should be imported, not run directly.")
    print("Use: from generate_yazi_theme import generate_yazi_colors, write_yazi_theme")
