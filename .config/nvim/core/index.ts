export function getTestExpectedObject(params: { testOutput: string }) {
  console.log("hi!");
  return {
    foo: "bar",
  };
}

export function handleRequest(action: string, params: any) {
  switch (action) {
    case "getTestExpectedObject":
      return getTestExpectedObject(params);
    default:
      throw new Error(`No such function: ${action}`);
  }
}

if (require.main === module) {
  const [action, paramsString] = process.argv.slice(2);
  const params = JSON.parse(paramsString);
  console.log(JSON.stringify(handleRequest(action, params)));
}
