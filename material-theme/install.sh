#!/usr/bin/env bash
# Installation script for standalone Material You theming system

set -e

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/.local/bin}"

THEME_DIR="$XDG_CONFIG_HOME/material-theme"
STATE_DIR="$XDG_STATE_HOME/material-theme"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Material You Theming System - Installer ==="
echo ""

# Check dependencies
echo "Checking dependencies..."
MISSING_DEPS=()

command -v python3 >/dev/null 2>&1 || MISSING_DEPS+=("python3")
command -v jq >/dev/null 2>&1 || MISSING_DEPS+=("jq")

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    echo "Error: Missing required dependencies: ${MISSING_DEPS[*]}"
    echo "Please install them and try again."
    exit 1
fi

echo "✓ All required dependencies found"
echo ""

# Check Python packages
echo "Checking Python packages..."
python3 -c "import PIL" 2>/dev/null || {
    echo "Missing Python package: Pillow"
    echo "Install with: pip install Pillow"
    exit 1
}

python3 -c "import materialyoucolor" 2>/dev/null || {
    echo "Missing Python package: materialyoucolor"
    echo "Install with: pip install materialyoucolor"
    exit 1
}

python3 -c "import cv2" 2>/dev/null || {
    echo "Warning: opencv-python not found (optional, for smart scheme detection)"
    echo "Install with: pip install opencv-python"
}

echo "✓ Python packages OK"
echo ""

# Create directories
echo "Creating directories..."
mkdir -p "$THEME_DIR"
mkdir -p "$STATE_DIR"
mkdir -p "$XDG_BIN_HOME"
echo "✓ Directories created"
echo ""

# Copy files
echo "Installing files..."

# Main generator script
cp "$SCRIPT_DIR/generate_material_theme.py" "$THEME_DIR/"
chmod +x "$THEME_DIR/generate_material_theme.py"

# Individual theme generators
for generator in generate_kitty_theme.py generate_nvim_theme.py generate_lazygit_theme.py \
                 generate_yazi_theme.py generate_fzf_theme.py generate_btop_theme.py \
                 generate_fish_theme.py; do
    if [ -f "$SCRIPT_DIR/$generator" ]; then
        cp "$SCRIPT_DIR/$generator" "$THEME_DIR/"
        echo "  ✓ $generator"
    else
        echo "  ⚠ $generator not found (skipping)"
    fi
done

# Wallpaper switcher
cp "$SCRIPT_DIR/switchwall.sh" "$THEME_DIR/"
chmod +x "$THEME_DIR/switchwall.sh"

# Create symlink in bin directory
ln -sf "$THEME_DIR/switchwall.sh" "$XDG_BIN_HOME/switchwall"
ln -sf "$THEME_DIR/generate_material_theme.py" "$XDG_BIN_HOME/material-theme"

echo "✓ Files installed"
echo ""

# Create default terminal scheme if it doesn't exist
TERM_SCHEME="$THEME_DIR/terminal-scheme.json"
if [ ! -f "$TERM_SCHEME" ]; then
    echo "Creating default terminal color scheme..."
    cat > "$TERM_SCHEME" << 'EOF'
{
    "dark": {
        "term0": "#282828",
        "term1": "#CC241D",
        "term2": "#98971A",
        "term3": "#D79921",
        "term4": "#458588",
        "term5": "#B16286",
        "term6": "#689D6A",
        "term7": "#A89984",
        "term8": "#928374",
        "term9": "#FB4934",
        "term10": "#B8BB26",
        "term11": "#FABD2F",
        "term12": "#83A598",
        "term13": "#D3869B",
        "term14": "#8EC07C",
        "term15": "#EBDBB2"
    },
    "light": {
        "term0": "#FDF9F3",
        "term1": "#FF6188",
        "term2": "#A9DC76",
        "term3": "#FC9867",
        "term4": "#FFD866",
        "term5": "#F47FD4",
        "term6": "#78DCE8",
        "term7": "#333034",
        "term8": "#121212",
        "term9": "#FF6188",
        "term10": "#A9DC76",
        "term11": "#FC9867",
        "term12": "#FFD866",
        "term13": "#F47FD4",
        "term14": "#78DCE8",
        "term15": "#333034"
    }
}
EOF
    echo "✓ Terminal scheme created"
fi

echo ""
echo "=== Installation Complete! ==="
echo ""
echo "Usage:"
echo "  switchwall --image /path/to/wallpaper.jpg"
echo "  switchwall --color '#89b4fa' --mode dark"
echo "  material-theme --path /path/to/image.jpg --generate-all --debug"
echo ""
echo "Configuration:"
echo "  Edit: $THEME_DIR/config.json"
echo "  Terminal colors: $THEME_DIR/terminal-scheme.json"
echo ""
echo "Make sure ~/.local/bin is in your PATH:"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
echo ""

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$XDG_BIN_HOME:"* ]]; then
    echo "⚠ Warning: $XDG_BIN_HOME is not in your PATH"
    echo ""
    echo "Add this to your shell config (.bashrc, .zshrc, or config.fish):"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\"    # for bash/zsh"
    echo "  set -gx PATH \$HOME/.local/bin \$PATH       # for fish"
    echo ""
fi

# Offer to test installation
read -p "Would you like to test the installation? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Running test with default color..."
    "$THEME_DIR/generate_material_theme.py" --color "#89b4fa" --mode dark --debug
fi
