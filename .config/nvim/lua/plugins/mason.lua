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
      },
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "eslint",
        "prettierd",
        "sql-formatter",
        "gofumpt",
        "gofumports",
      },
    })

    mason_dap.setup({
      ensure_installed = {
        "js",
        "delve",
      },
    })
  end,
}
