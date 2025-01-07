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
      // Handle closing brace/bracket
      if (line.endsWith(",")) {
        line = line.slice(0, -1); // Remove trailing comma
      }
      jsonLines.push(line);
    } else if (line) {
      // Handle regular properties
      if (!jsonLines.includes(line)) {
        jsonLines.push(line);
      }
    }

    // If we're back at depth 0 and had some content, we're done
    if (objectDepth === 0 && line.includes("}")) {
      break;
    }
  }

  // Convert parsed lines into single JSON string
  let jsonString = jsonLines.join("\n");

  // Remove quotes from object keys
  jsonString = jsonString
    .replace(/"(\w+)":/g, "$1:")
    // Fix nested object/array formatting
    .replace(/\{(\s*)\n\s*/g, "{\n    ") // Format after opening brace
    .replace(/\[(\s*)\n\s*/g, "[\n    ") // Format after opening bracket
    .replace(/,\s*\n\s*/g, ",\n    ") // Format properties
    .replace(/\s*\}\s*,?\s*\n/g, "\n  }") // Format closing brace
    .replace(/\s*\]\s*,?\s*\n/g, "\n  ]") // Format closing bracket
    .replace(/\s*\}\s*$/g, "\n}") // Format final closing brace
    .replace(/\s*\]\s*$/g, "\n]"); // Format final closing bracket

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
