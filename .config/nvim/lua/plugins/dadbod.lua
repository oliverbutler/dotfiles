return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    { "tpope/vim-dadbod", lazy = true },
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
  },
  cmd = {
    "DBUI",
    "DBUIToggle",
    "DBUIAddConnection",
    "DBUIFindBuffer",
  },
  config = function()
    -- Your DBUI configuration
    vim.g.db_ui_use_nerd_fonts = 1

    vim.g.dbs = {
      {
        name = "sqlitetest",
        url = "sqlite:///home/olly/Downloads/chinook.db",
      },
    }

    -- Disable folding in dbui (dadbod-ui left hand side sidebar)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "dbui",
      callback = function()
        vim.wo.foldenable = false
      end,
    })
  end,
}
