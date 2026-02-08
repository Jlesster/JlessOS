#!/bin/bash
# Neovim Configuration Installer
# For https://github.com/Jlesster/nvimConf

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Neovim Configuration Installer ===${NC}"

# === DEPENDENCY CHECK ===
check_dependency() {
  if command -v "$1" &> /dev/null; then
    echo -e "${GREEN}✓${NC} $1 found"
    return 0
  else
    echo -e "${RED}✗${NC} $1 not found"
    return 1
  fi
}

echo ""
echo "Checking dependencies..."

MISSING_DEPS=()

# Critical dependencies
for dep in neovim git ripgrep fd fzf npm python; do
  if ! check_dependency "$dep"; then
    MISSING_DEPS+=("$dep")
  fi
done

# === INSTALL MISSING DEPENDENCIES ===
if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
  echo ""
  echo -e "${YELLOW}Missing dependencies: ${MISSING_DEPS[*]}${NC}"
  echo "Installing..."

  sudo pacman -S --needed --noconfirm \
    neovim \
    git \
    ripgrep \
    fd \
    fzf \
    npm \
    python \
    python-pip \
    gcc \
    cmake \
    unzip \
    wget \
    curl
fi

# === INSTALL TREE-SITTER CLI ===
echo ""
echo "Checking for tree-sitter CLI..."
if ! command -v tree-sitter &> /dev/null; then
  echo -e "${YELLOW}Installing tree-sitter-cli...${NC}"

  # Try cargo first (faster)
  if command -v cargo &> /dev/null; then
    cargo install tree-sitter-cli
  else
    # Fallback to npm
    sudo npm install -g tree-sitter-cli
  fi
else
  echo -e "${GREEN}✓${NC} tree-sitter CLI found"
fi

# === INSTALL OPTIONAL TOOLS ===
echo ""
echo "Installing optional but recommended tools..."
sudo pacman -S --needed --noconfirm \
  lazygit \
  github-cli \
  glow \
  bat \
  eza \
  tldr \
  wl-clipboard \
  imagemagick \
  chafa \
  yazi

# === BACKUP EXISTING CONFIG ===
echo ""
if [ -d "$HOME/.config/nvim" ]; then
  echo -e "${YELLOW}Backing up existing nvim config...${NC}"
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
fi

# === CLONE CONFIG ===
echo ""
echo "Cloning nvimConf..."
git clone https://github.com/Jlesster/nvimConf.git "$HOME/.config/nvim"

# === INSTALL LANGUAGE SERVERS ===
echo ""
echo -e "${GREEN}Installing common language servers...${NC}"

# Lua
sudo pacman -S --needed --noconfirm lua-language-server

# Python
pip install --user python-lsp-server pylint black isort

# Bash
sudo pacman -S --needed --noconfirm bash-language-server shellcheck shfmt

# JavaScript/TypeScript (via npm)
sudo npm install -g \
  typescript \
  typescript-language-server \
  vscode-langservers-extracted \
  prettier

# Rust (via rustup)
if command -v rustup &> /dev/null; then
  rustup component add rust-analyzer rust-src
else
  echo -e "${YELLOW}Rustup not found. Install with: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh${NC}"
fi

# Java (you already have maven and JAVA_HOME set)
echo "Java LSP will be installed by Mason (jdtls)"

# === SETUP JAVA_HOME (if not set) ===
if [ -z "$JAVA_HOME" ]; then
  echo ""
  echo "Setting JAVA_HOME..."
  export JAVA_HOME="/usr/lib/jvm/java-21-openjdk"
  echo 'export JAVA_HOME="/usr/lib/jvm/java-21-openjdk"' >> "$HOME/.bashrc"
  echo 'export JAVA_HOME="/usr/lib/jvm/java-21-openjdk"' >> "$HOME/.config/fish/config.fish"
fi

# === INSTALL DASHT (for offline docs) ===
echo ""
echo "Setting up Dasht for offline documentation..."
if [ ! -d "$HOME/.dasht" ]; then
  git clone https://github.com/sunaku/dasht.git "$HOME/.dasht"

  # Install docsets
  if command -v wget &> /dev/null; then
    "$HOME/.dasht/bin/dasht-docsets-install" python
    "$HOME/.dasht/bin/dasht-docsets-install" java
    "$HOME/.dasht/bin/dasht-docsets-install" bash
    "$HOME/.dasht/bin/dasht-docsets-install" rust
  else
    echo -e "${YELLOW}wget not found. Skipping dasht docsets installation.${NC}"
    echo "Install wget and run: ~/.dasht/bin/dasht-docsets-install <language>"
  fi
fi

# === FIX SMART-DOCS.LUA ===
echo ""
echo "Fixing smart-docs.lua keymaps..."
sed -i 's/{ desc = \x27Python pydoc\x27, ft = \x27python\x27 }/{ desc = \x27Python pydoc\x27 }/g' \
  "$HOME/.config/nvim/lua/config/smart-docs.lua"
sed -i 's/{ desc = \x27Rust std docs\x27, ft = \x27rust\x27 }/{ desc = \x27Rust std docs\x27 }/g' \
  "$HOME/.config/nvim/lua/config/smart-docs.lua"
sed -i 's/{ desc = \x27Java docs\x27, ft = \x27java\x27 }/{ desc = \x27Java docs\x27 }/g' \
  "$HOME/.config/nvim/lua/config/smart-docs.lua"

# === FIRST RUN ===
echo ""
echo -e "${GREEN}=== Installation Complete! ===${NC}"
echo ""
echo "Starting Neovim for first-time setup..."
echo "Plugins will be automatically installed by Lazy.nvim"
echo ""
echo -e "${YELLOW}Note: First launch will take a few minutes.${NC}"
echo "Press ENTER to continue..."
read

nvim +Lazy

echo ""
echo -e "${GREEN}=== Setup Complete! ===${NC}"
echo ""
echo "Additional setup:"
echo "  1. Install more LSPs: Open nvim and run :Mason"
echo "  2. Update plugins: :Lazy sync"
echo "  3. Update treesitter: :TSUpdate"
echo "  4. Check health: :checkhealth"
echo ""
echo "Enjoy your Neovim setup!"
