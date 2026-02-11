return {
  {
    "stevearc/overseer.nvim",
    cmd = {
      "OverseerOpen",
      "OverseerClose",
      "OverseerToggle",
      "OverseerSaveBundle",
      "OverseerLoadBundle",
      "OverseerDeleteBundle",
      "OverseerRunCmd",
      "OverseerRun",
      "OverseerInfo",
      "OverseerBuild",
      "OverseerQuickAction",
      "OverseerTaskAction",
      "OverseerClearCache"
    },
    opts = {
      task_list = {
        direction = "bottom",
        min_height = 5,
        max_height = 5,
        default_detail = 1,
        border = "rounded",
        bindings = {
          ["<CR>"] = false,  -- Disable default open behavior
        },
        win_opts = {
          winblend = 0,
          winhighlight = "Normal:OverseerNormal,FloatBorder:OverseerBorder,NormalFloat:OverseerNormal",
        },
      },
      strategy = {
        "orchestrator",
        tasks = {
          {
            "shell",
            strategy = {
              "terminal",
              use_shell = true,
            },
          },
        },
      },
    },
    config = function(_, opts)
      require("overseer").setup(opts)

      -- Intercept task creation and redirect to Snacks terminal
      local overseer = require("overseer")
      local original_new_task = overseer.new_task

      overseer.new_task = function(opts_or_task)
        local task = original_new_task(opts_or_task)

        -- Hook into task start
        local original_start = task.start
        task.start = function(self)
          -- Only intercept tasks with jobstart strategy (the actual command runners)
          if self.strategy and self.strategy.name == "jobstart" then
            -- Call original_start first so Overseer window opens
            original_start(self)

            -- Then also open in Snacks terminal
            local cmd = self.cmd
            if type(cmd) == "table" then
              cmd = table.concat(cmd, " ")
            end

            vim.schedule(function()
              require("snacks").terminal.open(cmd, {
                cwd = self.cwd or vim.fn.getcwd(),
                win = {
                  position = "float",
                  border = "double",
                  width = 0.8,
                  height = 0.8,
                },
              })
            end)
          else
            -- Let orchestrator and other tasks run normally
            original_start(self)
          end
        end

        return task
      end

      -- Prevent opening files in Overseer window
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {"OverseerList", "OverseerForm"},
        callback = function(ev)
          vim.api.nvim_create_autocmd("BufEnter", {
            buffer = ev.buf,
            callback = function()
              -- Make the window non-modifiable and prevent buffer changes
              vim.bo[ev.buf].modifiable = false
              vim.wo.winfixbuf = true  -- Prevent changing buffer in this window (nvim 0.10+)
            end,
          })
        end,
      })

      -- Ensure Overseer window opens on task start
      vim.api.nvim_create_autocmd("User", {
        pattern = "OverseerTaskStart",
        callback = function()
          vim.cmd("OverseerOpen")
        end,
      })

      -- Add colored separator line at top of Overseer window
      vim.api.nvim_create_autocmd({"FileType", "BufEnter", "TermOpen"}, {
        callback = function()
          local wininfo = vim.fn.getwininfo(vim.fn.win_getid())[1]
          if wininfo and wininfo.height <= 10 and wininfo.botline then
            local ft = vim.bo.filetype
            local bufname = vim.api.nvim_buf_get_name(0)

            if ft == "OverseerList" or ft == "OverseerForm" or bufname:match("overseer") then
              if vim.fn.has('nvim-0.8') == 1 then
                vim.opt_local.winbar = "%#OverseerBorder#" .. string.rep("─", 999) .. "%*"
              end
            end
          end
        end,
      })
    end,
  },
}
