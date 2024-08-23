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
  functions = "Functions",
}

-- Used to filter down the codebase using rg to just these lines, cuts out a lot of noise + optimizes search
local ripgrep_line_patterns = {
  all = {
    [[\b(const|static|async|function|type|class|interface)\s+(\w+)]],
  },
  types = {
    [[\b(interface\s+(\w+)\s*\{|type\s+(\w+)\s*=)]],
  },
  classes = {
    [[\bclass\s+(\w+)(?:\s+(?:extends|implements)\s+\w+)?\s*\{?]],
  },
  zod = {
    [[const.*=\s*z\.]],
  },
  react = {
    [[\b(export\s+)?(const|let|var|function|class)\s+([A-Z][a-zA-Z0-9]*)\s*(?:=\s*(?:function\s*\(|(?:React\.)?memo\(|(?:React\.)?forwardRef(?:<[^>]+>)?\(|\()|extends\s+React\.Component|\(|:)]],
  },
  functions = {
    [[\b(async\s+)?function(\s*\*)?(\s+\w+)?\s*\(]], -- Matches standard and generator functions
    [[\b(const|let|var)\s+(\w+)\s*=\s*(async\s+)?\(?\s*(\(|=>)]], -- Matches arrow function declarations
    [[\b(static\s+)?(async\s+)?(\*\s*)?(\w+\s*\(|get\s+\w+\s*\(|set\s+\w+\s*\()]], -- Matches class methods, getters, and setters
  },
}

local function run_ripgrep(pattern, directory)
  local Job = require("plenary.job")
  local results = {}

  local start_time = vim.loop.hrtime()

  Job:new({
    command = "rg",
    args = {
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      pattern,
      directory or ".",
    },
    on_exit = function(j, return_val)
      for _, line in ipairs(j:result()) do
        table.insert(results, line)
      end

      local end_time = vim.loop.hrtime()
      local duration_ms = (end_time - start_time) / 1e6

      vim.notify(
        string.format("Found %d results for pattern '%s' in %.2f ms", #results, pattern, duration_ms),
        vim.log.levels.INFO
      )
    end,
  }):sync()

  return results
end

local function remove_duplicates(results)
  local seen = {}
  local unique_results = {}

  for _, result in ipairs(results) do
    if not seen[result] then
      seen[result] = true
      table.insert(unique_results, result)
    end
  end

  return unique_results
end

-- Emulates the "Search symbols" feature in VSCode/WebStorm but with much more control
local function custom_symbol_search(params)
  local search_type = params.type
  local include_file_name_in_search = params.also_search_file_name

  assert(valid_search_types[search_type], "Invalid search type")

  local patterns = ripgrep_line_patterns[search_type]

  local raw_results = {}

  for _, pattern in ipairs(patterns) do
    local results = run_ripgrep(pattern, params.directory)
    for _, result in ipairs(results) do
      table.insert(raw_results, result)
    end
  end

  local symbol_results = remove_duplicates(raw_results)

  if #symbol_results == 0 then
    vim.notify("No symbols found", vim.log.levels.WARN)
    return
  end

  local title = string.format(
    "Search %s symbols %s",
    valid_search_types[search_type],
    include_file_name_in_search and " (include file name)" or ""
  )

  local Job = require("plenary.job")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")

  local fzf_lua = require("telescope").extensions.fzf

  pickers
    .new({}, {
      prompt_title = title,
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
            ordinal = include_file_name_in_search and symbol .. "" .. file or symbol,
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
  ripgrep_line_patterns = ripgrep_line_patterns,
}
