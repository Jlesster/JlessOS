#!/usr/bin/env bash
# JlessOS One-Line Installer Bootstrap
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/Jlesster/JlessOS/master/bootstrap.sh)

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly NC='\033[0m'

# Configuration
REPO_URL="https://github.com/Jlesster/JlessOS.git"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.dotfiles/JlessOS}"
TEMP_DIR="/tmp/jlessos-install-$$"

# Banner
cat << "EOF"

     ██╗██╗     ███████╗███████╗███████╗ ██████╗ ███████╗
     ██║██║     ██╔════╝██╔════╝██╔════╝██╔═══██╗██╔════╝
     ██║██║     █████╗  ███████╗███████╗██║   ██║███████╗
██   ██║██║     ██╔══╝  ╚════██║╚════██║██║   ██║╚════██║
╚█████╔╝███████╗███████╗███████║███████║╚██████╔╝███████║
 ╚════╝ ╚══════╝╚══════╝╚══════╝╚══════╝ ╚═════╝ ╚══════╝

            Hyprland Dotfiles Installer

EOF

echo -e "${BLUE}Repository:${NC} $REPO_URL"
echo -e "${BLUE}Install to:${NC} $INSTALL_DIR"
echo ""

# Check for required tools
echo -e "${YELLOW}Checking prerequisites...${NC}"

MISSING_DEPS=()

for cmd in git curl; do
    if ! command -v "$cmd" &> /dev/null; then
        MISSING_DEPS+=("$cmd")
    fi
done

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo -e "${RED}Error: Missing required tools: ${MISSING_DEPS[*]}${NC}"
    echo ""
    echo "Install them with:"
    echo "  sudo pacman -S ${MISSING_DEPS[*]}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Prerequisites met"
echo ""

# Confirm installation
read -p "$(echo -e ${YELLOW}Continue with installation? [y/N]:${NC} )" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Installation cancelled.${NC}"
    exit 0
fi

# Create temp directory
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

echo ""
echo -e "${BLUE}Downloading installer...${NC}"

# Clone repository
if git clone --depth 1 "$REPO_URL" .; then
    echo -e "${GREEN}✓${NC} Repository cloned"
else
    echo -e "${RED}✗${NC} Failed to clone repository"
    exit 1
fi

# Make install script executable
chmod +x install.sh

echo ""
echo -e "${GREEN}Starting installation...${NC}"
echo ""

# Run the actual installer
./install.sh

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}Installation complete! 🎉${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Log out and select Hyprland session"
echo "  2. Press Super + Enter to open terminal"
echo "  3. Configure your theme:"
echo "     ~/.config/material-theme/switchwall.sh --image ~/path/to/wallpaper.jpg"
echo ""
echo -e "${YELLOW}Note:${NC} Your dotfiles are in $INSTALL_DIR"
echo ""
