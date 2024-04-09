return {
  "jackMort/ChatGPT.nvim",
  cmd = { "ChatGPT", "ChatGPTEditWithInstructions" },
  config = function()
    require("chatgpt").setup({
      api_key_cmd = "./lua/plugins/get-openapi-key.sh",
    })
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim",
    "nvim-telescope/telescope.nvim",
  },
}
