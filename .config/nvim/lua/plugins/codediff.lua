-- Codediff.nvim - VSCode-style side-by-side diff viewer

vim.pack.add({
  { src = "https://github.com/esmuellert/codediff.nvim" },
  { src = "https://github.com/MunifTanjim/nui.nvim" },
})

-----------------------------------------
-- Configuration
-----------------------------------------

require("codediff").setup({})

-- Set diagonal lines in place of deleted lines in diff-mode
vim.opt.fillchars:append({ diff = "╱" })

-----------------------------------------
-- Keymaps
-----------------------------------------

-- Explorer mode (git status overview)
vim.keymap.set("n", "<leader>ho", "<cmd>CodeDiff<CR>", { desc = "Diff Open (Explorer)" })

-- File diff against HEAD
vim.keymap.set("n", "<leader>hf", "<cmd>CodeDiff file HEAD<CR>", { desc = "Diff File vs HEAD" })

-- File history (commit log)
vim.keymap.set("n", "<leader>ha", "<cmd>CodeDiff history<CR>", { desc = "Diff History All" })

-- File history for current file
vim.keymap.set("n", "<leader>hs", "<cmd>CodeDiff history HEAD~50 %<CR>", { desc = "Diff History Current File" })

-- PR-like diff against main/master
vim.keymap.set("n", "<leader>hm", function()
  local mainOrMaster = "master"
  if vim.fn.executable("git") == 1 then
    local result = vim.fn.system("git rev-parse --verify origin/main 2>/dev/null")
    if vim.v.shell_error == 0 then
      mainOrMaster = "main"
    end
  end
  vim.cmd("CodeDiff origin/" .. mainOrMaster .. "...")
end, { desc = "Diff vs Main/Master (PR)" })

-- Preview SHA under cursor
vim.keymap.set("n", "<leader>gc", function()
  local word = vim.fn.expand("<cword>")
  if not word:match("^%x+$") or word:len() < 7 or word:len() > 40 then
    vim.notify("Invalid or no Git SHA selected", vim.log.levels.ERROR)
    return
  end
  vim.cmd("CodeDiff " .. word)
end, { desc = "Diff SHA under Cursor" })
