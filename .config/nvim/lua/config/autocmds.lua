-- Auto Commands Configuration
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Helper function to check if a plugin is available
local function is_available(plugin)
  local lazy_config_avail, lazy_config = pcall(require, "lazy.core.config")
  return lazy_config_avail and lazy_config.plugins[plugin] ~= nil
end

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
  end,
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  group = augroup("TrimWhitespace", { clear = true }),
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Restore cursor position
autocmd("BufReadPost", {
  group = augroup("RestoreCursor", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Java-specific settings and LSP setup
autocmd("FileType", {
  group = augroup("JavaSettings", { clear = true }),
  pattern = "java",
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.colorcolumn = "920"

    -- Start Java LSP
    require("lsp.java").setup()
  end,
})

-- ## PROJECT ROOT MANAGEMENT -----------------------------------------------

autocmd("BufEnter", {
  desc = "Change directory to project root or current buffer's directory",
  callback = function(args)
    -- Skip for special buffers
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
    if buftype ~= "" or
       vim.tbl_contains({ "alpha", "neo-tree", "OverseerList", "toggleterm" }, filetype) then
      return
    end

    -- Get the buffer's file path
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    if bufname == "" or not vim.loop.fs_stat(bufname) then
      return
    end

    local old_cwd = vim.fn.getcwd()
    local new_cwd = nil
    local found_project_root = false

    -- 🔥 NEW: Manually search for project root markers
    local function find_project_root(path)
      local markers = { "pom.xml", ".git", "build.gradle", "package.json" }
      local current = path

      while current ~= "/" do
        for _, marker in ipairs(markers) do
          local marker_path = current .. "/" .. marker
          if vim.fn.filereadable(marker_path) == 1 or vim.fn.isdirectory(marker_path) == 1 then
            return current
          end
        end
        current = vim.fn.fnamemodify(current, ":h")
      end

      return nil
    end

    -- Start from the file's directory
    local file_dir = vim.fn.fnamemodify(bufname, ":h")
    local project_root = find_project_root(file_dir)

    if project_root and vim.fn.isdirectory(project_root) == 1 then
      found_project_root = true
      new_cwd = project_root
    else
      -- Fallback to file directory
      new_cwd = file_dir
    end

    -- Only change directory if we found a valid new directory and it's different
    if new_cwd and new_cwd ~= old_cwd then
      local ok = pcall(function()
        vim.cmd("cd " .. vim.fn.fnameescape(new_cwd))
      end)

      if not ok then
        return
      end

      -- Refresh Neo-tree if directory actually changed
      if is_available("neo-tree.nvim") then
        vim.schedule(function()
          pcall(function()
            local manager = require("neo-tree.sources.manager")
            local state = manager.get_state("filesystem")

            if state then
              state.path = new_cwd
              manager.refresh("filesystem")
            end
          end)
        end)
      end
    end
  end,
})

-- Enable semantic token highlighting globally
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.server_capabilities.semanticTokensProvider then
      vim.lsp.semantic_tokens.start(args.buf, client.id)
    end
  end,
})
