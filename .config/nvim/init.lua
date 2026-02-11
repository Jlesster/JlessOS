-- NVIM INIT
-- Add necessary paths without replacing entire PATH
local paths_to_add = {
  vim.fn.expand('$HOME') .. '/go/bin',
  vim.fn.expand('$HOME') .. '/.local/bin',
}

for _, path in ipairs(paths_to_add) do
  if vim.fn.isdirectory(path) == 1 then
    vim.env.PATH = vim.env.PATH .. ':' .. path
  end
end

--get rid of annoying deprecate warining
vim.deprecate = function() end

-- Set leader key before lazy
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic Neovim settings
require("config.options")
require("config.keymaps")
require("config.highlights")
require("config.smart-docs")

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup({
  { import = "plugins" },
}, {
  ui = {
    border = "rounded",
  },
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
})

-- Load autocmds
require("config.autocmds")

--Load colorscheme
vim.cmd.colorscheme("material_purple_mocha")

vim.defer_fn(function()
  local ok, dynamic_colors = pcall(require, "utils.dynamic-colors")
  if not ok then
    require("snacks").notify("Failed to load dynamic-colors", {
      level = vim.log.levels.WARN,
      timeout = 2000,
    })
    return
  end

  dynamic_colors.setup()

end, 150)

