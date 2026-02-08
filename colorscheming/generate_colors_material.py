#!/usr/bin/env -S\_/bin/sh\_-c\_"source\_\$(eval\_echo\_\$ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate&&exec\_python\_-E\_"\$0"\_"\$@""
import argparse
import math
import json
import sys
from pathlib import Path
from PIL import Image

colorscheming_dir = Path.home() / '.config' / 'colorscheming'
sys.path.insert(0, str(colorscheming_dir))

from generate_nvim_theme import generate_neovim_theme, write_neovim_colorscheme
from generate_kitty_theme import write_kitty_colors
from generate_lazygit_theme import generate_lazygit_colors, write_lazygit_config, configure_git_diff_colors
from generate_yazi_theme import generate_yazi_colors, write_yazi_theme
from materialyoucolor.quantize import QuantizeCelebi
from materialyoucolor.score.score import Score
from materialyoucolor.hct import Hct
from materialyoucolor.dynamiccolor.material_dynamic_colors import MaterialDynamicColors
from materialyoucolor.utils.color_utils import (rgba_from_argb, argb_from_rgb, argb_from_rgba)
from materialyoucolor.utils.math_utils import (sanitize_degrees_double, difference_degrees, rotation_direction)

parser = argparse.ArgumentParser(description='Color generation script')
parser.add_argument('--path', type=str, default=None, help='generate colorscheme from image')
parser.add_argument('--size', type=int , default=128 , help='bitmap image size')
parser.add_argument('--color', type=str, default=None, help='generate colorscheme from color')
parser.add_argument('--mode', type=str, choices=['dark', 'light'], default='dark', help='dark or light mode')
parser.add_argument('--scheme', type=str, default='vibrant', help='material scheme to use')
parser.add_argument('--smart', action='store_true', default=False, help='decide scheme type based on image color')
parser.add_argument('--transparency', type=str, choices=['opaque', 'transparent'], default='opaque', help='enable transparency')
parser.add_argument('--termscheme', type=str, default=None, help='JSON file containg the terminal scheme for generating term colors')
parser.add_argument('--harmony', type=float , default=0.8, help='(0-1) Color hue shift towards accent')
parser.add_argument('--harmonize_threshold', type=float , default=100, help='(0-180) Max threshold angle to limit color hue shift')
parser.add_argument('--term_fg_boost', type=float , default=0.35, help='Make terminal foreground more different from the background')
parser.add_argument('--blend_bg_fg', action='store_true', default=False, help='Shift terminal background or foreground towards accent')
parser.add_argument('--cache', type=str, default=None, help='file path to store the generated color')
parser.add_argument('--debug', action='store_true', default=False, help='debug mode')
# New arguments for theme generation
parser.add_argument('--generate-nvim', action='store_true', default=False, help='generate neovim colorscheme')
parser.add_argument('--generate-kitty', action='store_true', default=False, help='generate kitty terminal theme')
parser.add_argument('--generate-lazygit', action='store_true', default=False, help='generate lazygit theme')
parser.add_argument('--generate-yazi', action='store_true', default=False, help='generate yazi file manager theme')
parser.add_argument('--generate-all', action='store_true', default=False, help='generate all themes')
parser.add_argument('--nvim-output', type=str, default=None, help='custom output path for neovim theme')
parser.add_argument('--kitty-output', type=str, default=None, help='custom output path for kitty theme')
parser.add_argument('--lazygit-output', type=str, default=None, help='custom output path for lazygit theme')
parser.add_argument('--yazi-output', type=str, default=None, help='custom output path for yazi theme')
args = parser.parse_args()

rgba_to_hex = lambda rgba: "#{:02X}{:02X}{:02X}".format(rgba[0], rgba[1], rgba[2])
argb_to_hex = lambda argb: "#{:02X}{:02X}{:02X}".format(*map(round, rgba_from_argb(argb)))
hex_to_argb = lambda hex_code: argb_from_rgb(int(hex_code[1:3], 16), int(hex_code[3:5], 16), int(hex_code[5:], 16))
display_color = lambda rgba : "\x1B[38;2;{};{};{}m{}\x1B[0m".format(rgba[0], rgba[1], rgba[2], "\x1b[7m   \x1b[7m")

def calculate_optimal_size (width: int, height: int, bitmap_size: int) -> (int, int):
    image_area = width * height;
    bitmap_area = bitmap_size ** 2
    scale = math.sqrt(bitmap_area/image_area) if image_area > bitmap_area else 1
    new_width = round(width * scale)
    new_height = round(height * scale)
    if new_width == 0:
        new_width = 1
    if new_height == 0:
        new_height = 1
    return new_width, new_height

def harmonize (design_color: int, source_color: int, threshold: float = 35, harmony: float = 0.5) -> int:
    from_hct = Hct.from_int(design_color)
    to_hct = Hct.from_int(source_color)
    difference_degrees_ = difference_degrees(from_hct.hue, to_hct.hue)
    rotation_degrees = min(difference_degrees_ * harmony, threshold)
    output_hue = sanitize_degrees_double(
        from_hct.hue + rotation_degrees * rotation_direction(from_hct.hue, to_hct.hue)
    )
    return Hct.from_hct(output_hue, from_hct.chroma, from_hct.tone).to_int()

def boost_chroma_tone (argb: int, chroma: float = 1, tone: float = 1) -> int:
    hct = Hct.from_int(argb)
    return Hct.from_hct(hct.hue, hct.chroma * chroma, hct.tone * tone).to_int()

def convert_catppuccin_to_terminal_colors(catppuccin_colors: dict) -> dict:
    """Convert Catppuccin color scheme to terminal colors (term0-term15)"""
    return {
        'term0': catppuccin_colors.get('base', '#1e1e2e'),      # background
        'term1': catppuccin_colors.get('red', '#f38ba8'),       # red
        'term2': catppuccin_colors.get('green', '#a6e3a1'),     # green
        'term3': catppuccin_colors.get('yellow', '#f9e2af'),    # yellow
        'term4': catppuccin_colors.get('blue', '#89b4fa'),      # blue
        'term5': catppuccin_colors.get('pink', '#f5c2e7'),      # magenta
        'term6': catppuccin_colors.get('teal', '#94e2d5'),      # cyan
        'term7': catppuccin_colors.get('text', '#cdd6f4'),      # white/foreground
        'term8': catppuccin_colors.get('surface2', '#585b70'),  # bright black
        'term9': catppuccin_colors.get('red', '#f38ba8'),       # bright red
        'term10': catppuccin_colors.get('green', '#a6e3a1'),    # bright green
        'term11': catppuccin_colors.get('yellow', '#f9e2af'),   # bright yellow
        'term12': catppuccin_colors.get('blue', '#89b4fa'),     # bright blue
        'term13': catppuccin_colors.get('pink', '#f5c2e7'),     # bright magenta
        'term14': catppuccin_colors.get('teal', '#94e2d5'),     # bright cyan
        'term15': catppuccin_colors.get('subtext1', '#bac2de'), # bright white
    }

darkmode = (args.mode == 'dark')
transparent = (args.transparency == 'transparent')

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

    if args.cache is not None:
        with open(args.cache, 'w') as file:
            file.write(argb_to_hex(argb))
    hct = Hct.from_int(argb)
    if(args.smart):
        if(hct.chroma < 20):
            args.scheme = 'neutral'
elif args.color is not None:
    argb = hex_to_argb(args.color)
    hct = Hct.from_int(argb)

if args.scheme == 'scheme-fruit-salad':
    from materialyoucolor.scheme.scheme_fruit_salad import SchemeFruitSalad as Scheme
elif args.scheme == 'scheme-expressive':
    from materialyoucolor.scheme.scheme_expressive import SchemeExpressive as Scheme
elif args.scheme == 'scheme-monochrome':
    from materialyoucolor.scheme.scheme_monochrome import SchemeMonochrome as Scheme
elif args.scheme == 'scheme-rainbow':
    from materialyoucolor.scheme.scheme_rainbow import SchemeRainbow as Scheme
elif args.scheme == 'scheme-tonal-spot':
    from materialyoucolor.scheme.scheme_tonal_spot import SchemeTonalSpot as Scheme
elif args.scheme == 'scheme-neutral':
    from materialyoucolor.scheme.scheme_neutral import SchemeNeutral as Scheme
elif args.scheme == 'scheme-fidelity':
    from materialyoucolor.scheme.scheme_fidelity import SchemeFidelity as Scheme
elif args.scheme == 'scheme-content':
    from materialyoucolor.scheme.scheme_content import SchemeContent as Scheme
elif args.scheme == 'scheme-vibrant':
    from materialyoucolor.scheme.scheme_vibrant import SchemeVibrant as Scheme
else:
    from materialyoucolor.scheme.scheme_tonal_spot import SchemeTonalSpot as Scheme
# Generate
scheme = Scheme(hct, darkmode, 0.0)

material_colors = {}
term_colors = {}

for color in vars(MaterialDynamicColors).keys():
    color_name = getattr(MaterialDynamicColors, color)
    if hasattr(color_name, "get_hct"):
        rgba = color_name.get_hct(scheme).to_rgba()
        material_colors[color] = rgba_to_hex(rgba)

# Extended material
if darkmode == True:
    material_colors['success'] = '#B5CCBA'
    material_colors['onSuccess'] = '#213528'
    material_colors['successContainer'] = '#374B3E'
    material_colors['onSuccessContainer'] = '#D1E9D6'
else:
    material_colors['success'] = '#4F6354'
    material_colors['onSuccess'] = '#FFFFFF'
    material_colors['successContainer'] = '#D1E8D5'
    material_colors['onSuccessContainer'] = '#0C1F13'

# Terminal Colors
if args.termscheme is not None:
    with open(args.termscheme, 'r') as f:
        json_termscheme = f.read()

    loaded_colors = json.loads(json_termscheme)

    # Check if it's the new format (dark/light keys) or old format (catppuccin-style)
    if 'dark' in loaded_colors or 'light' in loaded_colors:
        # New format with dark/light modes
        term_source_colors = loaded_colors['dark' if darkmode else 'light']
    else:
        # Old format (Catppuccin-style) - convert it
        term_source_colors = convert_catppuccin_to_terminal_colors(loaded_colors)

    # Use wallpaper accent HCT as base (like old script)
    accent_hct = hct
    base_hue = accent_hct.hue
    base_chroma = accent_hct.chroma

    for color, val in term_source_colors.items():
        if(args.scheme == 'monochrome') :
            term_colors[color] = val
            continue
        if color == "term0":
            # Generate background directly from wallpaper (like old script)
            if args.blend_bg_fg:
                # Instead of using potentially gray surfaceContainerLow, generate from wallpaper
                bg_hct = Hct.from_hct(base_hue, min(base_chroma * 0.6, 25), 8).to_int()
                harmonized = boost_chroma_tone(bg_hct, 1.2, 0.95)
            else:
                # Create dark background with wallpaper's hue
                harmonized = Hct.from_hct(base_hue, min(base_chroma * 0.6, 25), 6).to_int()
        elif color == "term8":
            # Bright black / secondary background - slightly lighter than term0
            harmonized = Hct.from_hct(base_hue, min(base_chroma * 0.5, 20), 15).to_int()
        elif args.blend_bg_fg and color == "term15":
            harmonized = boost_chroma_tone(hex_to_argb(material_colors['onSurface']), 3, 1)
        else:
            # Get the source color's properties
            source_hct = Hct.from_int(hex_to_argb(val))

            # IMPROVED: Stronger harmonization toward wallpaper hue
            # Calculate the hue difference and rotate more aggressively
            hue_diff = source_hct.hue - base_hue

            # Apply harmony more strongly - use a higher effective harmony
            effective_harmony = min(args.harmony * 1.3, 0.95)  # Boost harmony by 30%
            target_hue = base_hue + (hue_diff * (1 - effective_harmony))

            # Keep hues within a tighter range around base_hue (±60 degrees max)
            hue_distance = abs((target_hue - base_hue + 180) % 360 - 180)
            if hue_distance > 60:
                # Clamp to ±60 degrees around base_hue
                if (target_hue - base_hue + 360) % 360 > 180:
                    target_hue = base_hue - 60
                else:
                    target_hue = base_hue + 60

            # FORCE MAXIMUM SATURATION: Set absolute chroma values per color
            # This overrides source colors completely for vibrant results
            if color in ['term1', 'term9']:  # Red
                target_chroma = 90
                target_tone = 65 if darkmode else 50  # Optimal tone for vibrant red
            elif color in ['term2', 'term10']:  # Green
                target_chroma = 95
                target_tone = 70 if darkmode else 45  # Optimal tone for vibrant green
            elif color in ['term3', 'term11']:  # Yellow
                target_chroma = 90
                target_tone = 75 if darkmode else 55  # Optimal tone for vibrant yellow
            elif color in ['term4', 'term12']:  # Blue
                target_chroma = 95
                target_tone = 70 if darkmode else 50  # Optimal tone for vibrant blue
            elif color in ['term5', 'term13']:  # Magenta
                target_chroma = 92
                target_tone = 68 if darkmode else 48  # Optimal tone for vibrant magenta
            elif color in ['term6', 'term14']:  # Cyan
                target_chroma = 95
                target_tone = 72 if darkmode else 52  # Optimal tone for vibrant cyan
            elif color in ['term7']:  # Normal foreground
                target_chroma = 20
                target_tone = 85 if darkmode else 30
            elif color in ['term15']:  # Bright foreground
                target_chroma = 30
                target_tone = 90 if darkmode else 25
            else:
                target_chroma = 90
                target_tone = source_hct.tone

            # Apply tone boost only to foreground colors
            if color in ['term7', 'term15']:
                target_tone = target_tone * (1 + (args.term_fg_boost * (1 if darkmode else -1)))

            harmonized = Hct.from_hct(target_hue, target_chroma, target_tone).to_int()
        term_colors[color] = argb_to_hex(harmonized)

# Generate theme files if requested
if args.generate_all or args.generate_nvim:
    if args.debug:
        print('\n---------------Generating Neovim theme---------')
    nvim_theme = generate_neovim_theme(material_colors, term_colors, transparent, None, args.debug)
    nvim_path = write_neovim_colorscheme(nvim_theme, args.nvim_output, args.debug)
    if args.debug:
        print(f'Neovim theme written to: {nvim_path}')

if args.generate_all or args.generate_kitty:
    if term_colors:
        if args.debug:
            print('\n---------------Generating Kitty theme----------')
        kitty_path = write_kitty_colors(term_colors, args.kitty_output, args.debug)
        if args.debug:
            print(f'Kitty theme written to: {kitty_path}')
    else:
        if args.debug:
            print('Warning: No terminal colors generated. Use --termscheme to generate Kitty theme.')

if args.generate_all or args.generate_lazygit:
    if term_colors:
        if args.debug:
            print('\n---------------Generating LazyGit theme--------')
        lazygit_colors = generate_lazygit_colors(material_colors, term_colors, darkmode)
        lazygit_path = write_lazygit_config(lazygit_colors, args.lazygit_output, args.debug)
        configure_git_diff_colors(lazygit_colors, term_colors, args.debug)
        if args.debug:
            print(f'LazyGit theme written to: {lazygit_path}')
    else:
        if args.debug:
            print('Warning: No terminal colors generated. Use --termscheme to generate LazyGit theme.')

if args.generate_all or args.generate_yazi:
    if term_colors:
        if args.debug:
            print('\n---------------Generating Yazi theme-----------')
        yazi_colors = generate_yazi_colors(material_colors, term_colors, darkmode)
        yazi_path = write_yazi_theme(yazi_colors, args.yazi_output, args.debug)
        if args.debug:
            print(f'Yazi theme written to: {yazi_path}')
    else:
        if args.debug:
            print('Warning: No terminal colors generated. Use --termscheme to generate Yazi theme.')

# Original output
if args.debug == False:
    print(f"$darkmode: {darkmode};")
    print(f"$transparent: {transparent};")
    for color, code in material_colors.items():
        print(f"${color}: {code};")
    for color, code in term_colors.items():
        print(f"${color}: {code};")
else:
    if args.path is not None:
        print('\n--------------Image properties-----------------')
        print(f"Image size: {wsize} x {hsize}")
        print(f"Resized image: {wsize_new} x {hsize_new}")
    print('\n---------------Selected color------------------')
    print(f"Dark mode: {darkmode}")
    print(f"Scheme: {args.scheme}")
    print(f"Accent color: {display_color(rgba_from_argb(argb))} {argb_to_hex(argb)}")
    print(f"HCT: {hct.hue:.2f}  {hct.chroma:.2f}  {hct.tone:.2f}")
    print('\n---------------Material colors-----------------')
    for color, code in material_colors.items():
        rgba = rgba_from_argb(hex_to_argb(code))
        print(f"{color.ljust(32)} : {display_color(rgba)}  {code}")
    if term_colors:
        print('\n----------Harmonize terminal colors------------')
        for color, code in term_colors.items():
            rgba = rgba_from_argb(hex_to_argb(code))
            code_source = term_source_colors[color]
            rgba_source = rgba_from_argb(hex_to_argb(code_source))
            print(f"{color.ljust(6)} : {display_color(rgba_source)} {code_source} --> {display_color(rgba)} {code}")
    print('-----------------------------------------------')
