return {
  {
    -- By default some inlay hints are super long, this truncates them!
    "ray-d-song/inlay-hint-trim.nvim",
    config = function()
      require("inlay-hint-trim").setup()
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    event = "VeryLazy",
    keys = {
      {
        "<leader>i",
        function()
          vim.lsp.buf.code_action()
        end,
      },
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Configure each LSP server using vim.lsp.config
      vim.lsp.config("golangci_lint_ls", {
        capabilities = capabilities,
        filetypes = { "go", "gomod" },
      })

      vim.lsp.config("ts_ls", {
        capabilities = capabilities,
        cmd = { "typescript-language-server", "--stdio" },
        cmd_env = {
          TSS_LOG = "-level verbose -file /tmp/tsserver.log",
        },
        init_options = {
          maxTsServerMemory = 4096,
        },
        settings = {
          -- typescript = {
          --   inlayHints = {
          --     includeInlayParameterNameHints = "all",
          --     includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          --     includeInlayFunctionParameterTypeHints = true,
          --     includeInlayVariableTypeHints = false,
          --     includeInlayPropertyDeclarationTypeHints = true,
          --     includeInlayFunctionLikeReturnTypeHints = true,
          --     includeInlayEnumMemberValueHints = true,
          --   },
          -- },
          -- javascript = {
          --   inlayHints = {
          --     includeInlayParameterNameHints = "all",
          --     includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          --     includeInlayFunctionParameterTypeHints = true,
          --     includeInlayVariableTypeHints = false,
          --     includeInlayPropertyDeclarationTypeHints = true,
          --     includeInlayFunctionLikeReturnTypeHints = true,
          --     includeInlayEnumMemberValueHints = true,
          --   },
          -- },
        },
      })

      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
      })

      vim.lsp.config("tailwindcss", {
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
                '["`]([^"`]*)["`]', -- Class("...") or Class(`...`)
                "Classes\\(([^)]*)\\)",
                '["`]([^"`]*)["`]', -- Classes("...") or Classes(`...`)
                "Class\\{([^)]*)\\}",
                '["`]([^"`]*)["`]', -- Class{"..."} or Class{`...`}
                "Classes\\{([^)]*)\\}",
                '["`]([^"`]*)["`]', -- Classes{"..."} or Classes{`...`}
                'Class:\\s*["`]([^"`]*)["`]', -- Class: "..." or Class: `...`
                ':\\s*["`]([^"`]*)["`]', -- Classes: "..." or Classes: `...`

                -- support class variance authority
                { "cva\\(((?:[^()]|\\([^()]*\\))*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                { "cx\\(((?:[^()]|\\([^()]*\\))*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },

                -- support classnames
                { "classnames\\(([^)]*)\\)" },
              },
            },
          },
        },
      })

      vim.lsp.config("html", {
        capabilities = capabilities,
        filetypes = { "html", "templ" },
      })

      vim.lsp.config("htmx", {
        capabilities = capabilities,
        filetypes = { "html", "templ" },
      })

      vim.lsp.config("templ", {
        capabilities = capabilities,
      })

      vim.lsp.config("eslint", {
        capabilities = capabilities,
      })

      vim.lsp.config("terraformls", {
        capabilities = capabilities,
      })

      vim.lsp.config("typos_lsp", {
        capabilities = capabilities,
        init_options = {
          diagnosticSeverity = "Info",
        },
      })

      vim.lsp.config("gopls", {
        capabilities = capabilities,
        cmd = { "gopls" },
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        root_dir = function(fname)
          return vim.fs.root(fname, { "go.mod", ".git", "go.work" }) or vim.fn.getcwd()
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

      -- Enable all configured servers
      vim.lsp.enable("golangci_lint_ls")
      vim.lsp.enable("ts_ls")
      vim.lsp.enable("lua_ls")
      vim.lsp.enable("tailwindcss")
      vim.lsp.enable("html")
      vim.lsp.enable("htmx")
      vim.lsp.enable("templ")
      vim.lsp.enable("eslint")
      vim.lsp.enable("terraformls")
      vim.lsp.enable("typos_lsp")
      vim.lsp.enable("gopls")

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
        pcall(function()
          vim.cmd("Copilot enable")
          vim.cmd("Copilot attach")
        end)
      end, { noremap = true, desc = "Restart LSP" })

      vim.keymap.set("n", "<leader>rt", function()
        vim.notify("Restarting TS Language Server", vim.log.levels.INFO, {
          title = "Restart TS Language Server",
          icon = "🔌",
        })
        vim.cmd("LspRestart ts_ls")
        pcall(function()
          vim.cmd("Copilot enable")
          vim.cmd("Copilot attach")
        end)
      end, { noremap = true, desc = "Restart TS Language Server" })
    end,
  },
}
