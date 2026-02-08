#!/usr/bin/env python3
"""
FZF Theme Generator
Generates FZF color configuration with Material You colors
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


def generate_fzf_colors(material_colors: dict, term_colors: dict, darkmode: bool = True) -> dict:
    """
    Generate FZF color scheme

    Args:
        material_colors: Dict of Material You colors
        term_colors: Dict of terminal colors
        darkmode: Whether to use dark mode

    Returns:
        Dict of FZF color definitions
    """
    # Get primary hue for consistency
    primary_hct = Hct.from_int(hex_to_argb(material_colors['primary_paletteKeyColor']))
    base_hue = primary_hct.hue
    
    fzf_colors = {}
    
    # Background colors
    fzf_colors['bg'] = term_colors['term0']  # Main background
    fzf_colors['bg+'] = argb_to_hex(  # Selected line background
        Hct.from_hct(base_hue, min(primary_hct.chroma * 1.4, 55), 18 if darkmode else 85).to_int()
    )
    
    # Foreground colors
    fzf_colors['fg'] = term_colors['term7']  # Normal text
    fzf_colors['fg+'] = argb_to_hex(  # Selected line text (brighter)
        Hct.from_hct(base_hue, min(primary_hct.chroma * 0.3, 20), 92 if darkmode else 20).to_int()
    )
    
    # Border and UI elements
    fzf_colors['border'] = argb_to_hex(
        Hct.from_hct(base_hue, primary_hct.chroma * 0.7, 45 if darkmode else 60).to_int()
    )
    fzf_colors['separator'] = fzf_colors['border']
    
    # Header
    fzf_colors['header'] = argb_to_hex(
        Hct.from_hct(base_hue + 5, min(primary_hct.chroma * 1.3, 70), 75 if darkmode else 40).to_int()
    )
    
    # Info line
    fzf_colors['info'] = term_colors['term4']  # Purple
    
    # Prompt and pointer
    fzf_colors['prompt'] = argb_to_hex(
        Hct.from_hct(base_hue, min(primary_hct.chroma * 1.4, 80), 72 if darkmode else 42).to_int()
    )
    fzf_colors['pointer'] = argb_to_hex(  # Current selection pointer
        Hct.from_hct(base_hue - 5, min(primary_hct.chroma * 1.5, 85), 78 if darkmode else 38).to_int()
    )
    
    # Marker (multi-select)
    fzf_colors['marker'] = argb_to_hex(
        Hct.from_hct(base_hue + 15, min(primary_hct.chroma * 1.3, 75), 70 if darkmode else 45).to_int()
    )
    
    # Spinner (loading)
    fzf_colors['spinner'] = term_colors['term5']  # Pink-purple
    
    # Match highlighting
    fzf_colors['hl'] = argb_to_hex(  # Matched characters
        Hct.from_hct(base_hue + 10, min(primary_hct.chroma * 1.5, 85), 80 if darkmode else 35).to_int()
    )
    fzf_colors['hl+'] = argb_to_hex(  # Matched characters in selected line
        Hct.from_hct(base_hue + 12, min(primary_hct.chroma * 1.6, 90), 85 if darkmode else 30).to_int()
    )
    
    # Query (search text)
    fzf_colors['query'] = term_colors['term7']
    
    # Scrollbar
    fzf_colors['scrollbar'] = argb_to_hex(
        Hct.from_hct(base_hue, primary_hct.chroma * 0.5, 35 if darkmode else 70).to_int()
    )
    
    # Label
    fzf_colors['label'] = argb_to_hex(
        Hct.from_hct(base_hue - 5, min(primary_hct.chroma * 1.2, 65), 68 if darkmode else 48).to_int()
    )
    
    return fzf_colors


def write_fzf_config(fzf_colors: dict, output_path: str = None, debug: bool = False) -> str:
    """
    Write FZF configuration to shell config files

    Args:
        fzf_colors: Dict of FZF color definitions
        output_path: Optional custom output path
        debug: Enable debug output

    Returns:
        Path to the written config file
    """
    if output_path is None:
        fzf_config_dir = Path.home() / '.config' / 'fzf'
        fzf_config_dir.mkdir(parents=True, exist_ok=True)
        output_path = str(fzf_config_dir / 'colors.sh')
    
    # Build the FZF_DEFAULT_OPTS color string
    color_parts = [
        f"bg:{fzf_colors['bg']}",
        f"bg+:{fzf_colors['bg+']}",
        f"fg:{fzf_colors['fg']}",
        f"fg+:{fzf_colors['fg+']}",
        f"border:{fzf_colors['border']}",
        f"separator:{fzf_colors['separator']}",
        f"header:{fzf_colors['header']}",
        f"info:{fzf_colors['info']}",
        f"prompt:{fzf_colors['prompt']}",
        f"pointer:{fzf_colors['pointer']}",
        f"marker:{fzf_colors['marker']}",
        f"spinner:{fzf_colors['spinner']}",
        f"hl:{fzf_colors['hl']}",
        f"hl+:{fzf_colors['hl+']}",
        f"query:{fzf_colors['query']}",
        f"scrollbar:{fzf_colors['scrollbar']}",
        f"label:{fzf_colors['label']}"
    ]
    
    color_string = ','.join(color_parts)
    
    fzf_config = f'''# Auto-generated FZF colors (Material You theme)
# Source this file in your shell config (.bashrc, .zshrc, config.fish, etc.)

export FZF_DEFAULT_OPTS="\\
  --color={color_string} \\
  --border=rounded \\
  --preview-window=border-rounded \\
  --prompt='❯ ' \\
  --pointer='â–¶' \\
  --marker='✓'"
'''
    
    with open(output_path, 'w') as f:
        f.write(fzf_config)
    
    if debug:
        print(f"\nFZF color config written to: {output_path}")
        print("\nTo use these colors, add this to your shell config:")
        print(f"  source {output_path}")
        print("\nFor fish shell, also create a fish-compatible version")
    
    # Also create a fish-compatible version
    fish_output = str(Path(output_path).parent / 'colors.fish')
    fish_config = f'''# Auto-generated FZF colors (Material You theme) for Fish shell
# Source this file in your config.fish

set -gx FZF_DEFAULT_OPTS "\\
  --color={color_string} \\
  --border=rounded \\
  --preview-window=border-rounded \\
  --prompt='❯ ' \\
  --pointer='â–¶' \\
  --marker='✓'"
'''
    
    with open(fish_output, 'w') as f:
        f.write(fish_config)
    
    if debug:
        print(f"Fish-compatible config written to: {fish_output}")
    
    return output_path


if __name__ == "__main__":
    print("This module should be imported, not run directly.")
    print("Use: from generate_fzf_theme import generate_fzf_colors, write_fzf_config")
