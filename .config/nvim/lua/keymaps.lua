-- restart editor with session
vim.keymap.set("n", "<leader>re", function()
	-- Save current session before restarting
	local session_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
	require("mini.sessions").write(session_name, { force = true })
	-- Restart and restore the session
	vim.cmd("restart lua MiniSessions.read('" .. session_name .. "')")
end, { noremap = true, desc = "Restart Neovim with session" })

-- make ctrl d and ctrl u re-center the screen
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Ctrl+hjkl mappings are in vim-tmux-navigator plugin

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

vim.keymap.set("n", "<leader>fp", function()
	local path = vim.fn.expand("%:.")
	vim.fn.setreg("+", path)
	vim.notify("Copied: " .. path, vim.log.levels.INFO)
end, { desc = "Copy relative file path" })

vim.keymap.set("n", "<leader>fP", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	vim.notify("Copied: " .. path, vim.log.levels.INFO)
end, { desc = "Copy absolute file path" })

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

-----------------------------------------
-- Sibling File Toggle
-----------------------------------------

-- Define language-specific test patterns
local test_patterns = {
	-- JavaScript/TypeScript patterns
	js = { dot_suffix = { "spec", "test" } },
	jsx = { dot_suffix = { "spec", "test" } },
	ts = { dot_suffix = { "spec", "test" } },
	tsx = { dot_suffix = { "spec", "test" } },

	-- Go patterns
	go = { underscore_suffix = { "test" } },

	-- Default patterns for other languages
	default = { dot_suffix = { "spec", "test" } },
}

local function parseFilename(filename)
	local name, suffix, extension, suffix_type

	-- Find the last dot which should separate the file extension
	local lastDotIndex = filename:match("^.*()%.")
	if not lastDotIndex then
		return nil, nil, nil, nil -- No dot found
	end
	extension = filename:sub(lastDotIndex + 1)

	-- Remove the extension part from the filename
	local remaining = filename:sub(1, lastDotIndex - 1)

	-- Check for underscore suffix pattern (Go style: file_test.go)
	local underscore_idx = remaining:match("^(.-)_([^_]+)$")
	if underscore_idx then
		local potential_suffix = remaining:match("^.+_([^_]+)$")
		-- Check if the suffix matches known underscore suffixes for this extension
		local patterns = test_patterns[extension] or test_patterns.default
		if patterns.underscore_suffix then
			for _, valid_suffix in ipairs(patterns.underscore_suffix) do
				if potential_suffix == valid_suffix then
					name = remaining:sub(1, #remaining - #potential_suffix - 1) -- Remove _suffix
					suffix = potential_suffix
					suffix_type = "underscore"
					return name, suffix, extension, suffix_type
				end
			end
		end
	end

	-- Check for dot suffix pattern (JS/TS style: file.spec.js)
	local secondLastDotIndex = remaining:match("^.*()%.")
	if secondLastDotIndex then
		local potential_suffix = remaining:sub(secondLastDotIndex + 1)
		name = remaining:sub(1, secondLastDotIndex - 1)

		-- Check if the found suffix is a valid dot suffix for this extension
		local patterns = test_patterns[extension] or test_patterns.default
		if patterns.dot_suffix then
			for _, valid_suffix in ipairs(patterns.dot_suffix) do
				if potential_suffix == valid_suffix then
					suffix = potential_suffix
					suffix_type = "dot"
					return name, suffix, extension, suffix_type
				end
			end
		end

		-- If we get here, the suffix wasn't recognized as a test suffix
		name = remaining
		suffix = nil
	else
		name = remaining
	end

	return name, suffix, extension, suffix_type
end

vim.keymap.set("n", "<leader>gs", function()
	local current_file = vim.fn.expand("%:t") -- Get the current file name
	local current_dir = vim.fn.expand("%:p:h") -- Get the current directory path

	local name, suffix, extension, suffix_type = parseFilename(current_file)

	-- Get language-specific patterns
	local patterns = test_patterns[extension] or test_patterns.default
	local alternate_files = {}

	if suffix then
		-- If we have a suffix, create the alternate path without the suffix
		table.insert(alternate_files, {
			suffix = nil,
			filename = string.format("%s.%s", name, extension),
		})
	else
		-- If we don't have a suffix, create alternate paths with all possible patterns for this extension

		-- Add dot suffix patterns (file.spec.js, file.test.js)
		if patterns.dot_suffix then
			for _, pattern in ipairs(patterns.dot_suffix) do
				table.insert(alternate_files, {
					suffix = pattern,
					suffix_type = "dot",
					filename = string.format("%s.%s.%s", name, pattern, extension),
				})
			end
		end

		-- Add underscore suffix patterns (file_test.go)
		if patterns.underscore_suffix then
			for _, pattern in ipairs(patterns.underscore_suffix) do
				table.insert(alternate_files, {
					suffix = pattern,
					suffix_type = "underscore",
					filename = string.format("%s_%s.%s", name, pattern, extension),
				})
			end
		end
	end

	for _, alt in ipairs(alternate_files) do
		if alt.suffix ~= suffix or alt.suffix_type ~= suffix_type then
			local path = current_dir .. "/" .. alt.filename

			if vim.fn.filereadable(path) == 1 then
				vim.cmd("edit " .. path)
				return
			end
		end
	end

	vim.notify("No sibling file found", vim.log.levels.WARN)
end, { noremap = true, desc = "Toggle between sibling files" })
