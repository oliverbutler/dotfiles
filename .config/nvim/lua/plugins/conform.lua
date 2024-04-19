return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      log_level = vim.log.levels.DEBUG,
      formatters_by_ft = {
        javascript = { "prettierd" },
        typescript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescriptreact = { "prettierd" },
        svelte = { "prettierd" },
        css = { "prettierd" },
        html = { "prettierd" },
        json = { "prettierd" },
        yaml = { "prettierd" },
        markdown = { "prettierd" },
        graphql = { "prettierd" },
        liquid = { "prettierd" },
        lua = { "stylua" },
        python = { "isort", "black" },
        go = { "gofumpt", "gofumports" },
        sql = { "sql_formatter" },
        ["*"] = { "injected" },
      },
      format_on_save = {
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      },
    })

    conform.formatters.sql_formatter = {
      prepend_args = function(self, ctx)
        return { "-c", "/Users/olly/.config/nvim/lua/plugins/sql-formatter.json" }
      end,
    }

    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "Format file or range (in visual mode)" })
  end,
}
