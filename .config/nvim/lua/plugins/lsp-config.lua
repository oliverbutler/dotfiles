return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    event = "VeryLazy",
    config = function()
      local lspconfig = require("lspconfig")

      local capabilities = require("blink.cmp").get_lsp_capabilities()

      lspconfig.vtsls.setup({
        capabilities = capabilities,
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

      lspconfig.typos_lsp.setup({
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
          vim.keymap.set("n", "<C-i>", vim.lsp.buf.signature_help, opts)

          -- vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
          -- vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
          -- vim.keymap.set("n", "<space>wl", function()
          --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          -- end, opts)
          vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)

          vim.keymap.set("n", "gd", function()
            require("fzf-lua").lsp_definitions({
              winopts = {
                height = 0.8,
                width = 0.9,
                preview = {
                  hidden = "hidden",
                  vertical = "up:45%",
                  horizontal = "right:50%",
                  layout = "flex",
                  flip_columns = 120,
                },
              },
              jump_to_single_result = true, -- Jump directly if there's only one result
              fzf_opts = {
                ["--info"] = "inline",
                ["--layout"] = "reverse",
              },
            })
          end, opts)

          vim.keymap.set("n", "gr", function()
            require("fzf-lua").lsp_references({
              winopts = {
                height = 0.8,
                width = 0.9,
                preview = {
                  hidden = "hidden",
                  vertical = "up:45%",
                  horizontal = "right:50%",
                  layout = "flex",
                  flip_columns = 120,
                },
              },
              include_declaration = false,
              fzf_opts = {
                ["--info"] = "inline",
                ["--layout"] = "reverse",
              },
            })
          end, opts)
        end,
      })

      local function restart_lsp_clients(server_name)
        local active_clients = vim.lsp.get_clients()

        local clients_to_restart = {}

        for _, client in ipairs(active_clients) do
          if not server_name or client.name == server_name then
            table.insert(clients_to_restart, client)
          end
        end

        vim.notify("Stopping " .. #clients_to_restart .. " LSP clients", "info", {
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

        vim.cmd("Copilot attach")
      end

      vim.keymap.set("n", "<leader>ra", function()
        restart_lsp_clients()
        vim.cmd("Copilot enable")
      end, { noremap = true, desc = "Restart LSP" })

      vim.keymap.set("n", "<leader>rt", function()
        restart_lsp_clients("typescript-tools")
        vim.cmd("Copilot enable")
      end, { noremap = true, desc = "Restart LSP" })
    end,
  },
}
