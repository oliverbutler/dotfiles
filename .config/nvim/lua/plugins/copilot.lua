-- GitHub Copilot integration (pure Lua)

vim.pack.add({
	{ src = "https://github.com/zbirenbaum/copilot.lua" },
	{ src = "https://github.com/copilotlsp-nvim/copilot-lsp" }, -- NES functionality
})

-----------------------------------------
-- copilot-lsp Configuration
-----------------------------------------

vim.g.copilot_nes_debounce = 500

-----------------------------------------
-- copilot.lua Configuration
-----------------------------------------

require("copilot").setup({
	panel = {
		enabled = true,
		auto_refresh = true,
	},
	suggestion = {
		enabled = true,
		auto_trigger = true,
		keymap = {
			accept = "<Tab>",
			accept_word = "<C-e>",
			accept_line = "<M-j>",
			next = "<M-]>",
			prev = "<M-[>",
			dismiss = "<C-]>",
		},
	},
	nes = {
		enabled = true,
		keymap = {
			accept_and_goto = "<leader>p",
			accept = false,
			dismiss = "<Esc>"
		},
	},
	filetypes = {
		yaml = true,
		markdown = true,
		gitcommit = true,
		["."] = false,
	},
})

-----------------------------------------
-- Keymaps
-----------------------------------------

-- NES: Tab to accept in normal mode (jumps to edit, then applies)
vim.keymap.set("n", "<Tab>", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local state = vim.b[bufnr].nes_state
	if state then
		local _ = require("copilot-lsp.nes").walk_cursor_start_edit()
			or (
				require("copilot-lsp.nes").apply_pending_nes()
				and require("copilot-lsp.nes").walk_cursor_end_edit()
			)
		return
	end
	-- Fallback to normal <C-i> (jump forward in jumplist)
	vim.cmd("normal! \t")
end, { desc = "Accept Copilot NES or fallback" })

-- NES: Escape to clear suggestion
vim.keymap.set("n", "<Esc>", function()
	if not require("copilot-lsp.nes").clear() then
		-- Clear search highlight as fallback
		vim.cmd("nohlsearch")
	end
end, { desc = "Clear Copilot NES or nohlsearch" })

vim.keymap.set("n", "<leader>cp", function()
	require("copilot.panel").toggle()
end, { desc = "Toggle Copilot Panel" })

vim.keymap.set("n", "<leader>ct", function()
	require("copilot.suggestion").toggle_auto_trigger()
end, { desc = "Toggle Copilot Auto Trigger" })
