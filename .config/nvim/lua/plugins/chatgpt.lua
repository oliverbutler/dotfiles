return {
  "jackMort/ChatGPT.nvim",
  cmd = { "ChatGPT", "ChatGPTEditWithInstructions" },
  config = function()
    require("chatgpt").setup({
      api_key_cmd = 'op item get "OpenAPI" --fields credential',
    })
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim",
    "nvim-telescope/telescope.nvim",
  },
}
