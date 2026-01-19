-- nvim-ufo - Better folding

vim.pack.add({
	{ src = "https://github.com/kevinhwang91/nvim-ufo" },
	{ src = "https://github.com/kevinhwang91/promise-async" },
})

vim.o.foldcolumn = "0"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
vim.keymap.set("n", "zK", function()
	local winid = require("ufo").peekFoldedLinesUnderCursor()
	if not winid then
		vim.lsp.buf.hover()
	end
end, { desc = "Peek Fold" })

vim.keymap.set("n", "<leader>ft", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local current_pos = vim.api.nvim_win_get_cursor(0)
	local it_lines = {}

	-- Find all lines containing "it(" pattern (typical for test files)
	for i, line in ipairs(lines) do
		if line:match("%s*it%s*%(") then
			table.insert(it_lines, i)
		end
	end

	-- Fold each "it" block
	for _, lnum in ipairs(it_lines) do
		local view = vim.fn.winsaveview()
		vim.api.nvim_win_set_cursor(0, { lnum, 0 })
		vim.cmd("normal! zc")
		vim.fn.winrestview(view)
	end

	-- Return to original position
	vim.api.nvim_win_set_cursor(0, current_pos)

	vim.notify("Folded " .. #it_lines .. " test blocks", vim.log.levels.INFO, { title = "UFO" })
end, { desc = "Fold all test 'it' blocks" })

local handler = function(virtText, lnum, endLnum, width, truncate)
	local newVirtText = {}
	local suffix = (" 󰁂 %d "):format(endLnum - lnum)
	local sufWidth = vim.fn.strdisplaywidth(suffix)
	local targetWidth = width - sufWidth
	local curWidth = 0
	for _, chunk in ipairs(virtText) do
		local chunkText = chunk[1]
		local chunkWidth = vim.fn.strdisplaywidth(chunkText)
		if targetWidth > curWidth + chunkWidth then
			table.insert(newVirtText, chunk)
		else
			chunkText = truncate(chunkText, targetWidth - curWidth)
			local hlGroup = chunk[2]
			table.insert(newVirtText, { chunkText, hlGroup })
			chunkWidth = vim.fn.strdisplaywidth(chunkText)
			if curWidth + chunkWidth < targetWidth then
				suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
			end
			break
		end
		curWidth = curWidth + chunkWidth
	end
	table.insert(newVirtText, { suffix, "MoreMsg" })
	return newVirtText
end

require("ufo").setup({
	provider_selector = function(bufnr, filetype, buftype)
		return { "lsp", "indent" }
	end,
	fold_virt_text_handler = handler,
	close_fold_kinds_for_ft = {
		-- Don't auto-close anything by default
		default = {},
	},
	enable_get_fold_virt_text = true,
})
