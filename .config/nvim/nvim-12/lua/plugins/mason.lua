-- Mason.nvim - LSP server installer and manager
-- Automatically installs LSP servers on startup

vim.pack.add({
	{ src = "https://github.com/mason-org/mason.nvim" },
})

local mason = require("mason")
local mason_registry = require("mason-registry")

mason.setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

-- List of LSP servers to auto-install
-- Maps LSP name to Mason package name
local ensure_installed = {
	"vtsls",
	"lua-language-server",
	"gopls",
	"rust-analyzer",
	"eslint-lsp",
	"tailwindcss-language-server",
	"html-lsp",
	"htmx-lsp",
	"terraform-ls",
	"typos-lsp",
}

-- Auto-install LSP servers
local function ensure_installed_servers()
	for _, server in ipairs(ensure_installed) do
		local package = mason_registry.get_package(server)
		if not package:is_installed() then
			vim.notify("Installing " .. server, vim.log.levels.INFO, {
				title = "Mason",
			})
			package:install()
		end
	end
end

-- Wait for Mason registry to be ready before installing
if mason_registry.refresh then
	mason_registry.refresh(function()
		ensure_installed_servers()
	end)
else
	ensure_installed_servers()
end

