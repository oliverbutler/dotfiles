return {
  "numToStr/FTerm.nvim",
  config = function ()
    require("FTerm").setup({
      dimensions = {
        height = 0.8,
        width = 0.8,
      },
      border = "single",
    })

    vim.keymap.set("n", "<leader>tt", function ()
      require("FTerm").toggle()
    end, { noremap = true, silent = true, desc = "Toggle [T]erm" })

    local fterm = require("FTerm")

    fterm:new({
      ft = "lazygit",
      cmd = "lazygit",
      dimensions = {
        height = 0.8,
        width = 0.8,
      },
      border = "single",
    })

    vim.keymap.set("n", "<leader>gl", function ()
      fterm:toggle()
    end)
  end
}
