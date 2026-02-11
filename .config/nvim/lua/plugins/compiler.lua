return {
  {
    "zeioth/compiler.nvim",
    cmd = {
      "CompilerOpen",
      "CompilerToggleResults",
      "CompilerRedo",
      "CompilerStop"
    },
    dependencies = { "stevearc/overseer.nvim" },
    opts = {},
    config = function(_, opts)
      require("compiler").setup(opts)

      -- Disable compiler.nvim's built-in terminal hook
      vim.g.compiler_auto_open_quickfix = false

      -- Make sure it uses Overseer instead of opening its own terminal
      local compiler_group = vim.api.nvim_create_augroup("CompilerCustom", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = compiler_group,
        pattern = "compiler",
        callback = function()
          -- Prevent compiler from opening its own terminal
          vim.b.compiler_disable_terminal = true
        end,
      })
    end,
  },
}
