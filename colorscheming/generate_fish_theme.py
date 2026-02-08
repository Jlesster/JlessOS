#!/usr/bin/env python3
"""
Fish Shell Theme Generator
Generates Fish shell color configuration with Material You colors
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


def hex_to_rgb(hex_code: str) -> str:
    """Convert hex color to RGB values for fish"""
    # Remove the # if present
    hex_code = hex_code.lstrip('#')
    # Convert to RGB
    r = int(hex_code[0:2], 16)
    g = int(hex_code[2:4], 16)
    b = int(hex_code[4:6], 16)
    return f"{r:02x}{g:02x}{b:02x}"


def generate_fish_colors(material_colors: dict, term_colors: dict, darkmode: bool = True) -> dict:
    """
    Generate Fish shell color scheme

    Args:
        material_colors: Dict of Material You colors
        term_colors: Dict of terminal colors
        darkmode: Whether to use dark mode

    Returns:
        Dict of Fish color definitions
    """
    # Get primary hue for consistency
    primary_hct = Hct.from_int(hex_to_argb(material_colors['primary_paletteKeyColor']))
    base_hue = primary_hct.hue
    
    fish_colors = {}
    
    # Normal text colors
    fish_colors['normal'] = term_colors['term7']
    
    # Command colors (what you type)
    fish_colors['command'] = argb_to_hex(
        Hct.from_hct(base_hue, min(primary_hct.chroma * 1.4, 80), 75 if darkmode else 40).to_int()
    )
    
    # Keywords (if, else, end, etc.)
    fish_colors['keyword'] = argb_to_hex(
        Hct.from_hct(base_hue - 10, min(primary_hct.chroma * 1.5, 85), 78 if darkmode else 38).to_int()
    )
    
    # Quotes (strings)
    fish_colors['quote'] = argb_to_hex(
        Hct.from_hct(base_hue + 25, min(primary_hct.chroma * 1.2, 70), 72 if darkmode else 42).to_int()
    )
    
    # Redirection (>, <, |, etc.)
    fish_colors['redirection'] = argb_to_hex(
        Hct.from_hct(base_hue + 15, min(primary_hct.chroma * 1.3, 75), 70 if darkmode else 45).to_int()
    )
    
    # End of command (;, &, etc.)
    fish_colors['end'] = argb_to_hex(
        Hct.from_hct(base_hue - 5, min(primary_hct.chroma * 1.2, 70), 68 if darkmode else 47).to_int()
    )
    
    # Errors
    fish_colors['error'] = argb_to_hex(
        Hct.from_hct((base_hue + 200) % 360, min(primary_hct.chroma * 1.4, 80), 72 if darkmode else 42).to_int()
    )
    
    # Parameters/arguments
    fish_colors['param'] = term_colors['term7']
    
    # Comments
    fish_colors['comment'] = argb_to_hex(
        Hct.from_hct(base_hue, primary_hct.chroma * 0.5, 50 if darkmode else 65).to_int()
    )
    
    # Selection background
    fish_colors['selection_bg'] = argb_to_hex(
        Hct.from_hct(base_hue, min(primary_hct.chroma * 1.3, 60), 22 if darkmode else 82).to_int()
    )
    
    # Operators (+, -, *, /, =, etc.)
    fish_colors['operator'] = argb_to_hex(
        Hct.from_hct(base_hue + 10, min(primary_hct.chroma * 1.3, 75), 73 if darkmode else 43).to_int()
    )
    
    # Escape sequences (\n, \t, etc.)
    fish_colors['escape'] = argb_to_hex(
        Hct.from_hct(base_hue + 140, min(primary_hct.chroma * 1.2, 70), 70 if darkmode else 45).to_int()
    )
    
    # Autosuggestions (grayed out suggestions)
    fish_colors['autosuggestion'] = argb_to_hex(
        Hct.from_hct(base_hue, primary_hct.chroma * 0.3, 45 if darkmode else 70).to_int()
    )
    
    # Valid paths
    fish_colors['valid_path'] = argb_to_hex(
        Hct.from_hct(base_hue + 5, min(primary_hct.chroma * 1.1, 65), 72 if darkmode else 43).to_int()
    )
    
    # Search match
    fish_colors['search_match'] = argb_to_hex(
        Hct.from_hct(base_hue + 30, min(primary_hct.chroma * 1.4, 80), 75 if darkmode else 40).to_int()
    )
    
    # Pager (completion menu) colors
    fish_colors['pager_prefix'] = argb_to_hex(
        Hct.from_hct(base_hue, min(primary_hct.chroma * 1.5, 85), 78 if darkmode else 38).to_int()
    )
    fish_colors['pager_completion'] = term_colors['term7']
    fish_colors['pager_description'] = argb_to_hex(
        Hct.from_hct(base_hue, primary_hct.chroma * 0.6, 60 if darkmode else 55).to_int()
    )
    fish_colors['pager_progress'] = argb_to_hex(
        Hct.from_hct(base_hue + 20, min(primary_hct.chroma * 1.3, 75), 70 if darkmode else 45).to_int()
    )
    fish_colors['pager_selected_bg'] = fish_colors['selection_bg']
    
    return fish_colors


def write_fish_theme(fish_colors: dict, output_path: str = None, debug: bool = False) -> str:
    """
    Write Fish shell theme configuration file

    Args:
        fish_colors: Dict of Fish color definitions
        output_path: Optional custom output path
        debug: Enable debug output

    Returns:
        Path to the written config file
    """
    if output_path is None:
        fish_config_dir = Path.home() / '.config' / 'fish' / 'conf.d'
        fish_config_dir.mkdir(parents=True, exist_ok=True)
        output_path = str(fish_config_dir / 'material_you_colors.fish')
    
    # Convert all colors to fish RGB format (without #)
    fish_rgb = {k: hex_to_rgb(v) for k, v in fish_colors.items()}
    
    theme_content = f'''# Auto-generated Fish shell colors (Material You theme)
# This file is sourced automatically by fish

# Syntax highlighting colors
set -g fish_color_normal {fish_rgb['normal']}
set -g fish_color_command {fish_rgb['command']}
set -g fish_color_keyword {fish_rgb['keyword']}
set -g fish_color_quote {fish_rgb['quote']}
set -g fish_color_redirection {fish_rgb['redirection']}
set -g fish_color_end {fish_rgb['end']}
set -g fish_color_error {fish_rgb['error']}
set -g fish_color_param {fish_rgb['param']}
set -g fish_color_comment {fish_rgb['comment']}
set -g fish_color_selection --background={fish_rgb['selection_bg']}
set -g fish_color_operator {fish_rgb['operator']}
set -g fish_color_escape {fish_rgb['escape']}
set -g fish_color_autosuggestion {fish_rgb['autosuggestion']}
set -g fish_color_valid_path {fish_rgb['valid_path']} --underline
set -g fish_color_search_match --background={fish_rgb['search_match']}

# Pager (completion menu) colors
set -g fish_pager_color_prefix {fish_rgb['pager_prefix']} --bold
set -g fish_pager_color_completion {fish_rgb['pager_completion']}
set -g fish_pager_color_description {fish_rgb['pager_description']}
set -g fish_pager_color_progress {fish_rgb['pager_progress']}
set -g fish_pager_color_selected_background --background={fish_rgb['pager_selected_bg']}

# Additional useful colors
set -g fish_color_cancel {fish_rgb['error']}
set -g fish_color_cwd {fish_rgb['command']}
set -g fish_color_cwd_root {fish_rgb['error']}
set -g fish_color_history_current {fish_rgb['search_match']} --bold
set -g fish_color_host {fish_rgb['quote']}
set -g fish_color_host_remote {fish_rgb['quote']}
set -g fish_color_match {fish_rgb['search_match']}
set -g fish_color_user {fish_rgb['command']}
'''
    
    with open(output_path, 'w') as f:
        f.write(theme_content)
    
    if debug:
        print(f"\nFish shell theme written to: {output_path}")
        print("\nThe colors will be applied automatically when you start a new fish session.")
        print("To apply immediately, run:")
        print(f"  source {output_path}")
    
    return output_path


def write_fish_prompt(material_colors: dict, term_colors: dict, output_path: str = None, debug: bool = False) -> str:
    """
    Write a simple custom Fish prompt (optional)

    Args:
        material_colors: Dict of Material You colors
        term_colors: Dict of terminal colors
        output_path: Optional custom output path
        debug: Enable debug output

    Returns:
        Path to the written prompt file
    """
    if output_path is None:
        fish_functions_dir = Path.home() / '.config' / 'fish' / 'functions'
        fish_functions_dir.mkdir(parents=True, exist_ok=True)
        output_path = str(fish_functions_dir / 'fish_prompt.fish')
    
    # Get primary color for prompt
    primary_hct = Hct.from_int(hex_to_argb(material_colors['primary_paletteKeyColor']))
    base_hue = primary_hct.hue
    
    prompt_color = hex_to_rgb(argb_to_hex(
        Hct.from_hct(base_hue, min(primary_hct.chroma * 1.4, 80), 75).to_int()
    ))
    
    error_color = hex_to_rgb(argb_to_hex(
        Hct.from_hct((base_hue + 200) % 360, min(primary_hct.chroma * 1.4, 80), 72).to_int()
    ))
    
    dir_color = hex_to_rgb(term_colors['term4'])
    git_color = hex_to_rgb(term_colors['term5'])
    
    prompt_content = f'''# Auto-generated Fish prompt (Material You theme)
function fish_prompt
    # Save last status
    set -l last_status $status
    
    # Show username@hostname in SSH sessions
    if set -q SSH_CONNECTION
        set_color {prompt_color}
        echo -n (whoami)@(prompt_hostname)' '
    end
    
    # Current directory
    set_color {dir_color}
    echo -n (prompt_pwd)
    
    # Git info (if in a git repo)
    if command -q git
        set -l git_branch (git branch 2>/dev/null | sed -n '/\\* /s///p')
        if test -n "$git_branch"
            set_color {git_color}
            echo -n " ($git_branch)"
        end
    end
    
    # Prompt symbol (changes color on error)
    if test $last_status -eq 0
        set_color {prompt_color}
    else
        set_color {error_color}
    end
    echo -n ' ❯ '
    
    set_color normal
end
'''
    
    with open(output_path, 'w') as f:
        f.write(prompt_content)
    
    if debug:
        print(f"\nFish prompt written to: {output_path}")
        print("The prompt will be applied automatically in new fish sessions.")
    
    return output_path


if __name__ == "__main__":
    print("This module should be imported, not run directly.")
    print("Use: from generate_fish_theme import generate_fish_colors, write_fish_theme")
