const OWNER = "HimanM";
const REPO = "BrokenOps";
const API_ROOT = `https://api.github.com/repos/${OWNER}/${REPO}`;
const CACHE_TTL = 60 * 60 * 1000;
const MAX_PR_PAGES = 3;
const MAX_LABS = 6;
const MAX_CONTRIBUTORS = 12;

type CacheItem<T> = {
  data: T;
  timestamp: number;
};

export interface LabPR {
  id: number;
  number: number;
  title: string;
  body: string;
  merged_at: string;
  html_url: string;
  labId?: string;
}

export interface Contributor {
  id: number;
  login: string;
  avatar_url: string;
  html_url: string;
  contributions: number;
}

export interface ReleaseInfo {
  id: number;
  tag_name: string;
  name: string;
  body: string;
  html_url: string;
  draft: boolean;
  prerelease: boolean;
  published_at: string;
  created_at: string;
}

const FALLBACK_LABS: LabPR[] = [
  {
    id: 1,
    number: 101,
    title: "Nginx Service Failure",
    body: "Troubleshoot a broken Nginx configuration and permission issues in a live environment.",
    merged_at: new Date().toISOString(),
    html_url: "https://github.com/HimanM/BrokenOps",
    labId: "nginx-broken",
  },
  {
    id: 2,
    number: 102,
    title: "Docker Bind Mount Permissions",
    body: "Resolve permission denied errors when using Docker bind mounts on a Linux host.",
    merged_at: new Date().toISOString(),
    html_url: "https://github.com/HimanM/BrokenOps",
    labId: "docker-bind-mount",
  },
];

function cacheKey(key: string) {
  return `brokenops:${key}`;
}

function getCache<T>(key: string): T | null {
  if (typeof window === "undefined") return null;
  const item = localStorage.getItem(cacheKey(key));
  if (!item) return null;

  try {
    const parsed = JSON.parse(item) as CacheItem<T>;
    if (Date.now() - parsed.timestamp > CACHE_TTL) {
      localStorage.removeItem(cacheKey(key));
      return null;
    }
    return parsed.data;
  } catch {
    return null;
  }
}

function setCache<T>(key: string, data: T): void {
  if (typeof window === "undefined") return;
  const item: CacheItem<T> = {
    data,
    timestamp: Date.now(),
  };
  localStorage.setItem(cacheKey(key), JSON.stringify(item));
}

function stripMarkdown(text: string): string {
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

function summarize(text: string): string {
  const clean = stripMarkdown(text);
  if (!clean) return "";
  const match = clean.match(/^(.+?[.!?])(\s|$)/);
  return (match ? match[1] : clean).slice(0, 180);
}

function labIdFromFiles(files: Array<{ filename: string }>): string | undefined {
  const labPath = files.find((file) => file.filename.startsWith("labs/"))?.filename;
  if (!labPath) return undefined;
  return labPath.split("/")[1];
}

async function fetchJson<T>(url: string, cacheKeyName: string, fallback: T): Promise<T> {
  const cached = getCache<T>(cacheKeyName);
  if (cached) return cached;

  const response = await fetch(url, {
    headers: {
      Accept: "application/vnd.github+json",
      "X-GitHub-Api-Version": "2022-11-28",
    },
  });

  if (!response.ok) {
    return fallback;
  }

  const data = (await response.json()) as T;
  setCache(cacheKeyName, data);
  return data;
}

export async function fetchMergedLabs(): Promise<LabPR[]> {
  const cacheKeyName = "merged-labs";
  const cached = getCache<LabPR[]>(cacheKeyName);
  if (cached?.length) return cached;

  try {
    const labs: LabPR[] = [];
    const seenLabIds = new Set<string>();

    for (let page = 1; page <= MAX_PR_PAGES && labs.length < MAX_LABS; page += 1) {
      const prs = await fetchJson<Array<Record<string, unknown>>>(
        `${API_ROOT}/pulls?state=closed&sort=updated&direction=desc&per_page=30&page=${page}`,
        `pulls-${page}`,
        []
      );

      for (const pr of prs) {
        if (labs.length >= MAX_LABS) break;
        if (!pr.merged_at || typeof pr.number !== "number") continue;

        const files = await fetchJson<Array<{ filename: string }>>(
          `${API_ROOT}/pulls/${pr.number}/files?per_page=100`,
          `files-${pr.number}`,
          []
        );

        const labId = labIdFromFiles(files);
        if (!labId || seenLabIds.has(labId)) continue;

        seenLabIds.add(labId);
        labs.push({
          id: typeof pr.id === "number" ? pr.id : pr.number,
          number: pr.number,
          title: typeof pr.title === "string" ? pr.title : labId,
          body: summarize(typeof pr.body === "string" ? pr.body : "") || "Merged lab work discovered from a closed pull request.",
          merged_at: String(pr.merged_at),
          html_url: typeof pr.html_url === "string" ? pr.html_url : "https://github.com/HimanM/BrokenOps",
          labId,
        });
      }
    }

    const finalLabs = labs.length ? labs : FALLBACK_LABS;
    setCache(cacheKeyName, finalLabs);
    return finalLabs;
  } catch (error) {
    console.error("Error fetching labs:", error);
    return FALLBACK_LABS;
  }
}

export async function fetchContributors(): Promise<Contributor[]> {
  const cacheKeyName = "contributors";
  const cached = getCache<Contributor[]>(cacheKeyName);
  if (cached) return cached;

  try {
    const data = await fetchJson<Contributor[]>(
      `${API_ROOT}/contributors?per_page=${MAX_CONTRIBUTORS}&anon=1`,
      cacheKeyName,
      []
    );
    const filtered = data.filter((contributor) => contributor.login && contributor.avatar_url && contributor.html_url);
    setCache(cacheKeyName, filtered);
    return filtered;
  } catch (error) {
    console.error("Error fetching contributors:", error);
    return [];
  }
}

export async function fetchLatestRelease(): Promise<ReleaseInfo | null> {
  const cacheKeyName = "latest-release";
  const cached = getCache<ReleaseInfo | null>(cacheKeyName);
  if (cached !== null) return cached;

  try {
    const releases = await fetchJson<ReleaseInfo[]>(`${API_ROOT}/releases?per_page=20`, cacheKeyName, []);
    const latest = releases
      .filter((release) => !release.draft)
      .slice()
      .sort((a, b) => {
        const left = new Date(a.published_at || a.created_at).getTime();
        const right = new Date(b.published_at || b.created_at).getTime();
        return right - left;
      })[0] || null;

    setCache(cacheKeyName, latest);
    return latest;
  } catch (error) {
    console.error("Error fetching releases:", error);
    return null;
  }
}
