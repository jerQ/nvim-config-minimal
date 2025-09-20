-- Requirements: Neovim 0.9+, clangd, clang-format
-- Optional: ripgrep for Telescope, make for fzf-native.

-- =====================================================================
-- Basic options
-- =====================================================================
vim.g.mapleader = " "
local o = vim.opt

o.number = true
o.relativenumber = true
o.clipboard = "unnamedplus"
o.mouse = "a"
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.smartindent = true
o.wrap = false
o.swapfile = false
o.backup = false
o.undofile = true
o.termguicolors = true
o.timeoutlen = 500
o.completeopt = { "menuone", "noinsert", "noselect" }
o.signcolumn = "auto:1"

-- =====================================================================
-- Bootstrap lazy.nvim (plugin manager)
-- =====================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- =====================================================================
-- Plugins
-- =====================================================================
require("lazy").setup({
  { "nvim-lua/plenary.nvim", lazy = true },
  { "nvim-lua/popup.nvim", lazy = true },

  -- Telescope
  { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "plenary.nvim" } },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = vim.fn.executable("make") == 1 },

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- LSP and autocompletion
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },

  -- Git
  { "lewis6991/gitsigns.nvim" },

  -- Editing helpers
  { "windwp/nvim-autopairs" },
  { "numToStr/Comment.nvim" },

  -- Statusline (optional)
  { "nvim-lualine/lualine.nvim", dependencies = { "kyazdani42/nvim-web-devicons" }, optional = true },

  -- DAP
  { "mfussenegger/nvim-dap" },
  { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap" } },

}, {
  checker = { enabled = true },
})

-- =====================================================================
-- Keymaps
-- =====================================================================
local map = vim.keymap.set
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })
map("n", "<leader>gs", "<cmd>Gitsigns toggle_signs<cr>", { desc = "Toggle git signs" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Write" })

-- =====================================================================
-- Telescope setup
-- =====================================================================
local has_telescope, telescope = pcall(require, "telescope")
if has_telescope then
  telescope.setup({
    defaults = {
      layout_config = { horizontal = { preview_width = 0.55 } },
      file_ignore_patterns = { "node_modules", ".git" },
    },
    extensions = {
      fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true },
    },
  })
  pcall(telescope.load_extension, "fzf")
end

-- =====================================================================
-- Treesitter setup
-- =====================================================================
local has_ts, ts_configs = pcall(require, "nvim-treesitter.configs")
if has_ts then
  ts_configs.setup({
    ensure_installed = { "c", "cpp", "lua", "json", "yaml", "vim" },
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = { enable = true },
    textobjects = { enable = true },
  })
end

-- =====================================================================
-- LSP, Mason, and clangd setup
-- =====================================================================
local has_mason, mason = pcall(require, "mason")
local has_mason_lsp, mason_lsp = pcall(require, "mason-lspconfig")
local lspconfig = require("lspconfig")

if has_mason then mason.setup() end
if has_mason_lsp then
  mason_lsp.setup({
    ensure_installed = { "clangd" },
  })
end

-- on_attach for LSP (buffer-local mappings)
local on_attach = function(client, bufnr)
  local bufmap = function(mode, lhs, rhs, desc)
    if desc then desc = "LSP: " .. desc end
    vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
  end

  bufmap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", "Go to definition")
  bufmap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", "References")
  bufmap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", "Implementation")
  bufmap("n", "K",  "<cmd>lua vim.lsp.buf.hover()<CR>", "Hover")
  bufmap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", "Rename")
  bufmap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", "Code action")
  bufmap("n", "<leader>f", "<cmd>lua vim.lsp.buf.format({async=true})<CR>", "Format file")
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_ok then capabilities = cmp_nvim_lsp.default_capabilities(capabilities) end

-- clangd setup
lspconfig.clangd.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "clangd", "--background-index", "--clang-tidy" },
})

-- =====================================================================
-- nvim-cmp (autocompletion) + LuaSnip
-- =====================================================================
local has_cmp, cmp = pcall(require, "cmp")
if has_cmp then
  local luasnip = require("luasnip")
  require("luasnip.loaders.from_vscode").lazy_load()

  cmp.setup({
    snippet = {
      expand = function(args) require("luasnip").lsp_expand(args.body) end,
    },
    mapping = {
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
        else fallback() end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then luasnip.jump(-1)
        else fallback() end
      end, { "i", "s" }),
    },
    sources = {
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "buffer" },
      { name = "path" },
    },
  })
end

-- =====================================================================
-- Git signs, autopairs, comment, lualine
-- =====================================================================
pcall(function() require("gitsigns").setup() end)
pcall(function() require("nvim-autopairs").setup() end)
pcall(function() require("Comment").setup() end)
pcall(function() require("lualine").setup({ options = { theme = "auto" } }) end)

-- =====================================================================
-- DAP (debugging) for C/C++
-- =====================================================================
local dap_ok, dap = pcall(require, "dap")
if dap_ok then
  -- lldb adapter (lldb-vscode or codelldb). Adjust command/path if needed.
  dap.adapters.lldb = {
    type = "executable",
    command = "lldb-vscode", -- or full path to codelldb adapter
    name = "lldb"
  }

  dap.configurations.c = {
    {
      name = "Launch",
      type = "lldb",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      args = {},
    },
  }
  dap.configurations.cpp = dap.configurations.c

  -- DAP UI and keymaps
  pcall(function()
    local dapui = require("dapui")
    dapui.setup()
    map("n", "<F5>", "<cmd>lua require'dap'.continue()<CR>", { desc = "DAP Continue" })
    map("n", "<F10>", "<cmd>lua require'dap'.step_over()<CR>", { desc = "DAP Step Over" })
    map("n", "<F11>", "<cmd>lua require'dap'.step_into()<CR>", { desc = "DAP Step Into" })
    map("n", "<F12>", "<cmd>lua require'dap'.step_out()<CR>", { desc = "DAP Step Out" })
    map("n", "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", { desc = "Toggle breakpoint" })
    map("n", "<leader>dr", "<cmd>lua require'dap'.repl.open()<CR>", { desc = "Open REPL" })

    local dap, dapui = require("dap"), require("dapui")
    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
    dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
  end)
end

-- =====================================================================
-- Filetype settings for C/C++
-- =====================================================================
vim.api.nvim_create_autocmd("FileType", {
  pattern = "c,cpp",
  callback = function()
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
  end,
})

-- =====================================================================
-- Convenience commands
-- =====================================================================
vim.api.nvim_create_user_command("Format", function()
  vim.lsp.buf.format({ async = true })
end, {})

vim.api.nvim_create_user_command("InstallTools", function()
  print("Install: clangd, clang-format, lldb (or codelldb). Optional: ripgrep for Telescope.")
end, {})

-- =====================================================================
-- Misc: yank highlight, diagnostics, cursorhold float
-- =====================================================================
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 }) end,
})

vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 2 },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function() vim.diagnostic.open_float(nil, { focusable = false }) end,
})

-- End of init.lua

