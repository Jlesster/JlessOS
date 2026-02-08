#!/usr/bin/env bash

# JlessOS Dotfiles Installer
# Complete installation script for Arch + Hyprland setup

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)"

# Repositories
JLESSOS_REPO="https://github.com/Jlesster/JlessOS.git"
NVIM_REPO="https://github.com/Jlesster/nvimConf.git"

# Print functions
print_header() {
    echo -e "${MAGENTA}"
    echo "================================"
    echo "  JlessOS Dotfiles Installer"
    echo "================================"
    echo -e "${NC}"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "\n${CYAN}▶${NC} ${BOLD}$1${NC}"
}

# Confirm action with user
confirm() {
    local prompt="$1"
    local default="${2:-n}"

    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi

    read -p "$prompt" -n 1 -r
    echo

    if [[ "$default" == "y" ]]; then
        [[ $REPLY =~ ^[Nn]$ ]] && return 1 || return 0
    else
        [[ $REPLY =~ ^[Yy]$ ]] && return 0 || return 1
    fi
}

# Execute command with error handling
execute() {
    local cmd="$1"
    local desc="${2:-Executing command}"

    print_info "$desc"
    echo -e "${YELLOW}  → ${cmd}${NC}"

    if eval "$cmd"; then
        print_success "Done"
        return 0
    else
        print_error "Failed: $desc"
        return 1
    fi
}

# Detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ -f /etc/arch-release ]; then
        echo "arch"
    else
        echo "unknown"
    fi
}

# Helper function to parse packages from dependency file
parse_packages() {
    local file="$1"

    # Extract packages (ignore comments and empty lines)
    grep -v '^#' "$file" | \
    grep -v '^$' | \
    tr '\n' ' '
}

# Install dependencies based on distro
install_dependencies() {
    print_step "Installing dependencies"

    local distro=$(detect_distro)

    case "$distro" in
        arch|endeavouros|cachyos|manjaro)
            install_arch_deps
            ;;
        *)
            print_warning "Unsupported distribution: $distro"
            print_info "This installer is designed for Arch-based systems"
            if confirm "Continue anyway?"; then
                return 0
            else
                exit 1
            fi
            ;;
    esac
}

install_arch_deps() {
    print_info "Detected Arch-based system"

    local deps_file="$SCRIPT_DIR/deps.txt"

    # Check if deps.txt exists
    if [ ! -f "$deps_file" ]; then
        print_error "deps.txt not found at $deps_file"
        print_info "Falling back to manual package list..."

        # Fallback to minimal core packages
        local core_packages=(
            base base-devel linux linux-firmware linux-headers amd-ucode
            sudo efibootmgr dkms ly zram-generator btrfs-progs fuse2 smartmontools
            networkmanager iwd wpa_supplicant wireless_tools
            bluez bluez-utils pipewire pipewire-alsa pipewire-jack pipewire-pulse
            hyprland hyprpaper waybar wofi dunst grim slurp wl-clipboard
            kitty fish git wget curl unzip zip ripgrep fd fzf bat eza
            neovim lazygit github-cli firefox chromium
            noto-fonts-emoji ttf-jetbrains-mono-nerd
        )
    else
        # Parse packages from deps.txt
        print_info "Loading packages from deps.txt..."
        local core_packages=$(parse_packages "$deps_file")

        # Remove packages that need special handling
        core_packages=$(echo "$core_packages" | sed 's/yay//g' | sed 's/tree-sitter-cli//g')
    fi

    # Show what will be installed
    local pkg_count=$(echo "$core_packages" | wc -w)
    print_info "Found $pkg_count packages to install"

    if confirm "Install $pkg_count packages with pacman?" "y"; then
        execute "sudo pacman -S --needed $core_packages" "Installing packages"
    fi

    # Install yay if not present
    if ! command -v yay &> /dev/null; then
        print_warning "yay not found. Installing yay AUR helper..."
        if confirm "Install yay?"; then
            execute "git clone https://aur.archlinux.org/yay.git /tmp/yay && cd /tmp/yay && makepkg -si --noconfirm" "Installing yay"
        fi
    fi

    # AUR packages
    if command -v yay &> /dev/null; then
        local aur_packages=(
            grimblast-git
            hyprpicker
            opencode
        )

        if confirm "Install AUR packages with yay?"; then
            execute "yay -S --needed ${aur_packages[*]}" "Installing AUR packages"
        fi
    fi

    # Python packages for Material You theming
    print_info "Installing Python packages for theming system"
    local python_packages=(
        python-pillow
        python-opencv
    )

    if confirm "Install Python theming dependencies?"; then
        for pkg in "${python_packages[@]}"; do
            execute "sudo pacman -S $pkg" "Installing $pkg"
        done
        execute "yay -S kde-material-you-color" "Installing Material You"
    fi

    # Install tree-sitter-cli (critical for nvim)
    if ! command -v tree-sitter &> /dev/null; then
        print_info "Installing tree-sitter-cli for Neovim"
        if command -v cargo &> /dev/null; then
            execute "cargo install tree-sitter-cli" "Installing via cargo"
        else
            print_warning "Rustup not initialized. Run 'rustup default stable' first"
            if confirm "Initialize rustup now?"; then
                execute "rustup default stable" "Initializing Rust toolchain"
                execute "cargo install tree-sitter-cli" "Installing via cargo"
            fi
        fi
    else
        print_success "tree-sitter-cli already installed"
    fi
}

# Backup existing configs
backup_configs() {
    print_step "Backing up existing configurations"

    local configs=(
        "hypr"
        "waybar"
        "wofi"
        "kitty"
        "fish"
        "yazi"
        "fastfetch"
        "lazygit"
        "nvim"
        "Kvantum"
    )

    local backed_up=0

    for config in "${configs[@]}"; do
        if [ -e "$CONFIG_DIR/$config" ]; then
            if [ ! -d "$BACKUP_DIR" ]; then
                mkdir -p "$BACKUP_DIR"
            fi
            print_info "Backing up $config"
            mv "$CONFIG_DIR/$config" "$BACKUP_DIR/"
            ((backed_up++))
        fi
    done

    if [ $backed_up -gt 0 ]; then
        print_success "Backed up $backed_up configs to $BACKUP_DIR"
    else
        print_info "No existing configs found to backup"
    fi
}

# Clone or update dotfiles
clone_dotfiles() {
    print_step "Setting up dotfiles"

    local dotfiles_dir="${1:-$HOME/.dotfiles}"

    # Clone JlessOS
    if [ -d "$dotfiles_dir/JlessOS" ]; then
        print_info "JlessOS directory already exists"
        if confirm "Pull latest changes?"; then
            cd "$dotfiles_dir/JlessOS"
            execute "git pull" "Updating JlessOS dotfiles"
        fi
    else
        mkdir -p "$dotfiles_dir"
        execute "git clone $JLESSOS_REPO $dotfiles_dir/JlessOS" "Cloning JlessOS dotfiles"
    fi

    # Clone nvimConf
    if [ -d "$dotfiles_dir/nvimConf" ]; then
        print_info "nvimConf directory already exists"
        if confirm "Pull latest changes?"; then
            cd "$dotfiles_dir/nvimConf"
            execute "git pull" "Updating nvimConf"
        fi
    else
        mkdir -p "$dotfiles_dir"
        execute "git clone $NVIM_REPO $dotfiles_dir/nvimConf" "Cloning nvimConf"
    fi
}

# Install custom fonts
install_fonts() {
    print_step "Installing custom fonts"

    local font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"

    # Check for custom fonts in repo
    if [ -d "$HOME/.dotfiles/JlessOS/Fonts" ]; then
        print_info "Found custom fonts in repository"

        # Install IPatched fonts if they exist
        if [ -d "$HOME/.dotfiles/JlessOS/Fonts/IPatched" ]; then
            print_info "Installing IPatched fonts..."
            cp -r "$HOME/.dotfiles/JlessOS/Fonts/IPatched"/* "$font_dir/"
            print_success "Custom fonts copied to $font_dir"
        fi

        # Install any other font directories
        for font_subdir in "$HOME/.dotfiles/JlessOS/Fonts"/*; do
            if [ -d "$font_subdir" ] && [ "$(basename "$font_subdir")" != "IPatched" ]; then
                print_info "Installing fonts from $(basename "$font_subdir")..."
                cp -r "$font_subdir"/* "$font_dir/"
            fi
        done

        # Rebuild font cache
        execute "fc-cache -fv" "Rebuilding font cache"
        print_success "Custom fonts installed"
    else
        print_warning "Custom fonts directory not found in JlessOS repo"
        print_info "System fonts from deps.txt will be used"
    fi
}

# Setup Material You theming system
setup_material_theme() {
    print_step "Setting up Material You theming system"

    local dotfiles_dir="${1:-$HOME/.dotfiles}"
    local theme_dir="$CONFIG_DIR/material-theme"

    # Create theme directories
    mkdir -p "$theme_dir"
    mkdir -p "$HOME/.local/state/material-theme"
    mkdir -p "$HOME/.cache/material-theme"

    # Copy theme generation scripts
    if [ -d "$dotfiles_dir/JlessOS/colorscheming" ]; then
        print_info "Copying Material You theme generators"
        cp -r "$dotfiles_dir/JlessOS/colorscheming"/* "$theme_dir/"

        # Make scripts executable
        find "$theme_dir" -type f -name "*.sh" -exec chmod +x {} \;
        find "$theme_dir" -type f -name "*.py" -exec chmod +x {} \;

        print_success "Material You theme system installed"

        print_info "Theme usage:"
        echo "  Generate from wallpaper:"
        echo "    $theme_dir/switchwall.sh --image ~/path/to/wallpaper.jpg"
        echo ""
        echo "  Generate from color:"
        echo "    $theme_dir/switchwall.sh --color '#89b4fa'"
    else
        print_warning "Material theme directory not found in repo"
    fi
}

# Copy configurations (CHANGED FROM SYMLINK)
copy_configs() {
    print_step "Copying configuration files"

    local dotfiles_dir="${1:-$HOME/.dotfiles}"

    # JlessOS configs to copy
    local jlessos_configs=(
        "hypr"
        "waybar"
        "wofi"
        "kitty"
        "fish"
        "yazi"
        "fastfetch"
        "lazygit"
        "Kvantum"
        "scripts"
    )

    for config in "${jlessos_configs[@]}"; do
        local source="$dotfiles_dir/JlessOS/$config"
        local target="$HOME/.config/"

        if [ -e "$source" ]; then
            if [ -e "$target" ]; then
                print_warning "$config already exists at $target"
                if confirm "Overwrite $config?"; then
                    rm -rf "$target"
                else
                    print_info "Skipping $config"
                    continue
                fi
            fi

            print_info "Copying $config"
            cp -r "$source" "$target"
        else
            print_warning "Source not found: $source"
        fi
    done

    # Neovim config
    local nvim_source="$dotfiles_dir/nvimConf"
    local nvim_target="$CONFIG_DIR/nvim"

    if [ -e "$nvim_source" ]; then
        if [ -e "$nvim_target" ]; then
            if confirm "Overwrite nvim config?"; then
                rm -rf "$nvim_target"
                print_info "Copying nvim configuration"
                cp -r "$nvim_source" "$nvim_target"
            fi
        else
            print_info "Copying nvim configuration"
            cp -r "$nvim_source" "$nvim_target"
        fi
    fi

    print_success "Configuration files copied"
}

# Set fish as default shell
setup_fish() {
    print_step "Setting up Fish shell"

    if ! command -v fish &> /dev/null; then
        print_warning "Fish shell not found, skipping"
        return
    fi

    local fish_path=$(which fish)

    if [ "$SHELL" != "$fish_path" ]; then
        if confirm "Set Fish as default shell?"; then
            if ! grep -q "$fish_path" /etc/shells; then
                print_info "Adding Fish to /etc/shells"
                echo "$fish_path" | sudo tee -a /etc/shells
            fi
            execute "chsh -s $fish_path" "Changing default shell to Fish"
            print_success "Fish set as default shell (re-login to apply)"
        fi
    else
        print_info "Fish is already your default shell"
    fi
}

# Setup Neovim
setup_neovim() {
    print_step "Setting up Neovim"

    if ! command -v nvim &> /dev/null; then
        print_warning "Neovim not found, skipping setup"
        return
    fi

    print_info "Installing lazy.nvim package manager"
    local lazy_path="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy/lazy.nvim"

    if [ ! -d "$lazy_path" ]; then
        execute "git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable $lazy_path" \
            "Cloning lazy.nvim"
    fi

    print_info "Neovim will install plugins on first launch"
    print_info "Run :Lazy sync inside Neovim to install/update plugins"
}

# Make scripts executable
setup_scripts() {
    print_step "Setting up scripts"

    local scripts_dir="$CONFIG_DIR/scripts"

    if [ -d "$scripts_dir" ]; then
        print_info "Making scripts executable"
        find "$scripts_dir" -type f -name "*.sh" -exec chmod +x {} \;
        find "$scripts_dir" -type f -name "*.py" -exec chmod +x {} \;
        print_success "Scripts are now executable"
    else
        print_warning "Scripts directory not found"
    fi
}

# Post-installation steps
post_install() {
    print_step "Post-installation"

    print_info "To complete setup:"
    echo "  1. Log out and select Hyprland session"
    echo "  2. Open Neovim and run :Lazy sync"
    echo "  3. Generate theme: ~/.config/material-theme/switchwall.sh --image <wallpaper>"
    echo "  4. Review configuration files in $CONFIG_DIR"

    if [ -d "$BACKUP_DIR" ]; then
        echo "  5. Old configs backed up to: $BACKUP_DIR"
    fi

    echo ""
    print_info "Important Hyprland keybinds:"
    echo "  Super + Enter         - Terminal"
    echo "  Super + D             - App launcher"
    echo "  Super + Q             - Close window"
    echo "  Super + E             - File manager"
    echo "  Super + V             - Toggle floating"
}

# Main installation flow
main() {
    print_header

    print_info "This script will install JlessOS dotfiles and dependencies"
    echo ""

    if ! confirm "Continue with installation?" "n"; then
        print_info "Installation cancelled"
        exit 0
    fi

    # Installation steps
    install_dependencies || print_warning "Dependency installation had issues"
    backup_configs
    clone_dotfiles "$HOME/.dotfiles"
    install_fonts
    setup_material_theme "$HOME/.dotfiles"
    copy_configs "$HOME/.dotfiles"  # CHANGED: was symlink_configs
    setup_fish
    setup_neovim
    setup_scripts

    echo ""
    print_success "Installation complete! 🎉"
    echo ""

    post_install

    echo ""
    print_info "For issues or questions: https://github.com/Jlesster/JlessOS"
}

# Run main function
main "$@"
