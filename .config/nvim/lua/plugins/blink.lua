-- Blink.cmp completion plugin

vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp" },
  { src = "https://github.com/rafamadriz/friendly-snippets" },
  { src = "https://github.com/L3MON4D3/LuaSnip" },
})

-----------------------------------------
-- Configuration
----------------------------------------

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
  fuzzy = {
    implementation = "lua",
  },
  completion = {
    list = {
      selection = {
        preselect = true,
      },
    },
    ghost_text = { enabled = false }, -- Disable to avoid conflict with copilot
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
      "lazydev",
      "lsp",
      "snippets",
      "path",
    },
    per_filetype = {
      sql = { "snippets", "dadbod", "buffer" },
    },
    providers = {
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

-----------------------------------------
-- LuaSnip Snippets
-----------------------------------------

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

  -- BmoError snippet with auto-detected function name
  s(
    "ber",
    fmt(
      [[
throw new BmoError('{} > {}', {{
  data: {{
    {}
  }}
}})
]],
      {
        f(function()
          -- Get the current buffer content
          local bufnr = vim.api.nvim_get_current_buf()
          local cursor = vim.api.nvim_win_get_cursor(0)
          local current_line = cursor[1]

          -- Search backwards for function/method name
          for line_num = current_line - 1, math.max(1, current_line - 50), -1 do
            local line = vim.api.nvim_buf_get_lines(bufnr, line_num - 1, line_num, false)[1]
            if line then
              -- Match async method names like: async methodName(
              local method_match = line:match("async%s+(%w+)%s*%(")
              if method_match then
                return method_match
              end

              -- Match regular method names like: methodName(
              method_match = line:match("^%s*(%w+)%s*%(")
              if method_match and method_match ~= "if" and method_match ~= "for" and method_match ~= "while" then
                return method_match
              end

              -- Match arrow functions assigned to variables: const name = async (
              local arrow_match = line:match("const%s+(%w+)%s*=%s*async")
              if arrow_match then
                return arrow_match
              end
            end
          end

          return "unknownFunction"
        end, {}),
        i(1, "error description"),
        i(2),
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

  -- NestJS integration test boilerplate
  s(
    "integration",
    fmt(
      [[
import {{ Test, TestingModule }} from '@nestjs/testing';
import {{ INestApplication }} from '@nestjs/common';
import {{ {} }} from './{}';
import {{ {} }} from './{}';

describe('{}', () => {{
  let app: INestApplication;
  let moduleRef: TestingModule;
  let {}: {};

  beforeAll(async () => {{
    moduleRef = await Test.createTestingModule({{
      imports: [{}],
    }}).compile();

    app = moduleRef.createNestApplication();
    await app.init();

    {} = moduleRef.get({});
  }});

  beforeEach(() => {{}});

  afterAll(async () => {{
    await app.close();
  }});

  describe('{}', () => {{
    {}
  }});
}});
]],
      {
        -- Module name (PascalCase)
        f(function(_, snip)
          local dir = vim.fn.expand("%:p:h")
          local module_file = vim.fn.glob(dir .. "/*.module.ts")
          if module_file ~= "" then
            local basename = vim.fn.fnamemodify(module_file, ":t:r")
            return to_pascal_case(basename)
          end
          return "MyModule"
        end, {}),
        -- Module file path (without .ts extension)
        f(function(_, snip)
          local dir = vim.fn.expand("%:p:h")
          local module_file = vim.fn.glob(dir .. "/*.module.ts")
          if module_file ~= "" then
            return vim.fn.fnamemodify(module_file, ":t:r")
          end
          return "my.module"
        end, {}),
        -- Service name (PascalCase)
        f(function(_, snip)
          return to_pascal_case(vim.fn.expand("%:t:r:r"))
        end, {}),
        -- Service file path (without .ts extension)
        f(function(_, snip)
          local current_file = vim.fn.expand("%:t")
          return current_file:gsub("%.spec%.ts$", "")
        end, {}),
        -- describe block name (uses service name)
        f(function(_, snip)
          return to_pascal_case(vim.fn.expand("%:t:r:r"))
        end, {}),
        -- service variable name (camelCase)
        f(function(_, snip)
          local pascal = to_pascal_case(vim.fn.expand("%:t:r:r"))
          return pascal:gsub("^%u", string.lower)
        end, {}),
        -- Service type (PascalCase)
        f(function(_, snip)
          return to_pascal_case(vim.fn.expand("%:t:r:r"))
        end, {}),
        -- Module name in imports array
        f(function(_, snip)
          local dir = vim.fn.expand("%:p:h")
          local module_file = vim.fn.glob(dir .. "/*.module.ts")
          if module_file ~= "" then
            local basename = vim.fn.fnamemodify(module_file, ":t:r")
            return to_pascal_case(basename)
          end
          return "MyModule"
        end, {}),
        -- service variable assignment
        f(function(_, snip)
          local pascal = to_pascal_case(vim.fn.expand("%:t:r:r"))
          return pascal:gsub("^%u", string.lower)
        end, {}),
        -- Service type in moduleRef.get()
        f(function(_, snip)
          return to_pascal_case(vim.fn.expand("%:t:r:r"))
        end, {}),
        i(1, ""),
        i(0),
      }
    )
  ),
})

require("blink.cmp").setup(opts)
