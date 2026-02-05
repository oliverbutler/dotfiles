-- Function to get the first "symbol" from a line of text/code
-- e.g. "const foo = 1" will return "foo"
-- e.g. "function bar() {}" will return "bar"
-- e.g. "let baz = 2" will return "baz"
-- e.g. "    async function qux() {}" will return "qux"
--
-- Should work for JS/TS keywords, ignoring all preceding and trailing characters
-- If theres more than one keyword in the line e.g. "export const" it will ignore the earlier one(s)
-- Pre-compile patterns and create filetype-specific keyword lookups for better performance
local KEYWORDS = {
  typescript = {
    ["const"] = true,
    ["function"] = true,
    ["let"] = true,
    ["async"] = true,
    ["private"] = true,
    ["public"] = true,
    ["protected"] = true,
    ["type"] = true,
    ["interface"] = true,
    ["class"] = true,
    ["enum"] = true,
    ["export"] = true,
    ["static"] = true,
    ["get"] = true,
    ["set"] = true,
  },
  javascript = {
    ["const"] = true,
    ["function"] = true,
    ["let"] = true,
    ["async"] = true,
    ["private"] = true,
    ["public"] = true,
    ["protected"] = true,
    ["type"] = true,
    ["interface"] = true,
    ["class"] = true,
    ["enum"] = true,
    ["export"] = true,
    ["static"] = true,
    ["get"] = true,
    ["set"] = true,
  },
  go = {
    ["func"] = true,
    ["type"] = true,
    ["interface"] = true,
    ["struct"] = true,
    ["var"] = true,
    ["const"] = true,
    ["package"] = true,
    ["import"] = true,
    ["map"] = true,
    ["chan"] = true,
  }
}

-- Pre-compile patterns
local TRIM_PATTERN = "^%s*(.-)%s*$"
local IDENTIFIER_PATTERN = "^([%a_][%w_]*)"

local function get_first_symbol(input, filetype)
  if not input then
    return nil
  end

  -- Default to typescript if filetype not provided or not supported
  filetype = filetype or "typescript"
  if not KEYWORDS[filetype] then
    filetype = "typescript"
  end

  -- Remove leading/trailing whitespace
  input = input:match(TRIM_PATTERN)

  -- Single pass through the string to find first non-keyword identifier
  for word in input:gmatch("%S+") do
    if not KEYWORDS[filetype][word] then
      local identifier = word:match(IDENTIFIER_PATTERN)
      if identifier then
        return identifier
      end
    end
  end

  return nil
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

local function stream_ripgrep(pattern, directory, filetype)
  -- Pre-allocate args table with known size
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
      args[#args + 1] = "-t"
      args[#args + 1] = type
    end
  end

  args[#args + 1] = pattern
  args[#args + 1] = directory or "."

  -- Use vim.system instead of plenary.job (Neovim 0.10+)
  local result = vim.system({ "rg", unpack(args) }, { text = true }):wait()
  
  if result.code ~= 0 then
    return {}
  end
  
  -- Split output into lines
  local lines = {}
  for line in result.stdout:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end
  
  return lines
end

---@alias SymbolSearchResult {symbol: string, file: string, col: number, lnum: number, text: string}
---@alias SymbolSearchReturn {title: string, results: SymbolSearchResult[]}

-- Pre-compile the result parsing pattern
local RESULT_PATTERN = "([^:]+):([^:]+):([^:]+):(.+)"

-- Detect which filetypes exist in the current working directory (up to 3 levels deep)
local function detect_filetypes_in_cwd(directory)
	local dir = directory or "."
	local detected = {}

	-- Map file extensions to our internal filetypes
	local extension_map = {
		ts = "typescript",
		tsx = "typescript",
		js = "javascript",
		jsx = "javascript",
		go = "go",
	}

	-- Use find to scan up to 3 levels deep for relevant files
	local result = vim.system({
		"find",
		dir,
		"-maxdepth", "3",
		"-type", "f",
		"(",
		"-name", "*.ts",
		"-o", "-name", "*.tsx",
		"-o", "-name", "*.js",
		"-o", "-name", "*.jsx",
		"-o", "-name", "*.go",
		")",
	}, { text = true }):wait()

	if result.code == 0 and result.stdout then
		for line in result.stdout:gmatch("[^\r\n]+") do
			-- Extract extension from filename
			local ext = line:match("%.([^.]+)$")
			if ext and extension_map[ext] then
				detected[extension_map[ext]] = true
			end
		end
	end

	-- Convert to array
	local filetypes = {}
	for ft, _ in pairs(detected) do
		table.insert(filetypes, ft)
	end

	-- If no filetypes detected, default to typescript
	if #filetypes == 0 then
		filetypes = { "typescript" }
	end

	return filetypes
end

---@param params {type: string, also_search_file_name: boolean, directory: string}
---@return SymbolSearchReturn
local function get_symbol_results(params)
	local search_type = params.type
	local include_file_name_in_search = params.also_search_file_name
	local directory = params.directory or "."

	-- Detect all filetypes in the current working directory
	local filetypes = detect_filetypes_in_cwd(directory)

	---@type SymbolSearchResult[]
	local results = {}
	-- Track unique locations using file:line:col as key
	local seen_locations = {}

	local start_time = vim.loop.hrtime()

	-- Search across all detected filetypes
	for _, filetype in ipairs(filetypes) do
		-- Skip if this filetype doesn't support the requested search type
		if not (valid_search_types[filetype] and valid_search_types[filetype][search_type]) then
			goto next_filetype
		end

		-- Get patterns for this filetype
		local patterns = ripgrep_line_patterns[filetype][search_type]

		-- Process results after getting them all
		for _, pattern in ipairs(patterns) do
			local lines = stream_ripgrep(pattern, directory, filetype)

			for _, line in ipairs(lines) do
				local file, lnum, col, text = string.match(line, RESULT_PATTERN)
				if not file then
					goto continue
				end

				local symbol = get_first_symbol(text, filetype)
				if not symbol then
					goto continue
				end

				-- Create a unique location key
				local location_key = string.format("%s:%s:%s", file, lnum, col)

				-- Only add if we haven't seen this exact location before
				if not seen_locations[location_key] then
					seen_locations[location_key] = true
					results[#results + 1] = {
						symbol = symbol,
						file = file,
						lnum = tonumber(lnum),
						col = tonumber(col),
						text = text,
					}
				end

				::continue::
			end
		end

		::next_filetype::
	end

	local end_time = vim.loop.hrtime()
	local total_duration_ms = (end_time - start_time) / 1e6
	local total_matches = vim.tbl_count(seen_locations)

	-- Build title showing which filetypes were searched
	local filetype_names = table.concat(filetypes, ", ")
	local title = string.format(
		"Search %s symbols across %s%s",
		search_type,
		filetype_names,
		include_file_name_in_search and " (include file name)" or ""
	)

	pcall(
		vim.notify,
		string.format("Found %d unique locations in %.0fms across %s", total_matches, total_duration_ms, filetype_names),
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

