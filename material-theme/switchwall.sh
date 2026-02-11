#!/usr/bin/env bash
# Standalone wallpaper switcher with Material You theming
# No dependency on Quickshell - works with standard tools

set -e

# XDG directories
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Theme directories
THEME_DIR="$XDG_CONFIG_HOME/material-theme"
STATE_DIR="$XDG_STATE_HOME/material-theme"
CACHE_DIR="$XDG_CACHE_HOME/material-theme"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create directories
mkdir -p "$THEME_DIR" "$STATE_DIR" "$CACHE_DIR"

# Configuration file
CONFIG_FILE="$THEME_DIR/config.json"

# Create default config if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" << 'EOF'
{
    "wallpaper": {
        "current": "",
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
	    "wofi": true,
        "btop": true,
        "fish": true,
        "hyprland": true
    }
}
EOF
    echo "Created default config at $CONFIG_FILE"
fi

# Parse arguments
IMAGE_PATH=""
MODE=""
SCHEME=""
APPLY_NOW=true

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    --image PATH        Set wallpaper from image path
    --color HEX         Generate theme from hex color (e.g., #89b4fa)
    --mode MODE         Set mode: dark or light
    --scheme SCHEME     Set Material You scheme (vibrant, tonal-spot, etc.)
    --no-apply          Don't apply theme immediately
    -h, --help          Show this help message

Examples:
    $0 --image ~/Pictures/wallpaper.jpg
    $0 --image ~/Pictures/wallpaper.jpg --mode dark --scheme vibrant
    $0 --color "#89b4fa" --mode light
EOF
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --image)
            IMAGE_PATH="$2"
            shift 2
            ;;
        --color)
            COLOR_HEX="$2"
            shift 2
            ;;
        --mode)
            MODE="$2"
            shift 2
            ;;
        --scheme)
            SCHEME="$2"
            shift 2
            ;;
        --no-apply)
            APPLY_NOW=false
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Read current config
if command -v jq >/dev/null 2>&1; then
    WALLPAPER_BACKEND=$(jq -r '.wallpaper.backend // "hyprpaper"' "$CONFIG_FILE")
    [ -z "$MODE" ] && MODE=$(jq -r '.theming.mode // "dark"' "$CONFIG_FILE")
    [ -z "$SCHEME" ] && SCHEME=$(jq -r '.theming.scheme // "vibrant"' "$CONFIG_FILE")
    SMART_SCHEME=$(jq -r '.theming.smart_scheme // true' "$CONFIG_FILE")
    HARMONY=$(jq -r '.theming.harmony // 0.8' "$CONFIG_FILE")
    TRANSPARENCY=$(jq -r '.theming.transparency // "opaque"' "$CONFIG_FILE")
else
    echo "Warning: jq not found, using defaults"
    WALLPAPER_BACKEND="hyprpaper"
    [ -z "$MODE" ] && MODE="dark"
    [ -z "$SCHEME" ] && SCHEME="vibrant"
    SMART_SCHEME=true
    HARMONY=0.8
    TRANSPARENCY="opaque"
fi

# Validate input
if [ -z "$IMAGE_PATH" ] && [ -z "$COLOR_HEX" ]; then
    echo "Error: Must provide either --image or --color"
    show_help
    exit 1
fi

# Set wallpaper if image provided
if [ -n "$IMAGE_PATH" ]; then
    if [ ! -f "$IMAGE_PATH" ]; then
        echo "Error: Image file not found: $IMAGE_PATH"
        exit 1
    fi

    # Expand path
    IMAGE_PATH=$(realpath "$IMAGE_PATH")

    # Save wallpaper path
    if command -v jq >/dev/null 2>&1; then
        tmp=$(mktemp)
        jq --arg path "$IMAGE_PATH" '.wallpaper.current = $path' "$CONFIG_FILE" > "$tmp"
        mv "$tmp" "$CONFIG_FILE"
    fi

    # Set wallpaper based on backend
    case "$WALLPAPER_BACKEND" in
        hyprpaper)
            if command -v hyprctl >/dev/null 2>&1; then
                # Update hyprpaper config
                HYPRPAPER_CONF="$XDG_CONFIG_HOME/hypr/hyprpaper.conf"
                if [ -f "$HYPRPAPER_CONF" ]; then
                    # Get current monitor
                    MONITOR=$(hyprctl monitors -j | jq -r '.[0].name')

                    # Kill existing hyprpaper
                    killall hyprpaper 2>/dev/null || true

                    # Update config with new hyprpaper syntax
                    cat > "$HYPRPAPER_CONF" << EOF
wallpaper {
    monitor = $MONITOR
    path = $IMAGE_PATH
    fit_mode = cover
}

splash = false
EOF
                    # Start hyprpaper
                    hyprpaper &
                fi
            fi
            ;;
        swww)
            if command -v swww >/dev/null 2>&1; then
                swww img "$IMAGE_PATH" --transition-type fade --transition-duration 2
            fi
            ;;
        swaybg)
            if command -v swaybg >/dev/null 2>&1; then
                killall swaybg 2>/dev/null || true
                swaybg -i "$IMAGE_PATH" -m fill &
            fi
            ;;
        *)
            echo "Unknown wallpaper backend: $WALLPAPER_BACKEND"
            ;;
    esac

    echo "Wallpaper set to: $IMAGE_PATH"
fi

# Generate color scheme
echo "Generating Material You color scheme..."

GENERATOR_SCRIPT="$THEME_DIR/generate_material_theme.py"
if [ ! -f "$GENERATOR_SCRIPT" ]; then
    echo "Error: Generator script not found: $GENERATOR_SCRIPT"
    exit 1
fi

# Build generation command
GEN_CMD="python3 '$GENERATOR_SCRIPT'"
GEN_CMD="$GEN_CMD --mode '$MODE'"
GEN_CMD="$GEN_CMD --scheme '$SCHEME'"
GEN_CMD="$GEN_CMD --harmony $HARMONY"
GEN_CMD="$GEN_CMD --transparency '$TRANSPARENCY'"

if [ -n "$IMAGE_PATH" ]; then
    GEN_CMD="$GEN_CMD --path '$IMAGE_PATH'"
    [ "$SMART_SCHEME" = "true" ] && GEN_CMD="$GEN_CMD --smart"
elif [ -n "$COLOR_HEX" ]; then
    GEN_CMD="$GEN_CMD --color '$COLOR_HEX'"
fi

# Check which apps are enabled and generate themes
if command -v jq >/dev/null 2>&1; then
    ENABLE_KITTY=$(jq -r '.applications.kitty // true' "$CONFIG_FILE")
    ENABLE_NVIM=$(jq -r '.applications.nvim // true' "$CONFIG_FILE")
    ENABLE_LAZYGIT=$(jq -r '.applications.lazygit // true' "$CONFIG_FILE")
    ENABLE_STARSHIP=$(jq -r '.applications.starship // true' "$CONFIG_FILE")
    ENABLE_WOFI=$(jq -r '.applications.wofi | if type == "object" then .enabled else . end // false' "$CONFIG_FILE")
    ENABLE_GLOW=$(jq -r '.applications.glow // true' "$CONFIG_FILE")
    ENABLE_YAZI=$(jq -r '.applications.yazi // true' "$CONFIG_FILE")
    ENABLE_FZF=$(jq -r '.applications.fzf // true' "$CONFIG_FILE")
    ENABLE_BTOP=$(jq -r '.applications.btop // true' "$CONFIG_FILE")
    ENABLE_FISH=$(jq -r '.applications.fish // true' "$CONFIG_FILE")

    [ "$ENABLE_KITTY" = "true" ] && GEN_CMD="$GEN_CMD --generate-kitty"
    [ "$ENABLE_NVIM" = "true" ] && GEN_CMD="$GEN_CMD --generate-nvim"
    [ "$ENABLE_LAZYGIT" = "true" ] && GEN_CMD="$GEN_CMD --generate-lazygit"
    [ "$ENABLE_GLOW" = "true" ] && GEN_CMD="$GEN_CMD --generate-glow"
    [ "$ENABLE_STARSHIP" = "true" ] && GEN_CMD="$GEN_CMD --generate-starship --starship-output ~/.config/starship.toml"
    [ "$ENABLE_WOFI" = "true" ] && GEN_CMD="$GEN_CMD --generate-wofi"
    [ "$ENABLE_YAZI" = "true" ] && GEN_CMD="$GEN_CMD --generate-yazi"
    [ "$ENABLE_FZF" = "true" ] && GEN_CMD="$GEN_CMD --generate-fzf"
    [ "$ENABLE_BTOP" = "true" ] && GEN_CMD="$GEN_CMD --generate-btop"
    [ "$ENABLE_FISH" = "true" ] && GEN_CMD="$GEN_CMD --generate-fish"
else
    GEN_CMD="$GEN_CMD --generate-all"
fi

GEN_CMD="$GEN_CMD --debug"

# Execute generation
echo "Running: $GEN_CMD"
eval $GEN_CMD

if [ $? -eq 0 ]; then
    echo "✓ Color scheme generated successfully"
else
    echo "✗ Failed to generate color scheme"
    exit 1
fi

# Generate Waybar theme if enabled
if command -v jq >/dev/null 2>&1; then
    ENABLE_WAYBAR=$(jq -r '.applications.waybar // true' "$CONFIG_FILE")
    if [ "$ENABLE_WAYBAR" = "true" ]; then
        echo "Generating Waybar theme..."
        WAYBAR_GENERATOR="$THEME_DIR/generate_waybar_theme.py"
        if [ -f "$WAYBAR_GENERATOR" ]; then
            python3 "$WAYBAR_GENERATOR" --colors-file "$STATE_DIR/colors.json" --debug
            if [ $? -eq 0 ]; then
                echo "  ✓ Waybar theme generated"
            else
                echo "  ✗ Failed to generate Waybar theme"
            fi
        else
            echo "  ⚠ Waybar generator not found: $WAYBAR_GENERATOR"
        fi
    fi
fi

# Apply themes to running terminals (if applicable)
if [ "$APPLY_NOW" = true ]; then
    echo "Applying themes to running applications..."

    # Reload kitty if running
    if command -v kitty >/dev/null 2>&1 && pgrep -x kitty >/dev/null; then
        killall -SIGUSR1 kitty 2>/dev/null || true
        echo "  ✓ Kitty reloaded"
    fi

    # Apply Fish theme (works from any shell)
    if command -v fish >/dev/null 2>&1; then
        FISH_APPLY_SCRIPT="$THEME_DIR/apply_fish_colors.sh"
        if [ -f "$FISH_APPLY_SCRIPT" ]; then
            bash "$FISH_APPLY_SCRIPT"
        else
            # Fallback: basic reload for current shell
            if [ -n "$FISH_VERSION" ]; then
                source "$XDG_CONFIG_HOME/fish/conf.d/material_you_colors.fish" 2>/dev/null || true
                echo "  ✓ Fish colors reloaded"
            fi
        fi
    fi

    # Restart Waybar if available
    if command -v waybar >/dev/null 2>&1; then
        echo "  Restarting Waybar..."

        # Kill if running
        if pgrep -x waybar >/dev/null; then
            killall waybar
            sleep 0.5
        fi

        # Start Waybar
        nohup waybar > /tmp/waybar.log 2>&1 &
        sleep 1.5

        # Verify it started
        if pgrep -x waybar >/dev/null; then
            echo "  ✓ Waybar reloaded"
        else
            echo "  ✗ Waybar failed to start"
            echo "  Check log: tail /tmp/waybar.log"
        fi
    fi

    # Update Hyprland colors if running
    if command -v hyprctl >/dev/null 2>&1 && [ -f "$STATE_DIR/colors.json" ]; then
        PRIMARY=$(jq -r '.material.primary' "$STATE_DIR/colors.json")
        SURFACE=$(jq -r '.material.surface' "$STATE_DIR/colors.json")
        if [ -n "$PRIMARY" ] && [ -n "$SURFACE" ]; then
            hyprctl keyword general:col.active_border "rgb(${PRIMARY#\#})" 2>/dev/null || true
            hyprctl keyword general:col.inactive_border "rgb(${SURFACE#\#})" 2>/dev/null || true
            echo "  ✓ Hyprland colors updated"
        fi
    fi
fi

echo ""
echo "Theme switch complete!"
echo "Current wallpaper: ${IMAGE_PATH:-$COLOR_HEX}"
echo "Mode: $MODE | Scheme: $SCHEME"
echo ""
echo "Note: Some applications may need to be restarted to see changes."
