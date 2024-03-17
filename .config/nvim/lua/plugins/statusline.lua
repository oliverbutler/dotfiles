return {
	'nvim-lualine/lualine.nvim',
	dependencies = { 'nvim-tree/nvim-web-devicons' },
	config =  function()

		local function lsp_references_loading()
			if vim.fn.exists('*telescope#state') == 1 and telescope.state.get_status() then
				return 'Loading references...'
			end
			return ''
		end

		require("lualine").setup({
			theme = "catppuccin",
			sections = {
				lualine_c = {
					lsp_references_loading,
				}
			}
		})
	end
}
