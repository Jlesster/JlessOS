# nvimConf

A clean, minimal Neovim configuration focused on development workflow and Material You theming integration.

![Neovim](https://img.shields.io/badge/Neovim-0.10+-green?style=flat-square&logo=neovim)
![Lua](https://img.shields.io/badge/Lua-blue?style=flat-square&logo=lua)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)

## ✨ Features

- 🚀 **Fast Startup** - Lazy-loaded plugins for quick launch times
- 🎨 **Material You Integration** - Syncs with system theme from JlessOS
- 🔍 **Telescope** - Fuzzy finder for files, text, and more
- 🌳 **Treesitter** - Advanced syntax highlighting and text objects
- 💡 **LSP** - Native language server protocol support
- ⚡ **Autocompletion** - Smart completions with nvim-cmp
- 🎯 **Which-key** - Interactive keybinding helper
- 📦 **Lazy.nvim** - Modern plugin manager

## 📦 What's Included

### Core Plugins
- **Plugin Manager**: lazy.nvim
- **Fuzzy Finder**: Telescope with file browser
- **Syntax**: nvim-treesitter with auto-install
- **LSP**: Native LSP with Mason for easy server management
- **Completion**: nvim-cmp with multiple sources
- **Git**: Fugitive, Gitsigns, LazyGit integration
- **UI**: Which-key, lualine, indent-blankline
- **File Explorer**: Neo-tree or nvim-tree
- **Colorscheme**: Catppuccin with Material You support

## 🚀 Quick Install

### Standalone Installation

```Fish
bash (curl -fsSL https://raw.githubusercontent.com/Jlesster/nvimConf/main/nvim_install.sh | psub)
```

```bash
git clone https://github.com/Jlesster/nvimConf.git ~/.config/nvim
nvim
# lazy.nvim will auto-install on first launch
# Run :Lazy sync to update all plugins
```

### Install with JlessOS

This config is automatically installed when using the [JlessOS dotfiles](https://github.com/Jlesster/JlessOS):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Jlesster/JlessOS/master/bootstrap.sh)
```

## 📋 Requirements

- **Neovim** >= 0.10.0
- **Git** >= 2.19.0
- **Node.js** (for some LSP servers)
- **ripgrep** - For Telescope live grep
- **fd** - For Telescope file finding
- A [Nerd Font](https://www.nerdfonts.com/) (recommended: JetBrains Mono Nerd Font)

### Optional Dependencies
- **lazygit** - Git UI integration
- **tree-sitter CLI** - For manual grammar updates
- **Language servers** - Auto-installed via Mason

## ⌨️ Key Bindings

Leader key: `<Space>`

### General
| Keybind | Action |
|---------|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Browse buffers |
| `<leader>fh` | Help tags |
| `<leader>e` | Toggle file explorer |
| `<leader>gg` | Open LazyGit |

### LSP
| Keybind | Action |
|---------|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename symbol |
| `[d` / `]d` | Previous/next diagnostic |

### Git
| Keybind | Action |
|---------|--------|
| `<leader>gs` | Git status |
| `<leader>gb` | Git blame |
| `<leader>gd` | Git diff |
| `]c` / `[c` | Next/previous hunk |

## 📁 Structure

```
nvimConf/
├── init.lua           # Entry point
├── lua/
│   ├── config/        # Core configuration
│   │   ├── options.lua
│   │   ├── keymaps.lua
│   │   └── autocmds.lua
│   └── plugins/       # Plugin configurations
│       ├── lsp.lua
│       ├── telescope.lua
│       ├── treesitter.lua
│       └── ...
├── colors/            # Custom colorschemes
├── ftplugin/          # Filetype-specific settings
└── lazy-lock.json     # Plugin version lock
```

## 🎨 Theming

### Material You Integration

When used with JlessOS, this config automatically syncs with your system theme:

```bash
# Generate theme from wallpaper
switchwall.sh --image ~/path/to/wallpaper.jpg

# Theme updates automatically in Neovim
```

### Manual Theme Selection

```vim
:colorscheme catppuccin-mocha
:colorscheme catppuccin-latte
```

## 🔧 Customization

### Add Your Own Plugins

Create a new file in `lua/plugins/`:

```lua
-- lua/plugins/my-plugin.lua
return {
  "author/plugin-name",
  config = function()
    -- Plugin configuration
  end,
}
```

### Modify Keybindings

Edit `lua/config/keymaps.lua`:

```lua
vim.keymap.set('n', '<leader>custom', '<cmd>YourCommand<cr>', { desc = 'Description' })
```

### LSP Server Management

Install language servers via Mason:

```vim
:Mason
# Search and install servers with 'i'
# Uninstall with 'X'
```

Or auto-install in `lua/plugins/lsp.lua`:

```lua
ensure_installed = { "lua_ls", "rust_analyzer", "pyright" }
```

## 🛠️ Troubleshooting

### Plugins not loading
```vim
:Lazy sync          " Update all plugins
:Lazy clean         " Remove unused plugins
:Lazy restore       " Restore from lazy-lock.json
```

### LSP not working
```vim
:LspInfo            " Check LSP status
:Mason              " Check installed servers
:checkhealth        " Run health checks
```

### Treesitter issues
```vim
:TSUpdate           " Update all parsers
:TSInstall <lang>   " Install specific parser
:checkhealth nvim-treesitter
```

### LazyGit error on startup

If you get a "jobstart requires unmodified buffer" error, make sure you're opening nvim without any files:

```bash
nvim              # ✓ Good
nvim file.txt     # ✗ May cause issues on first launch
```

After first launch and plugin installation, opening files works normally.

## 📝 Post-Installation

1. Open Neovim: `nvim`
2. Wait for lazy.nvim to install plugins
3. Run `:Lazy sync` to update everything
4. Run `:checkhealth` to verify setup
5. Install language servers via `:Mason`
6. Restart Neovim

## 🤝 Integration with JlessOS

This config is designed to work seamlessly with [JlessOS](https://github.com/Jlesster/JlessOS):

- Automatic theme syncing from wallpapers
- Consistent colorscheme across all tools
- Fish shell integration
- Terminal colors match system theme

## 📄 License

MIT License - Feel free to use and modify!

## 🙏 Credits

- [LazyVim](https://github.com/LazyVim/LazyVim) - Configuration inspiration
- [Catppuccin](https://github.com/catppuccin/nvim) - Beautiful colorscheme
- [Neovim](https://neovim.io/) - The best editor

---

**Part of the [JlessOS](https://github.com/Jlesster/JlessOS) ecosystem**
