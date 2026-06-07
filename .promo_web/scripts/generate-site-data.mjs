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

  // Extract VM resources
  const vmBlock = content.match(/vm:\s*([\s\S]+?)(?:\n\w+:|$)/);
  let memory = 0;
  let cpu = 0;
  let disk = 0;
  if (vmBlock) {
    const memoryMatch = vmBlock[1].match(/memory:\s*(\d+)/);
    const cpuMatch = vmBlock[1].match(/cpu:\s*(\d+)/);
    const diskMatch = vmBlock[1].match(/disk:\s*["']?(\d+)G["']?/);
    if (memoryMatch) memory = parseInt(memoryMatch[1], 10);
    if (cpuMatch) cpu = parseInt(cpuMatch[1], 10);
    if (diskMatch) disk = parseInt(diskMatch[1], 10);
  }

  return {
    id: get("id"),
    name: get("name"),
    category: get("category"),
    difficulty: get("difficulty"),
    resources: { memory, cpu, disk }
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

const allLabs = readdirSync(labsDir, { withFileTypes: true })
  .filter((entry) => entry.isDirectory() && existsSync(path.join(labsDir, entry.name, "lab.yaml")))
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
      resources: yaml.resources
    };
  });

const requirements = allLabs.reduce((acc, lab) => {
  return {
    memory: Math.max(acc.memory, lab.resources.memory),
    cpu: Math.max(acc.cpu, lab.resources.cpu),
    disk: Math.max(acc.disk, lab.resources.disk)
  };
}, { memory: 0, cpu: 0, disk: 0 });

const labs = [...allLabs]
  .sort((left, right) => new Date(right.updatedAt).getTime() - new Date(left.updatedAt).getTime())
  .slice(0, 8);

mkdirSync(path.dirname(outFile), { recursive: true });
writeFileSync(
  outFile,
  JSON.stringify(
    {
      generatedAt: new Date().toISOString(),
      requirements: {
        maxLab: requirements,
        suggestedHost: {
          memory: Math.ceil(requirements.memory / 1024) + 1, // GB
          cpu: requirements.cpu + 1,
          disk: requirements.disk + 5 // GB
        }
      },
      labs,
    },
    null,
    2
  ) + "\n"
);
