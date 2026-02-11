-- Keymaps Configuration
local keymap = vim.keymap.set

-- Better escape
keymap("i", "jk", "<ESC>", { desc = "Exit insert mode" })
keymap("i", "<C-BS>", "<C-W>", { desc = "Enable CTRL+backspace to delete" })

-- Save and quit WITH SNACKS MENU
keymap("n", "<C-s>", ":w!<CR>", { desc = "Force write" })
keymap("n", "<leader>q", function()
  vim.ui.select(
    { "Save and Quit", "Quit without Saving", "Cancel" },
    { prompt = "Quit Options:" },
    function(choice)
      if choice == "Save and Quit" then
        vim.cmd("wq")
      elseif choice == "Quit without Saving" then
        vim.cmd("q!")
      end
    end
  )
end, { desc = "Quit" })
keymap("n", "<leader>w", ":w<CR>", { desc = "Save" })
keymap("n", "<leader>n", ":enew<CR>", { desc = "New file" })
keymap("n", "<leader>W", function()
  vim.ui.input(
    { prompt = "Sudo Password: ", default = "" },
    function(password)
      if password and password ~= "" then
        vim.env.SUDO_ASKPASS = "echo " .. vim.fn.shellescape(password)
        vim.cmd("SudaWrite")
      end
    end
  )
end, { desc = "Save as Sudo" })

-- Window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize windows
keymap("n", "<C-Up>", ":resize +2<CR>", { desc = "Resize split up" })
keymap("n", "<C-Down>", ":resize -2<CR>", { desc = "Resize split down" })
keymap("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Resize split left" })
keymap("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Resize split right" })

-- Splits
keymap("n", "|", ":vsplit<CR>", { desc = "Vertical Split" })
keymap("n", "\\", ":split<CR>", { desc = "Horizontal Split" })
keymap("n", "<leader>s", function()
  vim.ui.select(
    { "Vertical Split", "Horizontal Split", "Cancel" },
    { prompt = "Create Split:" },
    function(choice)
      if choice == "Vertical Split" then
        vim.cmd("vsplit")
      elseif choice == "Horizontal Split" then
        vim.cmd("split")
      end
    end
  )
end, { desc = "Split menu" })

-- Buffer navigation
keymap("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
keymap("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "]b", ":bnext<CR>", { desc = "Next buffer" })
keymap("n", "[b", ":bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "<leader>bd", function()
  vim.ui.select(
    { "Delete Current Buffer", "Delete All Other Buffers", "Cancel" },
    { prompt = "Buffer Delete:" },
    function(choice)
      if choice == "Delete Current Buffer" then
        vim.cmd("bdelete")
      elseif choice == "Delete All Other Buffers" then
        local current = vim.api.nvim_get_current_buf()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if buf ~= current and vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, 'buflisted') then
            vim.cmd("bdelete " .. buf)
          end
        end
      end
    end
  )
end, { desc = "Delete buffer menu" })
keymap("n", "<leader>ba", ":wa<CR>", { desc = "Write all changed buffers" })
keymap("n", "<leader>c", function() Snacks.bufdelete() end, { desc = "Close buffer" })
keymap("n", "<leader>bw", function() vim.cmd("silent! close") end, { desc = "Close window" })

-- Tab navigation
keymap("n", "]t", ":tabnext<CR>", { desc = "Next tab" })
keymap("n", "[t", ":tabprevious<CR>", { desc = "Previous tab" })

-- Move lines
keymap("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
keymap("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Better indenting
keymap("v", "<", "<gv", { desc = "Unindent line" })
keymap("v", ">", ">gv", { desc = "Indent line" })

-- Keep centered
keymap("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
keymap("n", "n", "nzzzv", { desc = "Next search result centered" })
keymap("n", "N", "Nzzzv", { desc = "Previous search result centered" })

-- Improved movement
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Move cursor down" })
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Move cursor up" })
keymap("n", "0", "^", { desc = "Go to first character of line" })

-- Improved gg/G
keymap("n", "gg", function()
  if vim.v.count > 0 then
    vim.cmd("normal! " .. vim.v.count .. "gg")
  else
    vim.cmd("normal! gg0")
  end
end, { desc = "Go to first line and first position" })

keymap("n", "G", "G$", { desc = "Go to last line and last position" })

-- Select all
keymap("n", "<C-a>", "gg0vG$", { desc = "Visually select all" })

-- Clipboard operations
keymap("n", "c", '"_c', { desc = "Change without yanking" })
keymap("n", "C", '"_C', { desc = "Change without yanking" })
keymap("x", "c", '"_c', { desc = "Change without yanking" })
keymap("x", "C", '"_C', { desc = "Change without yanking" })

-- Smart x - delete blank lines and characters without yanking
keymap("n", "x", function()
  if vim.fn.col "." == 1 then
    local line = vim.fn.getline "."
    if line:match "^%s*$" then
      vim.api.nvim_feedkeys('"_dd', "n", false)
      vim.api.nvim_feedkeys("$", "n", false)
    else
      vim.api.nvim_feedkeys('"_x', "n", false)
    end
  else
    vim.api.nvim_feedkeys('"_x', "n", false)
  end
end, { desc = "Delete character without yanking" })

keymap("n", "X", function()
  if vim.fn.col "." == 1 then
    local line = vim.fn.getline "."
    if line:match "^%s*$" then
      vim.api.nvim_feedkeys('"_dd', "n", false)
      vim.api.nvim_feedkeys("$", "n", false)
    else
      vim.api.nvim_feedkeys('"_X', "n", false)
    end
  else
    vim.api.nvim_feedkeys('"_X', "n", false)
  end
end, { desc = "Delete before character without yanking" })

keymap("x", "x", '"_x', { desc = "Delete without yanking" })

-- Better paste in visual mode
keymap("x", "p", "P", { desc = "Paste without yanking" })
keymap("x", "P", "p", { desc = "Paste and yank" })

-- Clear search highlighting
keymap("n", "<ESC>", function()
  if vim.fn.hlexists("Search") then
    vim.cmd("nohlsearch")
  else
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<ESC>", true, true, true),
      "n",
      true
    )
  end
end, { desc = "Clear search highlighting" })

-- Comment toggle
keymap("n", "<Leader>/", "gcc", { remap = true, desc = "Toggle comment line" })
keymap("x", "<Leader>/", "gc", { remap = true, desc = "Toggle comment" })

-- Shifted movement keys - fast navigation
keymap("n", "<S-Down>", "7j", { desc = "Fast move down" })
keymap("n", "<S-Up>", "7k", { desc = "Fast move up" })

-- Page navigation (20% of buffer)
keymap("n", "<S-PageDown>", function()
  local current_line = vim.fn.line "."
  local total_lines = vim.fn.line "$"
  local target_line = current_line + 1 + math.floor(total_lines * 0.20)
  if target_line > total_lines then target_line = total_lines end
  vim.api.nvim_win_set_cursor(0, { target_line, 0 })
  vim.cmd("normal! zz")
end, { desc = "Page down 20%" })

keymap("n", "<S-PageUp>", function()
  local current_line = vim.fn.line "."
  local target_line = current_line - 1 - math.floor(vim.fn.line "$" * 0.20)
  if target_line < 1 then target_line = 1 end
  vim.api.nvim_win_set_cursor(0, { target_line, 0 })
  vim.cmd("normal! zz")
end, { desc = "Page up 20%" })

-- File explorer (Neo-tree)
keymap("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle file explorer" })

-- Telescope
keymap("n", "<leader>ff", ":Telescope live_grep<CR>", { desc = "Find words in project" })
keymap("n", "<leader>fF", ":Telescope live_grep hidden=false no_ignore=false<CR>", { desc = "Find words (no hidden)" })
keymap("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live grep" })
keymap("n", "<leader>fb", ":Telescope buffers<CR>", { desc = "Find buffers" })
keymap("n", "<leader>fB", ":Telescope buffers<CR>", { desc = "Find buffers" })
keymap("n", "<leader>fh", ":Telescope help_tags<CR>", { desc = "Help tags" })
keymap("n", "<leader>fo", ":Telescope oldfiles<CR>", { desc = "Recent files" })
keymap("n", "<leader>fw", ":Telescope grep_string<CR>", { desc = "Find word under cursor" })
keymap("n", "<leader>f/", ":Telescope current_buffer_fuzzy_find<CR>", { desc = "Find in current buffer" })
keymap("n", "<leader>fk", ":Telescope keymaps<CR>", { desc = "Find keymaps" })
keymap("n", "<leader>fv", ":Telescope registers<CR>", { desc = "Find vim registers" })
keymap("n", "<leader>ft", ":Telescope colorscheme enable_preview=true<CR>", { desc = "Find themes" })
keymap("n", "<leader>f'", ":Telescope marks<CR>", { desc = "Find marks" })
keymap("n", "<leader>fC", ":Telescope commands<CR>", { desc = "Find commands" })
keymap("n", "<leader>f<CR>", ":Telescope resume<CR>", { desc = "Resume previous search" })
keymap("n", "<leader>fp", function() vim.cmd("Telescope projects") end, { desc = "Find Project" })
keymap("n", "<leader>fa", function()
  require("telescope.builtin").find_files({
    prompt_title = "Config Files",
    search_dirs = { vim.fn.stdpath("config") },
    cwd = vim.fn.stdpath("config"),
    follow = true,
  })
end, { desc = "Find nvim config files" })

-- Git (Telescope)
keymap("n", "<leader>gb", ":Telescope git_branches<CR>", { desc = "Git branches" })
keymap("n", "<leader>gc", ":Telescope git_commits<CR>", { desc = "Git commits (repository)" })
keymap("n", "<leader>gC", ":Telescope git_bcommits<CR>", { desc = "Git commits (current file)" })
keymap("n", "<leader>gt", ":Telescope git_status<CR>", { desc = "Git status" })

-- Git client (LazyGit/GitUI)
keymap("n", "<leader>gg", function() Snacks.lazygit(nil, { win = { position = "float" } }) end, { desc = "LazyGit" })

-- Yazi file manager
keymap("n", "<leader>r", ":Yazi<CR>", { desc = "File browser" })

-- Terminal (ToggleTerm)
keymap("n", "<leader>tt", function()
  vim.ui.select(
    { "Float Terminal", "Horizontal Terminal", "Vertical Terminal", "Cancel" },
    { prompt = "Terminal Type:" },
    function(choice)
      if choice == "Float Terminal" then
        Snacks.terminal()
      elseif choice == "Horizontal Terminal" then
        Snacks.terminal(nil, { win = { position = "bottom", height = 0.3 } })
      elseif choice == "Vertical Terminal" then
        Snacks.terminal(nil, { win = { position = "right", width = 0.4 } })
      end
    end
  )
end, { desc = "Toggle terminal menu" })
keymap("n", "<leader>th", function() Snacks.terminal(nil, { win = { position = "bottom", height = 0.3 } }) end, { desc = "Toggle terminal horizontal" })
keymap("n", "<leader>tv", function() Snacks.terminal(nil, { win = { position = "right", width = 0.4 } }) end, { desc = "Toggle terminal vertical" })

keymap("n", "<F7>", function() Snacks.terminal(nil, { win = { position = "float" } }) end, { desc = "Toggle terminal" })
keymap("t", "<F7>", "<cmd>close<cr>", { desc = "Close terminal" })

keymap("n", "<C-'>", function() Snacks.terminal(nil, { win = { position = "float" } }) end, { desc = "Toggle terminal" })
keymap("t", "<C-'>", "<cmd>close<cr>", { desc = "Close terminal" })

-- Terminal navigation
keymap("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Terminal left window navigation" })
keymap("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Terminal down window navigation" })
keymap("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Terminal up window navigation" })
keymap("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Terminal right window navigation" })

-- Compiler (if available)
keymap("n", "<leader>mm", ":CompilerOpen<CR>", { desc = "Open compiler" })
keymap("n", "<leader>mr", ":CompilerRedo<CR>", { desc = "Compiler redo" })
keymap("n", "<leader>mt", ":CompilerToggleResults<CR>", { desc = "Compiler results" })
keymap("n", "<F6>", ":CompilerOpen<CR>", { desc = "Open compiler" })
keymap("n", "<S-F6>", ":CompilerRedo<CR>", { desc = "Compiler redo" })
keymap("n", "<S-F7>", ":CompilerToggleResults<CR>", { desc = "Compiler toggle results" })
keymap("n", "<F8>", ":OverseerToggle<CR>", { desc = "Toggle Overseer" })

-- Debugger (DAP)
keymap("n", "<F5>", function() require("dap").continue() end, { desc = "Debugger: Start/Continue" })
keymap("n", "<S-F5>", function() require("dap").terminate() end, { desc = "Debugger: Stop" })
keymap("n", "<C-F5>", function() require("dap").restart_frame() end, { desc = "Debugger: Restart" })
keymap("n", "<F9>", function() require("dap").toggle_breakpoint() end, { desc = "Toggle breakpoint" })
keymap("n", "<S-F9>", function()
  vim.ui.input({ prompt = "Condition: " }, function(condition)
    if condition then require("dap").set_breakpoint(condition) end
  end)
end, { desc = "Conditional breakpoint" })
keymap("n", "<F10>", function() require("dap").step_over() end, { desc = "Step over" })
keymap("n", "<S-F10>", function() require("dap").step_back() end, { desc = "Step back" })
keymap("n", "<F11>", function() require("dap").step_into() end, { desc = "Step into" })
keymap("n", "<S-F11>", function() require("dap").step_out() end, { desc = "Step out" })

-- DAP leader mappings
keymap("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "Toggle breakpoint" })
keymap("n", "<leader>dB", function() require("dap").clear_breakpoints() end, { desc = "Clear breakpoints" })
keymap("n", "<leader>dc", function() require("dap").continue() end, { desc = "Start/Continue" })
keymap("n", "<leader>di", function() require("dap").step_into() end, { desc = "Step into" })
keymap("n", "<leader>do", function() require("dap").step_over() end, { desc = "Step over" })
keymap("n", "<leader>dO", function() require("dap").step_out() end, { desc = "Step out" })
keymap("n", "<leader>dq", function() require("dap").close() end, { desc = "Close session" })
keymap("n", "<leader>dQ", function() require("dap").terminate() end, { desc = "Terminate session" })
keymap("n", "<leader>dr", function() require("dap").restart_frame() end, { desc = "Restart" })
keymap("n", "<leader>dp", function() require("dap").pause() end, { desc = "Pause" })
keymap("n", "<leader>dR", function() require("dap").repl.toggle() end, { desc = "REPL" })
keymap("n", "<leader>dm", function()
  vim.ui.select(
    { "Continue/Start", "Pause", "Stop", "Restart", "Toggle Breakpoint", "Clear Breakpoints", "Cancel" },
    { prompt = "Debug Actions:" },
    function(choice)
      if choice == "Continue/Start" then
        require("dap").continue()
      elseif choice == "Pause" then
        require("dap").pause()
      elseif choice == "Stop" then
        require("dap").terminate()
      elseif choice == "Restart" then
        require("dap").restart_frame()
      elseif choice == "Toggle Breakpoint" then
        require("dap").toggle_breakpoint()
      elseif choice == "Clear Breakpoints" then
        require("dap").clear_breakpoints()
      end
    end
  )
end, { desc = "Debug menu" })

-- DAP UI
keymap("n", "<leader>du", function() require("dapui").toggle() end, { desc = "Toggle DAP UI" })
keymap("n", "<leader>dh", function() require("dap.ui.widgets").hover() end, { desc = "Debugger hover" })
keymap("n", "<leader>dE", function()
  vim.ui.input({ prompt = "Expression: " }, function(expr)
    if expr then require("dapui").eval(expr, { enter = true }) end
  end)
end, { desc = "Evaluate expression" })
keymap("x", "<leader>dE", function() require("dapui").eval() end, { desc = "Evaluate selection" })

-- Aerial (code outline)
keymap("n", "<leader>i", function() require("aerial").toggle() end, { desc = "Toggle Aerial" })

-- Gitsigns
keymap("n", "]g", function() require("gitsigns").nav_hunk('next') end, { desc = "Next Git hunk" })
keymap("n", "[g", function() require("gitsigns").nav_hunk('prev') end, { desc = "Previous Git hunk" })
keymap("n", "<leader>gl", function() require("gitsigns").blame_line() end, { desc = "View Git blame" })
keymap("n", "<leader>gL", function() require("gitsigns").blame_line({ full = true }) end, { desc = "View full Git blame" })
keymap("n", "<leader>gp", function() require("gitsigns").preview_hunk() end, { desc = "Preview Git hunk" })
keymap("n", "<leader>gh", function() require("gitsigns").reset_hunk() end, { desc = "Reset Git hunk" })
keymap("n", "<leader>gr", function() require("gitsigns").reset_buffer() end, { desc = "Reset Git buffer" })
keymap("n", "<leader>gs", function() require("gitsigns").stage_hunk() end, { desc = "Stage Git hunk" })
keymap("n", "<leader>gS", function() require("gitsigns").stage_buffer() end, { desc = "Stage Git buffer" })
keymap("n", "<leader>gu", function() require("gitsigns").undo_stage_hunk() end, { desc = "Unstage Git hunk" })
keymap("n", "<leader>gd", function() require("gitsigns").diffthis() end, { desc = "View Git diff" })
keymap("n", "<leader>gm", function()
  vim.ui.select(
    { "Blame Line", "Blame (Full)", "Preview Hunk", "Reset Hunk", "Reset Buffer", "Stage Hunk", "Stage Buffer", "Unstage Hunk", "Diff", "Cancel" },
    { prompt = "Git Actions:" },
    function(choice)
      if choice == "Blame Line" then
        require("gitsigns").blame_line()
      elseif choice == "Blame (Full)" then
        require("gitsigns").blame_line({ full = true })
      elseif choice == "Preview Hunk" then
        require("gitsigns").preview_hunk()
      elseif choice == "Reset Hunk" then
        require("gitsigns").reset_hunk()
      elseif choice == "Reset Buffer" then
        require("gitsigns").reset_buffer()
      elseif choice == "Stage Hunk" then
        require("gitsigns").stage_hunk()
      elseif choice == "Stage Buffer" then
        require("gitsigns").stage_buffer()
      elseif choice == "Unstage Hunk" then
        require("gitsigns").undo_stage_hunk()
      elseif choice == "Diff" then
        require("gitsigns").diffthis()
      end
    end
  )
end, { desc = "Git menu" })

-- Code Folding (nvim-ufo)
keymap("n", "zR", function() require("ufo").openAllFolds() end, { desc = "Open all folds" })
keymap("n", "zM", function() require("ufo").closeAllFolds() end, { desc = "Close all folds" })
keymap("n", "zr", function() require("ufo").openFoldsExceptKinds() end, { desc = "Fold less" })
keymap("n", "zm", function() require("ufo").closeFoldsWith() end, { desc = "Fold more" })
keymap("n", "zp", function() require("ufo").peekFoldedLinesUnderCursor() end, { desc = "Peek fold" })

-- OpenCode (AI assistant)
keymap("n", "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode about this" })
keymap("x", "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode about selection" })
keymap("n", "<leader>oA", function() require("opencode").ask() end, { desc = "Ask opencode (free-form)" })
keymap("n", "<leader>os", function() require("opencode").select() end, { desc = "Select opencode action" })
keymap("x", "<leader>os", function() require("opencode").select() end, { desc = "Select opencode action" })
keymap("n", "<leader>oo", function() require("opencode").toggle() end, { desc = "Toggle opencode" })
keymap("t", "<leader>oo", function() require("opencode").toggle() end, { desc = "Toggle opencode" })
keymap("n", "<leader>oe", function() require("opencode").prompt("explain @this") end, { desc = "Explain this code" })
keymap("x", "<leader>oe", function() require("opencode").prompt("explain @this") end, { desc = "Explain selection" })
keymap("n", "<leader>or", function() require("opencode").prompt("review @this") end, { desc = "Review this code" })
keymap("x", "<leader>or", function() require("opencode").prompt("review @this") end, { desc = "Review selection" })
keymap("n", "<leader>of", function() require("opencode").prompt("fix @diagnostics") end, { desc = "Fix diagnostics" })
keymap("n", "<leader>od", function() require("opencode").prompt("document @this") end, { desc = "Document this code" })
keymap("x", "<leader>od", function() require("opencode").prompt("document @this") end, { desc = "Document selection" })
keymap("n", "<leader>ot", function() require("opencode").prompt("test @this") end, { desc = "Generate tests" })
keymap("x", "<leader>ot", function() require("opencode").prompt("test @this") end, { desc = "Generate tests for selection" })
keymap("n", "<leader>op", function() require("opencode").prompt("optimize @this") end, { desc = "Optimize this code" })
keymap("x", "<leader>op", function() require("opencode").prompt("optimize @this") end, { desc = "Optimize selection" })
keymap("n", "<leader>oc", function() require("opencode").prompt("@this") end, { desc = "Add context to opencode" })
keymap("x", "<leader>oc", function() require("opencode").prompt("@this") end, { desc = "Add selection to opencode" })
keymap("n", "<leader>on", function() require("opencode").command("session.new") end, { desc = "New opencode session" })
keymap("n", "<leader>ol", function() require("opencode").command("session.list") end, { desc = "List opencode sessions" })
keymap("n", "<leader>oi", function() require("opencode").command("session.interrupt") end, { desc = "Interrupt opencode" })

-- Quick opencode terminal toggle
keymap("n", "<C-;>", function()
  Snacks.terminal("opencode", {
    win = {
      position = "float",
      width = 0.9,
      height = 0.9,
    }
  })
end, { desc = "Toggle opencode terminal" })

-- Alpha dashboard (home screen)
keymap("n", "<leader>h", function()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  if #wins > 1 and vim.api.nvim_get_option_value("filetype", {}) == "neo-tree" then
    vim.fn.win_gotoid(wins[2])
  end
  Snacks.dashboard()
end, { desc = "Home screen" })

-- Special autocommands for q to close certain windows
vim.api.nvim_create_autocmd("BufWinEnter", {
  desc = "Make q close help, man, quickfix, dap floats",
  callback = function(args)
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
    if vim.tbl_contains({ "help", "nofile", "quickfix" }, buftype) then
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, silent = true, nowait = true })
    end
  end,
})

vim.api.nvim_create_autocmd("CmdwinEnter", {
  desc = "Make q close command history (q: and q?)",
  callback = function(args)
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, silent = true, nowait = true })
  end,
})

-- Diagnostic keymaps
keymap("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Hover diagnostics" })
keymap("n", "gl", vim.diagnostic.open_float, { desc = "Hover diagnostics" })
keymap("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Previous diagnostic" })
keymap("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next diagnostic" })
keymap("n", "<leader>lD", ":Telescope diagnostics<CR>", { desc = "Telescope diagnostics" })

-- ============================================================================
-- LSP KEYMAPS (Buffer-specific, only work when LSP is attached)
-- ============================================================================

-- Note: These are fallback keymaps. The actual LSP keymaps are set in lsp.lua
-- via the on_attach function. These will work as global fallbacks.

-- Diagnostics (using lspsaga for better UI)
keymap("n", "gl", "<cmd>Lspsaga show_line_diagnostics<CR>", { desc = "Line diagnostics" })
keymap("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { desc = "Previous diagnostic" })
keymap("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", { desc = "Next diagnostic" })
keymap("n", "<leader>ld", "<cmd>Lspsaga show_cursor_diagnostics<CR>", { desc = "Cursor diagnostics" })
keymap("n", "<leader>lD", ":Telescope diagnostics<CR>", { desc = "Telescope diagnostics" })

-- Core LSP Navigation (using lspsaga for peek functionality)
keymap("n", "gd", "<cmd>Lspsaga goto_definition<CR>", { desc = "Go to definition" })
keymap("n", "gp", "<cmd>Lspsaga peek_definition<CR>", { desc = "Peek definition" })
keymap("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
keymap("n", "gI", "<cmd>Lspsaga finder imp<CR>", { desc = "Go to implementation" })
keymap("n", "gT", "<cmd>Lspsaga goto_type_definition<CR>", { desc = "Go to type definition" })
keymap("n", "gT", "<cmd>Lspsaga peek_type_definition<CR>", { desc = "Peek type definition" })
keymap("n", "gr", "<cmd>Lspsaga finder<CR>", { desc = "Find references" })

-- Hover and Help (using lspsaga)
keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", { desc = "Hover documentation" })
keymap("n", "gh", "<cmd>Lspsaga hover_doc<CR>", { desc = "Hover help" })
keymap("n", "gH", vim.lsp.buf.signature_help, { desc = "Signature help" })
keymap("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })

-- Code Actions (using lspsaga)
keymap("n", "<leader>la", "<cmd>Lspsaga code_action<CR>", { desc = "Code actions" })
keymap("v", "<leader>la", "<cmd>Lspsaga code_action<CR>", { desc = "Code actions" })

-- Rename (using lspsaga)
keymap("n", "<leader>lr", "<cmd>Lspsaga rename<CR>", { desc = "Rename symbol" })
keymap("n", "<leader>lR", "<cmd>Lspsaga rename ++project<CR>", { desc = "Rename in project" })

-- Format (native LSP)
keymap("n", "<leader>lf", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format buffer" })
keymap("v", "<leader>lf", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format selection" })
keymap("n", "<leader>f", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format buffer" })

-- LSP Info and Control
keymap("n", "<leader>li", ":LspInfo<CR>", { desc = "LSP info" })
keymap("n", "<leader>lL", ":LspRestart<CR>", { desc = "LSP restart" })

-- Symbols (using lspsaga outline + telescope)
keymap("n", "<leader>lo", "<cmd>Lspsaga outline<CR>", { desc = "Toggle outline" })
keymap("n", "<leader>ls", ":Telescope lsp_document_symbols<CR>", { desc = "Document symbols" })
keymap("n", "gs", ":Telescope lsp_document_symbols<CR>", { desc = "Document symbols" })
keymap("n", "<leader>lS", ":Telescope lsp_workspace_symbols<CR>", { desc = "Workspace symbols" })
keymap("n", "gS", ":Telescope lsp_workspace_symbols<CR>", { desc = "Workspace symbols" })

-- Workspace Management
keymap("n", "<leader>La", vim.lsp.buf.add_workspace_folder, { desc = "Add workspace folder" })
keymap("n", "<leader>Lr", vim.lsp.buf.remove_workspace_folder, { desc = "Remove workspace folder" })
keymap("n", "<leader>Ll", function()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, { desc = "List workspace folders" })

-- Inlay Hints Toggle
keymap("n", "<leader>lh", function()
  if vim.lsp.inlay_hint then
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
  else
    vim.notify("Inlay hints not supported", vim.log.levels.WARN)
  end
end, { desc = "Toggle inlay hints" })

-- Incoming/Outgoing Calls (lspsaga)
keymap("n", "<leader>lci", "<cmd>Lspsaga incoming_calls<CR>", { desc = "Incoming calls" })
keymap("n", "<leader>lco", "<cmd>Lspsaga outgoing_calls<CR>", { desc = "Outgoing calls" })

-- LSP Menu
keymap("n", "<leader>lm", function()
  vim.ui.select(
    {
      "Code Actions",
      "Rename",
      "Rename (Project)",
      "Format",
      "Hover Doc",
      "Outline",
      "LSP Info",
      "Restart LSP",
      "Document Symbols",
      "Workspace Symbols",
      "Toggle Inlay Hints",
      "Cancel"
    },
    { prompt = "LSP Actions:" },
    function(choice)
      if choice == "Code Actions" then
        vim.cmd("Lspsaga code_action")
      elseif choice == "Rename" then
        vim.cmd("Lspsaga rename")
      elseif choice == "Rename (Project)" then
        vim.cmd("Lspsaga rename ++project")
      elseif choice == "Format" then
        vim.lsp.buf.format({ async = true })
      elseif choice == "Hover Doc" then
        vim.cmd("Lspsaga hover_doc")
      elseif choice == "Outline" then
        vim.cmd("Lspsaga outline")
      elseif choice == "LSP Info" then
        vim.cmd("LspInfo")
      elseif choice == "Restart LSP" then
        vim.cmd("LspRestart")
      elseif choice == "Document Symbols" then
        vim.cmd("Telescope lsp_document_symbols")
      elseif choice == "Workspace Symbols" then
        vim.cmd("Telescope lsp_workspace_symbols")
      elseif choice == "Toggle Inlay Hints" then
        if vim.lsp.inlay_hint then
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end
      end
    end
  )
end, { desc = "LSP menu" })

-- Codeium chat and commands
keymap("n", "<leader>ac", function()
  vim.cmd("Codeium Chat")
end, { desc = "Open Codeium Chat" })

keymap("n", "<leader>ae", function()
  vim.cmd("Codeium Enable")
end, { desc = "Enable Codeium" })

keymap("n", "<leader>ad", function()
  vim.cmd("Codeium Disable")
end, { desc = "Disable Codeium" })

keymap("n", "<leader>at", function()
  vim.cmd("Codeium Toggle")
end, { desc = "Toggle Codeium" })

keymap("n", "<leader>am", function()
  vim.ui.select(
    { "Open Chat", "Enable", "Disable", "Toggle", "Cancel" },
    { prompt = "Codeium Actions:" },
    function(choice)
      if choice == "Open Chat" then
        vim.cmd("Codeium Chat")
      elseif choice == "Enable" then
        vim.cmd("Codeium Enable")
      elseif choice == "Disable" then
        vim.cmd("Codeium Disable")
      elseif choice == "Toggle" then
        vim.cmd("Codeium Toggle")
      end
    end
  )
end, { desc = "Codeium menu" })
