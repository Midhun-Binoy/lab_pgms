-- Enable line numbers
vim.opt.number = true
vim.opt.relativenumber = true

vim.o.guifont = "JetBrainsMono Nerd Font:h14"

-- Indentation settings
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Enable system clipboard
vim.opt.clipboard = "unnamedplus"

-- Enable syntax highlighting
vim.cmd('syntax on')

-- Auto-completion menu
vim.opt.completeopt = { "menuone", "noselect" }

-- Set colorscheme
-- vim.cmd('colorscheme desert')

-- Bootstrap Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd("colorscheme tokyonight")
  end
},

  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      lspconfig.pyright.setup({})
      lspconfig.ts_ls.setup({}) -- Updated from tsserver to ts_ls
    end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "python", "javascript", "html", "css" },
        highlight = { enable = true },
      })
    end
  },
  "nvimtools/none-ls.nvim",  -- Use none-ls instead of null-ls
  config = function()
    local null_ls = require("none-ls")

    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.isort,
        null_ls.builtins.diagnostics.flake8,
      },
    })
  end,
  {
  "neovim/nvim-lspconfig",   -- LSP configurations
  "hrsh7th/nvim-cmp",        -- Completion plugin
  "hrsh7th/cmp-nvim-lsp",    -- LSP completion source
  "hrsh7th/cmp-buffer",      -- Buffer completions
  "hrsh7th/cmp-path",        -- File path completions
  "hrsh7th/cmp-cmdline",     -- Command-line completions
  "L3MON4D3/LuaSnip",        -- Snippet engine
  "saadparwaiz1/cmp_luasnip" -- Snippet completions
  },
  {
  "windwp/nvim-autopairs",
  config = function()
    require("nvim-autopairs").setup({})
  end
  },
})

require("nvim-treesitter.configs").setup({
  ensure_installed = { "python" },
  highlight = { enable = true },
})

-- Setup nvim-cmp
local cmp = require("cmp")

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body) -- For snippet support
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping.select_next_item(), -- Tab to navigate
    ["<S-Tab>"] = cmp.mapping.select_prev_item(), -- Shift-Tab to go back
    ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Enter to confirm
    ["<C-Space>"] = cmp.mapping.complete(), -- Ctrl-Space to trigger manually
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" }, -- LSP suggestions
    { name = "buffer" }, -- Suggestions from open files
    { name = "path" }, -- File path suggestions
    { name = "luasnip" } -- Snippet suggestions
  }),
})

-- Enable LSP-based auto-suggestions
local capabilities = require("cmp_nvim_lsp").default_capabilities()
require("lspconfig").pyright.setup({ capabilities = capabilities }) -- Python
require("lspconfig").ts_ls.setup({ capabilities = capabilities }) -- TypeScript

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp = require("cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

vim.cmd('colorscheme tokyonight')
