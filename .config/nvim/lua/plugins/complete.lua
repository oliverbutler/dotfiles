return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    {
      "hrsh7th/cmp-nvim-lsp",
    },
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      dependencies = {
        "saadparwaiz1/cmp_luasnip",
        "rafamadriz/friendly-snippets",
      },
    },
    {
      "onsails/lspkind-nvim",
    },
  },
  config = function()
    local cmp = require("cmp")
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Open up complete menu to prompt for imports
    vim.api.nvim_set_keymap("i", "<C-x>", '<Cmd>lua require("cmp").complete()<CR>', { noremap = true, silent = true })

    local function to_pascal_case(file_name)
      local parts = vim.split(file_name, "[-.]")
      local pascal_case_parts = {}

      for _, part in ipairs(parts) do
        if part ~= "ts" then
          local part_cased = part:gsub("^%l", string.upper)
          table.insert(pascal_case_parts, part_cased)
        end
      end
      local pascal_name = table.concat(pascal_case_parts, "")
      return pascal_name
    end

    -- Add the snippet
    local ls = require("luasnip")
    local s = ls.snippet
    local f = ls.function_node
    local i = ls.insert_node
    local t = ls.text_node
    local fmt = require("luasnip.extras.fmt").fmt
    local rep = require("luasnip.extras").rep

    ls.add_snippets("typescript", {
      s(
        "inject",
        fmt(
          [[
				import {{ Injectable }} from '@nestjs/common';

				@Injectable()
				export class {} {{
					constructor() {{}}
				}}
				]],
          {
            f(function(_, snip)
              return to_pascal_case(vim.fn.expand("%:t"))
            end, {}),
          }
        )
      ),
    })

    ls.add_snippets("typescript", {
      s(
        "controller",
        fmt(
          [[
				import {{ Controller }} from '@nestjs/common';
				import {{TsRestHandler, tsRestHandler}} from "@ts-rest/nest";

				@Controller()
				export class {} {{
					constructor() {{}}

					@TsRestHandler({})
					async handler() {{
						return tsRestHandler({}, {{

						}})
					}}
				}}
				]],
          {
            f(function(_, snip)
              return to_pascal_case(vim.fn.expand("%:t:r"))
            end, {}),
            i(1, "contract"), -- First insertion, user types here
            rep(1), -- Repeat the value entered in the first insertion
          }
        )
      ),
    })

    cmp.setup({
      snippet = {
        expand = function(args)
          local ls = require("luasnip")
          ls.lsp_expand(args.body)
        end,
      },
      window = {
        completion = {
          winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
          col_offset = -3,
          side_padding = 0,
        },
      },
      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
          local kind = require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)
          local strings = vim.split(kind.kind, "%s", { trimempty = true })
          kind.kind = " " .. (strings[1] or "") .. " "
          kind.menu = "    (" .. (strings[2] or "") .. ")"

          return kind
        end,
      },
      mapping = cmp.mapping({
        ["<C-g>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-o>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<C-n>"] = {
          i = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        },
        ["<C-p>"] = {
          i = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        },
        ["<CR>"] = cmp.mapping.confirm({ cmp.ConfirmBehavior.Replace, select = true }),
        ["<TAB>"] = cmp.mapping.select_next_item(),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" }, -- For luasnip users.
      }, {
        { name = "buffer" },
      }),
    })
  end,
}
