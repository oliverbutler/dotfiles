import { getTestExpectedObject } from "./jest-parser/jest-parser";

type LogLevel = "debug" | "info" | "warn" | "error";
const LOG_PREFIX = "NVIM_LOG::";

function logMessage(level: LogLevel, message: string) {
  console.log(`${LOG_PREFIX}${level.toUpperCase()}::${message}`);
}

export async function handleRequest(action: string, params: any) {
  try {
    switch (action) {
      case "getTestExpectedObject":
        return await getTestExpectedObject(params);
      default:
        throw new Error(`No such function: ${action}`);
    }
  } catch (error) {
    logMessage("error", error instanceof Error ? error.message : String(error));
  }
}

const [action, paramsString] = process.argv.slice(2);
const params = JSON.parse(paramsString);

const result = await handleRequest(action, params);

console.log(JSON.stringify(result));
