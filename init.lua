-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Nerd Font configuration
vim.g.have_nerd_font = true

-- [[ Setting options ]]
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim (Modernized with vim.schedule)
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10

-- Indentation settings
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- [[ Diagnostic Config ]]
vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  virtual_text = true,
  virtual_lines = false,
  jump = { float = true },
})

-- [[ Basic Keymaps ]]
vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })

-- Keybinds for split navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Autocmds ]]
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Force true tabs for Go files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

-- [[ Install `lazy.nvim` ]]
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require('lazy').setup({

  -- 1. Modern Indent Detection
  { 'NMAC427/guess-indent.nvim', opts = {} },

  -- 2. Modern Git UI
  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim", "nvim-telescope/telescope.nvim" },
    config = true,
    keys = { { "<leader>gs", "<cmd>Neogit<cr>", desc = "Open Neogit" } }
  },

  -- 3. File System Editor (Oil)
  {
    'stevearc/oil.nvim',
    opts = {},
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = { { "-", "<cmd>Oil<cr>", desc = "Open parent directory (Oil)" } }
  },

  -- 4. Grapple: Pinned Files
  {
    "cbochs/grapple.nvim",
    opts = { scope = "git" },
    keys = {
      { "<leader>a", "<cmd>Grapple toggle<cr>",      desc = "Grapple toggle tag" },
      { "<leader>e", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple open tags window" },
    },
  },

  -- 5. Flash: Navigation
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = { { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" } },
  },

  -- 6. Grug-Far: Search & Replace
  {
    "MagicDuck/grug-far.nvim",
    opts = { headerMaxWidth = 80 },
    keys = { { "<leader>sr", "<cmd>GrugFar<cr>", desc = "Search and Replace" } },
  },

  -- 7. Copilot
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    opts = { suggestion = { enabled = true, auto_trigger = true, keymap = { accept = "<C-l>" } } },
  },

  -- 8. Neogen: Documentation
  { "danymat/neogen",            config = true, keys = { { "<leader>cg", "<cmd>Neogen<cr>", desc = "Generate Annotations" } } },

  -- 9. Lazydev
  { "folke/lazydev.nvim",        ft = "lua",    opts = {} },

  -- 10. Blink.cmp
  {
    'saghen/blink.cmp',
    dependencies = 'rafamadriz/friendly-snippets',
    version = '*',
    opts = {
      keymap = { preset = 'default', ['<C-q>'] = { 'select_and_accept', 'fallback' } },
      appearance = { use_nvim_cmp_as_default = true, nerd_font_variant = 'mono' },
      sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
    },
  },

  -- 11. Snacks.nvim
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      dashboard = {
        enabled = true,
        preset = {
          header = [[
▞▀▖  ▞▀▖ ▛▀▖         ▐
 ▄▘  ▙▄  ▙▄▘▞▀▖▞▀▖▛▀▖▜▀ ▞▀▌▞▀▖▛▀▖
▖ ▌▗▖▌ ▌ ▌▚ ▌ ▌▛▀ ▌ ▌▐ ▖▚▄▌▛▀ ▌ ▌
▝▀ ▝▘▝▀  ▘ ▘▝▀ ▝▀▘▘ ▘ ▀ ▗▄▘▝▀▘▘ ▘
      ▐               ▐           ▐   ▐           ▗ ▌  ▜
▛▀▖▞▀▖▜▀  ▞▀▌▙▀▖▞▀▖▝▀▖▜▀    ▛▀▖▞▀▖▜▀  ▜▀ ▞▀▖▙▀▖▙▀▖▄ ▛▀▖▐ ▞▀▖
▌ ▌▌ ▌▐ ▖ ▚▄▌▌  ▛▀ ▞▀▌▐ ▖▗▖ ▌ ▌▌ ▌▐ ▖ ▐ ▖▛▀ ▌  ▌  ▐ ▌ ▌▐ ▛▀
▘ ▘▝▀  ▀  ▗▄▘▘  ▝▀▘▝▀▘ ▀ ▗▘ ▘ ▘▝▀  ▀   ▀ ▝▀▘▘  ▘  ▀▘▀▀  ▘▝▀▘
          ]],
          keys = {},
        },
      },
      notifier = { enabled = true },
      lazygit = { enabled = true },
      terminal = { enabled = true },
    },
    keys = {
      { "<leader>lg", function() Snacks.lazygit() end,  desc = "Lazygit" },
      { "<c-/>",      function() Snacks.terminal() end, desc = "Toggle Terminal" },
    }
  },

  -- 12. Treesitter (MANAGED AUTOMATICALLY)
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.install').prefer_git = false
      require('nvim-treesitter.parsers').get_parser_configs().latex = nil

      require('nvim-treesitter.configs').setup({
        ensure_installed = {}, -- Install as you come across files
        ignore_install = { 'latex' },
        auto_install = true,
        highlight = { enable = true, disable = { 'latex' } },
        indent = { enable = true, disable = { 'latex' } },
      })
    end,
  },
  { "nvim-treesitter/nvim-treesitter-context",    opts = { max_lines = 3 } },
  { "nvim-treesitter/nvim-treesitter-textobjects" },

  -- 13. LSP (MASON-CENTRIC SETUP)
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim',       opts = {} },
      'Hoffs/omnisharp-extended-lsp.nvim', -- Better jumping for C#
    },
    config = function()
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      local servers = {
        lua_ls = {
          settings = { Lua = { diagnostics = { globals = { 'vim' } } } }
        },
        gopls = {},
        -- Markdown LSP
        marksman = {},
        omnisharp = {
          handlers = {
            ["textDocument/definition"] = function(...)
              return require("omnisharp_extended").handler(...)
            end,
          },
          enable_roslyn_analyzers = true,
          organize_imports_on_format = true,
        },
      }

      require('mason').setup()

      local ml_tools = {
        'netcoredbg',
        'csharpier',
        'gofumpt',
        'goimports',
        'stylua',
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, ml_tools)

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  -- 14. Telescope
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-ui-select.nvim' },
    config = function()
      require('telescope').setup({ extensions = { ['ui-select'] = {} } })
      require('telescope').load_extension('ui-select')
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find buffers' })
    end,
  },

  -- 15. Mini.nvim
  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup()
      require('mini.surround').setup()
      require('mini.statusline').setup()
    end,
  },

  -- 16. Todo Comments
  { 'folke/todo-comments.nvim', opts = { signs = false } },

  -- 17. Marks
  { 'chentoast/marks.nvim',     opts = {} },

  -- 18. Trouble
  { "folke/trouble.nvim",       opts = {},                                                                     keys = { { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>" } } },

  -- 19. Noice
  { "folke/noice.nvim",         opts = { presets = { command_palette = true, long_message_to_split = true } }, dependencies = { "MunifTanjim/nui.nvim" } },

  -- 20. Neotest
  {
    "nvim-neotest/neotest",
    dependencies = { "nvim-neotest/nvim-nio", "fredrikaverpil/neotest-golang" },
    config = function() require("neotest").setup({ adapters = { require("neotest-golang") } }) end,
    keys = { { "<leader>nr", function() require("neotest").run.run() end, desc = "Run Test" } },
  },

  -- 21. UndoTree
  { "mbbill/undotree",      keys = { { "<leader>u", vim.cmd.UndotreeToggle } } },

  -- 22. VimTeX (LaTeX Support)
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = 'zathura'
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_syntax_enabled = 1
    end
  },

  -- 23. Conform (Auto-Formatting)
  {
    'stevearc/conform.nvim',
    opts = {
      notify_on_error = false,
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
      formatters_by_ft = {
        lua = { 'stylua' },
        go = { 'gofumpt', 'goimports' },
        cs = { 'csharpier' },
      },
    },
  },

  -- 24. Render-Markdown (MODERN MD SUPPORT)
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
    opts = {
      file_types = { 'markdown' },
    },
    ft = { 'markdown' },
  },

  -- 25. Markdown Preview (BROWSER PREVIEW)
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },

  -- Core Kickstart Plugins
  require('kickstart.plugins.debug'),
  require('kickstart.plugins.lint'),
  require('kickstart.plugins.autopairs'),
  require('kickstart.plugins.neo-tree'),
  require('kickstart.plugins.gitsigns'),

  -- Which-Key
  { 'folke/which-key.nvim', opts = { icons = { mappings = true } } },

  -- Colorscheme
  { "sainnhe/everforest",   priority = 1000,                                   config = function() vim.cmd.colorscheme(
    "everforest") end },
}, {})
