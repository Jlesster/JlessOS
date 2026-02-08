#!/usr/bin/env python3
"""
Btop Theme Generator
Generates Btop system monitor configuration with Material You colors
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


def generate_btop_colors(material_colors: dict, term_colors: dict, darkmode: bool = True) -> dict:
    """
    Generate Btop color scheme

    Args:
        material_colors: Dict of Material You colors
        term_colors: Dict of terminal colors
        darkmode: Whether to use dark mode

    Returns:
        Dict of Btop color definitions
    """
    # Get primary hue for consistency
    primary_hct = Hct.from_int(hex_to_argb(material_colors['primary_paletteKeyColor']))
    base_hue = primary_hct.hue
    
    btop_colors = {}
    
    # Main background and foreground
    btop_colors['main_bg'] = term_colors['term0']
    btop_colors['main_fg'] = term_colors['term7']
    
    # Title
    btop_colors['title'] = argb_to_hex(
        Hct.from_hct(base_hue, min(primary_hct.chroma * 1.4, 80), 78 if darkmode else 38).to_int()
    )
    
    # Highlight colors (selected items, active elements)
    btop_colors['hi_fg'] = argb_to_hex(
        Hct.from_hct(base_hue + 5, min(primary_hct.chroma * 1.5, 85), 85 if darkmode else 30).to_int()
    )
    
    # Inactive/disabled text
    btop_colors['inactive_fg'] = argb_to_hex(
        Hct.from_hct(base_hue, primary_hct.chroma * 0.3, 55 if darkmode else 60).to_int()
    )
    
    # Process states - create a gradient of purples
    btop_colors['proc_misc'] = argb_to_hex(  # Process misc info
        Hct.from_hct(base_hue - 10, min(primary_hct.chroma * 1.2, 70), 70 if darkmode else 45).to_int()
    )
    
    # CPU colors - gradient from cool to warm purples
    btop_colors['cpu_box'] = argb_to_hex(
        Hct.from_hct(base_hue, min(primary_hct.chroma * 1.3, 75), 65 if darkmode else 50).to_int()
    )
    btop_colors['cpu_start'] = argb_to_hex(  # Low usage
        Hct.from_hct(base_hue + 20, min(primary_hct.chroma * 1.1, 60), 68 if darkmode else 48).to_int()
    )
    btop_colors['cpu_mid'] = argb_to_hex(  # Medium usage
        Hct.from_hct(base_hue, min(primary_hct.chroma * 1.4, 75), 72 if darkmode else 42).to_int()
    )
    btop_colors['cpu_end'] = argb_to_hex(  # High usage
        Hct.from_hct(base_hue - 15, min(primary_hct.chroma * 1.5, 85), 75 if darkmode else 38).to_int()
    )
    
    # Memory colors - cooler purple tones
    btop_colors['mem_box'] = argb_to_hex(
        Hct.from_hct(base_hue + 15, min(primary_hct.chroma * 1.2, 70), 65 if darkmode else 50).to_int()
    )
    btop_colors['mem_start'] = argb_to_hex(
        Hct.from_hct(base_hue + 25, min(primary_hct.chroma * 1.0, 55), 65 if darkmode else 50).to_int()
    )
    btop_colors['mem_mid'] = argb_to_hex(
        Hct.from_hct(base_hue + 15, min(primary_hct.chroma * 1.3, 70), 70 if darkmode else 45).to_int()
    )
    btop_colors['mem_end'] = argb_to_hex(
        Hct.from_hct(base_hue + 5, min(primary_hct.chroma * 1.5, 80), 75 if darkmode else 40).to_int()
    )
    
    # Network colors - cyan-purple tones
    btop_colors['net_box'] = argb_to_hex(
        Hct.from_hct(base_hue + 140, min(primary_hct.chroma * 1.2, 70), 65 if darkmode else 50).to_int()
    )
    btop_colors['net_download'] = argb_to_hex(
        Hct.from_hct(base_hue + 150, min(primary_hct.chroma * 1.3, 75), 72 if darkmode else 42).to_int()
    )
    btop_colors['net_upload'] = argb_to_hex(
        Hct.from_hct(base_hue + 130, min(primary_hct.chroma * 1.3, 75), 70 if darkmode else 45).to_int()
    )
    
    # Disk colors - warm purple tones
    btop_colors['disk_box'] = argb_to_hex(
        Hct.from_hct(base_hue + 30, min(primary_hct.chroma * 1.2, 70), 65 if darkmode else 50).to_int()
    )
    btop_colors['disk_start'] = argb_to_hex(
        Hct.from_hct(base_hue + 40, min(primary_hct.chroma * 1.1, 60), 65 if darkmode else 50).to_int()
    )
    btop_colors['disk_mid'] = argb_to_hex(
        Hct.from_hct(base_hue + 30, min(primary_hct.chroma * 1.3, 70), 70 if darkmode else 45).to_int()
    )
    btop_colors['disk_end'] = argb_to_hex(
        Hct.from_hct(base_hue + 20, min(primary_hct.chroma * 1.5, 80), 75 if darkmode else 40).to_int()
    )
    
    # Graph colors - various purple shades
    btop_colors['graph_text'] = term_colors['term7']
    
    # Meter background
    btop_colors['meter_bg'] = argb_to_hex(
        Hct.from_hct(base_hue, primary_hct.chroma * 0.4, 20 if darkmode else 85).to_int()
    )
    
    # Divider lines
    btop_colors['div_line'] = argb_to_hex(
        Hct.from_hct(base_hue, primary_hct.chroma * 0.6, 35 if darkmode else 70).to_int()
    )
    
    return btop_colors


def write_btop_theme(btop_colors: dict, output_path: str = None, debug: bool = False) -> str:
    """
    Write Btop theme configuration file

    Args:
        btop_colors: Dict of Btop color definitions
        output_path: Optional custom output path
        debug: Enable debug output

    Returns:
        Path to the written config file
    """
    if output_path is None:
        btop_config_dir = Path.home() / '.config' / 'btop' / 'themes'
        btop_config_dir.mkdir(parents=True, exist_ok=True)
        output_path = str(btop_config_dir / 'material-you.theme')
    
    # Btop uses a specific theme format
    theme_content = f'''# Auto-generated Btop theme (Material You)
# Main background, empty for terminal default, need to be empty if you want transparent background
theme[main_bg]="{btop_colors['main_bg']}"

# Main text color
theme[main_fg]="{btop_colors['main_fg']}"

# Title color for boxes
theme[title]="{btop_colors['title']}"

# Highlight color for keyboard shortcuts
theme[hi_fg]="{btop_colors['hi_fg']}"

# Background color of selected item in processes box
theme[selected_bg]="{btop_colors['cpu_start']}"

# Foreground color of selected item in processes box
theme[selected_fg]="{btop_colors['hi_fg']}"

# Color of inactive/disabled text
theme[inactive_fg]="{btop_colors['inactive_fg']}"

# Color of text appearing on top of graphs, i.e. uptime and current network graph scaling
theme[graph_text]="{btop_colors['graph_text']}"

# Background color of the percentage meters
theme[meter_bg]="{btop_colors['meter_bg']}"

# Misc colors for processes box including mini cpu graphs, details memory graph and details status text
theme[proc_misc]="{btop_colors['proc_misc']}"

# CPU, Memory, Network and Proc box outline colors
theme[cpu_box]="{btop_colors['cpu_box']}"
theme[mem_box]="{btop_colors['mem_box']}"
theme[net_box]="{btop_colors['net_box']}"
theme[proc_box]="{btop_colors['cpu_box']}"

# Box divider line and small boxes line color
theme[div_line]="{btop_colors['div_line']}"

# Temperature graph color (Green -> Yellow -> Red)
theme[temp_start]="{btop_colors['cpu_start']}"
theme[temp_mid]="{btop_colors['cpu_mid']}"
theme[temp_end]="{btop_colors['cpu_end']}"

# CPU graph colors (Teal -> Lavender)
theme[cpu_start]="{btop_colors['cpu_start']}"
theme[cpu_mid]="{btop_colors['cpu_mid']}"
theme[cpu_end]="{btop_colors['cpu_end']}"

# Mem/Disk free meter (Mauve -> Lavender -> Blue)
theme[free_start]="{btop_colors['mem_start']}"
theme[free_mid]="{btop_colors['mem_mid']}"
theme[free_end]="{btop_colors['mem_end']}"

# Mem/Disk cached meter (Sapphire -> Lavender)
theme[cached_start]="{btop_colors['mem_start']}"
theme[cached_mid]="{btop_colors['mem_mid']}"
theme[cached_end]="{btop_colors['mem_end']}"

# Mem/Disk available meter (Peach -> Red)
theme[available_start]="{btop_colors['disk_start']}"
theme[available_mid]="{btop_colors['disk_mid']}"
theme[available_end]="{btop_colors['disk_end']}"

# Mem/Disk used meter (Green -> Sky)
theme[used_start]="{btop_colors['cpu_start']}"
theme[used_mid]="{btop_colors['cpu_mid']}"
theme[used_end]="{btop_colors['cpu_end']}"

# Download graph colors (Peach -> Red)
theme[download_start]="{btop_colors['net_download']}"
theme[download_mid]="{btop_colors['net_download']}"
theme[download_end]="{btop_colors['net_download']}"

# Upload graph colors (Green -> Sky)
theme[upload_start]="{btop_colors['net_upload']}"
theme[upload_mid]="{btop_colors['net_upload']}"
theme[upload_end]="{btop_colors['net_upload']}"

# Process box color gradient for threads, mem and cpu usage (Sapphire -> Mauve)
theme[process_start]="{btop_colors['cpu_start']}"
theme[process_mid]="{btop_colors['cpu_mid']}"
theme[process_end]="{btop_colors['cpu_end']}"
'''
    
    with open(output_path, 'w') as f:
        f.write(theme_content)
    
    if debug:
        print(f"\nBtop theme written to: {output_path}")
        print("\nTo use this theme:")
        print("1. Open btop")
        print("2. Press ESC to open menu")
        print("3. Select 'Options'")
        print("4. Set 'Color theme' to 'material-you'")
        print("   Or edit ~/.config/btop/btop.conf and set:")
        print('   color_theme = "material-you"')
    
    return output_path


if __name__ == "__main__":
    print("This module should be imported, not run directly.")
    print("Use: from generate_btop_theme import generate_btop_colors, write_btop_theme")
