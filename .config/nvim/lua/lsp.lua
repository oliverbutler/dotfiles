-- Get capabilities from blink.cmp for LSP completion
local capabilities = require("blink.cmp").get_lsp_capabilities()

-- Add folding capabilities for nvim-ufo
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

-- List of LSP servers to configure
local servers = {
	"vtsls",
	"lua_ls",
	"gopls",
	"rust_analyzer",
	"eslint",
	"tailwindcss",
	"html",
	"htmx",
	"terraformls",
	"typos_lsp",
}

-- Load and register each server config from lsp/ directory
for _, server in ipairs(servers) do
	local config = require("lsp." .. server)

	-- Merge capabilities into the config
	config.capabilities = vim.tbl_deep_extend(
		"force",
		config.capabilities or {},
		capabilities
	)

	-- Register the server configuration
	vim.lsp.config(server, config)
end

-- Enable all configured LSP servers
vim.lsp.enable(servers)

-- Configure diagnostics globally
vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		focusable = false,
		style = "minimal",
		border = "rounded",
		header = "",
		prefix = "",
		wrap = true,
	},
})

-- Register MDX filetype
vim.filetype.add({
	extension = {
		mdx = "mdx",
	},
})

-- LspAttach autocmd - runs when LSP attaches to a buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)

		-- Set buffer-local capabilities
		if client then
			client.server_capabilities = vim.tbl_deep_extend(
				"force",
				client.server_capabilities or {},
				capabilities
			)
		end

		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		-- Enable inlay hints by default
		if client and client.server_capabilities.inlayHintProvider then
			vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
		end

		-- Buffer-local keymaps
		local opts = { buffer = ev.buf }

		-- Hover documentation
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

		-- Signature help
		vim.keymap.set("n", "<C-i>", vim.lsp.buf.signature_help, opts)

		-- Rename symbol
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	end,
})

-- Code action keymap (global)
vim.keymap.set("n", "<leader>i", function()
	vim.lsp.buf.code_action()
end, { desc = "LSP Code Action" })

-- Show line diagnostics
vim.keymap.set("n", "<leader>o", function()
	vim.diagnostic.open_float(nil, {
		scope = "cursor",
		focusable = false,
		close_events = {
			"BufLeave",
			"CursorMoved",
			"InsertEnter",
			"FocusLost",
		},
	})
end, { desc = "Show line diagnostics" })

-- Restart all LSP clients
vim.keymap.set("n", "<leader>ra", function()
	local active_clients = vim.lsp.get_clients()

	vim.notify("Stopping " .. #active_clients .. " LSP clients", vim.log.levels.INFO, {
		title = "Restart LSP",
	})

	for _, client in ipairs(active_clients) do
		-- Skip copilot to avoid errors
		if client.name ~= "copilot" then
			vim.lsp.stop_client(client.id)
		end
	end

	vim.defer_fn(function()
		local ok, err = pcall(function()
			vim.cmd("w!")
			vim.cmd("e")
		end)
		if not ok then
			vim.notify("Error restarting LSP: " .. tostring(err), vim.log.levels.WARN)
		else
			vim.notify("LSP clients restarted", vim.log.levels.INFO, {
				title = "Restart LSP",
			})
		end

		-- Re-enable Copilot if available
		pcall(function()
			vim.cmd("Copilot enable")
			vim.cmd("Copilot attach")
		end)
	end, 100)
end, { noremap = true, desc = "Restart LSP" })
