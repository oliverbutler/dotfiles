return {
  {
    "saghen/blink.cmp",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "Kaiser-Yang/blink-cmp-avante",
      { "L3MON4D3/LuaSnip", version = "v2.*" },
    },
    version = "*",
    config = function()
      --- @type blink.cmp.Config
      local opts = {
        keymap = {
          ["<C-x>"] = { "show", "show_documentation", "hide_documentation" },
          ["<C-y>"] = { "select_and_accept" },
          ["<C-e>"] = { "select_and_accept" }, -- easier for laptop

          ["<Up>"] = { "select_prev", "fallback" },
          ["<Down>"] = { "select_next", "fallback" },
          ["<S-Tab>"] = { "select_prev", "fallback" },
          ["<Tab>"] = { "select_next", "fallback" },
          ["<C-p>"] = { "select_prev", "fallback" },
          ["<C-n>"] = { "select_next", "fallback" },

          ["<C-b>"] = { "scroll_documentation_up", "fallback" },
          ["<C-f>"] = { "scroll_documentation_down", "fallback" },

          ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
        },
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = "mono",
        },
        completion = {
          list = {
            selection = {
              preselect = true,
            },
          },
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
          },
          menu = {
            draw = {
              components = {
                kind_icon = {
                  ellipsis = false,
                  text = function(ctx)
                    local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                    return kind_icon
                  end,
                  -- Optionally, you may also use the highlights from mini.icons
                  highlight = function(ctx)
                    local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                    return hl
                  end,
                },
              },
            },
          },
        },

        snippets = { preset = "luasnip" },

        sources = {
          default = {
            "avante",
            "lazydev",
            "lsp",
            "snippets",
            "path",
          },
          per_filetype = {
            sql = { "snippets", "dadbod", "buffer" },
          },
          providers = {
            dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
            avante = {
              module = "blink-cmp-avante",
              name = "Avante",
              opts = {
                -- options for blink-cmp-avante
              },
            },
            lsp = {
              name = "LSP",
              module = "blink.cmp.sources.lsp",
            },
            lazydev = {
              name = "LazyDev",
              module = "lazydev.integrations.blink",
              -- make lazydev completions top priority (see `:h blink.cmp`)
              score_offset = 100,
            },
          },
        },
      }

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

      ls.add_snippets("typescript", {
        -- Arrow function snippet
        s(
          "cb",
          fmt(
            [[
  () => {{
    {}
  }}
  ]],
            {
              i(1),
            }
          )
        ),

        s(
          "acb",
          fmt(
            [[
  async () => {{
    {}
  }}
  ]],
            {
              i(1),
            }
          )
        ),

        -- Async it block snippet
        s(
          "tit",
          fmt(
            [[
  it('{}', async () => {{
    {}
  }});
  ]],
            {
              i(1, "test description"),
              i(2),
            }
          )
        ),

        -- Describe block snippet
        s(
          "tde",
          fmt(
            [[
  describe('{}', () => {{
    {}
  }});
  ]],
            {
              i(1, "test suite description"),
              i(2),
            }
          )
        ),
      })

      require("blink.cmp").setup(opts)
    end,
  },
}
