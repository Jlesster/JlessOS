-- Enhanced nvim-treesitter config for the NEW API
-- No folding (using ufo.nvim), no conflicting keymaps
return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
    'nvim-treesitter/nvim-treesitter-context',
  },
  config = function()
    -- Setup with install directory
    require('nvim-treesitter').setup({
      install_dir = vim.fn.stdpath('data') .. '/site',
    })

    -- Install parsers (async)
    require('nvim-treesitter').install({
      -- Core
      'go', 'lua', 'vim', 'vimdoc', 'query',
      -- Web
      'javascript', 'typescript', 'tsx', 'html', 'css', 'json', 'yaml',
      -- Systems
      'c', 'cpp', 'rust', 'zig', 'python', 'bash', 'fish',
      -- Java/Dart for your plugins
      'java', 'dart',
      -- Others
      'markdown', 'markdown_inline', 'toml', 'xml', 'regex', 'comment',
    })

    -- =========================================================================
    -- HIGHLIGHTING - Enable for all file buffers
    -- =========================================================================
    vim.api.nvim_create_autocmd('FileType', {
      pattern = '*',
      callback = function(args)
        local buftype = vim.bo[args.buf].buftype
        if buftype == '' then
          pcall(vim.treesitter.start)
        end
      end,
    })

    -- =========================================================================
    -- INDENTATION (Optional - using treesitter for indent)
    -- =========================================================================
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'go', 'lua', 'python', 'javascript', 'typescript', 'rust', 'c', 'cpp', 'java', 'dart' },
      callback = function()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

    -- =========================================================================
    -- TEXTOBJECTS - Smart code navigation and selection
    -- =========================================================================
    local textobjects_ok, ts_textobjects = pcall(require, 'nvim-treesitter-textobjects')
    if textobjects_ok then
      -- Select around/inside functions, classes
      vim.keymap.set({'x', 'o'}, 'af', function()
        ts_textobjects.select_textobject('@function.outer')
      end, { desc = 'Select around function' })

      vim.keymap.set({'x', 'o'}, 'if', function()
        ts_textobjects.select_textobject('@function.inner')
      end, { desc = 'Select inside function' })

      vim.keymap.set({'x', 'o'}, 'ac', function()
        ts_textobjects.select_textobject('@class.outer')
      end, { desc = 'Select around class' })

      vim.keymap.set({'x', 'o'}, 'ic', function()
        ts_textobjects.select_textobject('@class.inner')
      end, { desc = 'Select inside class' })

      -- NOTE: Using ]m/[m for method navigation (]f/[f conflicts with your LSP keymaps)
      vim.keymap.set('n', ']m', function()
        ts_textobjects.goto_next('@function.outer')
      end, { desc = 'Next method/function' })

      vim.keymap.set('n', '[m', function()
        ts_textobjects.goto_previous('@function.outer')
      end, { desc = 'Previous method/function' })

      -- NOTE: ]C/[C for class navigation (avoiding conflict with ]c/[c which may be used elsewhere)
      vim.keymap.set('n', ']C', function()
        ts_textobjects.goto_next('@class.outer')
      end, { desc = 'Next class' })

      vim.keymap.set('n', '[C', function()
        ts_textobjects.goto_previous('@class.outer')
      end, { desc = 'Previous class' })
    end

    -- =========================================================================
    -- INCREMENTAL SELECTION - Expand selection intelligently
    -- NOTE: Your keymaps.lua doesn't use <C-space>, so this is safe
    -- =========================================================================
    vim.keymap.set('n', '<C-space>', function()
      local ok, incr_sel = pcall(require, 'nvim-treesitter.incremental_selection')
      if ok then
        incr_sel.init_selection()
      end
    end, { desc = 'Init treesitter selection' })

    vim.keymap.set('x', '<C-space>', function()
      local ok, incr_sel = pcall(require, 'nvim-treesitter.incremental_selection')
      if ok then
        incr_sel.node_incremental()
      end
    end, { desc = 'Increment selection' })

    vim.keymap.set('x', '<BS>', function()
      local ok, incr_sel = pcall(require, 'nvim-treesitter.incremental_selection')
      if ok then
        incr_sel.node_decremental()
      end
    end, { desc = 'Decrement selection' })

    -- =========================================================================
    -- CONTEXT - Show current function/class at top of screen
    -- NOTE: Conflicts with your [t keymap, using [x instead
    -- =========================================================================
    local context_ok, context = pcall(require, 'treesitter-context')
    if context_ok then
      context.setup({
        enable = true,
        max_lines = 3,
        min_window_height = 20,
        line_numbers = true,
        multiline_threshold = 1,
        trim_scope = 'outer',
        mode = 'cursor',
      })

      -- Jump to context (using [x to avoid conflict with [t = previous tab)
      vim.keymap.set('n', '[x', function()
        context.go_to_context(vim.v.count1)
      end, { silent = true, desc = 'Jump to context' })
    end

    -- =========================================================================
    -- UTILITIES
    -- =========================================================================
    vim.keymap.set('n', '<leader>ti', ':Inspect<CR>', { desc = 'Inspect treesitter node' })
    vim.keymap.set('n', '<leader>tT', ':InspectTree<CR>', { desc = 'Show treesitter tree' })

    -- Toggle treesitter highlighting
    vim.keymap.set('n', '<leader>th', function()
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.treesitter.highlighter.active[bufnr] then
        vim.treesitter.stop(bufnr)
        vim.notify('Treesitter disabled', vim.log.levels.INFO)
      else
        vim.treesitter.start(bufnr)
        vim.notify('Treesitter enabled', vim.log.levels.INFO)
      end
    end, { desc = 'Toggle treesitter' })
  end,
}
