return {
  "codethread/qmk.nvim",
  ft = "c",
  config = function()
    ---@type qmk.UserConfig
    local conf = {
      name = "LAYOUT",
      layout = {
        "x x x x x x _ _ _ x x x x x x",
        "x x x x x x _ _ _ x x x x x x",
        "x x x x x x _ _ _ x x x x x x",
        "x x x x x x x _ x x x x x x x",
        "_ _ x x x x x _ x x x x x _ _",
      },
    }
    require("qmk").setup(conf)

    -- Create autocmd for keymap.c files
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "keymap.c",
      callback = function()
        vim.cmd("QMKFormat")
      end,
    })
  end,
}
