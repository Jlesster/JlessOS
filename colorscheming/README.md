# Material You Theming System (Standalone)

A standalone, Quickshell-independent Material You theming system that generates beautiful, cohesive color schemes from wallpapers or colors and applies them across your terminal and applications.

## Features

- 🎨 Generate Material You color schemes from images or hex colors
- 🖼️ Automatic wallpaper setting (supports hyprpaper, swww, swaybg)
- 🔄 Harmonized colors across all applications
- 📦 Support for multiple applications:
  - Kitty terminal
  - Neovim
  - LazyGit
  - Yazi file manager
  - FZF fuzzy finder
  - Btop system monitor
  - Fish shell
- 🌓 Dark and light mode support
- 🎭 Multiple Material You schemes (vibrant, tonal-spot, neutral, etc.)
- 📝 Configurable via JSON

## Installation

### Prerequisites

**Required:**
- Python 3.7+
- jq

**Python packages:**
```bash
pip install Pillow materialyoucolor
```

**Optional (for smart scheme detection):**
```bash
pip install opencv-python
```

### Install

```bash
chmod +x install.sh
./install.sh
```

This will:
1. Check dependencies
2. Create necessary directories in `~/.config/material-theme`
3. Copy all generator scripts
4. Create symlinks in `~/.local/bin`
5. Generate default configuration

### Manual Installation

If you prefer manual installation:

```bash
# Create directories
mkdir -p ~/.config/material-theme
mkdir -p ~/.local/state/material-theme
mkdir -p ~/.local/bin

# Copy files
cp generate_*.py ~/.config/material-theme/
cp switchwall.sh ~/.config/material-theme/
chmod +x ~/.config/material-theme/*.py
chmod +x ~/.config/material-theme/switchwall.sh

# Create symlinks
ln -s ~/.config/material-theme/switchwall.sh ~/.local/bin/switchwall
ln -s ~/.config/material-theme/generate_material_theme.py ~/.local/bin/material-theme

# Ensure ~/.local/bin is in PATH
export PATH="$HOME/.local/bin:$PATH"
```

## Usage

### Quick Start

Set wallpaper and generate theme:
```bash
switchwall --image ~/Pictures/wallpaper.jpg
```

Generate theme from a color:
```bash
switchwall --color "#89b4fa"
```

### Advanced Usage

#### Wallpaper Switcher

```bash
# Set wallpaper with custom mode and scheme
switchwall --image ~/Pictures/wallpaper.jpg --mode dark --scheme vibrant

# Use light mode
switchwall --image ~/Pictures/wallpaper.jpg --mode light

# Different Material You schemes
switchwall --image ~/Pictures/wallpaper.jpg --scheme tonal-spot
switchwall --image ~/Pictures/wallpaper.jpg --scheme neutral

# Generate from color
switchwall --color "#89b4fa" --mode dark
```

Available schemes:
- `vibrant` - Vibrant, saturated colors (default)
- `tonal-spot` - Balanced, versatile scheme
- `neutral` - Subtle, professional look
- `expressive` - Bold, creative colors
- `content` - Faithful to source image
- `monochrome` - Grayscale
- `fidelity` - High fidelity to source
- `fruit-salad` - Playful, diverse colors
- `rainbow` - Full spectrum

#### Direct Theme Generation

For more control, use the generator directly:

```bash
# Generate all themes from image
material-theme --path ~/Pictures/wallpaper.jpg --generate-all --debug

# Generate specific themes
material-theme --path ~/Pictures/wallpaper.jpg \
    --generate-kitty \
    --generate-nvim \
    --generate-fzf \
    --debug

# From a color
material-theme --color "#89b4fa" \
    --mode dark \
    --scheme vibrant \
    --generate-all \
    --debug

# Fine-tune harmonization
material-theme --path ~/Pictures/wallpaper.jpg \
    --harmony 0.9 \
    --harmonize_threshold 120 \
    --generate-all
```

Options:
- `--path` - Path to image file
- `--color` - Hex color code (e.g., #89b4fa)
- `--mode` - `dark` or `light`
- `--scheme` - Material You scheme type
- `--smart` - Auto-select scheme based on image colorfulness
- `--harmony` - Color shift towards accent (0-1, default: 0.8)
- `--harmonize_threshold` - Max hue shift angle (0-180, default: 100)
- `--transparency` - `opaque` or `transparent`
- `--generate-all` - Generate all themes
- `--generate-kitty` - Generate Kitty theme only
- `--generate-nvim` - Generate Neovim theme only
- `--generate-lazygit` - Generate LazyGit theme only
- `--generate-yazi` - Generate Yazi theme only
- `--generate-fzf` - Generate FZF theme only
- `--generate-btop` - Generate Btop theme only
- `--generate-fish` - Generate Fish theme only
- `--debug` - Show detailed output

## Configuration

Edit `~/.config/material-theme/config.json`:

```json
{
    "wallpaper": {
        "current": "/home/user/Pictures/wallpaper.jpg",
        "backend": "hyprpaper"
    },
    "theming": {
        "mode": "dark",
        "scheme": "vibrant",
        "smart_scheme": true,
        "harmony": 0.8,
        "transparency": "opaque"
    },
    "applications": {
        "kitty": true,
        "nvim": true,
        "lazygit": true,
        "yazi": true,
        "fzf": true,
        "btop": true,
        "fish": true,
        "hyprland": true
    }
}
```

### Wallpaper Backends

Supported backends:
- `hyprpaper` (default for Hyprland)
- `swww` (smooth wallpaper transitions)
- `swaybg` (simple background setter)

Change in config.json:
```json
{
    "wallpaper": {
        "backend": "swww"
    }
}
```

### Terminal Color Scheme

Customize the base terminal colors in `~/.config/material-theme/terminal-scheme.json`:

```json
{
    "dark": {
        "term0": "#282828",   // background
        "term1": "#CC241D",   // red
        "term2": "#98971A",   // green
        "term3": "#D79921",   // yellow
        "term4": "#458588",   // blue
        "term5": "#B16286",   // magenta
        "term6": "#689D6A",   // cyan
        "term7": "#A89984",   // foreground
        "term8": "#928374",   // bright black
        "term9": "#FB4934",   // bright red
        "term10": "#B8BB26",  // bright green
        "term11": "#FABD2F",  // bright yellow
        "term12": "#83A598",  // bright blue
        "term13": "#D3869B",  // bright magenta
        "term14": "#8EC07C",  // bright cyan
        "term15": "#EBDBB2"   // bright white
    },
    "light": {
        // ... light mode colors
    }
}
```

These colors will be harmonized with your accent color automatically.

## Application-Specific Setup

### Kitty

Theme is automatically applied to `~/.config/kitty/current-theme.conf`.

Add to your `kitty.conf`:
```conf
include current-theme.conf
```

Reload Kitty: `Ctrl+Shift+F5` or `killall -SIGUSR1 kitty`

### Neovim

Theme is generated at `~/.config/nvim/colors/material-you.lua`.

Set in your `init.lua`:
```lua
vim.cmd('colorscheme material-you')
```

### LazyGit

Configuration is automatically written to `~/.config/lazygit/config.yml`.

Restart LazyGit to see changes.

### Yazi

Theme is written to `~/.config/yazi/theme.toml`.

Restart Yazi to apply.

### FZF

Source the theme in your shell config:

**Bash/Zsh** (`~/.bashrc` or `~/.zshrc`):
```bash
source ~/.config/fzf/colors.sh
```

**Fish** (`~/.config/fish/config.fish`):
```fish
source ~/.config/fzf/colors.fish
```

### Btop

Theme is saved as `~/.config/btop/themes/material-you.theme`.

In btop:
1. Press `ESC` to open menu
2. Select "Options"
3. Set "Color theme" to "material-you"

Or edit `~/.config/btop/btop.conf`:
```conf
color_theme = "material-you"
```

### Fish Shell

Colors are automatically loaded from `~/.config/fish/conf.d/material_you_colors.fish`.

Reload Fish: `source ~/.config/fish/config.fish`

### Hyprland

Colors are automatically applied to active and inactive borders when using `switchwall`.

Manual application:
```bash
# Read colors from cache
PRIMARY=$(jq -r '.material.primary' ~/.local/state/material-theme/colors.json)
SURFACE=$(jq -r '.material.surface' ~/.local/state/material-theme/colors.json)

# Apply
hyprctl keyword general:col.active_border "rgb(${PRIMARY#\#})"
hyprctl keyword general:col.inactive_border "rgb(${SURFACE#\#})"
```

## Directory Structure

```
~/.config/material-theme/
├── config.json                      # Main configuration
├── terminal-scheme.json             # Terminal color base
├── generate_material_theme.py       # Main generator
├── generate_kitty_theme.py         # Kitty generator
├── generate_nvim_theme.py          # Neovim generator
├── generate_lazygit_theme.py       # LazyGit generator
├── generate_yazi_theme.py          # Yazi generator
├── generate_fzf_theme.py           # FZF generator
├── generate_btop_theme.py          # Btop generator
├── generate_fish_theme.py          # Fish generator
└── switchwall.sh                    # Wallpaper switcher

~/.local/state/material-theme/
├── colors.json                      # Cached color data
└── current_color.txt               # Last used accent color

~/.local/bin/
├── switchwall -> ...               # Wallpaper switcher symlink
└── material-theme -> ...           # Generator symlink
```

## Troubleshooting

### Colors not applying

1. Check if theme files were generated:
```bash
ls ~/.config/kitty/current-theme.conf
ls ~/.config/nvim/colors/material-you.lua
ls ~/.config/yazi/theme.toml
```

2. Ensure applications are sourcing the theme files (see Application-Specific Setup)

3. Restart applications after generating themes

### Python import errors

Install missing packages:
```bash
pip install Pillow materialyoucolor opencv-python
```

### Wallpaper not changing

1. Check wallpaper backend is installed (`hyprpaper`, `swww`, or `swaybg`)
2. Verify backend in config.json matches your setup
3. Check logs: `journalctl --user -u hyprpaper` (for systemd units)

### jq command not found

Install jq:
```bash
# Arch Linux
sudo pacman -S jq

# Ubuntu/Debian
sudo apt install jq

# Fedora
sudo dnf install jq
```

## Examples

### Daily wallpaper rotation

Create a systemd timer or cron job:

```bash
# ~/.config/systemd/user/wallpaper-rotate.service
[Unit]
Description=Rotate wallpaper

[Service]
Type=oneshot
ExecStart=%h/.local/bin/switchwall --image %h/Pictures/Wallpapers/$(ls %h/Pictures/Wallpapers | shuf -n1)

# ~/.config/systemd/user/wallpaper-rotate.timer
[Unit]
Description=Rotate wallpaper daily

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

Enable:
```bash
systemctl --user enable --now wallpaper-rotate.timer
```

### Key binding

Add to your window manager config:

**Hyprland** (`~/.config/hypr/hyprland.conf`):
```conf
bind = SUPER, W, exec, switchwall --image $(find ~/Pictures/Wallpapers -type f | shuf -n1)
```

**i3/Sway** (`~/.config/i3/config` or `~/.config/sway/config`):
```conf
bindsym $mod+w exec switchwall --image $(find ~/Pictures/Wallpapers -type f | shuf -n1)
```

## Credits

- Material You color system by Google
- materialyoucolor-python library
- Original concept inspired by various Material You implementations

## License

MIT License - feel free to modify and distribute
