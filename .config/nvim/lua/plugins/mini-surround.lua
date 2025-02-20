return {
  "echasnovski/mini.surround",
  event = "VeryLazy",
  opts = {
    mappings = {
      add = "sa", -- Add surrounding in Normal and Visual modes
      delete = "sd", -- Delete surrounding
      find = "sf", -- Find surrounding (to the right)
      find_left = "sF", -- Find surrounding (to the left)
      highlight = "sh", -- Highlight surrounding
      replace = "sr", -- Replace surrounding
      update_n_lines = "sn", -- Update `n_lines`

      suffix_last = "l", -- Suffix to search with "prev" method
      suffix_next = "n", -- Suffix to search with "next" method
    },
  },
  config = function(_, opts)
    -- Setup mini.surround
    require("mini.surround").setup(opts)

    -- Disable default 's' behavior
    vim.keymap.set("n", "s", "<nop>")

    -- Register which-key mappings
    require("which-key").add({
      s = {
        name = "Surround",
        a = "Add surrounding",
        d = "Delete surrounding",
        f = "Find surrounding (right)",
        F = "Find surrounding (left)",
        h = "Highlight surrounding",
        r = "Replace surrounding",
        n = "Update n_lines",
      },
    })
  end,
}
