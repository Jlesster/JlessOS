return {
  {
    "folke/which-key.nvim",
    lazy = false,

    opts_extend = { "disable.ft", "disable.bt" },
    opts = {
      preset = "modern",
      icons = {
        group = "",
        rules = false,
        separator = "-",
      },
    },
    config = function(_, opts)
      require("which-key").setup(opts)

      local icons = require("utils.icons")

      -- Register group names with icons
      require("which-key").add({
        { "<leader>f", group = icons.get_icon("Find", true) .. "Find" },
        { "<leader>g", group = icons.get_icon("Git", true) .. "Git" },
        { "<leader>l", group = icons.get_icon("LSP", true) .. "LSP" },
        { "<leader>b", group = icons.get_icon("Buffer", true) .. "Buffers" },
        { "<leader>t", group = icons.get_icon("Terminal", true) .. "Terminal" },
        { "<leader>m", group = icons.get_icon("Run", true) .. "Compiler" },
        { "<leader>d", group = icons.get_icon("Debugger", true) .. "Debugger" },
        { "<leader>o", group = icons.get_icon("AI", true) .. "OpenCode" },
        { "<leader>j", group = icons.get_icon("Java", true) .. "Java" },
      })
    end,
  },
}
