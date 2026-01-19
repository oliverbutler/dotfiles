-- restart editor
vim.keymap.set("n", "<leader>re", ":restart +qall!<CR>", { noremap = true, desc = "Restart Neovim" })

-- make ctrl d and ctrl u re-center the screen
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Map leader [ and ] to navigate cursor positions
vim.keymap.set("n", "<leader>[", "<C-o>", { noremap = true })
vim.keymap.set("n", "<leader>]", "<C-i>", { noremap = true })

-- Go to the next quickfix item
vim.keymap.set("n", "]q", function()
	vim.cmd("cnext")
end, { desc = "Next Quickfix" })

vim.keymap.set("n", "[q", function()
	vim.cmd("cprev")
end, { desc = "Previous Quickfix" })

vim.keymap.set("n", "]e", function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next Error" })

vim.keymap.set("n", "[e", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Previous Error" })

vim.keymap.set("n", "]d", function()
	vim.diagnostic.goto_next()
end, { desc = "Next Diagnostic" })

vim.keymap.set("n", "[d", function()
	vim.diagnostic.goto_prev()
end, { desc = "Previous Diagnostic" })

-- Map leader [ and ] to navigate files
vim.keymap.set("n", "<leader>{", ":bprevious<CR>", { noremap = true })
vim.keymap.set("n", "<leader>}", ":bnext<CR>", { noremap = true })

vim.keymap.set("n", "<leader>w", function()
	-- Check if buffer is modifiable and not readonly
	if vim.bo.modifiable and not vim.bo.readonly then
		vim.cmd("w")
	else
		-- This is rather than the existing annoying text that appears
		vim.notify("Buffer is not saveable", vim.log.levels.INFO, {
			title = "Save Buffer",
			icon = "ℹ️",
		})
	end
end)


-- Quit
vim.keymap.set("n", "<leader>q", function()
	vim.cmd("q")
end)

-- File helpers
vim.keymap.set("n", "<leader>fo", function()
	local file_path = vim.fn.expand("%:p")
	vim.fn.system({ "open", "-R", file_path })
end, { noremap = true, silent = true, desc = "Open current file in Finder" })

-- Close neovim safely
vim.keymap.set("n", "<leader>-", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local modified = vim.api.nvim_buf_get_option(bufnr, "modified")
	if modified then
		vim.ui.input({
			prompt = "You have unsaved changes. Save before quitting? (y/n) ",
		}, function(input)
			if input == "y" then
				vim.cmd("wa")
				vim.cmd("qa!")
			elseif input == "n" or input == "N" then
				vim.cmd("qa!")
			end
		end)
	else
		vim.cmd("qa!")
	end
end, { desc = "Quit Neovim with prompt to save changes" })

-- Delete Neovim 0.11+ default LSP gr* mappings that cause delay on "gr"
vim.keymap.del("n", "gra")
vim.keymap.del("n", "gri")
vim.keymap.del("n", "grn")
vim.keymap.del("n", "grr")
vim.keymap.del("n", "grt")
