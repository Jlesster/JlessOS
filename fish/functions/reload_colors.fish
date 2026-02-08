# Reload Material You colors without restarting Fish
# Put this in: ~/.config/fish/functions/reload_colors.fish
# Usage: reload_colors

function reload_colors --description "Reload Material You theme colors"
    set -l theme_file ~/.config/fish/conf.d/material_you_colors.fish
    
    if test -f $theme_file
        echo "Reloading Material You colors..."
        source $theme_file
        echo "✓ Colors reloaded! Press Enter to see the new prompt."
    else
        echo "✗ Theme file not found: $theme_file"
        return 1
    end
end
