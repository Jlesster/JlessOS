#!/usr/bin/env bash
# JlessOS Dotfiles Installer - Simplified

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
    read -p "$(echo -e ${YELLOW}$1 [y/N]:${NC} )" -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)"
NVIM_REPO="https://github.com/Jlesster/nvimConf.git"

echo -e "${BLUE}"
cat << 'EOF'
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
        python-pillow python-opencv || warn "Some packages failed"

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
        yay -S --needed grimblast-git hyprpicker || warn "Some AUR packages failed"
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

# === COPY CONFIGS ===
info "Copying configurations..."

# Determine source directory
if [[ -d "$SCRIPT_DIR/.config" ]]; then
    SOURCE_DIR="$SCRIPT_DIR/.config"
else
    SOURCE_DIR="$SCRIPT_DIR"
fi

info "Using source: $SOURCE_DIR"

# Copy each config
COPIED=0
for conf in "${CONFIGS[@]}"; do
    if [[ -d "$SOURCE_DIR/$conf" ]]; then
        info "Installing $conf..."
        mkdir -p "$CONFIG_DIR"

        # Remove destination if it exists (prevents cp errors)
        [[ -e "$CONFIG_DIR/$conf" ]] && rm -rf "$CONFIG_DIR/$conf"

        # Copy with error handling
        if cp -r "$SOURCE_DIR/$conf" "$CONFIG_DIR/"; then
            success "$conf installed"
            ((COPIED++))
        else
            warn "Failed to copy $conf"
        fi
    else
        warn "$conf not found in repo, skipping"
    fi
done

[[ $COPIED -eq 0 ]] && error "No configs were copied!"

info "Copied $COPIED of ${#CONFIGS[@]} configs"

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
    mkdir -p "$THEME_DIR"
    cp -r "$SCRIPT_DIR/colorscheming"/* "$THEME_DIR/"
    find "$THEME_DIR" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} \;
    success "Theme system installed"
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

    info "Installing nvim config..."
    mkdir -p "$CONFIG_DIR"
    cp -rf "$HOME/.dotfiles/nvimConf" "$CONFIG_DIR/nvim"
    success "nvim config installed"
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
    LINKED=0
    for script in "$SOURCE_DIR/scripts"/*; do
        if [[ -f "$script" ]]; then
            SCRIPT_NAME=$(basename "$script")
            LINK_PATH="$BIN_DIR/$SCRIPT_NAME"

            # Remove existing symlink/file if it exists
            [[ -e "$LINK_PATH" ]] && rm -f "$LINK_PATH"

            # Create symlink
            if ln -s "$script" "$LINK_PATH"; then
                ((LINKED++))
            else
                warn "Failed to link $SCRIPT_NAME"
            fi
        fi
    done

    success "Linked $LINKED scripts to ~/.local/bin"

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
info "Next steps:"
echo "  1. Log out and select Hyprland session"
echo "  2. Open terminal (Super+Enter)"
echo "  3. Run: ~/.config/material-theme/switchwall.sh --image ~/path/to/wallpaper.jpg"
[[ -d "$BACKUP_DIR" ]] && echo "  4. Old configs: $BACKUP_DIR"
