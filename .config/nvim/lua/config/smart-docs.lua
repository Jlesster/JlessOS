local M = {}

-- Check if LSP is attached and has hover capability
local function has_lsp_hover()
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  for _, client in ipairs(clients) do
    if client.server_capabilities.hoverProvider then
      return true
    end
  end
  return false
end

-- Smart documentation function - tries multiple sources
function M.smart_docs()
  local ft = vim.bo.filetype
  local word = vim.fn.expand('<cword>')

  -- First try LSP hover
  if has_lsp_hover() then
    vim.lsp.buf.hover()
    return
  end

  -- Filetype-specific documentation
  if ft == 'python' then
    -- Try pydoc first
    if vim.fn.executable('python3') == 1 then
      vim.cmd('term python3 -m pydoc ' .. word)
      return
    end
  elseif ft == 'rust' then
    -- Try rustdoc
    if vim.fn.executable('rustup') == 1 then
      vim.fn.system('rustup doc --std ' .. word)
      return
    end
  elseif ft == 'lua' then
    -- Try vim help first for nvim API
    if word:match('^vim%.') or word:match('^nvim_') then
      local ok = pcall(vim.cmd, 'help ' .. word)
      if ok then return end
    end
  elseif ft == 'sh' or ft == 'bash' then
    -- Try man page
    if vim.fn.executable(word) == 1 then
      vim.cmd('Man ' .. word)
      return
    end
  end

  -- Fallback to DevDocs if available
  local ok = pcall(vim.cmd, 'DevdocsOpenFloat')
  if not ok then
    -- Final fallback to man page
    pcall(vim.cmd, 'Man ' .. word)
  end
end

-- Open web documentation
function M.web_docs()
  local ft = vim.bo.filetype
  local word = vim.fn.expand('<cword>')

  local urls = {
    python = 'https://docs.python.org/3/search.html?q=',
    java = 'https://docs.oracle.com/en/java/javase/21/docs/api/search?q=',
    javascript = 'https://developer.mozilla.org/en-US/search?q=',
    typescript = 'https://www.typescriptlang.org/docs/handbook/search?q=',
    rust = 'https://doc.rust-lang.org/std/?search=',
    go = 'https://pkg.go.dev/search?q=',
    lua = 'https://www.lua.org/manual/5.4/',
    cpp = 'https://en.cppreference.com/mwiki/index.php?search=',
  }

  local url = urls[ft]
  if url then
    vim.fn.jobstart({ 'xdg-open', url .. word }, { detach = true })
  else
    vim.notify('No web docs configured for: ' .. ft, vim.log.levels.WARN)
  end
end

-- Python-specific documentation
function M.python_docs()
  local word = vim.fn.expand('<cword>')

  -- Try pydoc in a floating terminal
  local Terminal = require('toggleterm.terminal').Terminal
  local pydoc = Terminal:new({
    cmd = 'python3 -m pydoc ' .. word,
    direction = 'float',
    close_on_exit = false,
    on_open = function(term)
      vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = term.bufnr })
    end,
  })
  pydoc:toggle()
end

-- Rust-specific documentation
function M.rust_docs()
  -- Open std docs
  if vim.fn.executable('rustup') == 1 then
    vim.fn.jobstart({ 'rustup', 'doc', '--std' }, { detach = true })
  else
    vim.cmd('DevdocsOpen rust')
  end
end

-- Java-specific documentation
function M.java_docs()
  local word = vim.fn.expand('<cword>')
  -- Try to find in JavaDoc
  local url = 'https://docs.oracle.com/en/java/javase/21/docs/api/search.html?q=' .. word
  vim.fn.jobstart({ 'xdg-open', url }, { detach = true })
end

-- Setup keybindings
function M.setup()
  local keymap = vim.keymap.set

  -- Override K to use smart docs (this is safe because LSP will still work)
  -- K is already mapped in your lsp.lua, so we'll use a different key

  -- Smart documentation (tries LSP, then DevDocs, then man)
  keymap('n', '<leader>dh', M.smart_docs, { desc = 'Smart Documentation' })

  -- Web documentation
  keymap('n', '<leader>dw', M.web_docs, { desc = 'Web Documentation' })

  -- Language-specific quick docs
  keymap('n', '<leader>dP', M.python_docs, { desc = 'Python pydoc' })
  keymap('n', '<leader>dR', M.rust_docs, { desc = 'Rust std docs' })
  keymap('n', '<leader>dJ', M.java_docs, { desc = 'Java docs' })

  -- Quick access to external tools
  keymap('n', '<leader>dE', function()
    local word = vim.fn.expand('<cword>')
    local Terminal = require('toggleterm.terminal').Terminal
    local docs = Terminal:new({
      cmd = 'tldr ' .. word,
      direction = 'float',
      close_on_exit = false,
    })
    docs:toggle()
  end, { desc = 'TLDR pages' })

  -- Setup autocommands for filetype-specific docs
  local augroup = vim.api.nvim_create_augroup('SmartDocs', { clear = true })

  -- Python: Add pydoc help
  vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    pattern = 'python',
    callback = function(args)
      vim.keymap.set('n', '<leader>dP', M.python_docs, {
        buffer = args.buf,
        desc = 'Python pydoc'
      })

      -- Add command to open python docs
      vim.api.nvim_buf_create_user_command(args.buf, 'PyDoc', function(opts)
        local term = require('toggleterm.terminal').Terminal:new({
          cmd = 'python3 -m pydoc ' .. (opts.args ~= '' and opts.args or vim.fn.expand('<cword>')),
          direction = 'float',
          close_on_exit = false,
        })
        term:toggle()
      end, { nargs = '?' })
    end,
  })

  -- Rust: Add cargo doc
  vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    pattern = 'rust',
    callback = function(args)
      vim.keymap.set('n', '<leader>dR', M.rust_docs, {
        buffer = args.buf,
        desc = 'Rust docs'
      })

      vim.keymap.set('n', '<leader>dC', function()
        vim.fn.jobstart({ 'cargo', 'doc', '--open' }, { detach = true })
      end, {
        buffer = args.buf,
        desc = 'Cargo doc (current project)'
      })
    end,
  })

  -- Java: Add javadoc
  vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    pattern = 'java',
    callback = function(args)
      vim.keymap.set('n', '<leader>dJ', M.java_docs, {
        buffer = args.buf,
        desc = 'Java docs'
      })
    end,
  })

  -- Shell scripts: Prioritize man pages
  vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    pattern = { 'sh', 'bash', 'zsh' },
    callback = function(args)
      vim.keymap.set('n', 'K', function()
        local word = vim.fn.expand('<cword>')
        if vim.fn.executable(word) == 1 then
          vim.cmd('Man ' .. word)
        else
          vim.lsp.buf.hover()
        end
      end, {
        buffer = args.buf,
        desc = 'Man page or hover'
      })
    end,
  })

  -- Lua: Prioritize vim help
  vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    pattern = 'lua',
    callback = function(args)
      vim.keymap.set('n', 'K', function()
        local word = vim.fn.expand('<cword>')
        if word:match('^vim%.') or word:match('^nvim_') then
          local ok = pcall(vim.cmd, 'help ' .. word)
          if ok then return end
        end
        vim.lsp.buf.hover()
      end, {
        buffer = args.buf,
        desc = 'Vim help or hover'
      })
    end,
  })
end

-- Auto-setup on module load
M.setup()

return M
