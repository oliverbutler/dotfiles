-- Git plugins: gitsigns, blame, diffview

vim.pack.add({
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/FabijanZulj/blame.nvim" },
  { src = "https://github.com/sindrets/diffview.nvim" },
})

-----------------------------------------
-- Configuration
-----------------------------------------

-- Gitsigns
require("gitsigns").setup({})

-- Blame
require("blame").setup({})

-- Diffview
require("diffview").setup({})

-- Set diagonal lines in place of deleted lines in diff-mode
vim.opt.fillchars:append({ diff = "╱" })

-----------------------------------------
-- Keymaps
-----------------------------------------

-- Gitsigns keymaps
vim.keymap.set("n", "<leader>gp", function()
  require("gitsigns").preview_hunk()
end, { desc = "Preview Git Hunk" })

vim.keymap.set("n", "<leader>gi", function()
  require("gitsigns").preview_hunk_inline()
end, { desc = "Preview Git Hunk Inline" })

-- Blame keymap
vim.keymap.set("n", "<leader>gb", "<cmd>BlameToggle<CR>", { desc = "Toggle Git Blame" })

-- Diffview keymaps
vim.keymap.set("n", "<leader>hf", ":DiffviewFileHistory %<CR>", { desc = "File History" })
vim.keymap.set("n", "<leader>ha", ":DiffviewFileHistory<CR>", { desc = "History All" })
vim.keymap.set("n", "<leader>hc", ":DiffviewClose<CR>", { desc = "History Close" })
vim.keymap.set("n", "<leader>ho", ":DiffviewOpen<CR>", { desc = "History Open" })
vim.keymap.set("v", "<leader>hs", ":DiffviewFileHistory<CR>", { desc = "History Selection" })

vim.keymap.set("n", "<leader>hm", function()
  local mainOrMaster = "master"
  if vim.fn.executable("git") == 1 then
    local result = vim.fn.system("git rev-parse --verify origin/main 2>/dev/null")
    if vim.v.shell_error == 0 then
      mainOrMaster = "main"
    end
  end
  vim.cmd("DiffviewOpen origin/" .. mainOrMaster .. "...HEAD")
end, { desc = "History vs Main/Master" })

vim.keymap.set("n", "<leader>gc", function()
  local word = vim.fn.expand("<cword>")
  if not word:match("^%x+$") or word:len() < 7 or word:len() > 40 then
    vim.notify("Invalid or no Git SHA selected", vim.log.levels.ERROR)
    return
  end
  local sha_only = word .. "^!"
  local status_ok, err = pcall(vim.cmd, "DiffviewOpen " .. sha_only)
  if not status_ok then
    vim.notify("Failed to open diff for SHA: " .. word .. "\nError: " .. err, vim.log.levels.ERROR)
  end
end, { desc = "Git Preview SHA under Cursor" })
