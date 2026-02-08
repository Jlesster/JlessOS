#!/bin/bash
# Neovim Configuration Dependencies
# Install these BEFORE running nvim for the first time

# === CORE ===
neovim                 # The editor itself
git                    # Required for plugin management

# === SEARCH & NAVIGATION (CRITICAL) ===
ripgrep                # REQUIRED for Telescope live_grep
fd                     # REQUIRED for Telescope file finding
fzf                    # Fuzzy finder

# === LSP DEPENDENCIES ===
npm                    # For many LSP servers
python-pip             # For Python LSPs
rustup                 # For rust-analyzer
cmake                  # For building some LSPs
gcc                    # For compiling tree-sitter parsers

# === LANGUAGE SERVERS (install via Mason or manually) ===
# These will be installed by Mason inside nvim
# But you need the base languages:
# - nodejs (via npm)
# - python
# - rust (via rustup)

# === TREE-SITTER ===
tree-sitter-cli        # IMPORTANT: Not in your list!
                       # Install via: cargo install tree-sitter-cli
                       # Or: npm install -g tree-sitter-cli

# === FORMATTERS & LINTERS (examples) ===
# Install these globally or let Mason handle them:
# - prettier (npm install -g prettier)
# - black (pip install black)
# - stylua (cargo install stylua)
# - shfmt (pacman -S shfmt)

# === FILE MANAGERS ===
yazi                   # For yazi.nvim integration

# === GIT INTEGRATION ===
lazygit               # For LazyGit terminal UI
github-cli            # For gh integration

# === TERMINAL ===
kitty                 # Your terminal (for terminal integration)

# === DOCUMENTATION TOOLS ===
glow                  # Markdown preview in terminal
tldr                  # Quick command help
man-db                # Man pages

# === AI ASSISTANT ===
opencode              # Your AI coding assistant

# === CLIPBOARD ===
wl-clipboard          # For Wayland clipboard support
xclip                 # Fallback for X11 (optional)

# === IMAGE SUPPORT ===
imagemagick           # For image.nvim
chafa                 # Terminal image viewing

# === JAVA DEVELOPMENT ===
jdk-openjdk           # Java 21 (you have JAVA_HOME set)
maven                 # Build tool

# === OPTIONAL BUT RECOMMENDED ===
bat                   # Better cat (syntax highlighting)
eza                   # Better ls (for file explorers)
delta                 # Better git diff viewer
gh                    # GitHub CLI
curl                  # HTTP requests
wget                  # Downloads
unzip                 # Archive extraction

# === FONTS (for terminal) ===
ttf-jetbrains-mono-nerd
ttf-nerd-fonts-symbols-mono

# === MISSING FROM YOUR SYSTEM ===
# YOU NEED TO INSTALL THESE:
echo "Installing missing critical dependencies..."
sudo pacman -S --needed ripgrep fd

# Tree-sitter CLI (choose one method):
# Method 1: Via cargo
cargo install tree-sitter-cli

# Method 2: Via npm
# npm install -g tree-sitter-cli

# Optional but recommended:
sudo pacman -S --needed \
  xclip \
  delta \
  shellcheck \
  shfmt \
  lua-language-server
