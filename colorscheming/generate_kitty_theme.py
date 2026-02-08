#!/usr/bin/env python3
"""
Kitty Terminal Theme Generator
Generates Kitty terminal color configuration with Material You colors
"""
from pathlib import Path


def write_kitty_colors(term_colors: dict, material_colors: dict = None, output_path: str = None, debug: bool = False) -> str:
    """
    Write Kitty terminal color configuration

    Args:
        term_colors: Dict of terminal colors (term0-term15)
        material_colors: Optional dict of Material You colors (uses surface/onSurface for bg/fg if provided)
        output_path: Optional custom output path
        debug: Enable debug output

    Returns:
        Path to the written config file
    """
    if output_path is None:
        kitty_config_dir = Path.home() / '.config' / 'kitty'
        kitty_config_dir.mkdir(parents=True, exist_ok=True)
        output_path = str(kitty_config_dir / 'current-theme.conf')

    # Use Material You colors for background/foreground if available, otherwise fallback to term colors
    if material_colors:
        background = material_colors.get('surface', term_colors["term0"])
        foreground = material_colors.get('onSurface', term_colors["term7"])
        selection_bg = material_colors.get('primaryContainer', term_colors["term12"])
        tab_bg = material_colors.get('surfaceContainerLow', term_colors["term0"])
        active_tab_bg = material_colors.get('surfaceContainerHigh', term_colors["term8"])
    else:
        background = term_colors["term0"]
        foreground = term_colors["term7"]
        selection_bg = term_colors["term12"]
        tab_bg = term_colors["term0"]
        active_tab_bg = term_colors["term8"]

    with open(output_path, 'w') as f:
        f.write('# Auto-generated Kitty colors (Material You theme)\n\n')

        # Main colors with opacity support
        f.write('# Main colors\n')
        f.write(f'background {background}\n')
        f.write(f'foreground {foreground}\n')

        # Cursor colors
        f.write('\n# Cursor colors\n')
        f.write(f'cursor {foreground}\n')
        f.write(f'cursor_text_color {background}\n')

        # Selection colors
        f.write('\n# Selection colors\n')
        f.write(f'selection_foreground {background}\n')
        f.write(f'selection_background {selection_bg}\n')

        # URL colors
        f.write('\n# URL underline color\n')
        f.write(f'url_color {term_colors["term12"]}\n')

        # Tab bar colors
        f.write('\n# Tab bar colors\n')
        f.write(f'active_tab_foreground {foreground}\n')
        f.write(f'active_tab_background {active_tab_bg}\n')
        f.write(f'inactive_tab_foreground {foreground}\n')
        f.write(f'inactive_tab_background {tab_bg}\n')
        f.write(f'tab_bar_background {background}\n')

        # Mark colors
        f.write('\n# Marks\n')
        f.write(f'mark1_foreground {background}\n')
        f.write(f'mark1_background {term_colors["term12"]}\n')
        f.write(f'mark2_foreground {background}\n')
        f.write(f'mark2_background {term_colors["term13"]}\n')
        f.write(f'mark3_foreground {background}\n')
        f.write(f'mark3_background {term_colors["term14"]}\n')

        # Terminal colors
        f.write('\n# Terminal ANSI colors\n')
        for i in range(16):
            f.write(f'color{i} {term_colors[f"term{i}"]}\n')

    if debug:
        print(f"\nKitty color config written to: {output_path}")

    return output_path


if __name__ == "__main__":
    print("This module should be imported, not run directly.")
    print("Use: from generate_kitty_theme import write_kitty_colors")
