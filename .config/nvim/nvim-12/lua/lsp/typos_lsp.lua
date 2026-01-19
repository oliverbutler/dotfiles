-- typos_lsp - Spell Checker Language Server
-- Provides spell checking and typo detection

---@type vim.lsp.Config
return {
	cmd = { "typos-lsp" },
	filetypes = { "*" },
	root_markers = { ".git" },
	init_options = {
		diagnosticSeverity = "Info",
	},
}
