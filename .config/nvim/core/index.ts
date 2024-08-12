type LogLevel = "debug" | "info" | "warn" | "error";
const LOG_PREFIX = "NVIM_LOG::";

function logMessage(level: LogLevel, message: string) {
  console.log(`${LOG_PREFIX}${level.toUpperCase()}::${message}`);
}

const getTestExpectedObject = (params: { testOutput: string }): string => {
  let lines = params.testOutput.split("\n");
  let jsonLines: string[] = [];

  for (let line of lines) {
    // Check for "+ Received" pattern
    if (/^\+ Received/.test(line)) {
      // Clear jsonLines array
      jsonLines = [];
      continue;
    }

    // Skip lines starting with "-"
    if (/^-/.test(line)) {
      continue;
    }

    // Skip lines that start with any number of blank spaces followed by "at"
    if (/^\s*at /.test(line)) {
      break;
    }

    // Replace "Array [" with "["
    line = line.replace(/Array \[/g, "[");

    // Replace "Object {" with "{"
    line = line.replace(/Object {/g, "{");

    // Remove leading "+"
    line = line.replace(/^\+\s?/, "");

    // Remove leading spaces
    line = line.trim();

    jsonLines.push(line);
  }

  // Convert parsed lines into single JSON string
  let jsonString = jsonLines.join("\n");

  // Remove quotes from object keys
  jsonString = jsonString.replace(/"(\w+)":/g, "$1:");

  return jsonString;
};

const add = (a: number, b: number) => {
  logMessage("error", "Test of error log");

  return a + b;
};

export function handleRequest(action: string, params: any) {
  try {
    switch (action) {
      case "getTestExpectedObject":
        return getTestExpectedObject(params);
      case "add":
        return add(params.a, params.b);
      default:
        throw new Error(`No such function: ${action}`);
    }
  } catch (error) {
    logMessage("error", error instanceof Error ? error.message : String(error));
  }
}

if (require.main === module) {
  const [action, paramsString] = process.argv.slice(2);
  const params = JSON.parse(paramsString);

  const result = handleRequest(action, params);

  console.log(JSON.stringify(result));
}
