local function mock_web_devicons()
  -- Create a table to represent the module and its functions
  local web_devicons_mock = {}

  -- Add any functions or properties that your code might be calling
  -- For example, if your code calls `require('nvim-web-devicons').get_icon()`,
  -- you should mock this function.
  function web_devicons_mock.get_icon(name, ext)
    -- You can return a mock value or set up logic to return different values
    return "mock_icon", "mock_highlight_group"
  end

  -- Return the mock table when required
  return web_devicons_mock
end

package.loaded["nvim-web-devicons"] = mock_web_devicons()

local getFirstSymbol = require("lua.olly.search-symbols").get_first_symbol
local ripgrep_line_patterns = require("lua.olly.search-symbols").ripgrep_line_patterns

-- Helper function to run ripgrep on a string
local function run_ripgrep_on_string(patterns, content, lang)
  lang = lang or "typescript"
  -- Create a temporary file
  local temp_file = os.tmpname()

  -- Write content to the temp file
  local file = io.open(temp_file, "w")
  file:write(content)
  file:close()

  -- Run ripgrep for each pattern
  for _, pattern in ipairs(patterns) do
    local handle = io.popen(string.format("rg -e '%s' %s", pattern, temp_file))
    local result = handle:read("*a")
    handle:close()

    if result ~= "" then
      -- Remove the temporary file
      os.remove(temp_file)
      return true
    end
  end

  -- Remove the temporary file
  os.remove(temp_file)

  return false
end

describe("ripgrep_line_patterns", function()
  describe("typescript", function()
    describe("all", function()
      it("should match variable declarations", function()
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.typescript.all, "const foo = 'bar';"))
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.typescript.all, "async myFunc = () => {};"))
      end)

      it("should match function declarations", function()
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.typescript.all, "function myFunction() {"))
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.typescript.all, "async function asyncFunc() {"))
      end)

      it("should match class declarations", function()
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.typescript.all, "class MyClass {"))
      end)

      it("should match type and interface declarations", function()
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.typescript.all, "type MyType = {"))
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.typescript.all, "interface MyInterface {"))
      end)

      it("should not match regular assignments or function calls", function()
        assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.typescript.all, "x = 5;"))
        assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.typescript.all, "myFunction();"))
      end)
    end)

    describe("types", function()
      it("should match interface declarations", function()
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.typescript.types, "interface MyInterface {"))
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.typescript.types, "interface AnotherInterface{"))
      end)

      it("should match type declarations", function()
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.typescript.types, "type MyType = {"))
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.typescript.types, "type AnotherType="))
      end)

      it("should not match class or function declarations", function()
        assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.typescript.types, "class MyClass {"))
        assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.typescript.types, "function myFunc() {"))
      end)
    end)

    describe("classes", function()
      it("should match simple class declarations", function()
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.typescript.classes, "class MyClass {"))
      end)

      it("should match class declarations with extends", function()
        assert.is_true(
          run_ripgrep_on_string(ripgrep_line_patterns.typescript.classes, "class ChildClass extends ParentClass {")
        )
      end)

      it("should match class declarations with implements", function()
        assert.is_true(
          run_ripgrep_on_string(ripgrep_line_patterns.typescript.classes, "class MyClass implements MyInterface {")
        )
      end)

      it("should not match function or interface declarations", function()
        assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.typescript.classes, "function myFunction() {"))
        assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.typescript.classes, "interface MyInterface {"))
      end)
    end)

    describe("zod", function()
      it("should match zod schema declarations", function()
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.typescript.zod, "const mySchema = z.object({"))
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.typescript.zod, "const anotherSchema = z.string()"))
      end)

      it("should not match non-zod constant declarations", function()
        assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.typescript.zod, "const myVar = 5;"))
        assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.typescript.zod, "const obj = {z: 5};"))
      end)
    end)

    describe("methods", function()
      it("should match class methods with modifiers", function()
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.typescript.methods, "  private handleClick() {"))
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.typescript.methods, "  public async getData() {"))
        assert.is_true(
          run_ripgrep_on_string(ripgrep_line_patterns.typescript.methods, "  protected static getInstance() {")
        )
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.typescript.methods, "  async fetchData() {"))
      end)

      it("should match class methods without modifiers", function()
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.typescript.methods, "  render() {"))
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.typescript.methods, "  componentDidMount() {"))
      end)

      it("should not match for loops", function()
        assert.is_false(
          run_ripgrep_on_string(ripgrep_line_patterns.typescript.methods, "  for (const item of items) {")
        )
        assert.is_false(
          run_ripgrep_on_string(ripgrep_line_patterns.typescript.methods, "  for (let i = 0; i < 10; i++) {")
        )
        assert.is_false(
          run_ripgrep_on_string(
            ripgrep_line_patterns.typescript.methods,
            "  for (const [key, value] of Object.entries(data)) {"
          )
        )
      end)

      it("should not match other control structures", function()
        assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.typescript.methods, "  if (condition) {"))
        assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.typescript.methods, "  while (running) {"))
        assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.typescript.methods, "  switch (value) {"))
      end)
    end)

    describe("react", function()
      it("should match functional component declarations", function()
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.typescript.react, "const MyComponent = () => {"))
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.typescript.react, "function MyComponent() {"))
      end)

      it("should match class component declarations", function()
        assert.is_true(
          run_ripgrep_on_string(ripgrep_line_patterns.typescript.react, "class MyComponent extends React.Component {")
        )
      end)

      it("should match memoized component declarations", function()
        assert.is_true(
          run_ripgrep_on_string(ripgrep_line_patterns.typescript.react, "const MyComponent = React.memo(() => {")
        )
        assert.is_true(
          run_ripgrep_on_string(ripgrep_line_patterns.typescript.react, "const AppRouter = memo((props) => {")
        )
      end)

      it("should match forwardRef component declarations", function()
        assert.is_true(
          run_ripgrep_on_string(
            ripgrep_line_patterns.typescript.react,
            "const MyComponent = React.forwardRef((props, ref) => {"
          )
        )
        assert.is_true(
          run_ripgrep_on_string(
            ripgrep_line_patterns.typescript.react,
            "const MyComponent = forwardRef((props, ref) => {"
          )
        )
        assert.is_true(
          run_ripgrep_on_string(
            ripgrep_line_patterns.typescript.react,
            "export const TextInput = forwardRef<HTMLInputElement, TextInputProps>("
          )
        )
      end)

      it("should not match non-component declarations", function()
        assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.typescript.react, "const myVar = 5;"))
        assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.typescript.react, "function helperFunction() {"))
      end)
    end)
  end)

  describe("go", function()
    describe("all", function()
      it("should match function declarations", function()
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.go.all, "func MyFunction() {", "go"))
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.go.all, "func (s *Server) HandleRequest() {", "go"))
      end)

      it("should match type declarations", function()
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.go.all, "type MyStruct struct {", "go"))
        assert.is_true(run_ripgrep_on_string(ripgrep_line_patterns.go.all, "type MyInterface interface {", "go"))
      end)

      it("should not match regular assignments or function calls", function()
        assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.go.all, "x := 5", "go"))
        assert.is_false(run_ripgrep_on_string(ripgrep_line_patterns.go.all, "myFunction()", "go"))
      end)
    end)
  end)
end)

describe("getFirstSymbol", function()
  it("should return the first symbol in a simple assignment", function()
    assert.are.equal("foo", getFirstSymbol("const foo = 42"))
  end)

  it("should ignore keywords", function()
    assert.are.equal("bar", getFirstSymbol("function bar() {}"))
  end)

  it("should handle type definitions", function()
    assert.are.equal("Person", getFirstSymbol("interface Person {}"))
  end)

  it("should handle class definitions", function()
    assert.are.equal("MyClass", getFirstSymbol("class MyClass extends BaseClass {}"))
  end)

  it("should handle assignments with spaces", function()
    assert.are.equal("baz", getFirstSymbol("let   baz    =   123"))
  end)

  it("should return nil for invalid input", function()
    assert.is_nil(getFirstSymbol("const = 42"))
  end)

  it("should handle ts types", function()
    assert.are.equal("MyType", getFirstSymbol("type MyType = { foo: string }"))
    assert.are.equal("MyType2", getFirstSymbol("export type MyType2 = { foo: string }"))
  end)

  it("should be able to search classes", function()
    assert.are.equal("OnsiApiMembersController", getFirstSymbol("export class OnsiApiMembersController {"))
  end)
end)
