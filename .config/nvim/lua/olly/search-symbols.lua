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

-- Search types per filetype
local valid_search_types = {
  typescript = {
    types = "Types",
    all = "All",
    zod = "Zod Schemas",
    classes = "Classes",
    react = "React Components",
  },
  javascript = {
    types = "Types",
    all = "All",
    zod = "Zod Schemas",
    classes = "Classes",
    react = "React Components",
  },
  go = {
    all = "All",
  },
}

-- Used to filter down the codebase using rg to just these lines, cuts out a lot of noise + optimizes search
local ripgrep_line_patterns = {
  typescript = {
    all = {
      -- Matches declarations of constants, static members, async functions, regular functions, types, classes, and interfaces
      [[\b(const|static|async|function|type|class|interface)\s+(\w+)]],
    },
    types = {
      -- Matches interface and type declarations
      -- Examples: "interface MyInterface {" or "type MyType ="
      [[\b(interface\s+(\w+)\s*\{|type\s+(\w+)\s*=)]],
    },
    classes = {
      -- Matches class declarations, including those with extends or implements
      -- Example: "class MyClass extends BaseClass {"
      [[\bclass\s+(\w+)(?:\s+(?:extends|implements)\s+\w+)?\s*\{?]],
    },
    zod = {
      -- Matches Zod schema declarations
      -- Example: "const mySchema = z."
      [[const.*=\s*z\.]],
    },
    react = {
      -- Matches React component declarations
      -- Covers functional components, class components, and components wrapped in higher-order functions
      -- Examples: "const MyComponent = (" or "class MyComponent extends React.Component"
      [[\b(export\s+)?(const|let|var|function|class)\s+([A-Z][a-zA-Z0-9]*)\s*(?:=\s*(?:function\s*\(|(?:React\.)?memo\(|(?:React\.)?forwardRef(?:<[^>]+>)?\(|\()|extends\s+React\.Component|\(|:)]],
    },
  },
  go = {
    all = {
      -- Match Go functions, methods, types, and structs
      [[\b(func\s+(\w+)|func\s+\([^)]+\)\s+(\w+)|type\s+(\w+)\s+struct|type\s+(\w+)\s+interface|type\s+(\w+)\s+)]],
    },
  },
}

-- JavaScript uses the same patterns as TypeScript
ripgrep_line_patterns.javascript = ripgrep_line_patterns.typescript

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

  -- Detect current filetype
  local current_filetype = vim.bo.filetype
  -- Default to typescript if filetype not supported
  local filetype = valid_search_types[current_filetype] and current_filetype or "typescript"

  -- Validate search type for the current filetype
  assert(
    valid_search_types[filetype] and valid_search_types[filetype][search_type],
    string.format("Invalid search type '%s' for filetype '%s'", search_type, filetype)
  )

  -- Get patterns for current filetype
  local patterns = ripgrep_line_patterns[filetype][search_type]

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
    "Search %s symbols %s in %s",
    valid_search_types[filetype][search_type],
    include_file_name_in_search and " (include file name)" or "",
    filetype
  )

  local fzf = require("fzf-lua")
  local formatted_results = {}
  local entries = {}

  for _, entry in ipairs(symbol_results) do
    local file, lnum, col, text = string.match(entry, "([^:]+):([^:]+):([^:]+):(.+)")
    local symbol = get_first_symbol(text)

    if symbol then
      local file_extension = string.match(file, "%.(%w+)$")
      local icon, icon_hl = devicons.get_icon(file, file_extension, { default = true })
      local display = icon .. "  " .. symbol .. " - " .. file .. ":" .. lnum

      table.insert(formatted_results, display)
      entries[display] = {
        filename = file,
        lnum = tonumber(lnum),
        col = tonumber(col),
      }
    end
  end

  fzf.fzf_exec(formatted_results, {
    prompt = title,
    actions = {
      ["default"] = function(selected)
        local entry = entries[selected[1]]
        if entry then
          vim.notify("Opening " .. entry.filename .. " at line " .. entry.lnum, vim.log.levels.INFO)
          vim.cmd("edit " .. entry.filename)
          vim.api.nvim_win_set_cursor(0, { entry.lnum, entry.col - 1 })
        end
      end,
    },
    winopts = {
      preview = {
        hidden = "hidden",
        vertical = "up:45%",
        horizontal = "right:50%",
      },
    },
  })
end

return {
  custom_symbol_search = custom_symbol_search,
}
