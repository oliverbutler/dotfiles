return {
	{
		'hrsh7th/cmp-nvim-lsp'
	},
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		dependencies = {
			'saadparwaiz1/cmp_luasnip',
			"rafamadriz/friendly-snippets"
		}
	},
	{

		'hrsh7th/nvim-cmp',
		config = function()
			local cmp = require('cmp')

			require("luasnip.loaders.from_vscode").lazy_load()


			cmp.setup({
				snippet = {
					expand = function(args)


						local ls = require('luasnip')

						ls.lsp_expand(args.body)

						local s = ls.snippet
						local i = ls.insert_node
						local f = ls.function_node
						local fmt = require("luasnip.extras.fmt").fmt

						-- Function to convert file name to PascalCase
						local function to_pascal_case(file_name)
							local parts = vim.split(file_name, "[-.]")
							local pascal_case_parts = {}

							for _, part in ipairs(parts) do
								if part ~= "ts" then
									table.insert(pascal_case_parts, vim.fn.substitute(part, "^.", string.upper, ""))
								end
							end

							return table.concat(pascal_case_parts, "")
						end


						ls.add_snippets("typescript", {
							s("exportclass", fmt(
							[[
							export class {} {{
								constructor() {{}}
							}}
							]],
							{
								f(function(_, snip)
									return to_pascal_case(vim.fn.expand("%:t"))
								end, {}),
							}
							)),
						})

					end,
				},
				window = {
					-- completion = cmp.config.window.bordered(),
					-- documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					['<C-b>'] = cmp.mapping.scroll_docs(-4),
					['<C-f>'] = cmp.mapping.scroll_docs(4),
					['<C-Space>'] = cmp.mapping.complete(),
					['<C-e>'] = cmp.mapping.abort(),
					['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				}),
				sources = cmp.config.sources({
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' }, -- For luasnip users.
				}, {
					{ name = 'buffer' },
				})
			})
		end
	}
}
