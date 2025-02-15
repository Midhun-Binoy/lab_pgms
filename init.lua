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
vim.cmd("syntax on")

-- Auto-completion menu
vim.opt.completeopt = { "menuone", "noselect" }

-- Set colorscheme
-- vim.cmd('colorscheme desert')

vim.api.nvim_set_keymap("n", "<leader>ls", ":!live-server --port=5500 --quiet &<CR>", { noremap = true, silent = true })

-- Auto format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.html", "*.css", "*.js" },
  callback = function()
    vim.lsp.buf.format()
  end,
})

-- Bootstrap Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    -- 🔷 File Explorer (like VS Code sidebar)
    { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },

    -- 🔷 Status Line & Buffer Tabs
    { "nvim-lualine/lualine.nvim" },
    { "akinsho/bufferline.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },

    -- 🔷 Treesitter (Syntax Highlighting)
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

    -- 🔷 LSP (C++ IntelliSense)
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },

    -- 🔷 Autocompletion
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "L3MON4D3/LuaSnip" },

    -- 🔷 Debugging (GDB for C++)
    { "mfussenegger/nvim-dap" },
    { "rcarriga/nvim-dap-ui" },

    -- 🔷 Formatting & Linting (clangd, clang-format)
    { "stevearc/conform.nvim" },

    -- 🔷 Theme (VS Code look-alike)
    { "Mofiqul/vscode.nvim" },
  },
  {
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd("colorscheme tokyonight")
		end,
	},

	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")
			lspconfig.pyright.setup({})
			lspconfig.ts_ls.setup({}) -- Updated from tsserver to ts_ls
		end,
	},
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")

      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettier.with({
            filetypes = { "html", "css", "javascript", "json", "yaml", "markdown" },
          }),
        },
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ async = false })
              end,
            })
          end
        end,
      })
    end,
  },
  {
		"neovim/nvim-lspconfig", -- LSP configurations
		"hrsh7th/nvim-cmp", -- Completion plugin
		"hrsh7th/cmp-nvim-lsp", -- LSP completion source
		"hrsh7th/cmp-buffer", -- Buffer completions
		"hrsh7th/cmp-path", -- File path completions
		"hrsh7th/cmp-cmdline", -- Command-line completions
		"L3MON4D3/LuaSnip", -- Snippet engine
		"saadparwaiz1/cmp_luasnip", -- Snippet completions
	},
	{
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup({})
		end,
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
		{ name = "luasnip" }, -- Snippet suggestions
	}),
})

-- Enable LSP-based auto-suggestions
local capabilities = require("cmp_nvim_lsp").default_capabilities()
require("lspconfig").pyright.setup({ capabilities = capabilities }) -- Python
require("lspconfig").ts_ls.setup({ capabilities = capabilities }) -- TypeScript

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp = require("cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

vim.cmd("colorscheme tokyonight")

-- Autoformat on Save (clang-format)
require("conform").setup({
  formatters_by_ft = {
    cpp = { "clang-format" },
  },
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.cpp,*.h",
  callback = function()
    require("conform").format()
  end,
})

-- Configure C++ LSP (clangd)
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "clangd" } -- C++ LSP
})

local lspconfig = require("lspconfig")
lspconfig.clangd.setup({
  cmd = { "/usr/bin/clangd", "--background-index", "--clang-tidy" },
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  on_attach = function(_, bufnr)
    local opts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  end,
})