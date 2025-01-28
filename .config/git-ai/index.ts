#!/usr/bin/env bun

import { $ } from "bun";

async function getAnthropicAPIKey() {
  try {
    const apiKey =
      await $`op item get "Anthropic API Key" --account "5S2IFKBEWJARZAMDT64SKMOSVA" --fields password --reveal`.text();
    return apiKey.trim();
  } catch (error) {
    console.error("Failed to retrieve Anthropic API Key:", error);
    process.exit(1);
  }
}

async function getCurrentBranchName() {
  try {
    const branchName = await $`git rev-parse --abbrev-ref HEAD`.text();
    return branchName.trim();
  } catch (error) {
    console.error("Failed to get current branch name:", error);
    process.exit(1);
  }
}

async function getLatestCommitMessage() {
  try {
    const commitMessage = await $`git log -1 --pretty=%B`.text();
    return commitMessage.trim();
  } catch (error) {
    console.error("Failed to get latest commit message:", error);
    process.exit(1);
  }
}

async function getGitDiff() {
  try {
    const mergeBase = await $`git merge-base master HEAD`.text();
    const diff = await $`git diff ${mergeBase.trim()}...HEAD`.text();
    return diff;
  } catch (error) {
    console.error("Failed to get git diff:", error);
    process.exit(1);
  }
}

interface PRContent {
  title: string;
  description: string;
}

async function generatePRDescription(): Promise<PRContent> {
  const apiKey = await getAnthropicAPIKey();
  const branchName = await getCurrentBranchName();
  const commitMessage = await getLatestCommitMessage();
  const gitDiff = await getGitDiff();

  const prompt = `
    Generate a concise PR description based on this git diff. Return in this format:
    First line is the PR title (short, includes type)

    Then a blank line

    Then a brief description with 2-4 bullet points that:
    - Focus on high-level changes only
    - Are short and to the point
    - Avoid implementation details unless crucial
    - Start with "Relates to BLB-XXX" if branch has ticket number
    - Only mention migrations if present

    Branch Name: ${branchName}
    Commit Message: ${commitMessage}
    Git Diff:
    ${gitDiff}
  `;

  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": apiKey,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({
      model: "claude-3-5-sonnet-20240620",
      max_tokens: 300,
      messages: [{ role: "user", content: prompt }],
    }),
  });

  const data = await response.json();
  const aiResponse = data.content[0].text.trim();

  console.log("Received AI response:");
  console.log(aiResponse);

  // Split response into title and description
  const [title, ...descriptionLines] = aiResponse
    .split("\n")
    .filter((line: any) => line.trim() !== "");
  const description = descriptionLines.join("\n").trim();

  return { title, description };
}

async function checkExistingPR(): Promise<boolean> {
  try {
    const currentBranch = await getCurrentBranchName();
    const result = await $`gh pr view ${currentBranch}`.text();
    return true;
  } catch (error) {
    return false;
  }
}

async function updateOrCreatePR(content: PRContent) {
  try {
    const currentBranch = await getCurrentBranchName();
    const prExists = await checkExistingPR();

    if (prExists) {
      await $`gh pr edit ${currentBranch} --title ${content.title} --body ${content.description}`;
      console.log("Successfully updated existing PR!");
    } else {
      await $`gh pr create --title ${content.title} --body ${content.description} --base master --head ${currentBranch}`;
      console.log("Successfully created new PR!");
    }

    // Open PR in browser
    await $`gh pr view ${currentBranch} --web`;
  } catch (error) {
    console.error("Failed to update/create PR:", error);
    throw error;
  }
}

async function main() {
  try {
    const prContent = await generatePRDescription();
    console.log("Generated PR Content:");
    console.log("Title:", prContent.title);
    console.log("Description:\n", prContent.description);

    await updateOrCreatePR(prContent);
  } catch (error) {
    console.error("Error in main:", error);
  }
}

main();
