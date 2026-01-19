-- tailwindcss - Tailwind CSS Language Server
-- Configured with Go components and template support

---@type vim.lsp.Config
return {
	cmd = { "tailwindcss-language-server", "--stdio" },
	filetypes = {
		"html",
		"javascriptreact",
		"typescriptreact",
		"svelte",
		"vue",
		"go",
		"css",
	},
	root_markers = {
		"tailwind.config.js",
		"tailwind.config.cjs",
		"tailwind.config.mjs",
		"tailwind.config.ts",
		"postcss.config.js",
		"postcss.config.cjs",
		"postcss.config.mjs",
		"postcss.config.ts",
	},
	init_options = { 
		userLanguages = {} 
	},
	settings = {
		tailwindCSS = {
			experimental = {
				classRegex = {
					-- Go components patterns
					"Class\\(([^)]*)\\)",
					'["`]([^"`]*)["`]',           -- Class("...") or Class(`...`)
					"Classes\\(([^)]*)\\)",
					'["`]([^"`]*)["`]',           -- Classes("...") or Classes(`...`)
					"Class\\{([^)]*)\\}",
					'["`]([^"`]*)["`]',           -- Class{"..."} or Class{`...`}
					"Classes\\{([^)]*)\\}",
					'["`]([^"`]*)["`]',           -- Classes{"..."} or Classes{`...`}
					'Class:\\s*["`]([^"`]*)["`]', -- Class: "..." or Class: `...`
					':\\s*["`]([^"`]*)["`]',      -- Classes: "..." or Classes: `...`

					-- support class variance authority
					{ "cva\\(((?:[^()]|\\([^()]*\\))*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
					{ "cx\\(((?:[^()]|\\([^()]*\\))*)\\)",  "(?:'|\"|`)([^']*)(?:'|\"|`)" },

					-- support classnames
					{ "classnames\\(([^)]*)\\)" },
				},
			},
		},
	},
}
