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

-- Indentation settings (4 spaces default, override for Go below)
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- [[ Diagnostic Config (Modernized UI) ]]
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

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Autocmds ]]
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank() -- Modernized to vim.hl
  end,
})

-- Force true tabs for Go files, bypassing global space settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.expandtab = false -- Use real tabs!
    vim.opt_local.tabstop = 4       -- Make those tabs look 4-spaces wide
    vim.opt_local.shiftwidth = 4
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
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

  -- 2. Modern Git UI (Neogit)
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim", -- Dependency used below
    },
    config = true,
    keys = {
      { "<leader>gs", "<cmd>Neogit<cr>", desc = "Open Neogit" }
    }
  },

  -- 3. File System Editor (Oil)
  {
    'stevearc/oil.nvim',
    opts = {},
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory (Oil)" }
    }
  },

  -- 4. Grapple: Pinned Files
  {
    "cbochs/grapple.nvim",
    opts = { scope = "git" },
    event = { "BufReadPost", "BufNewFile" },
    cmd = "Grapple",
    keys = {
      { "<leader>a", "<cmd>Grapple toggle<cr>", desc = "Grapple toggle tag" },
      { "<leader>e", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple open tags window" },
      { "<leader>1", "<cmd>Grapple select index=1<cr>", desc = "Grapple select 1" },
      { "<leader>2", "<cmd>Grapple select index=2<cr>", desc = "Grapple select 2" },
      { "<leader>3", "<cmd>Grapple select index=3<cr>", desc = "Grapple select 3" },
      { "<leader>4", "<cmd>Grapple select index=4<cr>", desc = "Grapple select 4" },
    },
  },

  -- 5. Flash: Navigation
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },
    },
  },

  -- 6. Grug-Far: Search & Replace
  {
    "MagicDuck/grug-far.nvim",
    opts = { headerMaxWidth = 80 },
    cmd = "GrugFar",
    keys = {
      { "<leader>sr", "<cmd>GrugFar<cr>", desc = "Search and Replace (Grug Far)" },
    },
  },

  -- 7. Copilot (Lua Native)
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = true, auto_trigger = true, keymap = { accept = "<C-l>" } },
      panel = { enabled = false },
    },
  },

  -- 8. Neogen: Documentation Generation
  {
    "danymat/neogen",
    config = true,
    keys = {
      { "<leader>cg", "<cmd>Neogen<cr>", desc = "Generate Annotations (Neogen)" }
    }
  },

  -- 9. Lazydev (Lua LSP Environment)
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true },

  -- 10. Blink.cmp (Fast Autocomplete)
  {
    'saghen/blink.cmp',
    dependencies = 'rafamadriz/friendly-snippets',
    version = '*',
    opts = {
      -- We keep the default preset (which includes Ctrl+y) and just add Ctrl+q
      keymap = {
        preset = 'default',
        ['<C-q>'] = { 'select_and_accept', 'fallback' },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono'
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      signature = { enabled = true }
    },
  },

  -- 11. Snacks.nvim (QoL & Dashboard Customization)
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      dashboard = { 
        enabled = true,
        preset = {
          -- CUSTOM ASCII HEADER
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
          -- Disable shortcut buttons by providing an empty list
          keys = {},
        },
      },
      notifier = { enabled = true },
      lazygit = { enabled = true },
      terminal = { enabled = true },
    },
    keys = {
      { "<leader>lg", function() Snacks.lazygit() end, desc = "Lazygit" },
      { "<c-/>",      function() Snacks.terminal() end, desc = "Toggle Terminal" },
    }
  },

  -- 12. Treesitter Context & Textobjects
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc', 'go', 'gomod' },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = { max_lines = 3, trim_scope = 'outer' },
    keys = {
      { "[c", function() require("treesitter-context").go_to_context(vim.v.count1) end, desc = "Jump to context" },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter.configs").setup({
        textobjects = {
          move = {
            enable = true,
            set_jumps = true,
            goto_previous_start = {
              ["[m"] = { query = "@function.outer", desc = "Previous function start" },
              ["[["] = { query = "@class.outer", desc = "Previous class start" },
            },
            goto_next_start = {
              ["]m"] = { query = "@function.outer", desc = "Next function start" },
              ["]]"] = { query = "@class.outer", desc = "Next class start" },
            },
          },
        },
      })
    end,
  },

  -- 13. Main LSP Configuration (Restored & Modernized)
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools
      { 'williamboman/mason.nvim', config = true }, 
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      -- Useful status updates for LSP
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      require('mason').setup()
      local servers = {
        gopls = {},
        lua_ls = {
          settings = {
            Lua = { completion = { callSnippet = 'Replace' } },
          },
        },
      }
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities())

      require('mason-tool-installer').setup { ensure_installed = vim.tbl_keys(servers) }
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

  -- 14. Telescope: The Finder (Missing Keymaps RESTORED)
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        extensions = {
          ['ui-select'] = { require('telescope.themes').get_dropdown() },
        },
      }
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
    end,
  },

  -- 15. Mini.nvim (Statusline & Surround RESTORED)
  {
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects (e.g. "vai" = visually select around inside)
      require('mini.ai').setup { n_lines = 500 }
      -- Add/delete/replace surroundings (e.g. "ysiw"" = you surround inner word with quotes)
      require('mini.surround').setup()
      -- Simple and functional statusline
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
    end,
  },

  -- 16. Todo Comments (RESTORED)
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  -- 17. Marks: Visual Highlighting for Marks (RESTORED)
  {
    'chentoast/marks.nvim',
    opts = {},
    keys = {
      { "dm!", "<cmd>delmarks!<cr>", desc = "Delete all lowercase marks" },
      { "dm<space>", "<cmd>MarksListBuf<cr>", desc = "List buffer marks" },
    }
  },

  -- ==========================================
  -- PHASE 3: WORKFLOW ENHANCEMENTS (New Tools)
  -- ==========================================

  -- 18. Trouble (Better Diagnostics)
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
    },
  },

  -- 19. Noice (Modern UI)
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true, 
        command_palette = true, 
        long_message_to_split = true, 
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
    }
  },

  -- 20. Neotest (Interactive Testing)
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "fredrikaverpil/neotest-golang", -- Go adapter
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-golang"),
        },
      })
    end,
    keys = {
      { "<leader>nr", function() require("neotest").run.run() end, desc = "Run Nearest Test" },
      { "<leader>nf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File Tests" },
      { "<leader>no", function() require("neotest").output.open({ enter = true }) end, desc = "Show Test Output" },
    },
  },

  -- 21. UndoTree (Visual History)
  {
    "mbbill/undotree",
    keys = {
      { "<leader>u", vim.cmd.UndotreeToggle, desc = "Toggle UndoTree" },
    },
  },

  -- Kickstart Core Remaining Plugins (Assuming you have these in lua/kickstart/plugins/)
  require('kickstart.plugins.debug'),
  require('kickstart.plugins.lint'),
  require('kickstart.plugins.autopairs'),
  require('kickstart.plugins.neo-tree'), -- (Optional: You can remove this if you prefer Oil entirely)
  require('kickstart.plugins.gitsigns'),

  -- Simplified Which-Key
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },
      spec = {
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },

  -- Colorscheme
  {
    "sainnhe/everforest",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("everforest")
    end,
  },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘', config = '🛠', event = '📅', ft = '📂', init = '⚙',
      keys = '🗝', plugin = '🔌', runtime = '💻', require = '🌙',
      source = '📄', start = '🚀', task = '📌', lazy = '💤 ',
    },
  },
})
