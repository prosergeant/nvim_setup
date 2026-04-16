-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Базовые настройки
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
vim.g.mapleader = " "

-- Плагины
require("lazy").setup({

  -- Тема
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      require("tokyonight").setup({})
      vim.cmd.colorscheme("tokyonight")
    end
  },

  -- Файловое дерево
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
    end
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = {
            ".git\\",
            ".git/",
            "node_modules\\",
            "node_modules/",
            ".idea\\",
            ".idea/",
            ".husky\\",
            ".husky/",
          }
        }
      })
    end
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter",
    opts = {
      ensure_installed = { "lua", "python", "javascript", "typescript", "rust", "bash", "vue" },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    }
  },

  -- Mason
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pyright", "ts_ls" }, -- , "vue_ls"
        automatic_installation = true,
      })
    end
  },

  -- LSP (новый API)
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason-lspconfig.nvim", "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      vim.lsp.config("lua_ls", { capabilities = capabilities })
      vim.lsp.config("pyright", { capabilities = capabilities })
      vim.lsp.config("ts_ls", {
        capabilities = capabilities,
        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        init_options = {
          plugins = {
            {
              name = "@vue/typescript-plugin",
              location = vim.fs.joinpath(vim.fn.getcwd(), "node_modules", "@vue", "typescript-plugin"),
              languages = { "vue" },
            },
          },
        },
        vim.lsp.config("vue_ls", {
          capabilities = capabilities,
          init_options = {
            typescript = {
              tsdk = vim.fs.joinpath(vim.fn.getcwd(), "node_modules", "typescript", "lib"),
            }
          },
        })
      })
      vim.lsp.enable({ "lua_ls", "pyright", "ts_ls", "vue_ls" })
    end
  },

  -- Автодополнение
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end
      },
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]     = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"]   = cmp.mapping(function(fallback)
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
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({ options = { theme = "catppuccin" } })
    end
  },

  -- Автозакрытие скобок
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end
  },

  -- Нативное комментирование (gc / gcc) + поддержка JSX/TSX
  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
  },

  -- Форматирование (Prettier и др.)
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          javascript      = { "prettier" },
          javascriptreact = { "prettier" },
          typescript      = { "prettier" },
          typescriptreact = { "prettier" },
          vue             = { "prettier" },
          json            = { "prettier" },
          jsonc           = { "prettier" },
          css             = { "prettier" },
          scss            = { "prettier" },
          html            = { "prettier" },
          markdown        = { "prettier" },
          yaml            = { "prettier" },
        },
        formatters = {
          prettier = {
            require_cwd = false,
          },
        },
      })
    end
  },

  -- Git
  { "tpope/vim-fugitive" },

  -- GitLab (для гитлаба нужна гошка)
  -- { "harrisoncramer/gitlab.nvim",
  -- dependencies = {
  --   "MunifTanjim/nui.nvim",
  --   "nvim-lua/plenary.nvim",
  --   "sindrets/diffview.nvim",
  -- },
  -- build = function () require("gitlab.server").build(true) end,
  -- config = function()
  --   require("gitlab").setup({
  --     port = 21036,
  --   })
  -- end},
})

-- Vue: динамический commentstring по секции (template/script/style)
-- Нужен потому что treesitter не парсит vue буфер без активного хайлайтера,
-- и нативный gcc фоллбэчит на vim.bo.commentstring.
vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved", "CursorMovedI" }, {
  pattern = "*.vue",
  callback = function()
    local lnum = vim.fn.line(".")
    for i = lnum, 1, -1 do
      local line = vim.fn.getline(i)
      if line:match("^<script") then
        vim.bo.commentstring = "// %s"
        return
      elseif line:match("^<style") then
        vim.bo.commentstring = "/* %s */"
        return
      elseif line:match("^<template") then
        break
      end
    end
    vim.bo.commentstring = "<!-- %s -->"
  end,
})

-- настройки телескопа
require('my_telescope').setup()

-- Кеймапы
local map = vim.keymap.set

map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "File tree" })
map("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live grep" })
map("n", "<leader>fb", ":Telescope buffers<CR>", { desc = "Buffers" })
map("n", "<leader>fh", ":Telescope help_tags<CR>", { desc = "Help" })
map('i', 'jj', '<Esc>', { noremap = true, silent = true }) -- Выход из режима вставки через jj

map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gr", vim.lsp.buf.references, { desc = "References" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover docs" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Diagnostic float" })
map({ "n", "v" }, "<leader>p", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format (Prettier)" })

-- Git keymaps
map("n", "<leader>gs", ":Git<CR>", { desc = "Git status" })
map("n", "<leader>gss", ":Telescope git_status<CR>", { desc = "Git status (Telescope)" })
map("n", "<leader>gp", ":Git push -u origin HEAD<CR>", { desc = "Git push" })
map("n", "<leader>gl", ":Git log<CR>", { desc = "Git log" })
map("n", "<leader>gd", ":Git diff<CR>", { desc = "Git diff" })
-- map("n", "<leader>gb", ":Git branch<CR>", { desc = "Git branch"})
map("n", "<leader>gb", ":Telescope git_branches<CR>", { desc = "Git branches" })
map("n", "<leader>gc", ":Git commit<CR>", { desc = "Git commit" })
map("n", "<leader>gsc", ":Telescope git_commits<CR>", { desc = "Git commits (Telescope)" })

-- Переключиться на ветку и обновить ее
map("n", "<leader>gcc", function()
  local branch = vim.fn.input("Checkout branch: ")
  if branch ~= "" then
    vim.cmd("Git checkout " .. branch)
    vim.cmd("Git pull")
  end
end, { desc = "Git checkout + pull" })

-- Создать новую ветку от выбранной но перед этим ее обновить
map("n", "<leader>gcb", function()
  local new_branch = vim.fn.input("New branch name: ")
  if new_branch == "" then return end
  local from_branch = vim.fn.input("From branch (default: dev): ")
  if from_branch == "" then from_branch = "dev" end

  vim.cmd("Git checkout " .. from_branch)
  vim.cmd("Git pull")

  -- Проверяем существует ли ветка
  local branch_exists = vim.fn.system("git branch --list " .. new_branch)
  branch_exists = branch_exists:gsub("%s+", "")

  if branch_exists ~= "" then
    local confirm = vim.fn.input("Branch '" .. new_branch .. "' already exists. Overwrite? (y/N): ")
    if confirm:lower() ~= "y" then
      print("\nAborted.")
      return
    end
    vim.cmd("Git branch -D " .. new_branch)
  end

  vim.cmd("Git checkout -b " .. new_branch)
end, { desc = "Git new branch" })

-- обновить ветку не переключаясь
vim.keymap.set("n", "<leader>gU", function()
  local branch = vim.fn.system("git branch --format='%(refname:short)' | grep -v '^*'"):gsub("\n$", "")

  local branches = {}
  for b in branch:gmatch("[^\n]+") do
    table.insert(branches, b)
  end

  vim.ui.select(branches, {
    prompt = "Update branch (fast-forward):",
  }, function(selected)
    if not selected then return end

    local result = vim.fn.system("git fetch origin " .. selected .. ":" .. selected .. " 2>&1")
    local ok = vim.v.shell_error == 0

    vim.notify(
      ok and ("✓ Updated: " .. selected) or ("✗ Failed:\n" .. result),
      ok and vim.log.levels.INFO or vim.log.levels.ERROR
    )
  end)
end, { desc = "Git: update branch without switching" })

-- посмотреть разницу между текущем файлом и таким же файлом на другой ветке
map("n", "<leader>gdf", function()
  local branch = vim.fn.input("Compare with branch (default: pp): ")
  if branch == "" then branch = "pp" end
  local file = vim.fn.expand("%") -- текущий файл относительно корня проекта
  vim.cmd("Gvdiffsplit " .. branch .. ":" .. file)
end, { desc = "Git diff current file with branch" })

-- забрать текущий файл целиком с другой ветки
map("n", "<leader>gdo", function()
  local branch = vim.fn.input("Get file from branch (default: pp): ")
  if branch == "" then branch = "pp" end
  local file = vim.fn.expand("%")
  vim.cmd("!git checkout " .. branch .. " -- " .. file)
  vim.cmd("edit!") -- перечитать файл
end, { desc = "Git checkout file from branch" })

-- работа с табами
map("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab" })
map("n", "<leader>tc", ":tabclose<CR>", { desc = "Close tab" })

-- GitLab keymap
-- map("n", "<leader>mrl", ":lua require('gitlab').list_mrs()<CR>", { desc = "List Mrs"})
