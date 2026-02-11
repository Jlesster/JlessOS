return {
  "edolphin-ydf/goimpl.nvim",
  ft = "go",
  config = function()
    -- No setup required; plugin is intentionally minimal

    -- Keymap:
    -- Cursor on a type → generate implementation for interface
    vim.keymap.set(
      "n",
      "<leader>Gi",
      ":GoImpl ",
      { desc = "Generate Go interface implementation" }
    )
  end,
}
