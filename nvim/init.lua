-- =============================================================================
-- VIM OPTIONS
-- =============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.number = true
vim.opt.syntax = "on"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.mouse = "a"
vim.opt.wrap = false
vim.opt.sidescroll = 1
vim.opt.sidescrolloff = 5
-- =============================================================================
-- LAZY.NVIM BOOTSTRAP
-- =============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- =============================================================================
-- LAZY.NVIM PLUGIN SETUP
-- =============================================================================
require("lazy").setup({
    install = {
        colorscheme = { "catppuccin" },
    },
    checker = {
        enabled = true,
    },
    spec = {
        { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

        {
            "nvim-telescope/telescope.nvim",
            tag = "0.1.8",
            dependencies = { "nvim-lua/plenary.nvim" },

            config = function()
                local builtin = require("telescope.builtin")
                vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
                vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
                vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
                vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
            end,
        },
        {
            "nvim-telescope/telescope-ui-select.nvim",
            config = function()
                require("telescope").setup({
                    extensions = {
                        ["ui-select"] = require("telescope.themes").get_dropdown({}),
                    },
                })
                require("telescope").load_extension("ui-select")
            end,
        },

        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            config = function()
                require("nvim-treesitter.configs").setup({
                    ensure_installed = { "c", "lua", "javascript", "python", "java", "typescript", "go", "ruby" },
                    auto_install = true,
                    highlight = { enable = true },
                    indent = { enable = true },
                })
            end,
        },

        {
            "nvim-neo-tree/neo-tree.nvim",
            branch = "v3.x",
            dependencies = {
                "nvim-lua/plenary.nvim",
                "nvim-tree/nvim-web-devicons",
                "MunifTanjim/nui.nvim",
            },
            config = function()
                require("neo-tree").setup({
                    event_handlers = {
                        {
                            event = "file_open_requested",
                            handler = function()
                                require("neo-tree.command").execute({ action = "close" })
                            end,
                        },
                    },
                })
                vim.keymap.set("n", "<leader>n", function()
                    require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
                end, { desc = "Toggle Neo-tree" })
            end,
        },

        -- Mason
        {
            "mason-org/mason.nvim",
            opts = {
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗",
                    },
                },
            },
        },

        -- Mason lspconfig
        {
            "mason-org/mason-lspconfig.nvim",
            opts = {
                ensure_installed = {
                    "lua_ls",
                    "rust_analyzer",
                    "pyright",
                    "gopls",
                    "clangd",
                    "jdtls",
                    "ts_ls",
                    "solidity_ls",
                },
            },
            dependencies = {
                { "mason-org/mason.nvim", opts = {} },
                "neovim/nvim-lspconfig",
            },
        },

        {
            "neovim/nvim-lspconfig",
            config = function()
                local lspconfig = require("lspconfig")
                lspconfig.lua_ls.setup({})
                lspconfig.rust_analyzer.setup({})
                lspconfig.pyright.setup({})
                lspconfig.gopls.setup({})
                --lspconfig.clangd.setup({})
                lspconfig.jdtls.setup({})
                lspconfig.ts_ls.setup({})
                lspconfig.solidity_ls.setup({})

                lspconfig.clangd.setup({
                    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
                    root_dir = lspconfig.util.root_pattern(
                        ".clangd",
                        ".clang-tidy",
                        ".clang-format",
                        "compile_commands.json",
                        "compile_flags.txt",
                        "configure.ac",
                        ".git"
                    ),
                    single_file_support = true,
                })

                vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
                vim.keymap.set({ "n" }, "<leader>ca", vim.lsp.buf.code_action, {})
            end,
        },

        {
            "nvimtools/none-ls.nvim",
            dependencies = { "mason-org/mason.nvim" },
            config = function()
                local null_ls = require("null-ls")
                null_ls.setup({
                    sources = {
                        null_ls.builtins.formatting.stylua,
                        --null_ls.builtins.diagnostics.luackeck,

                        null_ls.builtins.formatting.prettier,
                        --null_ls.builtins.diagnostics.eslint_d,

                        null_ls.builtins.formatting.black,
                        null_ls.builtins.formatting.isort,
                        --null_ls.builtins.diagnostics.flake8,

                        null_ls.builtins.formatting.goimports,
                        null_ls.builtins.diagnostics.golangci_lint,

                        null_ls.builtins.formatting.clang_format,

                        null_ls.builtins.formatting.google_java_format,
                        null_ls.builtins.diagnostics.checkstyle,

                        null_ls.builtins.diagnostics.solhint,
                    },
                })

                vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
            end,
        },

        {
            "hrsh7th/cmp-nvim-lsp",
        },
        {
            "L3MON4D3/LuaSnip",
            dependencies = {
                "saadparwaiz1/cmp_luasnip",
                "rafamadriz/friendly-snippets",
            },
        },
        {
            "hrsh7th/nvim-cmp",
            config = function()
                local cmp = require("cmp")
                require("luasnip.loaders.from_vscode").lazy_load()

                cmp.setup({
                    snippet = {
                        expand = function(args)
                            require("luasnip").lsp_expand(args.body)
                        end,
                    },
                    window = {
                        completion = cmp.config.window.bordered(),
                        documentation = cmp.config.window.bordered(),
                    },
                    mapping = cmp.mapping.preset.insert({
                        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                        ["<C-f>"] = cmp.mapping.scroll_docs(4),
                        ["<C-Space>"] = cmp.mapping.complete(),
                        ["<C-e>"] = cmp.mapping.abort(),
                        ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    }),
                    sources = cmp.config.sources({
                        { name = "nvim_lsp" },
                        { name = "luasnip" }, -- For luasnip users.
                    }, {
                        { name = "buffer" },
                    }),
                })
            end,
        },
    },
})

vim.cmd.colorscheme("catppuccin")

vim.diagnostic.config({
    virtual_text = true,
    severity_sort = true,
    float = {
        style = "minimal",
        border = "rounded",
        header = "",
        prefix = "",
    },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "✘",
            [vim.diagnostic.severity.WARN] = "▲",
            [vim.diagnostic.severity.HINT] = "⚑",
            [vim.diagnostic.severity.INFO] = "»",
        },
    },
})
