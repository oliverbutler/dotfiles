return {
  "rcarriga/nvim-notify",
  config = function()
    require("notify").setup({
      background_colour = "#1E1E1E",
    })
  end,
}