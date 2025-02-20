return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
    "nvim-treesitter/nvim-treesitter-textobjects",
    "nvim-treesitter/nvim-treesitter-context",
    "vrischmann/tree-sitter-templ",
  },
  config = function()
    vim.opt.runtimepath:append("~/.config/nvim/queries")

    local treesitter = require("nvim-treesitter.configs")

    treesitter.setup({
      modules = {},
      sync_install = true,
      auto_install = true,
      ignore_install = {},
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      injections = {
        enable = true,
        disable = {}, -- disable specific languages if needed
      },
      -- Configure parser settings
      parser_config = {
        javascript = {
          template_string = true, -- Enable template string parsing
        },
      },
      autotag = {
        enable = true,
        enable_rename = true,
        enable_close = true,
        enable_close_on_slash = true,
        filetypes = { "html", "xml" },
      },
      context = {
        enable = true,
        max_lines = 2,
      },
      ensure_installed = {
        "json",
        "javascript",
        "typescript",
        "tsx",
        "yaml",
        "html",
        "css",
        "prisma",
        "markdown",
        "markdown_inline",
        "svelte",
        "graphql",
        "bash",
        "lua",
        "vim",
        "dockerfile",
        "gitignore",
        "query",
        "vimdoc",
        "c",
        "dart",
        "go",
        "templ",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    })

    vim.treesitter.language.register("markdown", "mdx")
  end,
}
