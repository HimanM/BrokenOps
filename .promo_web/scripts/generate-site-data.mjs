import { existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { execFileSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

const appDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const repoRoot = path.resolve(appDir, "..");
const labsDir = path.join(repoRoot, "labs");
const outFile = path.join(appDir, "src", "generated", "site-data.json");

function stripMarkdown(text) {
  return (text || "")
    .replace(/^#{1,6}\s+/gm, "")
    .replace(/^\s*[-*+]\s+/gm, "")
    .replace(/`([^`]+)`/g, "$1")
    .replace(/\[(.*?)\]\((.*?)\)/g, "$1")
    .replace(/\*\*(.*?)\*\*/g, "$1")
    .replace(/\*(.*?)\*/g, "$1")
    .replace(/\s+/g, " ")
    .trim();
}

function summarizeQuestion(questionMd) {
  const clean = stripMarkdown(questionMd);
  if (!clean) return "";
  const lines = clean.split(/\n+/).map((line) => line.trim()).filter(Boolean);
  const preferred = lines.find((line) => !/^(scenario|objective|useful commands)$/i.test(line)) || lines[0] || "";
  const match = preferred.match(/^(.+?[.!?])(\s|$)/);
  return (match ? match[1] : preferred).slice(0, 180);
}

function readLabYaml(labPath) {
  const content = readFileSync(path.join(labPath, "lab.yaml"), "utf8");
  const get = (key) => {
    const match = content.match(new RegExp(`^${key}:\\s*(.+)$`, "m"));
    return match ? match[1].trim().replace(/^["']|["']$/g, "") : "";
  };
  return {
    id: get("id"),
    name: get("name"),
    category: get("category"),
    difficulty: get("difficulty"),
  };
}

function gitLogForLab(labId) {
  try {
    const output = execFileSync("git", ["log", "-1", "--format=%H|%cI|%s", "--", `labs/${labId}`], {
      cwd: repoRoot,
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    }).trim();
    const [sha, isoDate] = output.split("|");
    return {
      sha,
      updatedAt: isoDate || new Date().toISOString(),
    };
  } catch {
    return {
      sha: "",
      updatedAt: new Date().toISOString(),
    };
  }
}

const labs = readdirSync(labsDir, { withFileTypes: true })
  .filter((entry) => entry.isDirectory())
  .map((entry) => {
    const labPath = path.join(labsDir, entry.name);
    const yaml = readLabYaml(labPath);
    const questionPath = path.join(labPath, "question.md");
    const questionMd = existsSync(questionPath) ? readFileSync(questionPath, "utf8") : "";
    const gitInfo = gitLogForLab(entry.name);

    return {
      id: yaml.id || entry.name,
      title: yaml.name || entry.name,
      summary: summarizeQuestion(questionMd),
      category: yaml.category || "general",
      difficulty: yaml.difficulty || "unknown",
      labId: entry.name,
      updatedAt: gitInfo.updatedAt,
      commit: gitInfo.sha,
      url: `https://github.com/HimanM/BrokenOps/tree/main/labs/${entry.name}`,
    };
  })
  .sort((left, right) => new Date(right.updatedAt).getTime() - new Date(left.updatedAt).getTime())
  .slice(0, 8);

mkdirSync(path.dirname(outFile), { recursive: true });
writeFileSync(
  outFile,
  JSON.stringify(
    {
      generatedAt: new Date().toISOString(),
      labs,
    },
    null,
    2
  ) + "\n"
);
