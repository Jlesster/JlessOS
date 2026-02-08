#!/usr/bin/env python3
"""
Standalone Material You Color Generator
Generates color schemes from images or colors and applies them to multiple applications
"""
import argparse
import math
import json
import sys
from pathlib import Path
from PIL import Image

# Setup paths - using standard XDG directories instead of Quickshell
XDG_CONFIG_HOME = Path.home() / '.config'
XDG_CACHE_HOME = Path.home() / '.cache'
XDG_STATE_HOME = Path.home() / '.local' / 'state'

# Create base directories for theming
THEME_CONFIG_DIR = XDG_CONFIG_HOME / 'material-theme'
THEME_STATE_DIR = XDG_STATE_HOME / 'material-theme'
THEME_CACHE_DIR = XDG_CACHE_HOME / 'material-theme'

# Create directories if they don't exist
for dir_path in [THEME_CONFIG_DIR, THEME_STATE_DIR, THEME_CACHE_DIR]:
    dir_path.mkdir(parents=True, exist_ok=True)

# Import theme generators
try:
    from generate_nvim_theme import generate_neovim_theme, write_neovim_colorscheme
    from generate_kitty_theme import write_kitty_colors
    from generate_lazygit_theme import generate_lazygit_colors, write_lazygit_config, configure_git_diff_colors
    from generate_yazi_theme import generate_yazi_colors, write_yazi_theme
    from generate_waybar_theme import generate_waybar_colors, write_waybar_theme
    from generate_fzf_theme import generate_fzf_colors, write_fzf_config
    from generate_btop_theme import generate_btop_colors, write_btop_theme
    from generate_fish_theme import generate_fish_colors, write_fish_theme, write_fish_prompt
except ImportError as e:
    print(f"Error importing theme generators: {e}")
    print("Make sure all generator files are in the same directory or in Python path")
    sys.exit(1)

from materialyoucolor.quantize import QuantizeCelebi
from materialyoucolor.score.score import Score
from materialyoucolor.hct import Hct
from materialyoucolor.dynamiccolor.material_dynamic_colors import MaterialDynamicColors
from materialyoucolor.utils.color_utils import (rgba_from_argb, argb_from_rgb, argb_from_rgba)
from materialyoucolor.utils.math_utils import (sanitize_degrees_double, difference_degrees, rotation_direction)

parser = argparse.ArgumentParser(description='Standalone Material You color scheme generator')
parser.add_argument('--path', type=str, default=None, help='Generate colorscheme from image')
parser.add_argument('--size', type=int, default=128, help='Bitmap image size for processing')
parser.add_argument('--color', type=str, default=None, help='Generate colorscheme from hex color')
parser.add_argument('--mode', type=str, choices=['dark', 'light'], default='dark', help='Dark or light mode')
parser.add_argument('--scheme', type=str, default='vibrant', help='Material scheme to use')
parser.add_argument('--smart', action='store_true', default=False, help='Auto-select scheme based on image')
parser.add_argument('--transparency', type=str, choices=['opaque', 'transparent'], default='opaque', help='Enable transparency')
parser.add_argument('--termscheme', type=str, default=None, help='JSON file containing terminal color scheme')
parser.add_argument('--harmony', type=float, default=0.8, help='(0-1) Color hue shift towards accent')
parser.add_argument('--harmonize_threshold', type=float, default=100, help='(0-180) Max threshold angle for hue shift')
parser.add_argument('--term_fg_boost', type=float, default=0.35, help='Make terminal foreground more distinct')
parser.add_argument('--blend_bg_fg', action='store_true', default=False, help='Shift terminal bg/fg towards accent')
parser.add_argument('--generate-waybar', action='store_true', default=False, help='Generate Waybar theme')
parser.add_argument('--waybar-output', type=str, default=None, help='Custom Waybar theme output path')
parser.add_argument('--cache', type=str, default=None, help='File path to cache the generated color')
parser.add_argument('--debug', action='store_true', default=False, help='Enable debug output')

# Theme generation flags
parser.add_argument('--generate-all', action='store_true', default=False, help='Generate all themes')
parser.add_argument('--generate-nvim', action='store_true', default=False, help='Generate Neovim theme')
parser.add_argument('--generate-kitty', action='store_true', default=False, help='Generate Kitty theme')
parser.add_argument('--generate-lazygit', action='store_true', default=False, help='Generate LazyGit theme')
parser.add_argument('--generate-yazi', action='store_true', default=False, help='Generate Yazi theme')
parser.add_argument('--generate-fzf', action='store_true', default=False, help='Generate FZF theme')
parser.add_argument('--generate-btop', action='store_true', default=False, help='Generate Btop theme')
parser.add_argument('--generate-fish', action='store_true', default=False, help='Generate Fish shell theme')

# Custom output paths
parser.add_argument('--nvim-output', type=str, default=None, help='Custom Neovim theme output path')
parser.add_argument('--kitty-output', type=str, default=None, help='Custom Kitty theme output path')
parser.add_argument('--lazygit-output', type=str, default=None, help='Custom LazyGit theme output path')
parser.add_argument('--yazi-output', type=str, default=None, help='Custom Yazi theme output path')
parser.add_argument('--fzf-output', type=str, default=None, help='Custom FZF theme output path')
parser.add_argument('--btop-output', type=str, default=None, help='Custom Btop theme output path')
parser.add_argument('--fish-output', type=str, default=None, help='Custom Fish theme output path')

args = parser.parse_args()

# Utility functions
rgba_to_hex = lambda rgba: "#{:02X}{:02X}{:02X}".format(rgba[0], rgba[1], rgba[2])
argb_to_hex = lambda argb: "#{:02X}{:02X}{:02X}".format(*map(round, rgba_from_argb(argb)))
hex_to_argb = lambda hex_code: argb_from_rgb(int(hex_code[1:3], 16), int(hex_code[3:5], 16), int(hex_code[5:], 16))
display_color = lambda rgba: "\x1B[38;2;{};{};{}m{}\x1B[0m".format(rgba[0], rgba[1], rgba[2], "\x1b[7m   \x1b[7m")


def calculate_optimal_size(width: int, height: int, bitmap_size: int) -> tuple:
    """Calculate optimal size for image processing"""
    image_area = width * height
    bitmap_area = bitmap_size ** 2
    scale = math.sqrt(bitmap_area / image_area) if image_area > bitmap_area else 1
    new_width = max(1, round(width * scale))
    new_height = max(1, round(height * scale))
    return new_width, new_height


def harmonize(design_color: int, source_color: int, threshold: float = 35, harmony: float = 0.5) -> int:
    """Harmonize a color towards a source color"""
    from_hct = Hct.from_int(design_color)
    to_hct = Hct.from_int(source_color)
    difference_degrees_ = difference_degrees(from_hct.hue, to_hct.hue)
    rotation_degrees = min(difference_degrees_ * harmony, threshold)
    output_hue = sanitize_degrees_double(
        from_hct.hue + rotation_degrees * rotation_direction(from_hct.hue, to_hct.hue)
    )
    return Hct.from_hct(output_hue, from_hct.chroma, from_hct.tone).to_int()


def boost_chroma_tone(argb: int, chroma: float = 1, tone: float = 1) -> int:
    """Boost chroma and tone of a color"""
    hct = Hct.from_int(argb)
    return Hct.from_hct(hct.hue, hct.chroma * chroma, hct.tone * tone).to_int()


def convert_catppuccin_to_terminal_colors(catppuccin_colors: dict) -> dict:
    """Convert Catppuccin color scheme to terminal colors (term0-term15)"""
    return {
        'term0': catppuccin_colors.get('base', '#1e1e2e'),
        'term1': catppuccin_colors.get('red', '#f38ba8'),
        'term2': catppuccin_colors.get('green', '#a6e3a1'),
        'term3': catppuccin_colors.get('yellow', '#f9e2af'),
        'term4': catppuccin_colors.get('blue', '#89b4fa'),
        'term5': catppuccin_colors.get('pink', '#f5c2e7'),
        'term6': catppuccin_colors.get('teal', '#94e2d5'),
        'term7': catppuccin_colors.get('text', '#cdd6f4'),
        'term8': catppuccin_colors.get('surface2', '#585b70'),
        'term9': catppuccin_colors.get('red', '#f38ba8'),
        'term10': catppuccin_colors.get('green', '#a6e3a1'),
        'term11': catppuccin_colors.get('yellow', '#f9e2af'),
        'term12': catppuccin_colors.get('blue', '#89b4fa'),
        'term13': catppuccin_colors.get('pink', '#f5c2e7'),
        'term14': catppuccin_colors.get('teal', '#94e2d5'),
        'term15': catppuccin_colors.get('subtext1', '#bac2de'),
    }


# Main execution
darkmode = (args.mode == 'dark')
transparent = (args.transparency == 'transparent')

# Generate or load source color
if args.path is not None:
    image = Image.open(args.path)

    if image.format == "GIF":
        image.seek(1)

    if image.mode in ["L", "P"]:
        image = image.convert('RGB')

    wsize, hsize = image.size
    wsize_new, hsize_new = calculate_optimal_size(wsize, hsize, args.size)
    if wsize_new < wsize or hsize_new < hsize:
        image = image.resize((wsize_new, hsize_new), Image.Resampling.BICUBIC)

    colors = QuantizeCelebi(list(image.getdata()), 128)
    argb = Score.score(colors)[0]

    # Cache the color if requested
    if args.cache is not None:
        cache_path = Path(args.cache)
        cache_path.parent.mkdir(parents=True, exist_ok=True)
        with open(cache_path, 'w') as file:
            file.write(argb_to_hex(argb))
    
    # Also save to default cache location
    default_cache = THEME_STATE_DIR / 'current_color.txt'
    with open(default_cache, 'w') as f:
        f.write(argb_to_hex(argb))

    hct = Hct.from_int(argb)
    if args.smart and hct.chroma < 20:
        args.scheme = 'neutral'

elif args.color is not None:
    argb = hex_to_argb(args.color)
    hct = Hct.from_int(argb)
    
    # Save to cache
    default_cache = THEME_STATE_DIR / 'current_color.txt'
    with open(default_cache, 'w') as f:
        f.write(args.color)
else:
    print("Error: Must provide either --path or --color")
    sys.exit(1)

# Select scheme type
scheme_map = {
    'scheme-fruit-salad': 'materialyoucolor.scheme.scheme_fruit_salad.SchemeFruitSalad',
    'scheme-expressive': 'materialyoucolor.scheme.scheme_expressive.SchemeExpressive',
    'scheme-monochrome': 'materialyoucolor.scheme.scheme_monochrome.SchemeMonochrome',
    'scheme-rainbow': 'materialyoucolor.scheme.scheme_rainbow.SchemeRainbow',
    'scheme-tonal-spot': 'materialyoucolor.scheme.scheme_tonal_spot.SchemeTonalSpot',
    'scheme-neutral': 'materialyoucolor.scheme.scheme_neutral.SchemeNeutral',
    'scheme-fidelity': 'materialyoucolor.scheme.scheme_fidelity.SchemeFidelity',
    'scheme-content': 'materialyoucolor.scheme.scheme_content.SchemeContent',
    'scheme-vibrant': 'materialyoucolor.scheme.scheme_vibrant.SchemeVibrant',
}

scheme_name = f'scheme-{args.scheme}' if not args.scheme.startswith('scheme-') else args.scheme
if scheme_name in scheme_map:
    module_path, class_name = scheme_map[scheme_name].rsplit('.', 1)
    module = __import__(module_path, fromlist=[class_name])
    Scheme = getattr(module, class_name)
else:
    from materialyoucolor.scheme.scheme_tonal_spot import SchemeTonalSpot as Scheme

# Generate Material You color scheme
scheme = Scheme(hct, darkmode, 0.0)

material_colors = {}
term_colors = {}

# Extract all Material colors
for color in vars(MaterialDynamicColors).keys():
    color_name = getattr(MaterialDynamicColors, color)
    if hasattr(color_name, "get_hct"):
        rgba = color_name.get_hct(scheme).to_rgba()
        material_colors[color] = rgba_to_hex(rgba)

# Add extended material colors
if darkmode:
    material_colors['success'] = '#B5CCBA'
    material_colors['onSuccess'] = '#213528'
    material_colors['successContainer'] = '#374B3E'
    material_colors['onSuccessContainer'] = '#D1E9D6'
else:
    material_colors['success'] = '#4F6354'
    material_colors['onSuccess'] = '#FFFFFF'
    material_colors['successContainer'] = '#D1E8D5'
    material_colors['onSuccessContainer'] = '#0C1F13'

# Generate terminal colors
if args.termscheme is not None:
    termscheme_path = Path(args.termscheme)
else:
    # Try to find a default terminal scheme
    termscheme_path = THEME_CONFIG_DIR / 'terminal-scheme.json'
    if not termscheme_path.exists():
        # Create a default one
        default_scheme = {
            "dark": {
                "term0": "#282828", "term1": "#CC241D", "term2": "#98971A", "term3": "#D79921",
                "term4": "#458588", "term5": "#B16286", "term6": "#689D6A", "term7": "#A89984",
                "term8": "#928374", "term9": "#FB4934", "term10": "#B8BB26", "term11": "#FABD2F",
                "term12": "#83A598", "term13": "#D3869B", "term14": "#8EC07C", "term15": "#EBDBB2"
            },
            "light": {
                "term0": "#FDF9F3", "term1": "#FF6188", "term2": "#A9DC76", "term3": "#FC9867",
                "term4": "#FFD866", "term5": "#F47FD4", "term6": "#78DCE8", "term7": "#333034",
                "term8": "#121212", "term9": "#FF6188", "term10": "#A9DC76", "term11": "#FC9867",
                "term12": "#FFD866", "term13": "#F47FD4", "term14": "#78DCE8", "term15": "#333034"
            }
        }
        termscheme_path.parent.mkdir(parents=True, exist_ok=True)
        with open(termscheme_path, 'w') as f:
            json.dump(default_scheme, f, indent=4)

if termscheme_path.exists():
    with open(termscheme_path, 'r') as f:
        loaded_colors = json.load(f)

    # Check format and extract colors
    if 'dark' in loaded_colors or 'light' in loaded_colors:
        term_source_colors = loaded_colors['dark' if darkmode else 'light']
    else:
        term_source_colors = convert_catppuccin_to_terminal_colors(loaded_colors)

    primary_color_argb = hex_to_argb(material_colors['primary_paletteKeyColor'])
    for color, val in term_source_colors.items():
        if args.scheme == 'monochrome':
            term_colors[color] = val
            continue
        if args.blend_bg_fg and color == "term0":
            harmonized = boost_chroma_tone(hex_to_argb(material_colors['surfaceContainerLow']), 1.2, 0.95)
        elif args.blend_bg_fg and color == "term15":
            harmonized = boost_chroma_tone(hex_to_argb(material_colors['onSurface']), 3, 1)
        else:
            harmonized = harmonize(hex_to_argb(val), primary_color_argb, args.harmonize_threshold, args.harmony)
            harmonized = boost_chroma_tone(harmonized, 1, 1 + (args.term_fg_boost * (1 if darkmode else -1)))
        term_colors[color] = argb_to_hex(harmonized)

# Save color data to cache
color_data = {
    'mode': 'dark' if darkmode else 'light',
    'transparent': transparent,
    'material': material_colors,
    'terminal': term_colors,
    'source_color': argb_to_hex(argb)
}
cache_file = THEME_STATE_DIR / 'colors.json'
with open(cache_file, 'w') as f:
    json.dump(color_data, f, indent=2)

# Generate theme files
if args.generate_all or args.generate_nvim:
    if args.debug:
        print('\n=== Generating Neovim theme ===')
    nvim_theme = generate_neovim_theme(material_colors, term_colors, transparent, None, args.debug)
    nvim_path = write_neovim_colorscheme(nvim_theme, args.nvim_output, args.debug)
    if args.debug:
        print(f'✓ Neovim theme written to: {nvim_path}')

if args.generate_all or args.generate_waybar:
    if term_colors:
        if args.debug:
            print('\n=== Generating Waybar theme ===')
        waybar_colors = generate_waybar_colors(material_colors, term_colors, darkmode, transparent)
        waybar_path = write_waybar_theme(waybar_colors, args.waybar_output, transparent, args.debug)
        if args.debug:
            print(f'✓ Waybar theme written to: {waybar_path}')

if args.generate_all or args.generate_kitty:
    if term_colors:
        if args.debug:
            print('\n=== Generating Kitty theme ===')
        kitty_path = write_kitty_colors(term_colors, args.kitty_output, args.debug)
        if args.debug:
            print(f'✓ Kitty theme written to: {kitty_path}')

if args.generate_all or args.generate_lazygit:
    if term_colors:
        if args.debug:
            print('\n=== Generating LazyGit theme ===')
        lazygit_colors = generate_lazygit_colors(material_colors, term_colors, darkmode)
        lazygit_path = write_lazygit_config(lazygit_colors, args.lazygit_output, args.debug)
        configure_git_diff_colors(lazygit_colors, term_colors, args.debug)
        if args.debug:
            print(f'✓ LazyGit theme written to: {lazygit_path}')

if args.generate_all or args.generate_yazi:
    if term_colors:
        if args.debug:
            print('\n=== Generating Yazi theme ===')
        yazi_colors = generate_yazi_colors(material_colors, term_colors, darkmode)
        yazi_path = write_yazi_theme(yazi_colors, args.yazi_output, args.debug)
        if args.debug:
            print(f'✓ Yazi theme written to: {yazi_path}')

if args.generate_all or args.generate_fzf:
    if term_colors:
        if args.debug:
            print('\n=== Generating FZF theme ===')
        fzf_colors = generate_fzf_colors(material_colors, term_colors, darkmode)
        fzf_path = write_fzf_config(fzf_colors, args.fzf_output, args.debug)
        if args.debug:
            print(f'✓ FZF theme written to: {fzf_path}')

if args.generate_all or args.generate_btop:
    if term_colors:
        if args.debug:
            print('\n=== Generating Btop theme ===')
        btop_colors = generate_btop_colors(material_colors, term_colors, darkmode)
        btop_path = write_btop_theme(btop_colors, args.btop_output, args.debug)
        if args.debug:
            print(f'✓ Btop theme written to: {btop_path}')

if args.generate_all or args.generate_fish:
    if term_colors:
        if args.debug:
            print('\n=== Generating Fish shell theme ===')
        fish_colors = generate_fish_colors(material_colors, term_colors, darkmode)
        fish_path = write_fish_theme(fish_colors, args.fish_output, args.debug)
        write_fish_prompt(material_colors, term_colors, None, args.debug)
        if args.debug:
            print(f'✓ Fish theme written to: {fish_path}')

# Output for scripts (SCSS format for compatibility)
if not args.debug:
    print(f"$darkmode: {darkmode};")
    print(f"$transparent: {transparent};")
    for color, code in material_colors.items():
        print(f"${color}: {code};")
    for color, code in term_colors.items():
        print(f"${color}: {code};")
else:
    if args.path is not None:
        print('\n=== Image Properties ===')
        print(f"Image size: {wsize} x {hsize}")
        print(f"Resized: {wsize_new} x {hsize_new}")
    print('\n=== Selected Color ===')
    print(f"Dark mode: {darkmode}")
    print(f"Scheme: {args.scheme}")
    print(f"Accent: {display_color(rgba_from_argb(argb))} {argb_to_hex(argb)}")
    print(f"HCT: H={hct.hue:.2f} C={hct.chroma:.2f} T={hct.tone:.2f}")
    print('\n=== Material Colors ===')
    for color, code in material_colors.items():
        rgba = rgba_from_argb(hex_to_argb(code))
        print(f"{color.ljust(32)} : {display_color(rgba)}  {code}")
    if term_colors:
        print('\n=== Terminal Colors (Harmonized) ===')
        for color, code in term_colors.items():
            rgba = rgba_from_argb(hex_to_argb(code))
            print(f"{color.ljust(6)} : {display_color(rgba)} {code}")
    print('\n' + '=' * 50)
    print(f"Color data cached to: {cache_file}")
