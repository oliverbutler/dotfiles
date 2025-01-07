/**
 * Normalizes object string representation by removing whitespace and formatting
 * @param str The string to normalize
 */
export function normalizeObjectString(str: string): string {
  return str
    .trim()
    .replace(/\s+/g, "")
    .replace(/["\s\n\r]/g, "")
    .replace(/[:,]/g, "");
}

/**
 * Compares two object strings while ignoring whitespace, quotes, and formatting
 */
export function objectStringsAreEqual(
  actual: string,
  expected: string,
): boolean {
  return normalizeObjectString(actual) === normalizeObjectString(expected);
}
