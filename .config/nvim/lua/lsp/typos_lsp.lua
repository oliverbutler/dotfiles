-- typos_lsp - Spell Checker Language Server
-- Provides spell checking and typo detection

---@type vim.lsp.Config
return {
  cmd = { "typos-lsp" },
  -- Comprehensive list of text-based filetypes where spell checking is useful
  filetypes = {
    "markdown",
    "text",
    "gitcommit",
    "lua",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "go",
    "rust",
    "python",
    "html",
    "css",
    "json",
    "yaml",
    "toml",
    "vim",
  },
  root_markers = { ".git" },
  init_options = {
    diagnosticSeverity = "Info",
  },
}
