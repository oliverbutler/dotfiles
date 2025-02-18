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

local function stream_ripgrep(pattern, directory, callback)
  local Job = require("plenary.job")
  local start_time = vim.loop.hrtime()
  local count = 0

  return Job:new({
    command = "rg",
    args = {
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--max-filesize=1M",
      pattern,
      directory or ".",
    },
    on_stdout = function(_, line)
      count = count + 1
      callback(line)
    end,
    on_exit = function()
      local end_time = vim.loop.hrtime()
      local duration_ms = (end_time - start_time) / 1e6
      pcall(
        vim.notify,
        string.format("Found %d results for pattern '%s' in %.2f ms", count, pattern, duration_ms),
        vim.log.levels.INFO
      )
    end,
  })
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

local function format_entry(file, lnum, col, symbol)
  -- Get file icon and highlight group
  local icon, icon_hl = devicons.get_icon(file, string.match(file, "%a+$"), { default = true })
  local file_path = vim.fn.fnamemodify(file, ":~:.")
  return {
    display = string.format("%s %s %s:%s", icon, symbol, file_path, lnum),
    file = file,
    lnum = tonumber(lnum),
    col = tonumber(col),
    symbol = symbol,
    icon = icon,
    icon_hl = icon_hl,
  }
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

  local title = string.format(
    "Search %s symbols %s",
    valid_search_types[filetype][search_type],
    include_file_name_in_search and " (include file name)" or ""
  )

  local seen = {}
  local lookup = {}

  -- Add this before the fzf.fzf_exec call
  local builtin = require("fzf-lua.previewer.builtin")

  -- Create custom previewer
  local SymbolPreviewer = builtin.buffer_or_file:extend()

  function SymbolPreviewer:new(o, opts, fzf_win)
    SymbolPreviewer.super.new(self, o, opts, fzf_win)
    setmetatable(self, SymbolPreviewer)
    return self
  end

  function SymbolPreviewer:parse_entry(entry_str)
    -- Parse our custom entry format
    -- The entry_str will be in format: "icon symbol filepath:line"
    local _, symbol, file_info = entry_str:match("(%S+)%s+(%S+)%s+(.+)")
    local filepath, line = file_info:match("([^:]+):(%d+)")

    return {
      path = filepath,
      line = tonumber(line) or 1,
      col = 1,
    }
  end

  local fzf = require("fzf-lua")

  fzf.fzf_exec(function(fzf_cb)
    local jobs = {}

    for _, pattern in ipairs(patterns) do
      local job = stream_ripgrep(pattern, params.directory, function(result)
        local file, lnum, col, text = string.match(result, "([^:]+):([^:]+):([^:]+):(.+)")
        local symbol = get_first_symbol(text)

        if symbol and not seen[result] then
          seen[result] = true
          local entry = format_entry(file, lnum, col, symbol)
          lookup[entry.display] = entry
          fzf_cb(entry.display)
        end
      end)
      table.insert(jobs, job)
    end

    -- Start all jobs
    for _, job in ipairs(jobs) do
      job:start()
    end

    -- Wait for all jobs to complete
    for _, job in ipairs(jobs) do
      job:wait()
    end

    fzf_cb(nil)
  end, {
    prompt = title,
    actions = {
      ["default"] = function(selected)
        local entry = lookup[selected[1]]
        if entry then
          vim.cmd("edit " .. entry.file)
          vim.api.nvim_win_set_cursor(0, { entry.lnum, entry.col - 1 })
        end
      end,
    },
    winopts = {
      height = 0.85,
      width = 0.90,
      preview = {
        hidden = "nohidden",
        vertical = "right",
        horizontal = "right",
        layout = "flex",
        flip_columns = 120,
      },
    },
    fzf_opts = {
      ["--nth"] = params.include_file_name_in_search and "1.." or "2",
    },
    previewer = SymbolPreviewer, -- Use our custom previewer
  })
end

return {
  custom_symbol_search = custom_symbol_search,
}
