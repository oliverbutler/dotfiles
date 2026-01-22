-- eslint - JavaScript/TypeScript linting server
-- Provides ESLint integration for JS/TS projects

---@type vim.lsp.Config
return {
	cmd = { "vscode-eslint-language-server", "--stdio" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"vue",
		"svelte",
		"astro",
	},
	root_markers = {
		".eslintrc",
		".eslintrc.js",
		".eslintrc.cjs",
		".eslintrc.yaml",
		".eslintrc.yml",
		".eslintrc.json",
		"eslint.config.js",
		"eslint.config.mjs",
		"package.json",
	},
	on_new_config = function(config, new_root_dir)
		-- Try to detect flat config
		local flat_config_files = {
			"eslint.config.js",
			"eslint.config.mjs",
			"eslint.config.cjs",
			"eslint.config.ts",
			"eslint.config.mts",
			"eslint.config.cts",
		}
		
		config.settings = config.settings or {}
		config.settings.experimental = config.settings.experimental or {}
		
		-- Check if flat config exists
		for _, file in ipairs(flat_config_files) do
			if vim.fn.filereadable(new_root_dir .. "/" .. file) == 1 then
				config.settings.experimental.useFlatConfig = true
				return
			end
		end
		
		-- Default to legacy config
		config.settings.experimental.useFlatConfig = false
	end,
	settings = {
		experimental = {
			useFlatConfig = false,
		},
		codeAction = {
			disableRuleComment = {
				enable = true,
				location = "separateLine",
			},
			showDocumentation = {
				enable = true,
			},
		},
		codeActionOnSave = {
			enable = false,
			mode = "all",
		},
		format = false,
		nodePath = "",
		onIgnoredFiles = "off",
		packageManager = "npm",
		quiet = false,
		rulesCustomizations = {},
		run = "onType",
		useESLintClass = false,
		validate = "on",
		workingDirectory = {
			mode = "location",
		},
	},
}
