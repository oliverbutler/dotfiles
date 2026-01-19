# nvim-12 Coding Guidelines

This is a Neovim 0.12 configuration. Follow these patterns when writing or modifying code.

## Plugin Structure

Use `vim.pack.add` for plugin management (NOT lazy.nvim return tables):

```lua
-- Plugin installation
vim.pack.add({
	{ src = "https://github.com/author/plugin.nvim" },
	{ src = "https://github.com/author/dependency.nvim" },
})

-- Plugin configuration (called directly, not in a config function)
require("plugin").setup({
	-- options
})
```

## File Organization

```
nvim-12/
├── init.lua              # Entry point, vim options, requires plugins
├── agents.md             # This file
├── lua/
│   ├── keymaps.lua       # Global keymaps
│   ├── autocmds.lua      # Autocommands
│   ├── lsp.lua           # LSP configuration
│   ├── plugins/          # Plugin configs (one per file)
│   │   ├── blink.lua
│   │   ├── conform.lua
│   │   └── ...
│   └── lsp/              # Individual LSP server configs
│       ├── lua_ls.lua
│       └── ...
```

## Code Style

- Use tabs for indentation in Lua files
- Add section headers with dashed separators:
  ```lua
  -----------------------------------------
  -- Section Name
  -----------------------------------------
  ```
- Keep keymaps at the bottom of plugin files
- Use descriptive `desc` for all keymaps
- Leader key is space (`<leader>`)

## Adding a New Plugin

1. Create `lua/plugins/pluginname.lua`
2. Add `vim.pack.add({ { src = "..." } })`
3. Call `require("plugin").setup({ ... })`
4. Add keymaps at the bottom
5. Add `require("plugins.pluginname")` to `init.lua`

## Example Plugin File

```lua
-- Plugin description

vim.pack.add({
	{ src = "https://github.com/author/plugin.nvim" },
})

require("plugin").setup({
	option = true,
})

-----------------------------------------
-- Keymaps
-----------------------------------------

vim.keymap.set("n", "<leader>xx", function()
	require("plugin").action()
end, { desc = "Plugin Action" })
```
