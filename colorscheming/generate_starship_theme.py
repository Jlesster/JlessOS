#!/usr/bin/env python3
"""
Starship Prompt Theme Generator
Generates Starship prompt configuration with Material You colors
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


def generate_starship_colors(material_colors: dict, term_colors: dict, darkmode: bool = True) -> dict:
    """
    Generate Starship prompt color scheme

    Args:
        material_colors: Dict of Material You colors
        term_colors: Dict of terminal colors
        darkmode: Whether to use dark mode

    Returns:
        Dict of Starship color definitions
    """
    # Get primary hue for consistency
    primary_hct = Hct.from_int(hex_to_argb(material_colors['primary_paletteKeyColor']))
    base_hue = primary_hct.hue

    starship_colors = {}

    # Directory - vibrant primary color
    starship_colors['directory'] = argb_to_hex(
        Hct.from_hct(base_hue, min(primary_hct.chroma * 1.4, 80), 75 if darkmode else 40).to_int()
    )

    # Git branch - slightly shifted purple
    starship_colors['git_branch'] = argb_to_hex(
        Hct.from_hct(base_hue - 10, min(primary_hct.chroma * 1.3, 75), 72 if darkmode else 42).to_int()
    )

    # Git status - different states
    starship_colors['git_added'] = argb_to_hex(
        Hct.from_hct(base_hue + 140, min(primary_hct.chroma * 1.3, 75), 70 if darkmode else 45).to_int()
    )
    starship_colors['git_modified'] = argb_to_hex(
        Hct.from_hct(base_hue + 30, min(primary_hct.chroma * 1.4, 80), 75 if darkmode else 40).to_int()
    )
    starship_colors['git_deleted'] = argb_to_hex(
        Hct.from_hct((base_hue + 200) % 360, min(primary_hct.chroma * 1.3, 75), 70 if darkmode else 45).to_int()
    )
    starship_colors['git_untracked'] = argb_to_hex(
        Hct.from_hct(base_hue + 15, min(primary_hct.chroma * 1.2, 70), 68 if darkmode else 47).to_int()
    )

    # Command success/error
    starship_colors['success'] = argb_to_hex(
        Hct.from_hct(base_hue + 140, min(primary_hct.chroma * 1.3, 75), 72 if darkmode else 42).to_int()
    )
    starship_colors['error'] = argb_to_hex(
        Hct.from_hct((base_hue + 200) % 360, min(primary_hct.chroma * 1.4, 80), 72 if darkmode else 42).to_int()
    )

    # Language/environment indicators
    starship_colors['python'] = argb_to_hex(
        Hct.from_hct(base_hue + 25, min(primary_hct.chroma * 1.3, 75), 70 if darkmode else 45).to_int()
    )
    starship_colors['nodejs'] = argb_to_hex(
        Hct.from_hct(base_hue + 140, min(primary_hct.chroma * 1.2, 70), 68 if darkmode else 47).to_int()
    )
    starship_colors['rust'] = argb_to_hex(
        Hct.from_hct(base_hue + 20, min(primary_hct.chroma * 1.4, 80), 73 if darkmode else 43).to_int()
    )
    starship_colors['golang'] = argb_to_hex(
        Hct.from_hct(base_hue + 150, min(primary_hct.chroma * 1.3, 75), 70 if darkmode else 45).to_int()
    )

    # Time
    starship_colors['time'] = argb_to_hex(
        Hct.from_hct(base_hue, primary_hct.chroma * 0.6, 60 if darkmode else 55).to_int()
    )

    # Username/hostname
    starship_colors['username'] = argb_to_hex(
        Hct.from_hct(base_hue + 5, min(primary_hct.chroma * 1.3, 75), 73 if darkmode else 43).to_int()
    )
    starship_colors['hostname'] = argb_to_hex(
        Hct.from_hct(base_hue + 10, min(primary_hct.chroma * 1.2, 70), 70 if darkmode else 45).to_int()
    )

    # Character (prompt symbol)
    starship_colors['character_success'] = argb_to_hex(
        Hct.from_hct(base_hue, min(primary_hct.chroma * 1.5, 85), 78 if darkmode else 38).to_int()
    )
    starship_colors['character_error'] = starship_colors['error']

    # Duration
    starship_colors['duration'] = argb_to_hex(
        Hct.from_hct(base_hue + 30, min(primary_hct.chroma * 1.2, 70), 68 if darkmode else 47).to_int()
    )

    # Docker
    starship_colors['docker'] = argb_to_hex(
        Hct.from_hct(base_hue + 160, min(primary_hct.chroma * 1.3, 75), 70 if darkmode else 45).to_int()
    )

    # Package version
    starship_colors['package'] = argb_to_hex(
        Hct.from_hct(base_hue - 5, min(primary_hct.chroma * 1.2, 70), 68 if darkmode else 47).to_int()
    )

    return starship_colors


def write_starship_config(starship_colors: dict, output_path: str = None, debug: bool = False) -> str:
    """
    Write Starship configuration file with Material You colors

    Args:
        starship_colors: Dict of Starship color definitions
        output_path: Optional custom output path
        debug: Enable debug output

    Returns:
        Path to the written config file
    """
    if output_path is None:
        starship_config_dir = Path.home() / '.config'
        starship_config_dir.mkdir(parents=True, exist_ok=True)
        output_path = str(starship_config_dir / 'starship.toml')

    config_content = f'''# Auto-generated Starship configuration (Material You theme)
# Don't print a new line at the start of the prompt
add_newline = false

format = """
 ┌[$cmd_duration](fg:{starship_colors['duration']})──[$username$hostname](fg:{starship_colors['username']})────[$directory](fg:{starship_colors['directory']}) [$git_branch](fg:{starship_colors['git_branch']})
 └─[$character](fg:{starship_colors['character_success']})"""

# Right prompt
right_format = """$time"""

# Character (prompt symbol)
[character]
success_symbol = "[ ](bold fg:{starship_colors['character_success']})"
error_symbol = "[ ](bold fg:{starship_colors['character_error']})"

# Disable the package module by default
[package]
disabled = true

# Git branch
[git_branch]
style = "bold bg:{starship_colors['git_branch']} fg:black"
symbol = "󰘬 "
truncation_length = 12
truncation_symbol = ""
format = "󰜥 [](bold bg:none fg:{starship_colors['git_branch']})[ $symbol$branch(:$remote_branch) ]($style)[](bold bg:none fg:{starship_colors['git_branch']})"

[git_commit]
commit_hash_length = 4
tag_symbol = " "

[git_state]
format = '[\($state( $progress_current of $progress_total)\)]($style) '
cherry_pick = "[🍒 PICKING](bold red)"

# Git status
[git_status]
conflicted = " 🏳 "
ahead = " 🏎💨 "
behind = " 😰 "
diverged = " 😵 "
untracked = " 🤷 ‍"
stashed = " 📦 "
modified = " 📝 "
staged = '[++\($count\)](green)'
renamed = " ✍️ "
deleted = " 🗑 "

[git_metrics]
disabled = false
added_style = "{starship_colors['git_added']}"
deleted_style = "{starship_colors['git_deleted']}"
format = "([+$added]($added_style) )([-$deleted]($deleted_style) )"

# Hostname
[hostname]
ssh_only = false
format = "[• $hostname ](bg:{starship_colors['username']} bold fg:black)[](bold bg:none fg:{starship_colors['username']})"
trim_at = ".companyname.com"
disabled = false

# Line break
[line_break]
disabled = false

# Memory usage
[memory_usage]
disabled = true
threshold = -1
symbol = " "
style = "bold dimmed green"

# Time
[time]
disabled = true
format = '🕙[\[ $time \]]($style) '
time_format = "%T"

# Username
[username]
style_user = "bold bg:{starship_colors['username']} fg:black"
style_root = "red bold"
format = "[](bold bg:none fg:{starship_colors['username']})[ $user ]($style)"
disabled = false
show_always = true

# Directory
[directory]
home_symbol = "  "
read_only = "  "
style = "bold bg:{starship_colors['directory']} fg:black"
truncation_length = 6
truncation_symbol = " ••/"
format = '[](bold bg:none fg:{starship_colors['directory']})[ 󰉋 $path ]($style)[$read_only]($style)[](bold bg:none fg:{starship_colors['directory']})'

[directory.substitutions]
"Desktop" = "  "
"Documents" = "  "
"Downloads" = "  "
"Music" = " 󰎈 "
"Pictures" = "  "
"Videos" = "  "
"GitHub" = " 󰊤 "

# Command duration
[cmd_duration]
min_time = 0
format = '[](bold bg:none fg:{starship_colors['duration']})[ 󰪢 $duration ](bold bg:{starship_colors['duration']} fg:black)[](bold bg:none fg:{starship_colors['duration']})'

# Python
[python]
symbol = " "
style = "bold bg:{starship_colors['python']} fg:black"
format = '[ $symbol$version(\($virtualenv\)) ]($style)'
pyenv_version_name = false
python_binary = ["python3", "python"]

# Node.js
[nodejs]
symbol = " "
style = "bold bg:{starship_colors['nodejs']} fg:black"
format = '[ $symbol$version ]($style)'

# Rust
[rust]
symbol = " "
style = "bold bg:{starship_colors['rust']} fg:black"
format = '[ $symbol$version ]($style)'

# Go
[golang]
symbol = " "
style = "bold bg:{starship_colors['golang']} fg:black"
format = '[ $symbol$version ]($style)'

# Docker
[docker_context]
symbol = " "
style = "bold bg:{starship_colors['docker']} fg:black"
format = '[ $symbol$context ]($style)'
only_with_files = true

# Java
[java]
symbol = " "
style = "bold bg:{starship_colors['rust']} fg:black"
format = '[ $symbol$version ]($style)'

# Lua
[lua]
symbol = " "
style = "bold bg:{starship_colors['nodejs']} fg:black"
format = '[ $symbol$version ]($style)'

# Ruby
[ruby]
symbol = " "
style = "bold bg:{starship_colors['error']} fg:black"
format = '[ $symbol$version ]($style)'

# PHP
[php]
symbol = " "
style = "bold bg:{starship_colors['python']} fg:black"
format = '[ $symbol$version ]($style)'

# AWS
[aws]
symbol = "  "
style = "bold bg:{starship_colors['duration']} fg:black"
format = '[ $symbol$profile(\($region\)) ]($style)'

# Battery
[battery]
full_symbol = "󰂄 "
charging_symbol = "󰂄 "
discharging_symbol = "󰂃 "
unknown_symbol = "󰂎 "
empty_symbol = "󰂎 "

[[battery.display]]
threshold = 10
style = "bold {starship_colors['error']}"

[[battery.display]]
threshold = 30
style = "{starship_colors['duration']}"

[[battery.display]]
threshold = 100
style = "{starship_colors['success']}"

# Jobs
[jobs]
symbol = " "
style = "bold bg:{starship_colors['duration']} fg:black"
number_threshold = 1
format = "[ $symbol$number ]($style)"
'''

    with open(output_path, 'w') as f:
        f.write(config_content)

    if debug:
        print(f"\nStarship config written to: {output_path}")
        print("\nColors used:")
        for key, color in starship_colors.items():
            print(f"  {key}: {color}")
        print("\nThe configuration will take effect on your next shell session.")
        print("To apply immediately, restart your terminal or run: source ~/.bashrc (or ~/.zshrc)")

    return output_path


if __name__ == "__main__":
    print("This module should be imported, not run directly.")
    print("Use: from generate_starship_theme import generate_starship_colors, write_starship_config")
