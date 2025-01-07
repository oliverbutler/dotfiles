type LogLevel = "debug" | "info" | "warn" | "error";
const LOG_PREFIX = "NVIM_LOG::";

function logMessage(level: LogLevel, message: string) {
  console.log(`${LOG_PREFIX}${level.toUpperCase()}::${message}`);
}

/**
 * Used to get the real received object from a jest test output.
 */
export const getTestExpectedObject = (params: {
  testOutput: string;
}): string => {
  const lines = params.testOutput.split("\n");

  // Check for simple Expected: value pattern first
  const simpleExpectedMatch = params.testOutput.match(
    /Expected: (.*)\nReceived:/,
  );
  if (simpleExpectedMatch) {
    const expectedValue = simpleExpectedMatch[1].trim();
    return expectedValue;
  }

  let jsonLines: string[] = [];
  let isCollecting = false;
  let objectDepth = 0;

  for (let line of lines) {
    // Start collecting after we see the diff header
    if (line.includes("- Expected") || line.includes("+ Received")) {
      isCollecting = true;
      continue;
    }

    if (!isCollecting) continue;

    // Skip stack traces
    if (/^\s*at /.test(line)) {
      break;
    }

    // Track object depth
    const openBraces = (line.match(/{/g) || []).length;
    const closeBraces = (line.match(/}/g) || []).length;
    objectDepth += openBraces - closeBraces;

    // Skip lines that start with - (removed lines)
    if (line.trim().startsWith("-")) {
      continue;
    }

    // Clean up the line
    line = line
      .replace(/^[\s+-]*/, "") // Remove leading spaces, +, and -
      .replace(/Array \[/g, "[")
      .replace(/Object \{/g, "{") // Replace 'Object {' with '{' everywhere
      .trim();

    // Skip empty lines
    if (!line) {
      continue;
    }

    line = replaceDateWithExpectDate(line);

    // Handle nested object/array formatting
    if (line.includes("{") || line.includes("[")) {
      // Add opening brace/bracket with proper indentation
      jsonLines.push(line);
    } else if (line.includes("}") || line.includes("]")) {
      jsonLines.push(line);
    } else if (line) {
      jsonLines.push(line);
    }

    // Only break if we're at depth 0 and we see a closing bracket for an array
    if (objectDepth === 0 && line.includes("]")) {
      break;
    }
  }

  // Remove empty lines
  jsonLines = jsonLines.filter((line) => line.trim());

  // First, join all lines
  let jsonString = jsonLines.join("\n");

  // Remove quotes from object keys
  jsonString = jsonString
    .replace(/"(\w+)":/g, "$1:")
    // Handle array formatting
    .replace(/\[\s*{/g, "[\n      {") // Start of array
    .replace(/}\s*{/g, "},\n      {") // Between array items
    .replace(/}\s*]/g, "}\n    ]") // End of array
    // Handle object formatting
    .replace(/{\s*(\w+):/g, "{\n        $1:") // Start of object
    .replace(/,\s*(\w+):/g, ",\n        $1:") // Between object properties
    .replace(/([^,])\s*}/g, "$1\n      }"); // End of object

  return jsonString;
};

/**
 * input such as
 *    "createdAt": 2024-08-22T15:38:03.190Z,
 * to become
 *    "createdAt": expect.any(Date),
 */
const replaceDateWithExpectDate = (row: string): string => {
  const dateRegex = /(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z)/g;

  return row.replace(dateRegex, "expect.any(Date)");
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
