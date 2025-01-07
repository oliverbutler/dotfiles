import * as prettier from "prettier";

/**
 * Format a string using prettier
 */
export async function formatObjectWithPrettier(str: string): Promise<string> {
  try {
    // Adding "return " to the string so that prettier can format it as an object
    const res = await prettier.format("return " + str, {
      parser: "babel",
      semi: true,
      singleQuote: false,
    });

    return res.slice(7);
  } catch (error) {
    // If prettier fails, return the original string
    console.warn("Prettier formatting failed:", error);
    return str;
  }
}
