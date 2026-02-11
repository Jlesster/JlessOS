
return {
  "mrcjkb/rustaceanvim",
  version = "^5", -- recommended
  ft = { "rust" },
  config = function()
    vim.g.rustaceanvim = {
      tools = {
        -- UI helpers
        hover_actions = {
          auto_focus = true,
        },
        float_win_config = {
          border = "single",
        },
      },

      -- IMPORTANT: do NOT configure rust-analyzer here
      -- Let your global LSP config handle it
      server = {
        standalone = false,
      },

      -- DAP disabled by default (enable later if needed)
      dap = {
        autoload_configurations = false,
      },
    }

    -- Rust-specific keymaps
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "rust",
      callback = function()
        local opts = { buffer = true, silent = true }

        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.expandtab = true

        vim.keymap.set("n", "<leader>Rr", "<cmd>RustRun<CR>", opts)
        vim.keymap.set("n", "<leader>Rt", "<cmd>RustTest<CR>", opts)
        vim.keymap.set("n", "<leader>Rd", "<cmd>RustDebuggables<CR>", opts)
        vim.keymap.set("n", "<leader>Re", "<cmd>RustExpandMacro<CR>", opts)
      end,
    })
  end,
}
