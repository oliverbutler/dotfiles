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
    methods = "Class Methods",
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
      -- Pattern 1: Regular function/const component declarations
      -- Example: const MyComponent = () => { or function MyComponent() {
      [[\b(export\s+)?(const|let|var|function|class)\s+([A-Z][a-zA-Z0-9]*)\s*(?:=\s*(?:function\s*\(|(?:React\.)?memo\(|(?:React\.)?forwardRef(?:<[^>]+>)?\(|\()|extends\s+React\.Component|\(|:)]],

      -- Pattern 2: Generic function components
      -- Example: export function MoneyInputField<TForm extends FieldValues>({
      [[\b(export\s+)?function\s+([A-Z][a-zA-Z0-9]*)\s*<[^>]+>]],

      -- Pattern 3: Arrow function components with generics
      -- Example: export const MyComponent = <T extends unknown>({
      [[\b(export\s+)?const\s+([A-Z][a-zA-Z0-9]*)\s*=\s*<[^>]+>]],
    },
    methods = {
      -- Matches class methods with optional modifiers (public/private/protected/static/async)
      -- Examples:
      --   async getPartnerImports(
      --   private handleClick(
      --   static getInstance(
      --   public render() {
      -- Note: No whitespace allowed between method name and opening parenthesis
      [[^\s*((?:private|public|protected|static|async|\s)*)\s+([a-zA-Z_$][a-zA-Z0-9_$]*)\(]],
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

-- Map our filetypes to ripgrep type flags
local filetype_to_rg_type = {
  typescript = { "typescript" },
  javascript = { "js" },
  go = { "go" },
}

local function stream_ripgrep(pattern, directory, callback, filetype)
  local Job = require("plenary.job")
  local count = 0

  local args = {
    "--no-heading",
    "--with-filename",
    "--line-number",
    "--column",
    "--smart-case",
    "--max-filesize=1M",
  }

  -- Add type filters if filetype is specified
  if filetype and filetype_to_rg_type[filetype] then
    for _, type in ipairs(filetype_to_rg_type[filetype]) do
      table.insert(args, "-t")
      table.insert(args, type)
    end
  end

  table.insert(args, pattern)
  table.insert(args, directory or ".")

  vim.notify(vim.inspect(args), vim.log.levels.INFO)

  return Job:new({
    command = "rg",
    args = args,
    on_stdout = function(_, line)
      count = count + 1
      callback(line)
    end,
  })
end

---@alias SymbolSearchResult {symbol: string, file: string, col: number, lnum: number, text: string}
---@alias SymbolSearchReturn {title: string, results: SymbolSearchResult[]}

---@param params {type: string, also_search_file_name: boolean, directory: string}
---@return SymbolSearchReturn
local function get_symbol_results(params)
  local search_type = params.type
  local include_file_name_in_search = params.also_search_file_name
  local directory = params.directory or "."

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

  local title = string.format(
    "Search %s symbols %s",
    valid_search_types[filetype][search_type],
    include_file_name_in_search and " (include file name)" or ""
  )

  ---@type SymbolSearchResult[]
  local results = {}
  -- Track unique locations using file:line:col as key
  local seen_locations = {}

  local search_start_time = vim.loop.hrtime()
  local search_results = {}

  -- First phase: Collect all ripgrep results
  for _, pattern in ipairs(patterns) do
    local job = stream_ripgrep(pattern, directory, function(result)
      table.insert(search_results, result)
    end, filetype)
    job:sync()
  end
  local search_end_time = vim.loop.hrtime()

  -- Second phase: Process results
  local process_start_time = vim.loop.hrtime()
  for _, result in ipairs(search_results) do
    local file, lnum, col, text = string.match(result, "([^:]+):([^:]+):([^:]+):(.+)")
    local symbol = get_first_symbol(text)

    if symbol then
      -- Create a unique location key
      local location_key = string.format("%s:%s:%s", file, lnum, col)

      -- Only add if we haven't seen this exact location before
      if not seen_locations[location_key] then
        seen_locations[location_key] = true
        table.insert(results, {
          symbol = symbol,
          file = file,
          lnum = tonumber(lnum),
          col = tonumber(col),
          text = text, -- Include the full text for display purposes
        })
      end
    end
  end
  local process_end_time = vim.loop.hrtime()

  -- Calculate timings
  local search_duration_ms = (search_end_time - search_start_time) / 1e6
  local process_duration_ms = (process_end_time - process_start_time) / 1e6
  local total_duration_ms = search_duration_ms + process_duration_ms

  local total_matches = vim.tbl_count(seen_locations)

  pcall(
    vim.notify,
    string.format(
      "Found %d unique locations in %.0fms (%.0fms search, %.0fms processing)",
      total_matches,
      total_duration_ms,
      search_duration_ms,
      process_duration_ms
    ),
    vim.log.levels.INFO
  )

  return {
    title = title,
    results = results,
  }
end

return {
  get_symbol_results = get_symbol_results,
  ripgrep_line_patterns = ripgrep_line_patterns,
  get_first_symbol = get_first_symbol,
}
