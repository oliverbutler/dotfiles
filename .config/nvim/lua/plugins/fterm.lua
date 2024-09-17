return {
  "numToStr/FTerm.nvim",
  keys = {
    "<leader>tt",
    "<leader>ld",
  },
  config = function()
    local fterm = require("FTerm")

    local programs = {
      {
        cmd = nil,
        key = "<leader>tt",
      },
      {
        cmd = "lazydocker",
        key = "<leader>ld",
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
