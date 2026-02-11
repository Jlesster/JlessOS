return {
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      require("bufferline").setup({
        options = {
          -- CORE BEHAVIOR
          mode = "buffers",                    -- "buffers" shows open buffers, "tabs" shows vim tabs
          themable = true,                     -- allows colors from your colorscheme
          close_command = "bdelete! %d",       -- command to close buffer (can use "Bdelete %d" if using bufdelete.nvim)
          right_mouse_command = "bdelete! %d", -- right click closes buffer
          left_mouse_command = "buffer %d",    -- left click switches to buffer
          middle_mouse_command = nil,          -- middle click does nothing (can set to close)

          -- VISUAL STYLE
          style_preset = require("bufferline").style_preset.default,
          -- Options: default, minimal, no_italic, no_bold
          -- Or use a list: { require("bufferline").style_preset.no_italic, require("bufferline").style_preset.no_bold }

          indicator = {
            -- icon = '▎', -- The character shown on the left of active buffer
            icon = '│', -- Alternative: thin line
            -- icon = '▌',  -- Alternative: thick line
            style = 'icon', -- 'icon' | 'underline' | 'none'
          },

          -- BUFFER ICONS & TEXT
          buffer_close_icon = '󰅖', -- Icon for close button on buffers
          -- buffer_close_icon = '', -- Alternative
          modified_icon = '●', -- Icon shown when buffer is modified
          close_icon = '', -- Icon for close button in top right
          left_trunc_marker = '', -- Icon when buffers overflow left
          right_trunc_marker = '', -- Icon when buffers overflow right

          -- NUMBER DISPLAY
          numbers = "ordinal", -- "none" | "ordinal" | "buffer_id" | "both" | function
          -- numbers = "ordinal", -- Shows 1, 2, 3... for quick navigation
          -- numbers = function(opts) return string.format('%s', opts.raise(opts.ordinal)) end,

          -- TAB BEHAVIOR
          max_name_length = 18,   -- Max chars for buffer name before truncating
          max_prefix_length = 15, -- Max chars for directory name (when showing path)
          truncate_names = true,  -- Truncate long names instead of ellipsis
          tab_size = 18,          -- Width of each buffer tab

          -- DIAGNOSTICS (LSP errors/warnings)
          diagnostics = false,                -- false | "nvim_lsp" | "coc"
          diagnostics_update_in_insert = false, -- Don't update diagnostics while typing
          diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local icon = level:match("error") and " " or " "
            return " " .. icon .. count
          end,
          -- Custom diagnostics format - shows icon and count

          -- FILE TYPE FILTERING
          -- Show only certain filetypes in bufferline
          custom_filter = function(buf_number, buf_numbers)
            -- Don't show these filetypes
            local excluded_types = { "qf", "terminal", "help" }
            local filetype = vim.bo[buf_number].filetype
            return not vim.tbl_contains(excluded_types, filetype)
          end,

          -- OFFSET (for sidebars like neo-tree)
          offsets = {
            {
              filetype = "neo-tree",
              text = "NeoTree",        -- Header text for the offset area
              -- text = function() return vim.fn.getcwd() end, -- Alternative: show cwd
              text_align = "left",     -- "left" | "center" | "right"
              separator = true,        -- Show a separator line
              highlight = "Directory", -- Highlight group for text
            },
            -- You can add more offsets for other sidebars
            {
              filetype = "aerial",
              text = "Symbols",
              text_align = "center",
            },
          },

          -- COLORS & HIGHLIGHTS
          color_icons = true,             -- Show colored icons (uses nvim-web-devicons)
          show_buffer_icons = true,       -- Show file type icons
          show_buffer_close_icons = true, -- Show close button on each buffer
          show_close_icon = false,        -- Show close button in top right corner
          show_tab_indicators = true,     -- Show indicator for active tab
          show_duplicate_prefix = true,   -- Show directory when multiple files have same name

          -- SEPARATORS
          separator_style = "thin", -- "slant" | "slope" | "thick" | "thin" | { 'any', 'any' }
          -- separator_style = "slant", -- Angled separators (like powerline)
          -- separator_style = "padded_slant", -- Angled with padding
          -- separator_style = { '', '' }, -- Custom separator characters

          -- ALWAYS SHOW
          persist_buffer_sort = true, -- Keep buffer order when reopening nvim
          move_wraps_at_ends = false, -- When cycling buffers, don't wrap to other end

          -- GROUPING (group buffers by directory)
          groups = {
            options = {
              toggle_hidden_on_enter = true, -- Show hidden groups when entering
            },
            items = {
              require('bufferline.groups').builtin.pinned:with({ icon = "󰐃" }), -- Pinned buffers
              -- You can create custom groups:
              -- {
              --   name = "Tests",
              --   icon = "",
              --   matcher = function(buf)
              --     return buf.filename:match("_spec") or buf.filename:match("_test")
              --   end,
              -- },
            }
          },

          -- SORTING
          -- sort_by = 'insert_at_end',
          -- Options: 'insert_after_current' | 'insert_at_end' | 'id' | 'extension' | 'relative_directory' | 'directory' | 'tabs'
          sort_by = 'extension, insert_after_current, directory', -- Group by file type
          -- sort_by = 'directory', -- Group by directory

          -- HOVER BEHAVIOR
          hover = {
            enabled = true,     -- Show file path on hover
            delay = 200,        -- Delay in ms before showing
            reveal = { 'close' }, -- What to show on hover: 'close' button
          },
        },

        -- HIGHLIGHTS (customize colors)
        -- These override your colorscheme's bufferline colors
        highlights = {
        },
      })

      -- OPTIONAL: Keymaps for buffer navigation
      -- vim.keymap.set('n', '<Tab>', '<cmd>BufferLineCycleNext<cr>', { desc = "Next buffer" })
      -- vim.keymap.set('n', '<S-Tab>', '<cmd>BufferLineCyclePrev<cr>', { desc = "Previous buffer" })
      -- vim.keymap.set('n', '<leader>bp', '<cmd>BufferLineTogglePin<cr>', { desc = "Pin buffer" })
      -- vim.keymap.set('n', '<leader>bP', '<cmd>BufferLineGroupClose ungrouped<cr>', { desc = "Close unpinned buffers" })
      -- vim.keymap.set('n', '<leader>bo', '<cmd>BufferLineCloseOthers<cr>', { desc = "Close other buffers" })
      -- vim.keymap.set('n', '<leader>br', '<cmd>BufferLineCloseRight<cr>', { desc = "Close buffers to right" })
      -- vim.keymap.set('n', '<leader>bl', '<cmd>BufferLineCloseLeft<cr>', { desc = "Close buffers to left" })
      -- vim.keymap.set('n', '<leader>1', '<cmd>BufferLineGoToBuffer 1<cr>', { desc = "Go to buffer 1" })
      -- vim.keymap.set('n', '<leader>2', '<cmd>BufferLineGoToBuffer 2<cr>', { desc = "Go to buffer 2" })
      -- ... add more for 3-9
    end,
  }
}
