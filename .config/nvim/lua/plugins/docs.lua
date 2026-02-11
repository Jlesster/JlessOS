return {
  -- DevDocs integration - THE BEST offline docs solution
  {
    'luckasRanarison/nvim-devdocs',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    cmd = {
      'DevdocsOpen',
      'DevdocsOpenFloat',
      'DevdocsOpenCurrent',
      'DevdocsInstall',
      'DevdocsUninstall',
      'DevdocsFetch',
      'DevdocsUpdate',
    },
    keys = {
      -- Primary documentation lookup - overrides default K when no LSP
      { 'K', function()
        -- Check if LSP is attached
        local clients = vim.lsp.get_active_clients({ bufnr = 0 })
        if #clients > 0 then
          vim.lsp.buf.hover()
        else
          -- Fallback to DevDocs
          vim.cmd('DevdocsOpenFloat')
        end
      end, desc = 'Smart Documentation (LSP/DevDocs)' },

      -- DevDocs keybinds
      { '<leader>dd', '<cmd>DevdocsOpen<cr>', desc = 'DevDocs: Search' },
      { '<leader>df', '<cmd>DevdocsOpenFloat<cr>', desc = 'DevDocs: Float' },
      { '<leader>dF', '<cmd>DevdocsOpenCurrent<cr>', desc = 'DevDocs: Current' },

      -- Quick language shortcuts
      { '<leader>dp', function()
        require('nvim-devdocs').open('python', vim.fn.expand('<cword>'))
      end, desc = 'Python Docs' },

      { '<leader>dj', function()
        require('nvim-devdocs').open('javascript', vim.fn.expand('<cword>'))
      end, desc = 'JavaScript Docs' },

      { '<leader>dr', function()
        require('nvim-devdocs').open('rust', vim.fn.expand('<cword>'))
      end, desc = 'Rust Docs' },

      { '<leader>dl', function()
        require('nvim-devdocs').open('lua', vim.fn.expand('<cword>'))
      end, desc = 'Lua Docs' },

      { '<leader>dg', function()
        require('nvim-devdocs').open('go', vim.fn.expand('<cword>'))
      end, desc = 'Go Docs' },

      { '<leader>dc', function()
        require('nvim-devdocs').open('cpp', vim.fn.expand('<cword>'))
      end, desc = 'C++ Docs' },

      -- Management
      { '<leader>dI', '<cmd>DevdocsInstall<cr>', desc = 'Install DevDocs' },
      { '<leader>dU', '<cmd>DevdocsUninstall<cr>', desc = 'Uninstall DevDocs' },
      { '<leader>dR', '<cmd>DevdocsFetch<cr>', desc = 'Update DevDocs' },
    },
    opts = {
      dir_path = vim.fn.stdpath('data') .. '/devdocs',
      telescope = {},
      filetypes = {
        -- Map filetypes to DevDocs documentations
        python = 'python~3.11',
        javascript = 'javascript',
        javascriptreact = 'react',
        typescript = 'typescript',
        typescriptreact = { 'typescript', 'react' },
        rust = 'rust',
        go = 'go',
        cpp = 'cpp',
        c = 'c',
        lua = 'lua~5.4',
        java = 'openjdk~21',
        sh = 'bash',
        bash = 'bash',
        html = 'html',
        css = 'css',
        scss = 'sass',
        json = 'json',
        yaml = 'yaml',
      },
      float_win = {
        relative = 'editor',
        height = 0.8,
        width = 0.8,
        border = 'rounded',
      },
      wrap = true,
      ensure_installed = {
        -- Core languages you use
        'python~3.11',
        'javascript',
        'typescript',
        'rust',
        'go',
        'cpp',
        'c',
        'lua~5.4',
        'bash',
        'java~21',

        -- Web
        'html',
        'css',
        'react',
        'vue~3',
        'node',
        'express',

        -- Tools
        'git',
        'vim',
        'postgresql',
        'docker',
        'nginx',
        'redis',

        -- Frameworks
        'django~4',
        'flask~3',
        'fastapi',
      },
      previewer_cmd = 'glow',
      cmd_args = { '-s', 'dark', '-w', '80' },
      picker_cmd = true,
      picker_cmd_args = { '-p' },
    },
    config = function(_, opts)
      require('nvim-devdocs').setup(opts)

      -- Auto-open DevDocs for word under cursor by filetype
      vim.api.nvim_create_user_command('DevdocsAuto', function()
        local ft = vim.bo.filetype
        local word = vim.fn.expand('<cword>')

        if opts.filetypes[ft] then
          local docs = opts.filetypes[ft]
          if type(docs) == 'table' then
            docs = docs[1]
          end
          require('nvim-devdocs').open(docs, word)
        else
          vim.notify('No DevDocs configured for: ' .. ft, vim.log.levels.WARN)
        end
      end, {})
    end,
  },

  -- Man pages with better integration
  {
    'vim-utils/vim-man',
    cmd = { 'Man', 'Vman' },
    keys = {
      { '<leader>dm', '<cmd>Telescope man_pages<cr>', desc = 'Man Pages' },
      { '<leader>dM', function()
        local word = vim.fn.expand('<cword>')
        vim.cmd('Man ' .. word)
      end, desc = 'Man Page (word)' },
    },
    init = function()
      vim.g.no_man_maps = 1

      -- Custom man command with better defaults
      vim.api.nvim_create_user_command('Vman', function(opts)
        vim.cmd('vsplit | Man ' .. opts.args)
      end, { nargs = 1, complete = 'shellcmd' })

      -- Auto-configure man pages
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'man',
        callback = function()
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
          vim.opt_local.signcolumn = 'no'
          vim.opt_local.foldcolumn = '0'
          vim.opt_local.colorcolumn = ''

          -- Map q to close
          vim.keymap.set('n', 'q', '<cmd>quit<cr>', { buffer = true })
        end,
      })
    end,
  },

  -- Dasht for offline Dash/Zeal docsets
  {
    'sunaku/vim-dasht',
    cmd = 'Dasht',
    keys = {
      { '<leader>dk', function()
        local word = vim.fn.expand('<cword>')
        local ft = vim.bo.filetype
        vim.fn['dasht#query'](word, ft)
      end, desc = 'Dasht: Search Word' },

      { '<leader>dK', function()
        local word = vim.fn.expand('<cWORD>')
        local ft = vim.bo.filetype
        vim.fn['dasht#query'](word, ft)
      end, desc = 'Dasht: Search WORD' },

      { '<leader>dD', '<cmd>Dasht!<cr>', desc = 'Dasht: Prompt' },
    },
    init = function()
      -- Configure docsets per filetype
      vim.g.dasht_filetype_docsets = {
        python = { 'python', 'django', 'flask', 'numpy', 'pandas' },
        java = { 'java', 'javase', 'javaee' },
        javascript = { 'javascript', 'nodejs', 'express', 'react' },
        javascriptreact = { 'react', 'javascript' },
        typescript = { 'typescript', 'javascript', 'nodejs' },
        typescriptreact = { 'typescript', 'react' },
        rust = { 'rust' },
        go = { 'go' },
        lua = { 'lua' },
        cpp = { 'cpp', 'c', 'boost' },
        c = { 'c', 'man' },
        sh = { 'bash', 'man' },
        bash = { 'bash', 'man' },
        html = { 'html', 'css', 'javascript' },
        css = { 'css', 'html' },
      }
    end,
  },

  -- Telescope help integration
  {
    'nvim-telescope/telescope.nvim',
    keys = {
      { '<leader>sh', '<cmd>Telescope help_tags<cr>', desc = 'Help Tags' },
      { '<leader>sk', '<cmd>Telescope keymaps<cr>', desc = 'Keymaps' },
    },
  },

  -- Markdown preview for docs
  {
    'iamcco/markdown-preview.nvim',
    build = function()
      vim.fn['mkdp#util#install']()
    end,
    ft = 'markdown',
    cmd = { 'MarkdownPreview', 'MarkdownPreviewStop' },
    keys = {
      { '<leader>mp', '<cmd>MarkdownPreview<cr>', desc = 'Markdown Preview' },
      { '<leader>ms', '<cmd>MarkdownPreviewStop<cr>', desc = 'Stop Preview' },
    },
  },

  -- Better help viewing
  {
    'OXY2DEV/helpview.nvim',
    ft = 'help',
    dependencies = {
      'nvim-treesitter/nvim-treesitter'
    },
  },
}
