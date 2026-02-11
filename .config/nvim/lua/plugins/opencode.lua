return {
  {
    "NickvanDyke/opencode.nvim",
    config = function()
      vim.g.opencode_opts = {
        provider = {
          enabled = "snacks",
          snacks = {
            auto_close = true,
            win = {
              position = "left",
              width = 0.3,
              enter = false,
              wo = { winbar = "" },
              bo = { filetype = "opencode_terminal" },
            },
          },
        }
      }
    end,
  },
}
