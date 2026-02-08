#!/usr/bin/env bash
# JlessOS Bootstrap - One-liner installer
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/Jlesster/JlessOS/master/bootstrap.sh)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_URL="https://github.com/Jlesster/JlessOS.git"
INSTALL_DIR="$HOME/.dotfiles/JlessOS"

# Banner
cat << 'EOF'

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

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"
MISSING=()
for cmd in git curl; do
    command -v "$cmd" &>/dev/null || MISSING+=("$cmd")
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
    echo -e "${RED}Error: Missing required tools: ${MISSING[*]}${NC}"
    echo "Install with: sudo pacman -S ${MISSING[*]}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Prerequisites met"
echo ""

# Confirm
read -p "$(echo -e ${YELLOW}Continue with installation? [y/N]:${NC} )" -n 1 -r
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && echo -e "${BLUE}Cancelled.${NC}" && exit 0

# Clone repo
echo ""
echo -e "${BLUE}Cloning repository...${NC}"

if [[ -d "$INSTALL_DIR" ]]; then
    echo -e "${YELLOW}Directory exists, pulling latest...${NC}"
    (cd "$INSTALL_DIR" && git pull)
else
    git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"
fi

echo -e "${GREEN}✓${NC} Repository ready"

# Run installer
cd "$INSTALL_DIR"
chmod +x install.sh

echo ""
echo -e "${GREEN}Starting installation...${NC}"
echo ""

./install.sh

echo ""
echo -e "${GREEN}════════════════════════════════════${NC}"
echo -e "${GREEN}Installation complete! 🎉${NC}"
echo -e "${GREEN}════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Quick start:${NC}"
echo "  1. Log out → Select Hyprland"
echo "  2. Super+Enter → Terminal"
echo "  3. Super+D → App launcher"
echo ""
echo -e "${YELLOW}Dotfiles location:${NC} $INSTALL_DIR"
