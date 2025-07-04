return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "jay-babu/mason-nvim-dap.nvim",
  },
  cmd = "Mason",
  event = "BufReadPre",
  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")
    local mason_dap = require("mason-nvim-dap")

    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      ensure_installed = {
        "ts_ls",
        "html",
        "cssls",
        "tailwindcss",
        "lua_ls",
        "prismals",
        "terraformls",
        "templ",
        "html",
        "htmx",
        "typos_lsp",
        "vtsls",
        "gopls",
        "golangci_lint_ls"
      },
      automatic_installation = true,
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "eslint",
        "prettierd",
        "sleek",
        "gofumpt",
        "nixfmt",
      },
      automatic_installation = true,
    })

    mason_dap.setup({
      automatic_installation = true,
      ensure_installed = {
        "js",
        "delve",
      },
    })
  end,
}
