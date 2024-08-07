return {
  {
    "pmizio/typescript-tools.nvim",
    ft = { "typescript", "typescriptreact" },
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("typescript-tools").setup({
        on_attach = function() end,
        handlers = {},
        root_dir = function()
          return vim.fn.getcwd()
        end,
        settings = {
          -- spawn additional tsserver instance to calculate diagnostics on it
          separate_diagnostic_server = true, -- testing
          -- "change"|"insert_leave" determine when the client asks the server about diagnostic
          publish_diagnostic_on = "insert_leave",
          -- array of strings("fix_all"|"add_missing_imports"|"remove_unused"|
          -- "remove_unused_imports"|"organize_imports") -- or string "all"
          -- to include all supported code actions
          -- specify commands exposed as code_actions
          expose_as_code_action = "all",
          -- string|nil - specify a custom path to `tsserver.js` file, if this is nil or file under path
          -- not exists then standard path resolution strategy is applied
          tsserver_path = nil,
          -- specify a list of plugins to load by tsserver, e.g., for support `styled-components`
          -- (see 💅 `styled-components` support section)
          tsserver_plugins = {},
          -- this value is passed to: https://nodejs.org/api/cli.html#--max-old-space-sizesize-in-megabytes
          -- memory limit in megabytes or "auto"(basically no limit)
          tsserver_max_memory = "auto",
          -- described below
          tsserver_format_options = {},
          -- locale of all tsserver messages, supported locales you can find here:
          -- https://github.com/microsoft/TypeScript/blob/3c221fc086be52b19801f6e8d82596d04607ede6/src/compiler/utilitiesPublic.ts#L620
          tsserver_locale = "en",
          -- mirror of VSCode's `typescript.suggest.completeFunctionCalls`
          complete_function_calls = false,
          include_completions_with_insert_text = true,
          -- CodeLens
          -- WARNING: Experimental feature also in VSCode, because it might hit performance of server.
          -- possible values: ("off"|"all"|"implementations_only"|"references_only")
          code_lens = "off",
          -- by default code lenses are displayed on all referencable values and for some of you it can
          -- be too much this option reduce count of them by removing member references from lenses
          disable_member_code_lens = true,
          -- JSXCloseTag
          -- WARNING: it is disabled by default (maybe you configuration or distro already uses nvim-ts-autotag,
          -- that maybe have a conflict if enable this feature. )
          jsx_close_tag = {
            enable = true,
            filetypes = { "javascriptreact", "typescriptreact" },
          },
          tsserver_file_preferences = {
            includeInlayParameterNameHints = "all",
            includeInlayEnumMemberValueHints = true,
            includeInlayFunctionLikeReturnTypeHints = false,
            includeInlayFunctionParameterTypeHints = false,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayVariableTypeHints = false,
          },
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    config = function()
      local lspconfig = require("lspconfig")

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

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
        }, -- Added "go" here
        init_options = { userLanguages = { templ = "html" } },
        settings = {
          tailwindCSS = {
            experimental = {
              -- Support gocomponents
              classRegex = {
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
          },
        },
      })

      vim.filetype.add({
        extension = {
          mdx = "mdx",
        },
      })

      -- local ft_to_parser = require("nvim-treesitter.parsers").filetype_to_parsername
      -- ft_to_parser.mdx = "markdown"
      -- FIXME: This started breaking so i disabled it :)

      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next)

      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
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
            severity_sort = false,
            float = {
              focusable = false,
              style = "minimal",
              border = "rounded",
              source = "always",
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

          vim.keymap.set("n", "<leader>i", vim.lsp.buf.code_action, { buffer = ev.buf, desc = "Code action" })

          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
          -- vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
          -- vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
          -- vim.keymap.set("n", "<space>wl", function()
          --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          -- end, opts)
          vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)

          vim.keymap.set("n", "gd", function()
            require("telescope.builtin").lsp_definitions({
              show_line = false,
              trim_text = true,
              layout_strategy = "horizontal",
              layout_config = {
                width = 0.6,
                height = 0.8,
                preview_cutoff = 1,
                prompt_position = "top",
              },
            })
          end, opts)

          vim.keymap.set("n", "gr", function()
            require("telescope.builtin").lsp_references({
              show_line = false,
              trim_text = true,
              include_declaration = false,
              layout_strategy = "horizontal",
              layout_config = {
                width = 0.6,
                height = 0.8,
                preview_cutoff = 1,
                prompt_position = "top",
              },
            })
          end, opts)
        end,
      })
    end,
  },
}
