#!/bin/bash
# Neovim Configuration Installer
# For https://github.com/Jlesster/nvimConf

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Neovim Configuration Installer ===${NC}"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPS_FILE="$SCRIPT_DIR/nvim_deps.txt"

# Helper function to parse packages from dependency file
parse_packages() {
    local file="$1"

    # Extract packages (ignore comments, empty lines, and NOTE sections)
    grep -v '^#' "$file" | \
    grep -v '^$' | \
    tr '\n' ' '
}

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
echo "Checking critical dependencies..."

MISSING_DEPS=()

# Critical dependencies
for dep in neovim git ripgrep fd fzf npm python; do
  if ! check_dependency "$dep"; then
    MISSING_DEPS+=("$dep")
  fi
done

# === INSTALL DEPENDENCIES FROM FILE ===
if [ -f "$DEPS_FILE" ]; then
    echo ""
    echo -e "${BLUE}[INFO]${NC} Found nvim_deps.txt, loading packages..."

    # Parse packages
    PACKAGES=$(parse_packages "$DEPS_FILE")

    # Count packages
    PKG_COUNT=$(echo "$PACKAGES" | wc -w)
    echo -e "${BLUE}[INFO]${NC} Found $PKG_COUNT packages to install"

    # Confirm installation
    read -p "Install all dependencies? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${BLUE}[INFO]${NC} Installing packages via pacman..."
        sudo pacman -S --needed --noconfirm $PACKAGES
        echo -e "${GREEN}✓${NC} Packages installed"
    fi
else
    # Fallback to minimal critical packages
    echo -e "${YELLOW}[WARNING]${NC} nvim_deps.txt not found, installing minimal dependencies..."

    if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}Missing dependencies: ${MISSING_DEPS[*]}${NC}"
        echo "Installing minimal set..."

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
            curl \
            lazygit \
            github-cli \
            glow \
            bat \
            eza \
            tldr \
            wl-clipboard \
            imagemagick \
            chafa \
            yazi \
            lua-language-server \
            bash-language-server \
            shellcheck \
            shfmt \
            ttf-jetbrains-mono-nerd \
            ttf-nerd-fonts-symbols-mono
    fi
fi

# === INSTALL TREE-SITTER CLI ===
echo ""
echo "Checking for tree-sitter CLI..."
if ! command -v tree-sitter &> /dev/null; then
  echo -e "${YELLOW}Installing tree-sitter-cli...${NC}"

  # Check if cargo is available
  if command -v cargo &> /dev/null; then
    echo -e "${BLUE}[INFO]${NC} Installing via cargo..."
    cargo install tree-sitter-cli
  else
    # Check if rustup is installed but not initialized
    if command -v rustup &> /dev/null; then
      echo -e "${YELLOW}Rustup found but not initialized${NC}"
      echo -e "${BLUE}[INFO]${NC} Initializing Rust toolchain..."
      rustup default stable
      cargo install tree-sitter-cli
    else
      # Fallback to npm
      echo -e "${YELLOW}Cargo not available, using npm...${NC}"
      sudo npm install -g tree-sitter-cli
    fi
  fi
  echo -e "${GREEN}✓${NC} tree-sitter CLI installed"
else
  echo -e "${GREEN}✓${NC} tree-sitter CLI found"
fi

# === BACKUP EXISTING CONFIG ===
echo ""
if [ -d "$HOME/.config/nvim" ]; then
  echo -e "${YELLOW}Backing up existing nvim config...${NC}"
  BACKUP_DIR="$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
  mv "$HOME/.config/nvim" "$BACKUP_DIR"
  echo -e "${GREEN}✓${NC} Backup saved to: $BACKUP_DIR"
fi

# === CLONE CONFIG ===
echo ""
echo "Cloning nvimConf..."
if git clone https://github.com/Jlesster/nvimConf.git "$HOME/.config/nvim"; then
  echo -e "${GREEN}✓${NC} Configuration cloned"
else
  echo -e "${RED}✗${NC} Failed to clone configuration"
  exit 1
fi

# === INSTALL LANGUAGE SERVERS ===
echo ""
echo -e "${GREEN}Installing language servers...${NC}"

# Lua (already installed from deps.txt if present)
if ! pacman -Qi lua-language-server &>/dev/null; then
  sudo pacman -S --needed --noconfirm lua-language-server
fi

# Python
echo -e "${BLUE}[INFO]${NC} Installing Python LSP and tools..."
sudo pacman -S python-lsp-server python-pylint python-black python-isort

# Bash (already installed from deps.txt if present)
if ! pacman -Qi bash-language-server &>/dev/null; then
  sudo pacman -S --needed --noconfirm bash-language-server shellcheck shfmt
fi

# JavaScript/TypeScript (via npm)
echo -e "${BLUE}[INFO]${NC} Installing JS/TS language servers..."
sudo npm install -g \
  typescript \
  typescript-language-server \
  vscode-langservers-extracted \
  prettier

# Rust (via rustup)
if command -v rustup &> /dev/null; then
  echo -e "${BLUE}[INFO]${NC} Installing Rust analyzer..."
  rustup component add rust-analyzer rust-src
else
  echo -e "${YELLOW}Rustup not found. To add Rust support later:${NC}"
  echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
  echo "  rustup component add rust-analyzer rust-src"
fi

# Java
if command -v java &> /dev/null; then
  echo -e "${BLUE}[INFO]${NC} Java found - LSP will be installed by Mason (jdtls)"

  # Setup JAVA_HOME if not set
  if [ -z "$JAVA_HOME" ]; then
    echo ""
    echo "Setting JAVA_HOME..."
    export JAVA_HOME="/usr/lib/jvm/java-21-openjdk"

    # Add to shell configs
    for config in "$HOME/.bashrc" "$HOME/.config/fish/config.fish"; do
      if [ -f "$config" ] || [ "$config" = "$HOME/.bashrc" ]; then
        echo 'export JAVA_HOME="/usr/lib/jvm/java-21-openjdk"' >> "$config"
      fi
    done
    echo -e "${GREEN}✓${NC} JAVA_HOME configured"
  fi
fi

# === INSTALL DASHT (for offline docs) ===
echo ""
echo "Setting up Dasht for offline documentation..."
if [ ! -d "$HOME/.dasht" ]; then
  git clone https://github.com/sunaku/dasht.git "$HOME/.dasht"
  echo -e "${GREEN}✓${NC} Dasht installed"

  # Install docsets
  if command -v wget &> /dev/null; then
    echo -e "${BLUE}[INFO]${NC} Installing documentation sets..."
    for lang in python java bash rust; do
      "$HOME/.dasht/bin/dasht-docsets-install" "$lang" &
    done
    wait
    echo -e "${GREEN}✓${NC} Docsets installed"
  else
    echo -e "${YELLOW}wget not found. To install docsets later:${NC}"
    echo "  ~/.dasht/bin/dasht-docsets-install <language>"
  fi
else
  echo -e "${GREEN}✓${NC} Dasht already installed"
fi

# === FIX SMART-DOCS.LUA ===
echo ""
echo "Fixing smart-docs.lua keymaps..."
SMART_DOCS="$HOME/.config/nvim/lua/config/smart-docs.lua"

if [ -f "$SMART_DOCS" ]; then
  sed -i "s/{ desc = 'Python pydoc', ft = 'python' }/{ desc = 'Python pydoc' }/g" "$SMART_DOCS"
  sed -i "s/{ desc = 'Rust std docs', ft = 'rust' }/{ desc = 'Rust std docs' }/g" "$SMART_DOCS"
  sed -i "s/{ desc = 'Java docs', ft = 'java' }/{ desc = 'Java docs' }/g" "$SMART_DOCS"
  echo -e "${GREEN}✓${NC} smart-docs.lua fixed"
else
  echo -e "${YELLOW}smart-docs.lua not found, skipping fix${NC}"
fi

# === FIRST RUN ===
echo ""
echo -e "${GREEN}=== Installation Complete! ===${NC}"
echo ""
echo "Starting Neovim for first-time setup..."
echo "Plugins will be automatically installed by Lazy.nvim"
echo ""
echo -e "${YELLOW}Note: First launch may take a few minutes.${NC}"
echo ""
read -p "Press ENTER to launch Neovim (or Ctrl+C to skip)..."

nvim +Lazy

echo ""
echo -e "${GREEN}=== Setup Complete! ===${NC}"
echo ""
echo "Next steps:"
echo "  1. Install more LSPs: Open nvim and run ${BLUE}:Mason${NC}"
echo "  2. Update plugins: ${BLUE}:Lazy sync${NC}"
echo "  3. Update treesitter: ${BLUE}:TSUpdate${NC}"
echo "  4. Check health: ${BLUE}:checkhealth${NC}"
echo ""
echo "Keybindings:"
echo "  Documentation: ${BLUE}<leader>dd${NC} - DevDocs search"
echo "  LSP actions:   ${BLUE}<leader>lm${NC} - LSP menu"
echo "  File browser:  ${BLUE}<leader>e${NC}  - Neo-tree"
echo "  Find files:    ${BLUE}<leader>ff${NC} - Telescope"
echo ""
echo "Enjoy your Neovim setup! 🚀"
