#!/usr/bin/env fish
# Quick fix for Fish prompt colors not updating
# Run this after switching wallpapers

echo "🔧 Quick Fish Color Fix"
echo "======================="
echo ""

# Clear all old prompt variables
echo "Clearing old prompt color variables..."
for var in material_prompt_bracket material_prompt_username material_prompt_hostname material_prompt_path material_prompt_git material_prompt_arrow
    set -e $var
end
echo "✓ Cleared"
echo ""

# Source the theme file to reload colors
echo "Reloading theme colors..."
if test -f ~/.config/fish/conf.d/material_you_colors.fish
    source ~/.config/fish/conf.d/material_you_colors.fish
    echo "✓ Theme loaded"
else
    echo "✗ Theme file not found!"
    echo "Run: ./switchwall.sh --image ~/Pictures/wallpaper.jpg"
    exit 1
end
echo ""

# Show what colors we got
echo "Current prompt colors:"
echo "  Brackets:  $material_prompt_bracket"
echo "  Username:  $material_prompt_username"
echo "  Hostname:  $material_prompt_hostname"
echo "  Path:      $material_prompt_path"
echo "  Git:       $material_prompt_git"
echo ""

echo "✓ Done! Press Enter to see updated prompt"
