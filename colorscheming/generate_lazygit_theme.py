#!/usr/bin/env python3
"""
LazyGit Theme Generator
Generates LazyGit configuration with Material You colors
"""
import os
import subprocess
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


def generate_lazygit_colors(material_colors: dict, term_colors: dict, darkmode: bool = True) -> dict:
    """
    Generate LazyGit color scheme

    Args:
        material_colors: Dict of Material You colors
        term_colors: Dict of terminal colors
        darkmode: Whether to use dark mode

    Returns:
        Dict of LazyGit color definitions
    """
    lazygit_colors = {}

    # Get primary hue for consistency
    primary_hct = Hct.from_int(hex_to_argb(material_colors['primary_paletteKeyColor']))
    base_hue = primary_hct.hue

    # Selection background - darker, more saturated purple
    lazygit_colors['selectedLineBg'] = argb_to_hex(
        Hct.from_hct(base_hue, min(primary_hct.chroma * 1.6, 65), 15 if darkmode else 88).to_int()
    )

    # Selected range - darker medium purple
    lazygit_colors['selectedRangeBg'] = argb_to_hex(
        Hct.from_hct(base_hue, min(primary_hct.chroma * 1.5, 60), 22 if darkmode else 82).to_int()
    )

    # Inactive border - desaturated purple
    lazygit_colors['inactiveBorder'] = argb_to_hex(
        Hct.from_hct(base_hue, primary_hct.chroma * 0.6, 40 if darkmode else 55).to_int()
    )

    # Active border - vibrant purple
    lazygit_colors['activeBorder'] = argb_to_hex(
        Hct.from_hct(base_hue, min(primary_hct.chroma * 1.5, 85), 70 if darkmode else 45).to_int()
    )

    # Options text - bright purple
    lazygit_colors['optionsText'] = argb_to_hex(
        Hct.from_hct(base_hue + 5, min(primary_hct.chroma * 1.4, 75), 75 if darkmode else 40).to_int()
    )

    # Default foreground - light purple-tinted white
    lazygit_colors['defaultFg'] = argb_to_hex(
        Hct.from_hct(base_hue, min(primary_hct.chroma * 0.2, 18), 88 if darkmode else 25).to_int()
    )

    # Cherry picked - slightly shifted purple
    lazygit_colors['cherryPickedBg'] = argb_to_hex(
        Hct.from_hct(base_hue - 10, min(primary_hct.chroma * 1.4, 60), 32 if darkmode else 78).to_int()
    )
    lazygit_colors['cherryPickedFg'] = argb_to_hex(
        Hct.from_hct(base_hue - 10, 12, 90 if darkmode else 20).to_int()
    )

    # DIFF COLORS - Subtle purple-tinted versions
    # Deletions (red) - desaturated red-purple, subtle
    lazygit_colors['unstagedChanges'] = argb_to_hex(
        Hct.from_hct(
            base_hue - 12,  # Slight shift towards red
            min(primary_hct.chroma * 0.8, 45),  # Low saturation
            58 if darkmode else 52
        ).to_int()
    )

    # Additions (green) - desaturated blue-purple/teal, subtle
    lazygit_colors['stagedChanges'] = argb_to_hex(
        Hct.from_hct(
            base_hue + 25,  # Slight shift towards cyan
            min(primary_hct.chroma * 0.9, 48),  # Low saturation
            62 if darkmode else 48
        ).to_int()
    )

    # Modified/changed sections - use term3 (light purple)
    lazygit_colors['diffModified'] = term_colors['term3']

    # Context lines - use term7 (normal text)
    lazygit_colors['diffContext'] = term_colors['term7']

    # Search / diff emphasis - soft purple
    lazygit_colors['searchMatching'] = argb_to_hex(
        Hct.from_hct(
            base_hue + 8,
            min(primary_hct.chroma * 1.2, 65),
            72 if darkmode else 55
        ).to_int()
    )

    # Default text color - use term7
    lazygit_colors['defaultText'] = term_colors['term7']

    # Conflict colors - all subtle purples
    lazygit_colors['conflictOurs'] = argb_to_hex(
        Hct.from_hct(base_hue + 20, min(primary_hct.chroma * 0.85, 50), 60 if darkmode else 50).to_int()
    )
    lazygit_colors['conflictTheirs'] = argb_to_hex(
        Hct.from_hct(base_hue - 15, min(primary_hct.chroma * 0.85, 50), 56 if darkmode else 48).to_int()
    )
    lazygit_colors['conflictBase'] = term_colors['term3']

    return lazygit_colors


def write_lazygit_config(lazygit_colors: dict, output_path: str = None, debug: bool = False) -> str:
    """
    Write LazyGit configuration file

    Args:
        lazygit_colors: Dict of LazyGit color definitions
        output_path: Optional custom output path
        debug: Enable debug output

    Returns:
        Path to the written config file
    """
    if output_path is None:
        lazygit_config_dir = Path.home() / '.config' / 'lazygit'
        lazygit_config_dir.mkdir(parents=True, exist_ok=True)
        output_path = str(lazygit_config_dir / 'config.yml')

    lazygit_config = f'''# Auto-generated LazyGit theme colors
gui:
  theme:
    activeBorderColor:
      - "{lazygit_colors['activeBorder']}"
      - bold
    inactiveBorderColor:
      - "{lazygit_colors['inactiveBorder']}"
    optionsTextColor:
      - "{lazygit_colors['optionsText']}"
    selectedLineBgColor:
      - "{lazygit_colors['selectedLineBg']}"
    selectedRangeBgColor:
      - "{lazygit_colors['selectedRangeBg']}"
    cherryPickedCommitBgColor:
      - "{lazygit_colors['cherryPickedBg']}"
    cherryPickedCommitFgColor:
      - "{lazygit_colors['cherryPickedFg']}"
    unstagedChangesColor:
      - "{lazygit_colors['unstagedChanges']}"
    defaultFgColor:
      - "{lazygit_colors['defaultFg']}"
    searchingActiveBorderColor:
      - "{lazygit_colors['searchMatching']}"

  nerdFontsVersion: "3"
  showFileTree: true
  showRandomTip: false

# Git diff settings with custom colors
git:
  paging:
    colorArg: always
    useConfig: false
    # Using delta for better diff rendering
    pager: delta --dark --paging=never --line-numbers --minus-style='syntax "{lazygit_colors['unstagedChanges']}"' --minus-emph-style='syntax "{lazygit_colors['unstagedChanges']}"' --plus-style='syntax "{lazygit_colors['stagedChanges']}"' --plus-emph-style='syntax "{lazygit_colors['stagedChanges']}"' --hunk-header-style='file line-number syntax'
'''

    with open(output_path, 'w') as f:
        f.write(lazygit_config)

    if debug:
        print(f"\nLazyGit config written to: {output_path}")
        print("Note: You may need to install 'delta' for best diff rendering:")
        print("  cargo install git-delta")
        print("  or: brew install git-delta")

    return output_path


def configure_git_diff_colors(lazygit_colors: dict, term_colors: dict, debug: bool = False):
    """
    Configure git global config with matching diff colors

    Args:
        lazygit_colors: Dict of LazyGit colors
        term_colors: Dict of terminal colors
        debug: Enable debug output
    """
    # Use the same colors we generated for LazyGit diffs
    git_diff_colors = {
        'old': lazygit_colors['unstagedChanges'],
        'new': lazygit_colors['stagedChanges'],
        'meta': term_colors['term4'],  # Purple info color
        'frag': term_colors['term4'],  # Purple info color
        'commit': term_colors['term5'], # Pink-purple
    }

    # Set git config colors
    try:
        for key, color in git_diff_colors.items():
            subprocess.run(
                ['git', 'config', '--global', f'color.diff.{key}', color],
                check=True
            )

        # Also set diff-highlight colors (for better diffs)
        subprocess.run(['git', 'config', '--global', 'color.diff-highlight.oldNormal', git_diff_colors['old']], check=True)
        subprocess.run(['git', 'config', '--global', 'color.diff-highlight.newNormal', git_diff_colors['new']], check=True)

        # Status colors
        subprocess.run(['git', 'config', '--global', 'color.status.added', git_diff_colors['new']], check=True)
        subprocess.run(['git', 'config', '--global', 'color.status.deleted', git_diff_colors['old']], check=True)
        subprocess.run(['git', 'config', '--global', 'color.status.changed', git_diff_colors['meta']], check=True)

        if debug:
            print("\nGit diff colors configured:")
            print(f"  Deletions (red): {git_diff_colors['old']}")
            print(f"  Additions (green): {git_diff_colors['new']}")
            print(f"  Metadata: {git_diff_colors['meta']}")
    except subprocess.CalledProcessError as e:
        if debug:
            print(f"Warning: Could not set git config colors: {e}")
    except FileNotFoundError:
        if debug:
            print("Warning: git command not found, skipping git color configuration")


if __name__ == "__main__":
    print("This module should be imported, not run directly.")
    print("Use: from generate_lazygit_theme import generate_lazygit_colors, write_lazygit_config")
