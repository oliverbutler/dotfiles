-- OpenCode integration

vim.pack.add({
	{ src = "https://github.com/NickvanDyke/opencode.nvim" },
})

---@type opencode.Opts
vim.g.opencode_opts = {
	provider = {
		enabled = "tmux",
	},
}

-- Required for `opts.events.reload`.
vim.o.autoread = true

-----------------------------------------
-- Keymaps
-----------------------------------------

vim.keymap.set("n", "<leader>oa", function()
	require("opencode").ask("@this: ", { submit = true })
end, { desc = "Execute opencode action on text object 'this'" })

vim.keymap.set("n", "<leader>os", function()
	require("opencode").select()
end, { desc = "Execute opencode action…" })

vim.keymap.set({ "n", "x" }, "go", function()
	return require("opencode").operator("@this ")
end, { expr = true, desc = "Add range to opencode" })

vim.keymap.set("n", "goo", function()
	return require("opencode").operator("@this ") .. "_"
end, { expr = true, desc = "Add line to opencode" })
