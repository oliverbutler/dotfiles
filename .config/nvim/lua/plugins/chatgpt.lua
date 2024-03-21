return {
	"jackMort/ChatGPT.nvim",
	cmd = { "ChatGPT" },
	config = function()
		require("chatgpt").setup({
			api_key_cmd = "echo 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",
		})
	end,
	dependencies = {
		"MunifTanjim/nui.nvim",
		"nvim-lua/plenary.nvim",
		"folke/trouble.nvim",
		"nvim-telescope/telescope.nvim",
	},
}
