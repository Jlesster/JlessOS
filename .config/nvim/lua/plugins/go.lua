return {
  "ray-x/go.nvim",
  dependencies = {
    "ray-x/guihua.lua", -- required
  },
  ft = { "go", "gomod" },
  config = function()
    require("go").setup({
      -- Core behavior
      gofmt = "gofmt",          -- or "goimports"
      goimports = "goimports",
      fillstruct = "gopls",     -- use gopls for struct filling
      test_runner = "go",       -- standard `go test`

      -- Disable go.nvim's LSP management (you said LSPs are standard)
      lsp_cfg = false,
      lsp_on_attach = false,
      lsp_keymaps = false,

      -- Formatting
      run_in_floaterm = true,   -- good for TUI apps
      trouble = false,

      -- Diagnostics / tooling
      diagnostic = {
        hdlr = false,           -- let your global setup handle this
      },

      -- Save hooks
      gofmt_on_save = true,
      goimports_on_save = true,

      -- Test config
      test_timeout = "30s",
      test_env = {},
    })

    -- Useful keymaps (buffer-local via FileType)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "go",
      callback = function()
        local opts = { buffer = true, silent = true }

        vim.keymap.set("n", "<leader>Gr", ":GoRun<CR>", opts)
        vim.keymap.set("n", "<leader>Gt", ":GoTest<CR>", opts)
        vim.keymap.set("n", "<leader>GT", ":GoTestFunc<CR>", opts)
        vim.keymap.set("n", "<leader>Gc", ":GoCoverage<CR>", opts)
        vim.keymap.set("n", "<leader>Gi", ":GoImports<CR>", opts)
      end,
    })
  end,
}
