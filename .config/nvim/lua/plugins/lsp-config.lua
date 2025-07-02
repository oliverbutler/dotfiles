return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp", "yioneko/nvim-vtsls" },
    event = "VeryLazy",
    keys = {
      {
        "<leader>i",
        function()
          vim.lsp.buf.code_action()
        end,
      },
      {
        "<leader>I",
        function()
          require("vtsls").commands.source_actions()
        end,
        desc = "[S]earch source actions",
      },
    },
    config = function()
      require("lspconfig.configs").vtsls = require("vtsls")
          .lspconfig -- set default server config, optional but recommended

      local lspconfig = require("lspconfig")

      local configs = require 'lspconfig/configs'

      if not configs.golangcilsp then
        configs.golangcilsp = {
          default_config = {
            cmd = { 'golangci-lint-langserver' },
            root_dir = lspconfig.util.root_pattern('.git', 'go.mod'),
            init_options = {
              command = { "golangci-lint", "run", "--output.json.path", "stdout", "--show-stats=false", "--issues-exit-code=1" },
            },
          }
        }
      end

      local capabilities = require("blink.cmp").get_lsp_capabilities()

      lspconfig.golangci_lint_ls.setup {
        filetypes = { 'go', 'gomod' }
      }

      lspconfig.vtsls.setup({
        capabilities = capabilities,
        settings = {
          typescript = {
            tsserver = {
              maxTsServerMemory = 8192,
            },
          },
        },
      })

      lspconfig.lua_ls.setup({
        capabilities = capabilities,
      })

      lspconfig.tailwindcss.setup({
        capabilities = capabilities,
        filetypes = {
          "html",
          "javascriptreact",
          "typescriptreact",
          "svelte",
          "vue",
          "go",
          "templ",
          "css",
        },
        init_options = { userLanguages = { templ = "html" } },
        settings = {
          tailwindCSS = {
            experimental = {
              classRegex = {
                -- Go components patterns
                "Class\\(([^)]*)\\)",
                '["`]([^"`]*)["`]',           -- Class("...") or Class(`...`)
                "Classes\\(([^)]*)\\)",
                '["`]([^"`]*)["`]',           -- Classes("...") or Classes(`...`)
                "Class\\{([^)]*)\\}",
                '["`]([^"`]*)["`]',           -- Class{"..."} or Class{`...`}
                "Classes\\{([^)]*)\\}",
                '["`]([^"`]*)["`]',           -- Classes{"..."} or Classes{`...`}
                'Class:\\s*["`]([^"`]*)["`]', -- Class: "..." or Class: `...`
                ':\\s*["`]([^"`]*)["`]',      -- Classes: "..." or Classes: `...`

                -- support class variance authority
                { "cva\\(((?:[^()]|\\([^()]*\\))*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                { "cx\\(((?:[^()]|\\([^()]*\\))*)\\)",  "(?:'|\"|`)([^']*)(?:'|\"|`)" },

                -- support classnames
                { "classnames\\(([^)]*)\\)" },
              },
            },
          },
        },
      })

      lspconfig.html.setup({
        capabilities = capabilities,
        filetypes = { "html", "templ" },
      })

      lspconfig.htmx.setup({
        capabilities = capabilities,
        filetypes = { "html", "templ" },
      })

      lspconfig.templ.setup({
        capabilities = capabilities,
      })

      lspconfig.eslint.setup({
        capabilities = capabilities,
      })

      lspconfig.terraformls.setup({
        capabilities = capabilities,
      })

      lspconfig.typos_lsp.setup({
        capabilities = capabilities,
        init_options = {
          diagnosticSeverity = "Info",
        },
      })

      lspconfig.gopls.setup({
        capabilities = capabilities,
        cmd = { "gopls" },
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        -- root_dir = lspconfig.util.root_pattern("go.mod", ".git", "go.work"),
        -- FIXME: had issues with it starting in single file modes
        root_dir = function(fname)
          return lspconfig.util.root_pattern("go.mod", ".git", "go.work")(fname) or vim.fn.getcwd()
        end,
        settings = {
          gopls = {
            completeUnimported = true,
            analyses = {
              unusedparams = true,
              unreachable = true,
              unusedvariable = true,
            },
            templateExtensions = { ".html", ".tmpl", ".js" },
            experimentalTemplateSupport = true,
          },
        },
      })

      vim.filetype.add({
        extension = {
          mdx = "mdx",
        },
      })

      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next)

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

          vim.lsp.inlay_hint.enable(true)

          vim.diagnostic.config({
            virtual_text = true,
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
            float = {
              focusable = false,
              style = "minimal",
              border = "rounded",
              header = "",
              prefix = "",
              wrap = true,
            },
          })

          vim.keymap.set("n", "<leader>o", function()
            vim.diagnostic.open_float(nil, {
              scope = "cursor",
              focusable = false,
              close_events = {
                "BufLeave",
                "CursorMoved",
                "InsertEnter",
                "FocusLost",
              },
            })
          end, { desc = "Show line diagnostics" })

          local opts = { buffer = ev.buf }

          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<C-i>", vim.lsp.buf.signature_help, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        end,
      })

      local function restart_lsp_clients()
        local active_clients = vim.lsp.get_clients()

        vim.notify("Stopping " .. #active_clients .. " LSP clients", vim.log.levels.INFO, {
          title = "Restart LSP",
          icon = "🔌",
        })

        for _, client in ipairs(active_clients) do
          vim.lsp.stop_client(client.id)
        end

        vim.defer_fn(function()
          vim.cmd("w!")
          vim.cmd("e")
        end, 100)
      end

      vim.keymap.set("n", "<leader>ra", function()
        restart_lsp_clients()
        vim.cmd("Copilot enable")
        vim.cmd("Copilot attach")
      end, { noremap = true, desc = "Restart LSP" })

      vim.keymap.set("n", "<leader>rt", function()
        vim.notify("Restarting TS Language Server", vim.log.levels.INFO, {
          title = "Restart TS Language Server",
          icon = "🔌",
        })
        require("vtsls").commands.restart_tsserver()
        vim.cmd("Copilot enable")
        vim.cmd("Copilot attach")
      end, { noremap = true, desc = "Restart TS Language Server" })
    end,
  },
}
