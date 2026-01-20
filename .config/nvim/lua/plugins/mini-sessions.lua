-- mini.sessions - Session management

vim.pack.add({
	{ src = "https://github.com/echasnovski/mini.sessions" },
})

require("mini.sessions").setup({
	-- Whether to read default session if Nvim opened without file arguments
	autoread = false,
	-- Whether to write current session before quitting Nvim
	autowrite = true,
	-- Directory where global sessions are stored
	directory = vim.fn.stdpath("data") .. "/sessions",
	-- Whether to force possibly harmful actions (delete, overwrite)
	force = { read = false, write = true, delete = false },
	-- Hook functions for actions
	hooks = {
		pre = {
			read = nil,
			write = function()
				-- Close neotest windows before saving session
				-- These don't restore properly and appear as blank panes
				local ok, neotest = pcall(require, "neotest")
				if ok then
					pcall(function() neotest.summary.close() end)
					pcall(function() neotest.output_panel.close() end)
				end
			end,
			delete = nil,
		},
		post = { read = nil, write = nil, delete = nil },
	},
	-- Whether to print session path after action
	verbose = { read = false, write = true, delete = true },
})

-- Create sessions directory if it doesn't exist
local session_dir = vim.fn.stdpath("data") .. "/sessions"
if vim.fn.isdirectory(session_dir) == 0 then
	vim.fn.mkdir(session_dir, "p")
end
