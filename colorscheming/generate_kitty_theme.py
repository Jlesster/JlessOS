#!/usr/bin/env python3
"""
Kitty Terminal Theme Generator
Generates Kitty terminal color configuration with Material You colors
"""
from pathlib import Path


def write_kitty_colors(term_colors: dict, output_path: str = None, debug: bool = False) -> str:
    """
    Write Kitty terminal color configuration

    Args:
        term_colors: Dict of terminal colors (term0-term15)
        output_path: Optional custom output path
        debug: Enable debug output

    Returns:
        Path to the written config file
    """
    if output_path is None:
        kitty_config_dir = Path.home() / '.config' / 'kitty'
        kitty_config_dir.mkdir(parents=True, exist_ok=True)
        output_path = str(kitty_config_dir / 'current-theme.conf')

    with open(output_path, 'w') as f:
        f.write('# Auto-generated Kitty colors (Material You theme)\n')
        f.write(f'background {term_colors["term0"]}\n')
        f.write(f'foreground {term_colors["term7"]}\n')
        f.write('\n# Terminal colors\n')
        for i in range(16):
            f.write(f'color{i} {term_colors[f"term{i}"]}\n')

    if debug:
        print(f"\nKitty color config written to: {output_path}")

    return output_path


if __name__ == "__main__":
    print("This module should be imported, not run directly.")
    print("Use: from generate_kitty_theme import write_kitty_colors")
