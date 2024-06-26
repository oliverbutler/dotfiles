return {
  "numToStr/FTerm.nvim",
  keys = {
    "<leader>tt",
    "<leader>gl",
    "<leader>ld",
    "<leader>gs",
    "<leader>gd",
  },
  config = function()
    local fterm = require("FTerm")

    local programs = {
      {
        cmd = nil,
        key = "<leader>tt",
      },
      {
        cmd = "lazygit",
        key = "<leader>gl",
      },
      {
        cmd = "lazydocker",
        key = "<leader>ld",
      },
      {
        cmd = "~/projects/gosuite/gosuite",
        key = "<leader>gs",
      },
      {
        cmd = "cd ~/projects/gosuite && go run main.go",
        key = "<leader>gd",
      },
    }

    for _, program in ipairs(programs) do
      local fterm_instance = fterm:new({
        cmd = program.cmd,
        dimensions = {
          height = 0.9,
          width = 0.9,
        },
        border = "single",
      })

      vim.keymap.set("n", program.key, function()
        fterm_instance:toggle()
      end)
    end
  end,
}
