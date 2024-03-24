return {
  "numToStr/FTerm.nvim",
  config = function()
    local fterm = require("FTerm")

    fterm.setup({
      dimensions = {
        height = 0.8,
        width = 0.8,
      },
      border = "single",
    })

    vim.keymap.set("n", "<leader>tt", function()
      require("FTerm").toggle()
    end, { noremap = true, silent = true, desc = "Toggle [T]erm" })

    local lazygitui = fterm:new({
      cmd = "lazygit",
      dimensions = {
        height = 0.9,
        width = 0.9,
      },
      border = "single",
    })

    vim.keymap.set("n", "<leader>gl", function()
      lazygitui:toggle()
    end)

    local lazy_home_git_ui = fterm:new({
      cmd = "yal",
      dimensions = {
        height = 0.9,
        width = 0.9,
      },
      border = "single",
    })

    vim.keymap.set("n", "<leader>g;", function()
      lazy_home_git_ui:toggle()
    end)

    local lazy_docker_ui = fterm:new({
      cmd = "lazydocker",
      dimensions = {
        height = 0.9,
        width = 0.9,
      },
      border = "single",
    })

    vim.keymap.set("n", "<leader>ld", function()
      lazy_docker_ui:toggle()
    end)
  end,
}
