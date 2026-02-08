#!/usr/bin/env bash
# Apply Fish shell theme colors - SAFE VERSION
# This version doesn't try to reload running shells, just sets up for next launch

set -e

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
FISH_THEME_FILE="$XDG_CONFIG_HOME/fish/conf.d/material_you_colors.fish"

echo "Applying Fish shell theme..."

# Check if Fish is installed
if ! command -v fish >/dev/null 2>&1; then
    echo "  ⚠ Fish shell not installed, skipping"
    exit 0
fi

# Check if theme file exists
if [ ! -f "$FISH_THEME_FILE" ]; then
    echo "  ✗ Theme file not found: $FISH_THEME_FILE"
    exit 1
fi

# Simply source the theme file to update universal variables
# This sets the variables globally for all future Fish shells
echo "  Loading Material You theme colors..."
fish -c "source '$FISH_THEME_FILE'" 2>/dev/null || {
    echo "  ✗ Failed to load theme"
    exit 1
}

echo "  ✓ Theme colors updated successfully!"
echo ""
echo "  To see the new colors:"
echo "    • Close and reopen your terminal, OR"
echo "    • Run: exec fish"
echo ""

exit 0
