#!/bin/bash
# JlessOS Essential Packages
# Minimal system setup for Arch + Hyprland

# === SYSTEM CORE ===
base
base-devel
linux
linux-firmware
linux-headers
amd-ucode
sudo
efibootmgr
dkms

# === BOOTLOADER & INIT ===
ly                      # Display manager
zram-generator         # RAM compression

# === FILESYSTEM ===
btrfs-progs
fuse2
smartmontools

# === NETWORKING ===
networkmanager
iwd
wpa_supplicant
wireless_tools
modemmanager-qt

# === BLUETOOTH ===
bluez
bluez-utils
bluez-qt
bluetui

# === AUDIO ===
pipewire
pipewire-alsa
pipewire-jack
pipewire-pulse
wireplumber
libpulse
pamixer
pulsemixer
sof-firmware

# === HYPRLAND COMPOSITOR ===
hyprland
hyprpaper
hyprshade
xdg-desktop-portal-hyprland
xdg-desktop-portal-gtk
xdg-utils

# === DISPLAY MANAGEMENT ===
qt5-wayland
qt6-wayland
qt5ct
qt6ct
nwg-look
kvantum
kvantum-qt5

# === WAYLAND UTILITIES ===
waybar
wofi
dunst
grim
slurp
slop
wl-clipboard
cliphist
brightnessctl
wf-recorder

# === KDE INTEGRATION ===
kde-cli-tools
kde-gtk-config
kdecoration
kscreen
plasma-pa
polkit-kde-agent
powerdevil
power-profiles-daemon
systemsettings
qqc2-desktop-style
kirigami2
breeze
dolphin
ark

# === TERMINAL & SHELL ===
kitty
fish
fisher
starship

# === CORE CLI TOOLS ===
git
wget
curl
unzip
zip
man-db
nano
vim
htop
btop
bat
eza
fzf
jq
tldr
fastfetch

# === PROGRAMMING ===
rustup
npm
python-pip
maven
cmake

# === NVIDIA ===
nvidia-open-dkms
libva-nvidia-driver

# === FILE MANAGERS ===
yazi
imv

# === BROWSERS ===
firefox
chromium

# === COMMUNICATION ===
vesktop

# === PRODUCTIVITY ===
libreoffice-fresh
calcurse
newsboat
taskwarrior-tui
zathura

# === MEDIA ===
mpv
obs-studio
imagemagick
chafa

# === DEVELOPMENT TOOLS ===
github-cli
lazygit
glow
neovim

# === UTILITIES ===
scrot
keyd
uwsm
grimblast-git          # AUR

# === DOCUMENTATION ===
python-docs
zeal

# === AUR HELPER ===
yay

# === FONTS (MINIMAL) ===
# Keep only essential fonts - see fonts-minimal.txt
noto-fonts-emoji
noto-fonts-extra
noto-fonts-cjk
ttf-dejavu
ttf-liberation-mono-nerd
ttf-jetbrains-mono-nerd
ttf-fira-code
ttf-nerd-fonts-symbols-mono
inter-font
cantarell-fonts
