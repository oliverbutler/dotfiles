-- vtsls - TypeScript/JavaScript Language Server
-- Superior alternative to tsserver with better performance

---@type vim.lsp.Config
return {
	cmd = { "vtsls", "--stdio" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},
	root_markers = {
		"package.json",
		"tsconfig.json",
		"jsconfig.json",
		".git",
	},
	init_options = {
		maxTsServerMemory = 4096,
	},
	settings = {
		vtsls = {
			autoUseWorkspaceTsdk = true,
		},
		typescript = {
			preferences = {
				importModuleSpecifier = "relative",
			},
			suggest = {
				completeFunctionCalls = true,
			},
			-- inlayHints = {
			-- 	parameterNames = { enabled = "all" },
			-- 	parameterTypes = { enabled = true },
			-- 	variableTypes = { enabled = false },
			-- 	propertyDeclarationTypes = { enabled = true },
			-- 	functionLikeReturnTypes = { enabled = true },
			-- 	enumMemberValues = { enabled = true },
			-- },
		},
		javascript = {
			preferences = {
				importModuleSpecifier = "relative",
			},
			suggest = {
				completeFunctionCalls = true,
			},
			-- inlayHints = {
			-- 	parameterNames = { enabled = "all" },
			-- 	parameterTypes = { enabled = true },
			-- 	variableTypes = { enabled = false },
			-- 	propertyDeclarationTypes = { enabled = true },
			-- 	functionLikeReturnTypes = { enabled = true },
			-- 	enumMemberValues = { enabled = true },
			-- },
		},
	},
}
