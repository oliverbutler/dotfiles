-- htmx - HTMX Language Server
-- Provides HTMX attribute support and validation

---@type vim.lsp.Config
return {
	cmd = { "htmx-lsp" },
	filetypes = { "html" },
	root_markers = { ".git", "package.json" },
}
