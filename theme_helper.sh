#!/usr/bin/env bash
# JlessOS Material You Theme Helper
# Quick theme generation and application

set -e

# Colors
readonly BLUE='\033[0;34m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

THEME_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/material-theme"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

print_header() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════╗"
    echo "║   JlessOS Theme Manager        ║"
    echo "╚════════════════════════════════╝"
    echo -e "${NC}"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if theming system is installed
check_installation() {
    if [ ! -f "$THEME_DIR/switchwall.sh" ]; then
        print_error "Material You theming system not found!"
        echo "Please run the JlessOS installer first."
        exit 1
    fi
    
    if ! command -v python3 >/dev/null 2>&1; then
        print_error "Python 3 is required but not found"
        exit 1
    fi
    
    if ! python3 -c "import materialyoucolor" 2>/dev/null; then
        print_error "materialyoucolor package not found"
        echo "Install with: pip3 install --user materialyoucolor"
        exit 1
    fi
}

# List available wallpapers
list_wallpapers() {
    if [ ! -d "$WALLPAPER_DIR" ]; then
        print_error "Wallpaper directory not found: $WALLPAPER_DIR"
        return 1
    fi
    
    echo -e "${BLUE}Available wallpapers:${NC}"
    local i=1
    find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | while read -r file; do
        echo "  [$i] $(basename "$file")"
        ((i++))
    done
}

# Apply theme from wallpaper
apply_wallpaper_theme() {
    local wallpaper="$1"
    local mode="${2:-dark}"
    local scheme="${3:-vibrant}"
    
    if [ ! -f "$wallpaper" ]; then
        print_error "Wallpaper not found: $wallpaper"
        return 1
    fi
    
    print_info "Generating theme from: $(basename "$wallpaper")"
    print_info "Mode: $mode | Scheme: $scheme"
    
    bash "$THEME_DIR/switchwall.sh" \
        --image "$wallpaper" \
        --mode "$mode" \
        --scheme "$scheme"
    
    if [ $? -eq 0 ]; then
        print_success "Theme applied successfully!"
    else
        print_error "Failed to apply theme"
        return 1
    fi
}

# Apply theme from color
apply_color_theme() {
    local color="$1"
    local mode="${2:-dark}"
    local scheme="${3:-vibrant}"
    
    # Validate hex color
    if [[ ! "$color" =~ ^#[0-9A-Fa-f]{6}$ ]]; then
        print_error "Invalid hex color: $color"
        echo "Format should be: #RRGGBB (e.g., #89b4fa)"
        return 1
    fi
    
    print_info "Generating theme from color: $color"
    print_info "Mode: $mode | Scheme: $scheme"
    
    bash "$THEME_DIR/switchwall.sh" \
        --color "$color" \
        --mode "$mode" \
        --scheme "$scheme"
    
    if [ $? -eq 0 ]; then
        print_success "Theme applied successfully!"
    else
        print_error "Failed to apply theme"
        return 1
    fi
}

# Interactive wallpaper selection
select_wallpaper() {
    if [ ! -d "$WALLPAPER_DIR" ]; then
        print_error "Wallpaper directory not found: $WALLPAPER_DIR"
        return 1
    fi
    
    # Create array of wallpapers
    local wallpapers=()
    while IFS= read -r file; do
        wallpapers+=("$file")
    done < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | sort)
    
    if [ ${#wallpapers[@]} -eq 0 ]; then
        print_error "No wallpapers found in $WALLPAPER_DIR"
        return 1
    fi
    
    echo -e "${BLUE}Select a wallpaper:${NC}"
    for i in "${!wallpapers[@]}"; do
        echo "  [$((i+1))] $(basename "${wallpapers[$i]}")"
    done
    
    echo ""
    read -p "Enter number (1-${#wallpapers[@]}): " selection
    
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#wallpapers[@]} ]; then
        local idx=$((selection-1))
        echo "${wallpapers[$idx]}"
        return 0
    else
        print_error "Invalid selection"
        return 1
    fi
}

# Show current theme info
show_current_theme() {
    local colors_file="$HOME/.local/state/material-theme/colors.json"
    
    if [ ! -f "$colors_file" ]; then
        print_info "No theme currently applied"
        return
    fi
    
    if command -v jq >/dev/null 2>&1; then
        echo -e "${BLUE}Current theme:${NC}"
        echo "  Mode: $(jq -r '.mode' "$colors_file")"
        echo "  Source: $(jq -r '.source_color' "$colors_file")"
        echo ""
        echo "  Primary: $(jq -r '.material.primary' "$colors_file")"
        echo "  Secondary: $(jq -r '.material.secondary' "$colors_file")"
        echo "  Surface: $(jq -r '.material.surface' "$colors_file")"
    else
        print_info "Install jq to view theme details"
        echo "Theme file: $colors_file"
    fi
}

# Main menu
show_menu() {
    print_header
    echo "1) Apply theme from wallpaper"
    echo "2) Apply theme from color"
    echo "3) Select wallpaper interactively"
    echo "4) List wallpapers"
    echo "5) Show current theme"
    echo "6) Toggle dark/light mode"
    echo "0) Exit"
    echo ""
}

# Toggle mode
toggle_mode() {
    local colors_file="$HOME/.local/state/material-theme/colors.json"
    
    if [ ! -f "$colors_file" ]; then
        print_error "No theme to toggle. Apply a theme first."
        return 1
    fi
    
    local current_mode=$(jq -r '.mode' "$colors_file" 2>/dev/null || echo "dark")
    local new_mode="light"
    [ "$current_mode" = "light" ] && new_mode="dark"
    
    local source=$(jq -r '.source_color' "$colors_file" 2>/dev/null)
    
    if [ -n "$source" ]; then
        print_info "Switching to $new_mode mode..."
        bash "$THEME_DIR/switchwall.sh" --color "$source" --mode "$new_mode"
    else
        print_error "Could not determine source color"
        return 1
    fi
}

# Main script
main() {
    check_installation
    
    # If arguments provided, use them
    if [ $# -gt 0 ]; then
        case "$1" in
            --wallpaper|-w)
                shift
                apply_wallpaper_theme "$@"
                ;;
            --color|-c)
                shift
                apply_color_theme "$@"
                ;;
            --toggle|-t)
                toggle_mode
                ;;
            --list|-l)
                list_wallpapers
                ;;
            --current|-s)
                show_current_theme
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  -w, --wallpaper PATH [MODE] [SCHEME]    Apply theme from wallpaper"
                echo "  -c, --color HEX [MODE] [SCHEME]         Apply theme from color"
                echo "  -t, --toggle                             Toggle dark/light mode"
                echo "  -l, --list                               List available wallpapers"
                echo "  -s, --current                            Show current theme"
                echo "  -h, --help                               Show this help"
                echo ""
                echo "Examples:"
                echo "  $0 -w ~/Pictures/wallpaper.jpg dark vibrant"
                echo "  $0 -c '#89b4fa' light"
                echo "  $0 -t"
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
        exit $?
    fi
    
    # Interactive mode
    while true; do
        show_menu
        read -p "Select option: " choice
        
        case $choice in
            1)
                read -p "Wallpaper path: " wallpaper
                read -p "Mode (dark/light) [dark]: " mode
                mode=${mode:-dark}
                read -p "Scheme (vibrant/tonal-spot/neutral) [vibrant]: " scheme
                scheme=${scheme:-vibrant}
                apply_wallpaper_theme "$wallpaper" "$mode" "$scheme"
                read -p "Press Enter to continue..."
                ;;
            2)
                read -p "Hex color (e.g., #89b4fa): " color
                read -p "Mode (dark/light) [dark]: " mode
                mode=${mode:-dark}
                read -p "Scheme (vibrant/tonal-spot/neutral) [vibrant]: " scheme
                scheme=${scheme:-vibrant}
                apply_color_theme "$color" "$mode" "$scheme"
                read -p "Press Enter to continue..."
                ;;
            3)
                wallpaper=$(select_wallpaper)
                if [ $? -eq 0 ]; then
                    read -p "Mode (dark/light) [dark]: " mode
                    mode=${mode:-dark}
                    apply_wallpaper_theme "$wallpaper" "$mode" "vibrant"
                fi
                read -p "Press Enter to continue..."
                ;;
            4)
                list_wallpapers
                read -p "Press Enter to continue..."
                ;;
            5)
                show_current_theme
                read -p "Press Enter to continue..."
                ;;
            6)
                toggle_mode
                read -p "Press Enter to continue..."
                ;;
            0)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid option"
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

main "$@"
