# JlessOS

A clean, modern Hyprland dotfiles configuration for Arch Linux with Material You theming support going for a TUI vibe.

![Hyprland](https://img.shields.io/badge/Hyprland-blue?style=flat-square)
![Arch Linux](https://img.shields.io/badge/Arch-1793D1?style=flat-square&logo=arch-linux&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)

## ✨ Features

-  **Material You Theming** - Dynamic color schemes from wallpapers
-  **Hyprland** - Modern Wayland compositor with animations
-  **Waybar** - Beautiful, customizable status bar
-  **Fish Shell** - Friendly interactive shell
-  **Optimized** - Fast and responsive configuration
-  **Complete Setup** - All dependencies and configs included

## 📦 What's Included

- **Window Manager**: Hyprland with custom keybindings
- **Status Bar**: Waybar with custom modules
- **App Launcher**: Wofi with custom styling
- **Terminal**: Kitty with catppuccin theme
- **Shell**: Fish with custom config
- **File Manager**: Yazi terminal file manager
- **Editor**: Neovim configuration (separate repo)
- **Utilities**: Fastfetch, lazygit, and custom scripts
- **Theming**: Material You color generation system

## 🚀 Quick Install

### One-Line Install

**For Bash/Zsh:**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Jlesster/JlessOS/master/bootstrap.sh)
```

**For Fish:**
```fish
bash (curl -fsSL https://raw.githubusercontent.com/Jlesster/JlessOS/master/bootstrap.sh | psub)
```

### Manual Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Jlesster/JlessOS.git ~/.dotfiles/JlessOS
   cd ~/.dotfiles/JlessOS
   ```

2. **Run the installer:**
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

3. **Follow the prompts** to install dependencies and copy configurations

## 📋 Requirements

- **OS**: Arch Linux (or Arch-based: EndeavourOS, CachyOS, Manjaro)
- **Display Server**: Wayland
- **Dependencies**: Automatically installed by the script

### Core Packages
- `hyprland` - Wayland compositor
- `waybar` - Status bar
- `wofi` - Application launcher
- `kitty` - Terminal emulator
- `fish` - Shell
- `dunst` - Notification daemon
- `pipewire` - Audio server

## 🎨 Theming

Generate a Material You theme from your wallpaper:

```bash
switchwall.sh --image ~/path/to/wallpaper.jpg
```

Or from a hex color:

```bash
switchwall.sh --color '#89b4fa'
```

## ⌨️ Key Bindings

| Keybind | Action |
|---------|--------|
| `Super + T` | Open terminal |
| `Super`     | App launcher |
| `Super + Q` | Close window |
| `Super + E` | Yazi         |
| `Super + ALT + SPACE` | Toggle floating |
| `Super + F` | Fullscreen |
| `Super + 1-9` | Switch workspace |
| `Super + Shift + 1-9` | Move to workspace |

See [keybinds-cheatsheet.txt](keybinds-cheatsheet.txt) for full list.

## 📁 Structure

```
JlessOS/
├── hypr/              # Hyprland configuration
├── waybar/            # Waybar config and styles
├── wofi/              # Wofi launcher config
├── kitty/             # Kitty terminal config
├── fish/              # Fish shell config
├── yazi/              # Yazi file manager config
├── fastfetch/         # System info config
├── lazygit/           # Git UI config
├── scripts/           # Utility scripts (linked to ~/.local/bin)
├── colorscheming/     # Material You theme generator
├── Fonts/             # Custom fonts
└── Kvantum/           # Qt theming
```

## 🔧 Post-Installation

1. **Log out** and select **Hyprland** from your display manager
2. Press `Super + Enter` to open terminal
3. Open Neovim and run `:Lazy sync` to install plugins
4. Generate your theme with a wallpaper
5. Enjoy!

## 🛠️ Customization

- **Hyprland**: Edit `~/.config/hypr/hyprland.conf`
- **Waybar**: Edit `~/.config/waybar/config.jsonc`
- **Colors**: Regenerate theme or edit `~/.config/hypr/colors.conf`
- **Scripts**: Modify scripts in `~/.dotfiles/JlessOS/scripts/`

## 🐛 Troubleshooting

**Scripts not working:**
- Ensure `~/.local/bin` is in your PATH
- For Fish: `fish_add_path $HOME/.local/bin` in `~/.config/fish/config.fish`
- For Bash/Zsh: `export PATH="$HOME/.local/bin:$PATH"` in `~/.bashrc` or `~/.zshrc`

**Configs not applying:**
- Log out and log back into Hyprland
- Reload Hyprland: `Super + Shift + R` or `hyprctl reload`

**Missing fonts:**
- Run `fc-cache -fv` to rebuild font cache
- Check fonts in `~/.local/share/fonts`

## 📝 Credits

- [Hyprland](https://hyprland.org/) - Amazing Wayland compositor
- [Catppuccin](https://github.com/catppuccin) - Color scheme inspiration
- Material You color generation system

## 📄 License

MIT License - Feel free to use and modify!

## 🤝 Contributing

Issues and pull requests welcome! Feel free to customize and share your improvements.

---

**Note**: Backup your existing configs before installing. The installer creates automatic backups in `~/.dotfiles-backup-<timestamp>`
