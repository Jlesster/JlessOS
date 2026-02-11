return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      input = { enabled = true },
      picker = {
        enabled = true,
        win = {
          border = "rounded",
        },
      },
      terminal = {
        enabled = true,
        win = {
          style = "terminal",
          border = "single",
        },
      },
      select  = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 3000,
        width = { min = 40, max = 0.4 },
        height = { min = 1, max = 0.6 },
        style = "compact",
      },
      bigfile = { enabled = true },
      indent = {
        enabled = true,
        char = " ",
        only_scope = false,
        only_current = true,
        animate = {
          enabled = true,
        },
      },
      scope = {
        enabled = true,
        cursor = false,
        char = "│",
        treesitter = { enabled = true },
      },
      scroll = {
        enabled = false,
        animate = {
          duration = { step = 50, total = 250 },
          easing = "linear",
        },
      },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      zen = {
        enabled = true,
        toggles = {
          dim = true,
          git_signs = false,
          mini_diff_signs = false,
        },
        zoom = {
          width = 0.8,
          height = 0.9,
        },
      },
      git = { enabled = true },
      gitbrowse = { enabled = true },
      lazygit = {
        enabled = true,
        configure = true,
        theme = {
          activeBorderColor = { fg = "Special" },
          inactiveBorderColor = { fg = "Comment" },
        },
      },
      bufdelete = { enabled = true },
      scratch = {
        enabled = true,
        name = "Scratch",
        ft = "markdown",
        icon = "󱓧",
        root = vim.fn.stdpath("data") .. "/scratch",
        autowrite = true,
        filekey = {
          cwd = true,
          branch = true,
          count = true,
        },
        win = {
          width = 100,
          height = 30,
          bo = { filetype = "markdown" },
          minimal = false,
          noautocmd = false,
        },
        win_by_ft = {
          lua = {
            keys = {
              ["source"] = {
                "<cr>",
                function(self)
                  local name = "scratch." .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self.buf), ":e")
                  Snacks.debug.run({ buf = self.buf, name = name })
                end,
                desc = "Source buffer",
                mode = { "n", "x" },
              },
            },
          },
        },
      },
      quickfile = { enabled = true }, -- Fast file opening
      rename = { enabled = true },    -- Better file rename
      toggle = {
        enabled = true,
        which_key = true,
        notify = true,
      },
      dashboard = {
        enabled = true,
        preset = {
          header =[[
          ⠀ ⣿⠙⣦⠀⠀⠀⠀⠀⠀⣀⣤⡶⠛⠁
          ⠀⠀⠀⠀⢻⠀⠈⠳⠀⠀⣀⣴⡾⠛⠁⣠⠂⢠⠇
          ⠀⠀⠀⠀⠈⢀⣀⠤⢤⡶⠟⠁⢀⣴⣟⠀⠀⣾
          ⠀⠀⠀⠠⠞⠉⢁⠀⠉⠀⢀⣠⣾⣿⣏⠀⢠⡇
          ⠀⠀⡰⠋⠀⢰⠃⠀⠀⠉⠛⠿⠿⠏⠁⠀⣸⠁
            ⠀⣄⠀⠀⠏⣤⣤⣀⡀⠀⠀⠀⠀⠀⠾⢯⣀
            ⠀⣻⠃⠀⣰⡿⠛⠁⠀⠀⠀⢤⣀⡀⠀⠺⣿⡟⠛⠁
          ⠀⡠⠋⡤⠠⠋⠀⠀⢀⠐⠁⠀⠈⣙⢯⡃⠀⢈⡻⣦
          ⢰⣷⠇⠀⠀⠀⢀⡠⠃⠀⠀⠀⠀⠈⠻⢯⡄⠀⢻⣿⣷
          ⠉⠲⣶⣶⢾⣉⣐⡚⠋⠀⠀⠀⠀⠀⠘⠀⠀⡎⣿⣿⡇
          ⠀⠀⠀⠀⣸⣿⣿⣿⣷⡄⠀⠀⢠⣿⣴⠀⠀⣿⣿⣿⣧
          ⠀⠀⢀⣴⣿⣿⣿⣿⣿⠇⠀⢠⠟⣿⠏⢀⣾⠟⢸⣿⡇
          ⠀⢠⣿⣿⣿⣿⠟⠘⠁⢠⠜⢉⣐⡥⠞⠋⢁⣴⣿⣿⠃
          ⠀⣾⢻⣿⣿⠃⠀⠀⡀⢀⡄⠁⠀⠀⢠⡾⠁⢠⣾⣿⠃
    ⠀⠃⢸⣿⡇⠀⢠⣾⡇⢸⡇⠀⠀⠀⡞
⠀⠀⠈⢿⡇⡰⠋⠈⠙⠂⠙⠢
⠈⢧
          ]],
          -- stylua: ignore
          --@type snacks.dashboard.Item[]
          keys = {
            { icon = "󰈙 ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = "󰮳 ", key = "e", desc = "Recent Files", action = ":Telescope oldfiles" },
            { icon = "󰪶 ", key = "r", desc = "Yazi", action = ":Yazi", enabled = vim.fn.executable("ya") == 1 },
            { icon = "󰮗 ", key = "s", desc = "Sessions", action = ":SessionManager! load_session" },
            { icon = " ", key = "p", desc = "Projects", action = ":Telescope projects" },
            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = "󰅚 ", key = "q", desc = "Quit", action = ":qa" }
          }
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1, },
          { section = "startup" },
        },
        formats = {
          key = function(item)
            return { { "[", hl = "SnacksDashboardSpecial" }, { item.key, hl = "SnacksDashboardKey" }, { "]", hl = "SnacksDashboardSpecial" } }
          end,
        },
      },
    },
    config = function(_, opts)
      require("snacks").setup(opts)

      local function sync_scope_colors()
        local rainbow_hls = {
          'RainbowDelimiterRed',
          'RainbowDelimiterYellow',
          'RainbowDelimiterBlue',
          'RainbowDelimiterOrange',
          'RainbowDelimiterGreen',
          'RainbowDelimiterViolet',
          'RainbowDelimiterCyan',
        }

        for i, hl_name in ipairs(rainbow_hls) do
          local hl = vim.api.nvim_get_hl(0, { name = hl_name, link = false })
          if hl.fg then
            vim.api.nvim_set_hl(0, 'SnacksIndentScope' .. i, {
              fg = hl.fg,
              bold = true
            })
          end
        end

        local first_hl = vim.api.nvim_get_hl(0, { name = rainbow_hls[1], link = false })
        if first_hl.fg then
          vim.api.nvim_set_hl(0, 'SnacksIndentScope', {
            fg = first_hl.fg,
            bold = true
          })
        end
      end

      local function update_scope_color()
        local cursor_line = vim.fn.line('.')
        local cursor_col = vim.fn.col('.')
        local bufnr = vim.api.nvim_get_current_buf()
        local filetype = vim.bo.filetype
        local is_lua = (filetype == 'lua')

        local function get_rainbow_hl(line_num, col, is_keyword)
          local search_start, search_end
          if is_lua and is_keyword then
            search_start = math.max(0, col - 5)
            search_end = col + 20
          else
            search_start = math.max(0, col - 2)
            search_end = col + 2
          end

          local extmarks = vim.api.nvim_buf_get_extmarks(
            bufnr, -1,
            {line_num - 1, search_start},
            {line_num - 1, search_end},
            {details = true}
          )

          for _, extmark in ipairs(extmarks) do
            local details = extmark[4]
            if details and details.hl_group and details.hl_group:match("^RainbowDelimiter") then
              return details.hl_group
            end
          end
          return nil
        end

        local current_line_text = vim.fn.getline(cursor_line)
        local current_line_hl = nil
        local has_immediate_close = false

        if is_lua then
          local keywords = {
            {pattern = '%f[%w_]if%f[^%w_]', closer = 'end'},
            {pattern = '%f[%w_]for%f[^%w_]', closer = 'end'},
            {pattern = '%f[%w_]while%f[^%w_]', closer = 'end'},
            {pattern = '%f[%w_]function%f[^%w_]', closer = 'end'},
            {pattern = '%f[%w_]repeat%f[^%w_]', closer = 'until'},
          }

          for _, kw in ipairs(keywords) do
            local kw_start, kw_end = current_line_text:find(kw.pattern)
            if kw_start then
              local closer_pattern = '%f[%w_]' .. kw.closer .. '%f[^%w_]'
              local closer_pos = current_line_text:find(closer_pattern, kw_end + 1)
              if closer_pos then
                has_immediate_close = true
              else
                current_line_hl = get_rainbow_hl(cursor_line, kw_start, true)
                if current_line_hl then break end
              end
            end
          end

          if not current_line_hl then
            for col = 1, #current_line_text do
              if current_line_text:sub(col, col) == '{' then
                local close_pos = current_line_text:find('}', col + 1, true)
                if close_pos then
                  has_immediate_close = true
                else
                  current_line_hl = get_rainbow_hl(cursor_line, col, false)
                end
                break
              end
            end

            if not current_line_hl and not has_immediate_close then
              for col = 1, #current_line_text do
                if current_line_text:sub(col, col) == '(' then
                  local close_pos = current_line_text:find(')', col + 1, true)
                  if close_pos then
                    has_immediate_close = true
                  else
                    current_line_hl = get_rainbow_hl(cursor_line, col, false)
                  end
                  break
                end
              end
            end
          end
        else
          for col = 1, #current_line_text do
            if current_line_text:sub(col, col) == '{' then
              local close_pos = current_line_text:find('}', col + 1, true)
              if close_pos then
                has_immediate_close = true
              else
                current_line_hl = get_rainbow_hl(cursor_line, col, false)
              end
              break
            end
          end

          if not current_line_hl and not has_immediate_close then
            for col = 1, #current_line_text do
              if current_line_text:sub(col, col) == '(' then
                local close_pos = current_line_text:find(')', col + 1, true)
                if close_pos then
                  has_immediate_close = true
                else
                  current_line_hl = get_rainbow_hl(cursor_line, col, false)
                end
                break
              end
            end
          end
        end

        if current_line_hl and not has_immediate_close then
          local hl = vim.api.nvim_get_hl(0, { name = current_line_hl, link = false })
          if hl.fg then
            vim.api.nvim_set_hl(0, 'SnacksIndentScope', {
              fg = hl.fg,
              bold = true
            })
            return
          end
        end

        local stack = {}

        for line_num = 1, cursor_line - 1 do
          local line = vim.fn.getline(line_num)

          if is_lua then
            local i = 1
            while i <= #line do
              local found_keyword = false

              local keywords = {
                {pattern = '%f[%w_]if%f[^%w_]'},
                {pattern = '%f[%w_]for%f[^%w_]'},
                {pattern = '%f[%w_]while%f[^%w_]'},
                {pattern = '%f[%w_]function%f[^%w_]'},
                {pattern = '%f[%w_]repeat%f[^%w_]'},
              }

              for _, kw in ipairs(keywords) do
                local kw_start, kw_end = line:find(kw.pattern, i)
                if kw_start == i then
                  local hl_name = get_rainbow_hl(line_num, i, true)
                  table.insert(stack, {
                    line = line_num,
                    col = i,
                    hl = hl_name,
                    type = 'keyword'
                  })
                  i = kw_end + 1
                  found_keyword = true
                  break
                end
              end

              if not found_keyword then
                local char = line:sub(i, i)

                local end_start, end_end = line:find('%f[%w_]end%f[^%w_]', i)
                if end_start == i then
                  if #stack > 0 and stack[#stack].type == 'keyword' then
                    table.remove(stack)
                  end
                  i = end_end + 1
                elseif line:find('%f[%w_]until%f[^%w_]', i) == i then
                  if #stack > 0 and stack[#stack].type == 'keyword' then
                    table.remove(stack)
                  end
                  local _, until_end = line:find('%f[%w_]until%f[^%w_]', i)
                  i = until_end + 1
                elseif char == '{' then
                  local hl_name = get_rainbow_hl(line_num, i, false)
                  table.insert(stack, {
                    line = line_num,
                    col = i,
                    hl = hl_name,
                    type = 'brace'
                  })
                  i = i + 1
                elseif char == '}' then
                  for i = #stack, 1, -1 do
                    if stack[i].type == 'brace' then
                      table.remove(stack, i)
                      break
                    end
                  end
                  i = i + 1
                elseif char == '(' then
                  local hl_name = get_rainbow_hl(line_num, i, false)
                  table.insert(stack, {
                    line = line_num,
                    col = i,
                    hl = hl_name,
                    type = 'paren'
                  })
                  i = i + 1
                elseif char == ')' then
                  for i = #stack, 1, -1 do
                    if stack[i].type == 'paren' then
                      table.remove(stack, i)
                      break
                    end
                  end
                  i = i + 1
                else
                  i = i + 1
                end
              end
            end
          else
            for col = 1, #line do
              local char = line:sub(col, col)

              if char == '{' then
                local hl_name = get_rainbow_hl(line_num, col, false)
                table.insert(stack, {
                  line = line_num,
                  col = col,
                  hl = hl_name,
                  type = 'brace'
                })
              elseif char == '}' then
                for i = #stack, 1, -1 do
                  if stack[i].type == 'brace' then
                    table.remove(stack, i)
                    break
                  end
                end
              elseif char == '(' then
                local hl_name = get_rainbow_hl(line_num, col, false)
                table.insert(stack, {
                  line = line_num,
                  col = col,
                  hl = hl_name,
                  type = 'paren'
                })
              elseif char == ')' then
                for i = #stack, 1, -1 do
                  if stack[i].type == 'paren' then
                    table.remove(stack, i)
                    break
                  end
                end
              end
            end
          end
        end

        if #stack > 0 then
          local top = nil

          for i = #stack, 1, -1 do
            if stack[i].type == 'brace' or stack[i].type == 'keyword' then
              top = stack[i]
              break
            end
          end

          if not top then
            for i = #stack, 1, -1 do
              if stack[i].type == 'paren' then
                top = stack[i]
                break
              end
            end
          end

          if not top then
            top = stack[#stack]
          end

          if top and top.hl and top.hl:match("^RainbowDelimiter") then
            local hl = vim.api.nvim_get_hl(0, { name = top.hl, link = false })
            if hl.fg then
              vim.api.nvim_set_hl(0, 'SnacksIndentScope', {
                fg = hl.fg,
                bold = true
              })
              return
            end
          end
        end

        local current_indent = vim.fn.indent('.')
        local shiftwidth = vim.bo.shiftwidth
        if shiftwidth == 0 then shiftwidth = 2 end

        local indent_level = math.floor(current_indent / shiftwidth)
        local color_index = (indent_level % 7) + 1
        local target_hl = 'SnacksIndentScope' .. color_index

        local hl = vim.api.nvim_get_hl(0, { name = target_hl, link = false })
        if hl.fg then
          vim.api.nvim_set_hl(0, 'SnacksIndentScope', {
            fg = hl.fg,
            bold = true
          })
        end
      end

      -- Single ColorScheme autocmd for both scope and dashboard colors
      vim.api.nvim_create_autocmd({"ColorScheme"}, {
        callback = function()
          vim.defer_fn(function()
            -- Sync scope colors
            sync_scope_colors()

            -- Dashboard colors - set custom colors
            vim.api.nvim_set_hl(0, 'ModeMsg', { fg = '#a78bfa', bold = true })
            vim.api.nvim_set_hl(0, 'SnacksDashboardIcon', { fg = '#8b5cf6', bold = true })
            vim.api.nvim_set_hl(0, 'SnacksDashboardKey', { fg = '#fbbf24', bold = true })
            vim.api.nvim_set_hl(0, 'SnacksDashboardSpecial', { fg = '#6b7280' })
            vim.api.nvim_set_hl(0, 'MoreMsg', { fg = '#e0e7ff' })
            vim.api.nvim_set_hl(0, 'SnacksDashboardFooter', { fg = '#9ca3af', italic = true })
          end, 50)
        end
      })

      local timer = nil
      vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI", "BufEnter"}, {
        callback = function()
          if timer then
            vim.fn.timer_stop(timer)
          end
          timer = vim.fn.timer_start(1, function()
            pcall(update_scope_color)
            timer = nil
          end)
        end
      })

      vim.defer_fn(function()
        local colorscheme = vim.g.colors_name
        if colorscheme then
          vim.cmd('colorscheme ' .. colorscheme)
        end
      end, 1500)

      local function ensure_rainbow_loaded(callback)
        local function check_rainbow()
          local hl = vim.api.nvim_get_hl(0, { name = 'RainbowDelimiterRed', link = false })
          if hl.fg then
            callback()
          else
            vim.defer_fn(check_rainbow, 100)
          end
        end
        check_rainbow()
      end

      vim.defer_fn(function()
        ensure_rainbow_loaded(function()
          pcall(sync_scope_colors)
          pcall(update_scope_color)
        end)
      end, 100)
    end
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    lazy = false,
    opts = {
      scope = {
        enabled = false,
        char = "",
        highlight = "IblScope",
        show_start = true,
        show_end = false,
      },
      indent = {
        char = "•",
        highlight = "IblIndent"
      },
    },
  },
}
