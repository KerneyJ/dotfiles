vim.cmd("set number")
vim.cmd("set expandtab")
vim.cmd("set mouse=a")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set list")
vim.cmd("set lcs+=space:•")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
    {"xiyaowong/transparent.nvim", name="transparent" },
    {
    'nvim-telescope/telescope.nvim', tag = '0.1.6',
      dependencies = {'nvim-lua/plenary.nvim'}
    },
    {
        "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
        opts = { ensure_installed = { "cpp" } },
    },
    {
        "pest-parser/pest.vim",
        ft = { "pest" },
    },
    {
        "Julian/lean.nvim",
        ft = { "lean" },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "hrsh7th/nvim-cmp",
        },
        opts = {
            mappings = true,
        },
        config = function(_, opts)
            local lean = require('lean')
            lean.setup(opts)
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            cmp.setup({
                  snippet = {
                    expand = function(args)
                      luasnip.lsp_expand(args.body)
                    end,
                  },
                  mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                      if cmp.visible() then
                        cmp.select_next_item()
                      elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                      else
                        fallback()
                      end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                      if cmp.visible() then
                        cmp.select_prev_item()
                      elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                      else
                        fallback()
                      end
                    end, { "i", "s" }),
                  }),
                  sources = cmp.config.sources({
                    { name = "nvim_lsp" }, -- Pull completions from rust-analyzer
                    { name = "luasnip" },  -- Snippets
                  }),
                })
        end,
    },
    -- Scala
    {
        "scalameta/nvim-metals",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        ft = { "scala", "sbt", "java" },
        opts = function()
            local metals_config = require("metals").bare_config()

            metals_config.settings = {
                serverVersion = "1.2.0"
            }

            metals_config.init_options.statusBarProvider = "on"
            metals_config.on_attach = function(client, bufnr)
                -- Enable completion triggered by <c-x><c-o>
                vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

                -- Metals Key mappings
                local bufopts = { noremap=true, silent=true, buffer=bufnr }
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
                vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
                vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
                vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
                vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
                vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
                vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
            end
            return metals_config
        end,
        config = function(self, metals_config)
            local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
            vim.api.nvim_create_autocmd("FileType", {
                pattern = self.ft,
                callback = function()
                    require("metals").initialize_or_attach(metals_config)
                end,
                group = nvim_metals_group,
            })
        end
    },
    -- Rust
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            { "williamboman/mason.nvim", config = true },
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "rust_analyzer", "pest_ls" },
            })
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            vim.lsp.config('rust_analyzer', {
                capabilities = capabilities,
                settings = {
                    ["rust-analyzer"] = {
                        check = { command = "clippy" }
                    },
                },
            })
            vim.lsp.config('pest_ls', {
                capabilities = capabilities,
            })
            vim.lsp.config('leanls', {
                capabilities = capabilities,
                on_attach = function(client, bufnr)
                    -- Lean Key mappings
                    local bufopts = { noremap=true, silent=true, buffer=bufnr }
                    -- gD: Jump to declaration (where symbol is first declared)
                    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
                    -- gd: Jump to definition (actual implementation)
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
                    -- K: Show hover documentation/type information
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
                    -- gi: Jump to implementation
                    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
                    -- Ctrl+k: Show function signature help
                    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
                    -- \ca: Show code actions (tactics, quick fixes)
                    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
                    -- gr: Show all references to symbol under cursor
                    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
                end,
            })
        end,
    },
}

local opts = {}

require("lazy").setup(plugins, opts)
require("catppuccin").setup()
vim.cmd.colorscheme "catppuccin-frappe"

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", builtin.find_files, {})
vim.keymap.set("n", "<C-f>", builtin.live_grep, {})
vim.keymap.set("n", "<C-y>", ":TransparentToggle<CR>")

local configs = require("nvim-treesitter.configs")
configs.setup({
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html", "rust" },
    sync_install = false,
    highlight = { enable = true },
    indent = { enable = true },
})
