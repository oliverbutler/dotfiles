local function is_nixos()
  local os_release = io.open("/etc/os-release", "r")
  if os_release then
    local content = os_release:read("*all")
    os_release:close()
    return content:match("ID=nixos")
  end
  return false
end

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
    if not is_nixos() then
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
          "tsserver",
          "html",
          "cssls",
          "tailwindcss",
          "lua_ls",
          "prismals",
          "terraformls",
          "templ",
          "html",
          "htmx",
          "typos-lsp",
        },
      })

      mason_tool_installer.setup({
        ensure_installed = {
          "eslint",
          "prettierd",
          "sql-formatter",
          "gofumpt",
          "gofumports",
          "typos-lsp",
        },
      })

      mason_dap.setup({
        ensure_installed = {
          "js",
          "delve",
        },
      })
    else
      vim.notify("Mason is not supported on NixOS", "warn")
    end
  end,
}
