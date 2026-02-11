-- Custom ghost text highlighting
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    -- Codeium ghost text (inline suggestions)
    vim.api.nvim_set_hl(0, "CodeiumSuggestion", {
      fg = "#565f89",
      italic = true,
      bold = false,
    })

    -- nvim-cmp ghost text
    vim.api.nvim_set_hl(0, "CmpGhostText", {
      fg = "#565f89",
      italic = true,
      bold = false,
    })
  end,
})

-- Apply immediately
vim.api.nvim_set_hl(0, "CodeiumSuggestion", {
  fg = "#565f89",
  italic = true,
  bold = false,
})

vim.api.nvim_set_hl(0, "CmpGhostText", {
  fg = "#565f89",
  italic = true,
  bold = false,
})

return {}
