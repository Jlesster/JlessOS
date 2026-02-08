install_arch_deps() {
    print_info "Detected Arch-based system"
    
    local packages=(
        # Core
        "hyprland"
        "waybar"
        "wofi"
        "kitty"
        "fish"
        
        # Tools
        "yazi"
        "ffmpegthumbnailer"
        "p7zip"
        "jq"
        "ripgrep"
        "fd"
        "fzf"
        "fastfetch"
        "lazygit"
        "btop"
        
        # Neovim
        "neovim"
        "python-pynvim"
        "nodejs"
        "npm"
        
        # Python for theming system
        "python"
        "python-pip"
        "python-pillow"
        
        # Fonts
        "ttf-font-awesome"
        "ttf-jetbrains-mono-nerd"
        "ttf-iosevka-nerd"
        "noto-fonts"
        "noto-fonts-emoji"
        
        # Media
        "grim"
        "slurp"
        "wl-clipboard"
        "cliphist"
        "swappy"
        
        # Wallpaper backends
        "hyprpaper"
        "swaybg"
        
        # System
        "polkit-gnome"
        "xdg-desktop-portal-hyprland"
        "qt5-wayland"
        "qt6-wayland"
        
        # Appearance
        "kvantum"
        "qt5ct"
        "nwg-look"
        
        # Optional but recommended
        "starship"
    )
    
    if confirm "Install ${#packages[@]} packages with pacman?"; then
        execute "sudo pacman -S --needed ${packages[*]}" "Installing packages"
    fi
    
    # Python packages for Material You theming
    print_info "Installing Python packages for theming system"
    local python_packages=(
        "materialyoucolor"
        "Pillow"
    )
    
    if confirm "Install Python theming dependencies?"; then
        for pkg in "${python_packages[@]}"; do
            execute "pip3 install --user $pkg" "Installing $pkg"
        done
    fi#!/usr/bin/env bash

# JlessOS Dotfiles Installer
# Inspired by end-4/dots-hyprland installation system

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
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

# Install dependencies based on distro
install_dependencies() {
    print_step "Installing dependencies"
    
    local distro=$(detect_distro)
    
    case "$distro" in
        arch|endeavouros|cachyos)
            install_arch_deps
            ;;
        ubuntu|debian|pop)
            install_debian_deps
            ;;
        fedora)
            install_fedora_deps
            ;;
        *)
            print_warning "Unsupported distribution: $distro"
            print_info "Please install dependencies manually"
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
    
    local packages=(
        # Core
        "hyprland"
        "waybar"
        "wofi"
        "kitty"
        "fish"
        
        # Tools
        "yazi"
        "ffmpegthumbnailer"
        "p7zip"
        "jq"
        "ripgrep"
        "fd"
        "fzf"
        "fastfetch"
        "lazygit"
        
        # Neovim
        "neovim"
        "python-pynvim"
        "nodejs"
        "npm"
        
        # Fonts
        "ttf-font-awesome"
        "ttf-jetbrains-mono-nerd"
        "noto-fonts"
        "noto-fonts-emoji"
        
        # Media
        "grim"
        "slurp"
        "wl-clipboard"
        "cliphist"
        "swappy"
        
        # System
        "polkit-gnome"
        "xdg-desktop-portal-hyprland"
        "qt5-wayland"
        "qt6-wayland"
        
        # Appearance
        "kvantum"
        "qt5ct"
        "nwg-look"
    )
    
    if confirm "Install ${#packages[@]} packages with pacman?"; then
        execute "sudo pacman -S --needed ${packages[*]}" "Installing packages"
    fi
    
    # AUR packages
    if command -v yay &> /dev/null || command -v paru &> /dev/null; then
        local aur_helper=$(command -v yay &> /dev/null && echo "yay" || echo "paru")
        local aur_packages=(
            "hyprpicker"
        )
        
        if confirm "Install AUR packages with $aur_helper?"; then
            execute "$aur_helper -S --needed ${aur_packages[*]}" "Installing AUR packages"
        fi
    else
        print_warning "No AUR helper found. Install yay or paru for additional packages."
    fi
}

install_debian_deps() {
    print_info "Detected Debian-based system"
    print_warning "Hyprland installation on Debian-based systems requires additional steps"
    print_info "Please refer to: https://wiki.hyprland.org/Getting-Started/Installation/"
    
    local packages=(
        "kitty"
        "fish"
        "neovim"
        "git"
        "curl"
        "wget"
        "ripgrep"
        "fd-find"
        "fzf"
        "nodejs"
        "npm"
        "python3"
        "python3-pip"
        "python3-venv"
        "python3-pil"
        "jq"
        "btop"
    )
    
    if confirm "Install available packages with apt?"; then
        execute "sudo apt update && sudo apt install -y ${packages[*]}" "Installing packages"
    fi
    
    # Python packages for theming
    if confirm "Install Python theming dependencies?"; then
        execute "pip3 install --user materialyoucolor Pillow" "Installing Python packages"
    fi
}

install_fedora_deps() {
    print_info "Detected Fedora system"
    
    local packages=(
        "hyprland"
        "waybar"
        "wofi"
        "kitty"
        "fish"
        "neovim"
        "python3-neovim"
        "nodejs"
        "npm"
        "ripgrep"
        "fd-find"
        "fzf"
        "git"
        "jq"
        "btop"
        "fontawesome-fonts"
        "jetbrains-mono-fonts"
        "google-noto-fonts"
        "grim"
        "slurp"
        "wl-clipboard"
        "python3"
        "python3-pip"
        "python3-pillow"
    )
    
    if confirm "Install packages with dnf?"; then
        execute "sudo dnf install -y ${packages[*]}" "Installing packages"
    fi
    
    # Python packages for theming
    if confirm "Install Python theming dependencies?"; then
        execute "pip3 install --user materialyoucolor" "Installing Python packages"
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
        
        # Check if Python dependencies are available
        if ! python3 -c "import materialyoucolor" 2>/dev/null; then
            print_warning "materialyoucolor Python package not found"
            if confirm "Install materialyoucolor via pip?"; then
                execute "pip3 install --user materialyoucolor" "Installing materialyoucolor"
            fi
        fi
        
        # Check for PIL/Pillow
        if ! python3 -c "import PIL" 2>/dev/null; then
            print_warning "Pillow (PIL) not found"
            if confirm "Install Pillow via pip?"; then
                execute "pip3 install --user Pillow" "Installing Pillow"
            fi
        fi
        
        print_info "Material You theme usage:"
        echo "  Generate theme from wallpaper:"
        echo "    bash $theme_dir/switchwall.sh --image ~/path/to/wallpaper.jpg"
        echo ""
        echo "  Generate theme from color:"
        echo "    bash $theme_dir/switchwall.sh --color '#89b4fa'"
        echo ""
        echo "  Options:"
        echo "    --mode dark|light    Set dark or light mode"
        echo "    --scheme vibrant     Set color scheme (vibrant, tonal-spot, etc.)"
    else
        print_warning "Material theme directory not found in repo"
    fi
}

# Install fonts
install_fonts() {
    print_step "Installing custom fonts"
    
    local font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"
    
    if [ -d "$HOME/.dotfiles/JlessOS/Fonts/IPatched" ]; then
        print_info "Copying patched fonts"
        cp -r "$HOME/.dotfiles/JlessOS/Fonts/IPatched"/* "$font_dir/"
        execute "fc-cache -fv" "Rebuilding font cache"
    else
        print_warning "Fonts directory not found"
    fi
}

# Symlink configurations
symlink_configs() {
    print_step "Creating symbolic links"
    
    local dotfiles_dir="${1:-$HOME/.dotfiles}"
    
    # JlessOS configs
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
        "colorscheming"
        "scripts"
    )
    
    for config in "${jlessos_configs[@]}"; do
        local source="$dotfiles_dir/JlessOS/$config"
        local target="$CONFIG_DIR/$config"
        
        if [ -e "$source" ]; then
            if [ -e "$target" ] && [ ! -L "$target" ]; then
                print_warning "$config already exists at $target (not a symlink)"
                continue
            fi
            
            print_info "Linking $config"
            ln -sf "$source" "$target"
        else
            print_warning "Source not found: $source"
        fi
    done
    
    # Neovim config
    local nvim_source="$dotfiles_dir/nvimConf"
    local nvim_target="$CONFIG_DIR/nvim"
    
    if [ -e "$nvim_source" ]; then
        print_info "Linking nvim configuration"
        ln -sf "$nvim_source" "$nvim_target"
    fi
    
    print_success "Configuration links created"
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

# Display keybinds
show_keybinds() {
    print_step "Keybindings"
    
    local keybinds_file="$CONFIG_DIR/hypr/keybinds-cheatsheet.txt"
    
    if [ -f "$keybinds_file" ]; then
        print_info "Your keybindings are located at: $keybinds_file"
    else
        print_info "Important Hyprland keybinds:"
        echo "  Super + Enter         - Terminal"
        echo "  Super + D             - App launcher"
        echo "  Super + Q             - Close window"
        echo "  Super + M             - Exit"
        echo "  Super + V             - Toggle floating"
        echo "  Super + F             - Toggle fullscreen"
        echo "  Super + [1-9]         - Switch workspace"
        echo "  Super + Shift + [1-9] - Move to workspace"
    fi
}

# Post-installation setup
post_install() {
    print_step "Post-installation steps"
    
    print_info "To complete setup:"
    echo "  1. Log out and select Hyprland session"
    echo "  2. Open Neovim and run :Lazy sync"
    echo "  3. Review configuration files in $CONFIG_DIR"
    echo "  4. Check keybindings in hypr config"
    
    if [ -d "$BACKUP_DIR" ]; then
        echo "  5. Old configs backed up to: $BACKUP_DIR"
    fi
    
    echo ""
    print_info "Material You Theming System:"
    echo "  Generate theme from wallpaper:"
    echo "    ~/.config/material-theme/switchwall.sh --image ~/Pictures/wallpaper.jpg"
    echo ""
    echo "  Generate theme from color:"
    echo "    ~/.config/material-theme/switchwall.sh --color '#89b4fa'"
    echo ""
    echo "  Options:"
    echo "    --mode dark|light       Dark or light mode"
    echo "    --scheme vibrant        Color scheme (vibrant, tonal-spot, neutral, etc.)"
    echo ""
    echo "  Supported applications:"
    echo "    • Kitty          • Neovim        • LazyGit"
    echo "    • Yazi           • FZF           • Btop"
    echo "    • Fish           • Wofi          • Waybar"
    echo "    • Starship       • Hyprland"
    echo ""
    print_info "The theming system will automatically:"
    echo "  • Extract colors from your wallpaper"
    echo "  • Generate Material You color schemes"
    echo "  • Apply themes to all configured applications"
    echo "  • Reload running applications when possible"
}

# Main installation flow
main() {
    print_header
    
    # Check if running in a supported environment
    if [ -z "${XDG_SESSION_TYPE:-}" ]; then
        print_warning "XDG_SESSION_TYPE not set"
    fi
    
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
    symlink_configs "$HOME/.dotfiles"
    setup_fish
    setup_neovim
    setup_scripts
    
    echo ""
    print_success "Installation complete! 🎉"
    echo ""
    
    show_keybinds
    post_install
    
    echo ""
    print_info "For issues or questions: https://github.com/Jlesster/JlessOS"
}

# Run main function
main "$@"
