local devicons = require("nvim-web-devicons")

-- Function to get the first "symbol" from a line of text/code
-- e.g. "const foo = 1" will return "foo"
-- e.g. "function bar() {}" will return "bar"
-- e.g. "let baz = 2" will return "baz"
-- e.g. "    async function qux() {}" will return "qux"
--
-- Should work for JS/TS keywords, ignoring all preceding and trailing characters
-- If theres more than one keyword in the line e.g. "export const" it will ignore the earlier one(s)
local function get_first_symbol(input)
  -- List of keywords to ignore
  local keywords = {
    "const",
    "function",
    "let",
    "async",
    "private",
    "public",
    "protected",
    "type",
    "interface",
    "class",
    "enum",
    "export",
    "static",
    "get",
    "set",
  }

  if not input then
    return nil
  end

  -- Remove leading whitespace
  input = input:match("^%s*(.-)%s*$")

  -- Iterate through words
  for word in input:gmatch("%S+") do
    -- Check if the word is not a keyword
    if not table.concat(keywords, " "):find(word, 1, true) then
      -- Extract the identifier part (without parentheses or other characters)
      local identifier = word:match("^([%a_][%w_]*)")
      if identifier then
        return identifier
      end
    end
  end

  return nil -- Return nil if no valid symbol is found
end

local valid_search_types = {
  types = "Types",
  all = "All",
  zod = "Zod Schemas",
  classes = "Classes",
  react = "React Components",
}

-- @oliverbutler's custom search!
-- Honestly I miss webstorms incredible searching, it does turn my computer into a jet engine through
-- I figured, f it, we can easily rg for the things we care about and then display them in a nice way
-- For example, this lets you search any react component in your project and then open it in a new buffer
local function custom_symbol_search(search_type)
  assert(valid_search_types[search_type], "Invalid search type")

  local patterns = {
    all = [[\b(const|async|function|type|class|interface)\s+(\w+)]],
    types = [[\b(interface\s+(\w+)\s*\{|type\s+(\w+)\s*=)]],
    classes = [[\bclass\s+(\w+)(?:\s+(?:extends|implements)\s+\w+)?\s*\{?]],
    zod = [[const.*=\s*z\.]],
    react = [[\b(export\s+)?(const|function|class)\s+([A-Z][a-zA-Z0-9]*)\s*(?:=\s*(?:function\s*\(|React\.memo\(|React\.forwardRef\(|\()|extends\s+React\.Component|\()]],
  }

  local keyword_pattern = patterns[search_type]

  vim.notify("Starting symbol search for " .. search_type, vim.log.levels.INFO)

  local Job = require("plenary.job")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")

  local fzf_lua = require("telescope").extensions.fzf

  local function grep_symbols()
    local results = {}
    local args = {}

    table.insert(args, "--no-heading")
    table.insert(args, "--with-filename")
    table.insert(args, "--line-number")
    table.insert(args, "--column")
    table.insert(args, "--smart-case")
    if search_type == "react" then
      table.insert(args, "--glob=*.tsx")
    end
    table.insert(args, keyword_pattern)
    table.insert(args, ".")

    vim.notify("Running rg with args: " .. table.concat(args, " "), vim.log.levels.INFO)

    Job:new({
      command = "rg",
      args = args,
      on_exit = function(j, return_val)
        for _, line in ipairs(j:result()) do
          table.insert(results, line)
        end
      end,
    }):sync()
    vim.notify("Found " .. #results .. " symbols", vim.log.levels.INFO)
    return results
  end

  local symbol_results = grep_symbols()

  if #symbol_results == 0 then
    vim.notify("No symbols found", vim.log.levels.WARN)
    return
  end

  pickers
    .new({}, {
      prompt_title = "Search " .. valid_search_types[search_type],
      finder = finders.new_table({
        results = symbol_results,
        entry_maker = function(entry)
          local file, lnum, col, text = string.match(entry, "([^:]+):([^:]+):([^:]+):(.+)")

          local symbol = get_first_symbol(text)

          if not symbol then
            return nil -- Skip this entry if no symbol is found
          end

          local file_extension = string.match(file, "%.(%w+)$")

          local icon, icon_hl = devicons.get_icon(file, file_extension, { default = true })

          return {
            value = entry,
            display = icon .. "  " .. symbol .. " - " .. file .. ":" .. lnum,
            ordinal = symbol .. " " .. file,
            filename = file,
            lnum = tonumber(lnum),
            col = tonumber(col),
            icon = icon,
            icon_hl = icon_hl,
          }
        end,
      }),
      sorter = fzf_lua.native_fzf_sorter(),
      previewer = previewers.vim_buffer_vimgrep.new({}),
      layout_strategy = "horizontal",
      layout_config = {
        width = 0.8,
        height = 0.8,
        preview_width = 0.5,
      },
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          vim.notify("Opening " .. selection.filename .. " at line " .. selection.lnum, vim.log.levels.INFO)
          vim.cmd("edit " .. selection.filename)
          vim.api.nvim_win_set_cursor(0, { selection.lnum, selection.col - 1 })
        end)
        return true
      end,
    })
    :find()
end

return {
  custom_symbol_search = custom_symbol_search,
  get_first_symbol = get_first_symbol,
}
