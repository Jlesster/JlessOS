#!/bin/bash
# Helper function to parse packages from dependency file
parse_packages() {
    local file="$1"

    # Extract packages (ignore comments and empty lines)
    grep -v '^#' "$file" | \
    grep -v '^$' | \
    tr '\n' ' '
}

install_arch_deps() {
    print_info "Detected Arch-based system"

    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local deps_file="$script_dir/deps.txt"

    # Check if deps.txt exists
    if [ ! -f "$deps_file" ]; then
        print_error "deps.txt not found at $deps_file"
        print_info "Falling back to manual package list..."

        # Fallback to hardcoded list
        local core_packages=(
            base base-devel linux linux-firmware linux-headers amd-ucode
            sudo efibootmgr dkms ly zram-generator btrfs-progs fuse2 smartmontools
            networkmanager iwd wpa_supplicant wireless_tools modemmanager-qt
            bluez bluez-utils bluez-qt bluetui
            pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber
            libpulse pamixer pulsemixer sof-firmware
            hyprland hyprpaper hyprshade xdg-desktop-portal-hyprland
            xdg-desktop-portal-gtk xdg-utils
            qt5-wayland qt6-wayland qt5ct qt6ct nwg-look kvantum kvantum-qt5
            waybar wofi dunst grim slurp slop wl-clipboard cliphist
            brightnessctl wf-recorder
            kde-cli-tools kde-gtk-config kdecoration kscreen plasma-pa
            polkit-kde-agent powerdevil power-profiles-daemon systemsettings
            qqc2-desktop-style kirigami2 breeze dolphin ark
            kitty fish fisher starship
            git wget curl unzip zip man-db nano vim htop btop bat eza fzf
            ripgrep fd jq tldr fastfetch
            rustup npm python python-pip maven cmake gcc
            nvidia-open-dkms libva-nvidia-driver
            yazi imv ffmpegthumbnailer p7zip
            firefox chromium vesktop
            libreoffice-fresh calcurse newsboat taskwarrior-tui zathura
            mpv obs-studio imagemagick chafa
            github-cli lazygit glow neovim
            scrot keyd uwsm
            python-docs zeal
            noto-fonts-emoji noto-fonts-extra noto-fonts-cjk
            ttf-dejavu ttf-liberation-mono-nerd ttf-jetbrains-mono-nerd
            ttf-fira-code ttf-nerd-fonts-symbols-mono ttf-font-awesome
            inter-font cantarell-fonts
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

    if confirm "Install $pkg_count packages with pacman?"; then
        execute "sudo pacman -S --needed $core_packages" "Installing packages"
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
    else
        print_warning "yay not found. Installing yay first..."
        if confirm "Install yay AUR helper?"; then
            execute "git clone https://aur.archlinux.org/yay.git /tmp/yay && cd /tmp/yay && makepkg -si --noconfirm" "Installing yay"
        fi
    fi

    # Python packages for Material You theming
    print_info "Installing Python packages for theming system"
    local python_packages=(
        materialyoucolor
        Pillow
        opencv-python
    )

    if confirm "Install Python theming dependencies?"; then
        for pkg in "${python_packages[@]}"; do
            execute "pip3 install --user $pkg" "Installing $pkg"
        done
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

# Alternative: Install directly from file
install_from_deps_file() {
    local deps_file="$1"

    if [ ! -f "$deps_file" ]; then
        print_error "Dependency file not found: $deps_file"
        return 1
    fi

    print_info "Installing packages from $deps_file..."

    # Method 1: Parse and install
    local packages=$(parse_packages "$deps_file")
    sudo pacman -S --needed $packages

    # Method 2: Direct pipe (cleaner)
    # grep -v '^#' "$deps_file" | grep -v '^$' | sudo pacman -S --needed -
}
