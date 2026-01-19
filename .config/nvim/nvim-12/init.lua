------------------------------
-- Olly's nvim 0.12 config 2026
------------------------------

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.maplocalleader = "," -- Same for `maplocalleader`

vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50" -- Use vertical line cursor in insert mode

vim.opt.signcolumn = "yes:1" -- Always show sign column
vim.opt.termguicolors = true -- Enable true colors
vim.opt.ignorecase = true -- Ignore case in search
vim.opt.swapfile = false -- Disable swap files
vim.opt.autoindent = true -- Enable auto indentation
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.tabstop = 4 -- Number of spaces for a tab
vim.opt.softtabstop = 4 -- Number of spaces for a tab when editing
vim.opt.shiftwidth = 4 -- Number of spaces for autoindent
vim.opt.shiftround = true -- Round indent to multiple of shiftwidth
vim.opt.listchars = "tab: ,multispace:|   " -- Characters to show for tabs, spaces, and end of line
vim.opt.list = true -- Show whitespace characters
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.numberwidth = 2 -- Width of the line number column
vim.opt.wrap = false -- Disable line wrapping
vim.opt.cursorline = true -- Highlight the current line
vim.opt.scrolloff = 8 -- Keep 8 lines above and below the cursor
vim.opt.inccommand = "nosplit" -- Shows the effects of a command incrementally in the buffer
vim.opt.undodir = os.getenv('HOME') .. '/.vim/undodir' -- Directory for undo files
vim.opt.undofile = true -- Enable persistent undo
vim.opt.completeopt = { "menuone", "popup", "noinsert" } -- Options for completion menu
vim.opt.winborder = "rounded" -- Use rounded borders for windows
vim.opt.hlsearch = false -- Disable highlighting of search results
vim.opt.clipboard = { "unnamedplus" } -- Sync clipboard with system
vim.opt.scrolloff = 25 -- Minimal number of screen lines to keep above and below the cursor.
vim.opt.shortmess:append("F") -- Don't show file info when editing

require("keymaps")

require("plugins.blink")
require("plugins.catppuccin")
require("plugins.flash")
require("plugins.git")
require("plugins.lazydev")
require("plugins.lualine")
require("plugins.mason")
require("plugins.mini-files")
require("plugins.mini-icons")
require("plugins.noice")
require("plugins.snacks")
require("plugins.treesitter")
require("plugins.ufo")
require("plugins.whichkey")

require("lsp")
require("autocmds")
