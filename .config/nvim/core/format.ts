import * as prettier from "prettier";

/**
 * Format a string using prettier
 */
export async function formatWithPrettier(str: string): Promise<string> {
  try {
    return await prettier.format(str, {
      parser: "babel",
      semi: true,
      singleQuote: false,
    });
  } catch (error) {
    // If prettier fails, return the original string
    console.warn("Prettier formatting failed:", error);
    return str;
  }
}
