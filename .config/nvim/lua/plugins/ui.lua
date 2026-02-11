return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = "MunifTanjim/nui.nvim",
    cmd = "Neotree",
    opts = function()
      vim.g.neo_tree_remove_legacy_commands = true
      local icons = require("utils.icons")
      local get_icon = icons.get_icon
      return {
        auto_clean_after_session_restore = true,
        close_if_last_window = true,
        popout_border_style = "rounded",
        buffers = {
          show_unloaded = true
        },
        sources = { "filesystem", "buffers", "git_status" },
        source_selector = {
          winbar = true,
          content_layout = "center",
          sources = {
            {
              source = "filesystem",
              display_name = get_icon("FolderClosed", true) .. " File",
            },
            {
              source = "buffers",
              display_name = get_icon("DefaultFile", true) .. " Bufs",
            },
            {
              source = "git_status",
              display_name = get_icon("Git", true) .. " Git",
            },
            {
              source = "diagnostics",
              display_name = get_icon("Diagnostic", true) .. " Diagnostic",
            },
          },
        },
        default_component_configs = {
          indent = { padding = 0 },
          icon = {
            folder_closed = get_icon("FolderClosed"),
            folder_open = get_icon("FolderOpen"),
            folder_empty = get_icon("FolderEmpty"),
            folder_empty_open = get_icon("FolderEmpty"),
            default = get_icon("DefaultFile"),
          },
          modified = { symbol = get_icon("FileModified") },
          git_status = {
            symbols = {
              added = get_icon("GitAdd"),
              deleted = get_icon("GitDelete"),
              modified = get_icon("GitChange"),
              renamed = get_icon("GitRenamed"),
              untracked = get_icon("GitUntracked"),
              ignored = get_icon("GitIgnored"),
              unstaged = get_icon("GitUnstaged"),
              staged = get_icon("GitStaged"),
              conflict = get_icon("GitConflict"),
            },
          },
        },
        -- A command is a function that we can assign to a mapping (below)
        commands = {
          system_open = function(state)
            local path = state.tree:get_node():get_id()
            local cmd
            if vim.fn.has("mac") == 1 then
              cmd = { "open", path }
            elseif vim.fn.has("win32") == 1 then
              cmd = { "explorer", path }
            else
              cmd = { "xdg-open", path }
            end
            vim.fn.jobstart(cmd, { detach = true })
          end,
          parent_or_close = function(state)
            local node = state.tree:get_node()
            if
                (node.type == "directory" or node:has_children())
                and node:is_expanded()
            then
              state.commands.toggle_node(state)
            else
              require("neo-tree.ui.renderer").focus_node(
                state,
                node:get_parent_id()
              )
            end
          end,
          child_or_open = function(state)
            local node = state.tree:get_node()
            if node.type == "directory" or node:has_children() then
              if not node:is_expanded() then -- if unexpanded, expand
                state.commands.toggle_node(state)
              else                           -- if expanded and has children, seleect the next child
                require("neo-tree.ui.renderer").focus_node(
                  state,
                  node:get_child_ids()[1]
                )
              end
            else -- if not a directory just open it
              state.commands.open(state)
            end
          end,
          copy_selector = function(state)
            local node = state.tree:get_node()
            local filepath = node:get_id()
            local filename = node.name
            local modify = vim.fn.fnamemodify

            local results = {
              e = { val = modify(filename, ":e"), msg = "Extension only" },
              f = { val = filename, msg = "Filename" },
              F = {
                val = modify(filename, ":r"),
                msg = "Filename w/o extension",
              },
              h = {
                val = modify(filepath, ":~"),
                msg = "Path relative to Home",
              },
              p = {
                val = modify(filepath, ":."),
                msg = "Path relative to CWD",
              },
              P = { val = filepath, msg = "Absolute path" },
            }

            local messages = {
              { "\nChoose to copy to clipboard:\n", "Normal" },
            }
            for i, result in pairs(results) do
              if result.val and result.val ~= "" then
                vim.list_extend(messages, {
                  { ("%s."):format(i),           "Identifier" },
                  { (" %s: "):format(result.msg) },
                  { result.val,                  "String" },
                  { "\n" },
                })
              end
            end
            vim.api.nvim_echo(messages, false, {})
            local result = results[vim.fn.getcharstr()]
            if result and result.val and result.val ~= "" then
              Snacks.notify("Copied: " .. result.val)
              vim.fn.setreg("+", result.val)
            end
          end,
          find_in_dir = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            require("telescope.builtin").find_files {
              cwd = node.type == "directory" and path
                  or vim.fn.fnamemodify(path, ":h"),
            }
          end,
        },
        window = {
          position = "right",
          width = 40,
          popup = {
            size = {
              height = "100%",
              width = 25,
            },
            position = {
              row = 0,
              col = 0
            },
          },
          mappings = {
            ["<space>"] = false,
            ["<S-CR>"] = "system_open",
            ["[b"] = "prev_source",
            ["]b"] = "next_source",
            F = pcall(require, "telescope.builtin") and "find_in_dir" or nil,
            O = "system_open",
            Y = "copy_selector",
            h = "parent_or_close",
            l = "child_or_open",
          },
        },
        filesystem = {
          follow_current_file = {
            enabled = true,
          },
          hijack_netrw_behavior = "open_current",
          use_libuv_file_watcher = true,
        },
        event_handlers = {
          {
            event = "neo_tree_buffer_enter",
            handler = function(_) vim.opt_local.signcolumn = "auto" end,
          },
        },
      }
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = "VeryLazy",
    config = function()
      -- Helper function to get colors from highlight groups
      local function get_hl_colors(hl_name)
        local hl = vim.api.nvim_get_hl(0, { name = hl_name, link = false })
        return {
          fg = hl.fg and string.format("#%06x", hl.fg) or nil,
          bg = hl.bg and string.format("#%06x", hl.bg) or nil,
          gui = hl.bold and 'bold' or nil,
        }
      end

      -- Build theme dynamically from highlight groups
      local function build_theme()
        return {
          normal = {
            a = get_hl_colors('lualine_a_normal'),
            b = get_hl_colors('lualine_b_normal'),
            c = get_hl_colors('lualine_c_normal'),
            x = get_hl_colors('lualine_x_normal'),
            y = get_hl_colors('lualine_y_normal'),
            z = get_hl_colors('lualine_z_normal'),
          },
          insert = {
            a = get_hl_colors('lualine_a_insert'),
            b = get_hl_colors('lualine_b_insert'),
            c = get_hl_colors('lualine_c_insert'),
            x = get_hl_colors('lualine_x_insert'),
            y = get_hl_colors('lualine_y_insert'),
            z = get_hl_colors('lualine_z_insert'),
          },
          visual = {
            a = get_hl_colors('lualine_a_visual'),
            b = get_hl_colors('lualine_b_visual'),
            c = get_hl_colors('lualine_c_visual'),
            x = get_hl_colors('lualine_x_visual'),
            y = get_hl_colors('lualine_y_visual'),
            z = get_hl_colors('lualine_z_visual'),
          },
          replace = {
            a = get_hl_colors('lualine_a_replace'),
            b = get_hl_colors('lualine_b_replace'),
            c = get_hl_colors('lualine_c_replace'),
            x = get_hl_colors('lualine_x_replace'),
            y = get_hl_colors('lualine_y_replace'),
            z = get_hl_colors('lualine_z_replace'),
          },
          command = {
            a = get_hl_colors('lualine_a_command'),
            b = get_hl_colors('lualine_b_command'),
            c = get_hl_colors('lualine_c_command'),
            x = get_hl_colors('lualine_x_command'),
            y = get_hl_colors('lualine_y_command'),
            z = get_hl_colors('lualine_z_command'),
          },
          inactive = {
            a = get_hl_colors('lualine_a_inactive'),
            b = get_hl_colors('lualine_b_inactive'),
            c = get_hl_colors('lualine_c_inactive'),
          },
        }
      end


      -- Custom LSP component
      local function lsp_status()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then
          return ""
        end

        local client_names = {}
        for _, client in ipairs(clients) do
          table.insert(client_names, client.name)
        end

        return " " .. table.concat(client_names, ", ")
      end

      require('lualine').setup({
        options = {
          theme = build_theme(),
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
          icon = '',  -- Neovim logo,
          refresh = { statusline = 100, },
          globalstatus = true,
          disabled_filetypes = {
            statusline = { 'snacks_dashboard' },
          },
        },
        sections = {
          lualine_a = {
            {
              'mode',
              fmt = function(mode)
                  local map = {
                    ['NORMAL'] = 'N',
                    ['INSERT'] = 'I',
                    ['VISUAL'] = 'V',
                    ['V-LINE'] = 'VI',
                    ['V-BLOCK'] = 'VB',
                    ['SELECT'] = 'S',
                    ['S-LINE'] = 'S',
                    ['S-BLOCK'] = 'SB',
                    ['REPLACE'] = 'R',
                    ['COMMAND'] = 'C',
                    ['TERMINAL'] = 'T',
                  }
                return map[mode] or mode:sub(1, 1)
              end,
            }
          },
          lualine_b = {
            {
              'branch',
              icon = '',
            },
            {
              'diff',
              icon = false,
              on_click = function()
                vim.cmd('TermExec cmd="lazygit && exit" direction=float go_back=0')
                vim.defer_fn(function()
                  vim.cmd('startinsert!')
                end, 200)
              end,
              symbols = { added = ' ', modified = ' ', removed = ' ' },
            },
          },
          lualine_c = {
            {
              'filename',
              path = 1, -- relative path
              icon = false,
              fmt = function(name)
                -- max characters for the whole path
                local max = 30

                if #name <= max then
                  return name
                end

                -- keep filename, truncate directories
                local sep = package.config:sub(1,1)
                local parts = vim.split(name, sep)

                if #parts <= 1 then
                  return name:sub(1, max - 1) .. '…'
                end

                local filename = table.remove(parts)
                local dir = table.concat(parts, sep)

                local available = max - (#filename + 2) -- "/…/"
                if available <= 0 then
                  return filename
                end

                return dir:sub(1, available) .. '…' .. sep .. filename
              end,
              -- Click to open system file browser in current directory
              on_click = function()
                -- Get the directory of current file
                local file_dir = vim.fn.expand('%:p:h')

                -- Detect OS and use appropriate command
                local open_cmd
                if vim.fn.has('mac') == 1 then
                  open_cmd = 'open'  -- macOS
                elseif vim.fn.has('win32') == 1 then
                  open_cmd = 'explorer'  -- Windows
                else
                  open_cmd = 'xdg-open'  -- Linux
                end

                -- Open in background without blocking
                vim.fn.jobstart({open_cmd, file_dir}, {detach = true})
              end,
            }
          },
          lualine_x = {
            {
              lsp_status,
              icon = "",
              color = { gui = "none" },
              on_click = function()
                vim.cmd('LspInfo')
              end,
            },
            {
              'diagnostics',
              icon = false,
              sources = { 'nvim_diagnostic' },
              symbols = { error = ' ', warn = '●', info = '', hint = ' ' },
              on_click = function()
                  require('telescope.builtin').diagnostics()
              end,
            },
            {
              'filetype',
              colored = false,
              icon_only = true,
            },
          },
          lualine_y = {
            {
              'progress',
              icon = false,
            }
          },
          lualine_z = {
            {
              'location',
              icon = false,
            }
          }
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { 'filename' },
          lualine_x = { 'location' },
          lualine_y = {},
          lualine_z = {}
        },
        extensions = { 'neo-tree', 'lazy', 'mason', 'toggleterm' }
      })
    end,
  },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      icons = {
        group = "+",
        separator = "-",
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)

      local icons = require("utils.icons")
      local get_icon = icons.get_icon

      wk.add({
        { "<leader>j", group = get_icon("Java", true) .. "Java" },
        { "<leader>o", group = get_icon("AI", true) .. "OpenCode" },
      })
    end,
  },
}

