return {
  "rmagatti/auto-session",
  lazy = false,
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  keys = {
    -- Session management keymaps
    { "<leader>Ss", "<cmd>SessionSave<CR>", desc = "Save session" },
    { "<leader>Sr", "<cmd>SessionRestore<CR>", desc = "Restore session" },
    { "<leader>Sd", "<cmd>SessionDelete<CR>", desc = "Delete session" },
    { "<leader>Sf", "<cmd>Telescope session-lens<CR>", desc = "Find sessions" },
    { "<leader>Sl", "<cmd>Telescope session-lens<CR>", desc = "List sessions" },
    { "<leader>Sp", "<cmd>SessionPurgeOrphaned<CR>", desc = "Purge orphaned sessions" },
    { "<leader>St", "<cmd>SessionToggleAutoSave<CR>", desc = "Toggle auto-save" },
  },
  opts = {
    -- Automatically save sessions
    auto_save = false,
    -- Automatically restore sessions
    auto_restore = false,
    -- Auto save on exit
    auto_session_enable_last_session = false,
    -- Use git branch in session name
    auto_session_use_git_branch = true,
    -- Root directory for session files
    auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",
    -- Session lens configuration
    session_lens = {
      -- Load on setup
      load_on_setup = true,
      -- Theme configuration
      theme_conf = {
        border = true,
        winblend = 10,
      },
      -- Previewer
      previewer = false,
      -- Telescope mappings
      mappings = {
        delete_session = { "i", "<C-D>" },
        alternate_session = { "i", "<C-S>" },
      },
    },
    -- Files/directories to ignore when saving sessions
    bypass_session_save_file_types = {
      "snacks_dashboard",
      "neo-tree",
      "Trouble",
      "lazy",
      "mason",
      "toggleterm",
    },
    -- Hook to run before saving session
    pre_save_cmds = {
      "tabdo Neotree close", -- Close Neo-tree before saving
    },
    -- Hook to run after restoring session
    post_restore_cmds = {
      -- "Neotree show", -- Optionally reopen Neo-tree
    },
    -- Suppress session create/restore if in one of these directories
    auto_session_suppress_dirs = {
      "~/",
      "~/Downloads",
      "~/Desktop",
      "/tmp",
    },
    -- Auto restore behavior
    auto_restore_lazy_delay_enabled = true,
    -- Log level
    log_level = "error",
    -- Enable colors in log
    auto_session_enable_last_session = false,
    -- Close all windows before saving
    close_unsupported_windows = true,
    -- Arguments handling
    args_allow_single_directory = true,
    args_allow_files_auto_save = false,
    -- Continue session
    continue_restore_on_setup = false,
    -- Cwd change handling
    cwd_change_handling = {
      restore_upcoming_session = true,
      pre_cwd_changed_hook = nil,
      post_cwd_changed_hook = function()
        require("lualine").refresh()
      end,
    },
  },
  config = function(_, opts)
    -- Setup auto-session
    require("auto-session").setup(opts)

    -- Setup telescope integration
    local telescope = require("telescope")
    telescope.load_extension("session-lens")
  end,
}
