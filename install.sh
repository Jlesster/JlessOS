#!/usr/bin/env bash
# JlessOS Dotfiles Installer - Symlink Version with Monitor Detection

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[*]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

confirm() {
    read -p "$(echo -e ${YELLOW}$1 [y/N]:${NC})" -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)"
NVIM_REPO="https://github.com/Jlesster/nvimConf.git"

echo -e "${BLUE}"
cat <<'EOF'
   ╦╦  ╔═╗╔═╗╔═╗╔═╗╔═╗
   ║║  ║╣ ╚═╗╚═╗║ ║╚═╗
  ╚╝╚═╝╚═╝╚═╝╚═╝╚═╝╚═╝
   Dotfiles Installer
EOF
echo -e "${NC}"

# Check if running on Arch
if ! grep -qi arch /etc/os-release 2>/dev/null; then
    warn "Not detected as Arch-based system"
    confirm "Continue anyway?" || exit 0
fi

# === MONITOR DETECTION FUNCTION ===
detect_monitors() {
    info "Detecting monitors..."

    # Array to store monitor configurations
    declare -g -a MONITORS
    declare -g -a MONITOR_RESOLUTIONS
    declare -g -a MONITOR_REFRESH_RATES
    declare -g -a MONITOR_POSITIONS

    # Try to detect monitors using different methods
    if command -v hyprctl &>/dev/null && [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
        # If already in Hyprland session
        info "Detecting via hyprctl..."
        MONITOR_COUNT=$(hyprctl monitors -j | jq '. | length')

        for i in $(seq 0 $((MONITOR_COUNT - 1))); do
            MONITOR_NAME=$(hyprctl monitors -j | jq -r ".[$i].name")
            MONITOR_WIDTH=$(hyprctl monitors -j | jq -r ".[$i].width")
            MONITOR_HEIGHT=$(hyprctl monitors -j | jq -r ".[$i].height")
            MONITOR_REFRESH=$(hyprctl monitors -j | jq -r ".[$i].refreshRate")
            MONITOR_X=$(hyprctl monitors -j | jq -r ".[$i].x")
            MONITOR_Y=$(hyprctl monitors -j | jq -r ".[$i].y")

            MONITORS+=("$MONITOR_NAME")
            MONITOR_RESOLUTIONS+=("${MONITOR_WIDTH}x${MONITOR_HEIGHT}")
            MONITOR_REFRESH_RATES+=("$MONITOR_REFRESH")
            MONITOR_POSITIONS+=("${MONITOR_X}x${MONITOR_Y}")
        done
    elif command -v wlr-randr &>/dev/null; then
        # Use wlr-randr if available
        info "Detecting via wlr-randr..."
        while IFS= read -r line; do
            if [[ $line =~ ^([A-Z0-9-]+)[[:space:]] ]]; then
                MONITOR_NAME="${BASH_REMATCH[1]}"
                MONITORS+=("$MONITOR_NAME")
                # Default to common resolution
                MONITOR_RESOLUTIONS+=("1920x1080")
                MONITOR_REFRESH_RATES+=("60")
                MONITOR_POSITIONS+=("auto")
            fi
        done < <(wlr-randr)
    elif command -v xrandr &>/dev/null; then
        # Fallback to xrandr detection (for X11)
        info "Detecting via xrandr..."
        while IFS= read -r line; do
            if [[ $line =~ ^([A-Z0-9-]+)[[:space:]]connected ]]; then
                MONITOR_NAME="${BASH_REMATCH[1]}"
                MONITORS+=("$MONITOR_NAME")

                # Try to extract resolution
                if [[ $line =~ ([0-9]+)x([0-9]+)\+[0-9]+\+[0-9]+[[:space:]]+([0-9]+\.[0-9]+)\* ]]; then
                    MONITOR_RESOLUTIONS+=("${BASH_REMATCH[1]}x${BASH_REMATCH[2]}")
                    MONITOR_REFRESH_RATES+=("${BASH_REMATCH[3]}")
                else
                    MONITOR_RESOLUTIONS+=("1920x1080")
                    MONITOR_REFRESH_RATES+=("60")
                fi
                MONITOR_POSITIONS+=("auto")
            fi
        done < <(xrandr)
    else
        # Manual detection fallback
        warn "No monitor detection tools available"
        return 1
    fi

    # If no monitors detected, ask user
    if [[ ${#MONITORS[@]} -eq 0 ]]; then
        warn "No monitors detected automatically"
        return 1
    fi

    success "Detected ${#MONITORS[@]} monitor(s)"
    for i in "${!MONITORS[@]}"; do
        info "  Monitor $((i + 1)): ${MONITORS[$i]} @ ${MONITOR_RESOLUTIONS[$i]} ${MONITOR_REFRESH_RATES[$i]}Hz"
    done

    return 0
}

# === CONFIGURE HYPRLAND FOR MONITORS ===
configure_hyprland_monitors() {
    local HYPR_CONF="$SOURCE_DIR/hypr/hyprland.conf"

    if [[ ! -f "$HYPR_CONF" ]]; then
        warn "hyprland.conf not found in source, skipping monitor configuration"
        return 1
    fi

    info "Configuring Hyprland monitors in source repo..."

    # Backup original in the dotfiles repo
    cp "$HYPR_CONF" "${HYPR_CONF}.pre-monitor-detection"

    # Remove existing monitor configurations
    sed -i '/^monitor[[:space:]]*=/d' "$HYPR_CONF"

    # Add new monitor configurations
    # Find the appropriate place to insert (after initial comments, before first section)
    local INSERT_LINE=$(grep -n "^#.*Monitor Configuration" "$HYPR_CONF" | head -1 | cut -d: -f1)

    if [[ -z "$INSERT_LINE" ]]; then
        # If no monitor section marker found, insert after first block of comments
        INSERT_LINE=$(awk '/^[^#]/ {print NR; exit}' "$HYPR_CONF")
        [[ -z "$INSERT_LINE" ]] && INSERT_LINE=1

        # Add section header
        sed -i "${INSERT_LINE}i\# ===== Monitor Configuration (Auto-generated) =====" "$HYPR_CONF"
        ((INSERT_LINE++))
    else
        ((INSERT_LINE++))
    fi

    # Generate monitor configurations
    for i in "${!MONITORS[@]}"; do
        local MONITOR="${MONITORS[$i]}"
        local RESOLUTION="${MONITOR_RESOLUTIONS[$i]}"
        local REFRESH="${MONITOR_REFRESH_RATES[$i]}"
        local POSITION="${MONITOR_POSITIONS[$i]}"

        # Format refresh rate (remove decimals if whole number)
        REFRESH=$(echo "$REFRESH" | awk '{print int($1+0.5)}')

        # Determine position
        if [[ "$POSITION" == "auto" ]]; then
            if [[ $i -eq 0 ]]; then
                POSITION="0x0"
            else
                POSITION="auto"
            fi
        fi

        local MONITOR_LINE="monitor = $MONITOR, ${RESOLUTION}@${REFRESH}, $POSITION, 1"
        sed -i "${INSERT_LINE}i\\${MONITOR_LINE}" "$HYPR_CONF"
        ((INSERT_LINE++))
    done

    # Add fallback for unknown monitors
    sed -i "${INSERT_LINE}i\\monitor = , preferred, auto, 1" "$HYPR_CONF"
    sed -i "${INSERT_LINE}i\\" "$HYPR_CONF"

    success "Hyprland monitor configuration updated in dotfiles repo"
    info "Backup saved: ${HYPR_CONF}.pre-monitor-detection"
}

# === CONFIGURE HYPRPAPER FOR MONITORS ===
configure_hyprpaper() {
    local HYPRPAPER_CONF="$SOURCE_DIR/hypr/hyprpaper.conf"

    if [[ ! -f "$HYPRPAPER_CONF" ]]; then
        # Create a basic hyprpaper.conf if it doesn't exist
        info "Creating hyprpaper.conf in dotfiles repo..."
        mkdir -p "$SOURCE_DIR/hypr"
        cat >"$HYPRPAPER_CONF" <<'HYPRPAPER_EOF'
# Hyprpaper Configuration (Auto-generated)

# Preload wallpapers
# preload = ~/path/to/wallpaper.jpg

# Set wallpapers per monitor
# wallpaper = MONITOR_NAME, ~/path/to/wallpaper.jpg

# Disable splash text
splash = false

# Disable IPC
ipc = off
HYPRPAPER_EOF
    else
        # Backup original
        cp "$HYPRPAPER_CONF" "${HYPRPAPER_CONF}.pre-monitor-detection"
    fi

    info "Configuring Hyprpaper monitors in source repo..."

    # Remove existing wallpaper configurations (keep preload lines)
    sed -i '/^wallpaper[[:space:]]*=/d' "$HYPRPAPER_CONF"

    # Add wallpaper entries for each monitor
    echo "" >>"$HYPRPAPER_CONF"
    echo "# Monitor wallpaper assignments (Auto-generated)" >>"$HYPRPAPER_CONF"

    for MONITOR in "${MONITORS[@]}"; do
        echo "wallpaper = $MONITOR, ~/path/to/wallpaper.jpg" >>"$HYPRPAPER_CONF"
    done

    success "Hyprpaper configuration updated in dotfiles repo"
    [[ -f "${HYPRPAPER_CONF}.pre-monitor-detection" ]] && info "Backup saved: ${HYPRPAPER_CONF}.pre-monitor-detection"
    info "Remember to update wallpaper paths in $HYPRPAPER_CONF"
}

# === INSTALL DEPENDENCIES ===
if confirm "Install dependencies?"; then
    info "Installing packages..."

    # Core packages
    sudo pacman -S --needed \
        base-devel git wget curl \
        hyprland waybar wofi dunst grim slurp wl-clipboard \
        kitty fish \
        neovim lazygit \
        yazi fastfetch ripgrep fd fzf bat eza \
        pipewire wireplumber \
        brightnessctl playerctl pamixer \
        noto-fonts-emoji ttf-jetbrains-mono-nerd \
        python-pillow python-opencv \
        jq || warn "Some packages failed"

    # Install yay
    if ! command -v yay &>/dev/null; then
        info "Installing yay..."
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        (cd /tmp/yay && makepkg -si --noconfirm)
        rm -rf /tmp/yay
        success "yay installed"
    fi

    # AUR packages
    if command -v yay &>/dev/null && confirm "Install AUR packages?"; then
        yay -S --needed grimblast-git hyprpicker wlr-randr || warn "Some AUR packages failed"
    fi

    success "Dependencies installed"
fi

# === BACKUP EXISTING CONFIGS ===
CONFIGS=(hypr waybar wofi kitty fish yazi fastfetch lazygit Kvantum scripts)
NEEDS_BACKUP=false

for conf in "${CONFIGS[@]}"; do
    [[ -e "$CONFIG_DIR/$conf" ]] && NEEDS_BACKUP=true && break
done

if $NEEDS_BACKUP && confirm "Backup existing configs?"; then
    mkdir -p "$BACKUP_DIR"
    for conf in "${CONFIGS[@]}"; do
        if [[ -e "$CONFIG_DIR/$conf" ]]; then
            info "Backing up $conf..."
            mv "$CONFIG_DIR/$conf" "$BACKUP_DIR/" 2>/dev/null || warn "Couldn't backup $conf"
        fi
    done
    success "Backed up to $BACKUP_DIR"
fi

# === DETERMINE SOURCE DIRECTORY ===
if [[ -d "$SCRIPT_DIR/.config" ]]; then
    SOURCE_DIR="$SCRIPT_DIR/.config"
else
    SOURCE_DIR="$SCRIPT_DIR"
fi

info "Using source: $SOURCE_DIR"

# === DETECT AND CONFIGURE MONITORS (BEFORE SYMLINKING) ===
if confirm "Auto-detect and configure monitors?"; then
    if detect_monitors; then
        configure_hyprland_monitors
        configure_hyprpaper

        # Offer to commit changes to git
        if [[ -d "$SCRIPT_DIR/.git" ]] && command -v git &>/dev/null; then
            echo ""
            info "Monitor configurations have been written to your dotfiles repo"
            if confirm "Commit monitor changes to git?"; then
                cd "$SCRIPT_DIR"
                git add "$SOURCE_DIR/hypr/hyprland.conf" "$SOURCE_DIR/hypr/hyprpaper.conf" 2>/dev/null
                git commit -m "Auto-configure monitors: ${MONITORS[*]}" 2>/dev/null && success "Changes committed"
            fi
        fi
    else
        warn "Monitor detection failed. You'll need to configure monitors manually."
        info "Edit: $SOURCE_DIR/hypr/hyprland.conf"
        info "Edit: $SOURCE_DIR/hypr/hyprpaper.conf"
    fi
fi

# === SYMLINK CONFIGS ===
info "Creating symlinks for configurations..."

LINKED=0
for conf in "${CONFIGS[@]}"; do
    if [[ -d "$SOURCE_DIR/$conf" ]] || [[ -f "$SOURCE_DIR/$conf" ]]; then
        info "Symlinking $conf..."
        mkdir -p "$CONFIG_DIR"

        SOURCE_PATH="$SOURCE_DIR/$conf"
        DEST_PATH="$CONFIG_DIR/$conf"

        # Remove destination if it exists (could be old symlink or directory)
        if [[ -L "$DEST_PATH" ]]; then
            info "Removing old symlink: $conf"
            rm "$DEST_PATH"
        elif [[ -e "$DEST_PATH" ]]; then
            warn "$conf already exists and is not a symlink (should have been backed up)"
        fi

        # Create symlink
        if ln -s "$SOURCE_PATH" "$DEST_PATH"; then
            success "$conf symlinked"
            ((LINKED++))
        else
            error "Failed to symlink $conf"
        fi
    else
        warn "$conf not found in repo, skipping"
    fi
done

[[ $LINKED -eq 0 ]] && error "No configs were symlinked!"

info "Symlinked $LINKED of ${#CONFIGS[@]} configs"

# === INSTALL FONTS ===
if [[ -d "$SCRIPT_DIR/Fonts" ]]; then
    info "Installing custom fonts..."
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    cp -r "$SCRIPT_DIR/Fonts"/* "$FONT_DIR/" 2>/dev/null || true
    fc-cache -fv >/dev/null 2>&1
    success "Fonts installed"
fi

# === SETUP MATERIAL THEME ===
if [[ -d "$SCRIPT_DIR/colorscheming" ]]; then
    info "Setting up Material You theme..."
    THEME_DIR="$CONFIG_DIR/material-theme"

    # Remove old material-theme if exists
    [[ -L "$THEME_DIR" ]] && rm "$THEME_DIR"
    [[ -d "$THEME_DIR" ]] && rm -rf "$THEME_DIR"

    # Symlink the theme directory
    if ln -s "$SCRIPT_DIR/colorscheming" "$THEME_DIR"; then
        find "$SCRIPT_DIR/colorscheming" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} \;
        success "Theme system symlinked"
    else
        warn "Failed to symlink theme system, copying instead..."
        mkdir -p "$THEME_DIR"
        cp -r "$SCRIPT_DIR/colorscheming"/* "$THEME_DIR/"
        find "$THEME_DIR" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} \;
    fi
fi

# === CLONE NEOVIM CONFIG ===
if confirm "Install nvim config from separate repo?"; then
    if [[ -d "$HOME/.dotfiles/nvimConf" ]]; then
        info "Updating nvimConf..."
        (cd "$HOME/.dotfiles/nvimConf" && git pull)
    else
        info "Cloning nvimConf..."
        mkdir -p "$HOME/.dotfiles"
        git clone "$NVIM_REPO" "$HOME/.dotfiles/nvimConf"
    fi

    info "Symlinking nvim config..."
    NVIM_DEST="$CONFIG_DIR/nvim"

    # Remove old nvim config
    [[ -L "$NVIM_DEST" ]] && rm "$NVIM_DEST"
    [[ -d "$NVIM_DEST" ]] && rm -rf "$NVIM_DEST"

    # Symlink nvim config
    if ln -s "$HOME/.dotfiles/nvimConf" "$NVIM_DEST"; then
        success "nvim config symlinked"
    else
        warn "Failed to symlink, copying instead..."
        cp -rf "$HOME/.dotfiles/nvimConf" "$NVIM_DEST"
    fi
fi

# === SETUP FISH SHELL ===
if command -v fish &>/dev/null && [[ "$SHELL" != "$(which fish)" ]]; then
    if confirm "Set Fish as default shell?"; then
        FISH_PATH=$(which fish)
        grep -q "$FISH_PATH" /etc/shells || echo "$FISH_PATH" | sudo tee -a /etc/shells
        chsh -s "$FISH_PATH"
        success "Fish set as default shell (restart to apply)"
    fi
fi

# === SETUP SCRIPTS IN ~/.local/bin ===
if [[ -d "$SOURCE_DIR/scripts" ]]; then
    info "Setting up scripts in ~/.local/bin..."
    BIN_DIR="$HOME/.local/bin"
    mkdir -p "$BIN_DIR"

    # Make scripts executable first
    find "$SOURCE_DIR/scripts" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} \;

    # Create symlinks for each script
    LINKED_SCRIPTS=0
    for script in "$SOURCE_DIR/scripts"/*; do
        if [[ -f "$script" ]]; then
            SCRIPT_NAME=$(basename "$script")
            LINK_PATH="$BIN_DIR/$SCRIPT_NAME"

            # Remove existing symlink/file if it exists
            [[ -e "$LINK_PATH" ]] && rm -f "$LINK_PATH"

            # Create symlink
            if ln -s "$script" "$LINK_PATH"; then
                ((LINKED_SCRIPTS++))
            else
                warn "Failed to link $SCRIPT_NAME"
            fi
        fi
    done

    success "Linked $LINKED_SCRIPTS scripts to ~/.local/bin"

    # Check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        warn "~/.local/bin is not in your PATH"
        info "Add this to your shell config:"
        echo '  export PATH="$HOME/.local/bin:$PATH"'
    fi
fi

echo ""
success "Installation complete! 🎉"
echo ""
info "All configs are now SYMLINKED to your dotfiles repo"
info "Changes you make in ~/.config will reflect in your repo"
echo ""
info "Next steps:"
echo "  1. Log out and select Hyprland session"
echo "  2. Open terminal (Super+Enter)"
echo "  3. Run: ~/.config/material-theme/switchwall.sh --image ~/path/to/wallpaper.jpg"
[[ -d "$BACKUP_DIR" ]] && echo "  4. Old configs: $BACKUP_DIR"
echo ""
info "To update your dotfiles:"
echo "  cd $SCRIPT_DIR"
echo "  git add -A && git commit -m 'Update configs' && git push"
