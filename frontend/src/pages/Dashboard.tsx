import { useState, useEffect, type ComponentType } from 'react';
import { CheckCircle2, Play, RefreshCw, Search } from 'lucide-react';
import { FaLinux, FaNetworkWired } from 'react-icons/fa';
import { SiHackthebox, SiKubernetes, SiDocker, SiGnubash } from 'react-icons/si';
import { useNavigate } from 'react-router-dom';

interface Lab {
  id: string;
  name: string;
  category: string;
  difficulty: string;
  description: {
    summary: string;
  };
}

type CategoryMeta = {
  label: string;
  accent: string;
  rail: string;
  Icon: ComponentType<{ className?: string }>;
};

const categoryMeta: Record<string, CategoryMeta> = {
  linux: {
    label: 'Linux',
    accent: 'text-[#14c6cb] bg-[#14c6cb]/10 border-[#14c6cb]/25',
    rail: 'bg-[#14c6cb]',
    Icon: FaLinux,
  },
  security: {
    label: 'Security',
    accent: 'text-[#ffcf25] bg-[#ffcf25]/10 border-[#ffcf25]/25',
    rail: 'bg-[#ffcf25]',
    Icon: SiHackthebox,
  },
  networking: {
    label: 'Networking',
    accent: 'text-[#00ca8e] bg-[#00ca8e]/10 border-[#00ca8e]/25',
    rail: 'bg-[#00ca8e]',
    Icon: FaNetworkWired,
  },
  docker: {
    label: 'Docker',
    accent: 'text-[#2b89ff] bg-[#2b89ff]/10 border-[#2b89ff]/25',
    rail: 'bg-[#2b89ff]',
    Icon: SiDocker,
  },
  kubernetes: {
    label: 'Kubernetes',
    accent: 'text-[#8aa6ff] bg-[#8aa6ff]/10 border-[#8aa6ff]/25',
    rail: 'bg-[#8aa6ff]',
    Icon: SiKubernetes,
  },
};

const fallbackMeta: CategoryMeta = {
  label: 'Operations',
  accent: 'text-[#d6d8dc] bg-[#1f232b] border-[#3b3d45]',
  rail: 'bg-[#656a76]',
  Icon: SiGnubash,
};

const difficultyOrder: Record<string, number> = {
  beginner: 0,
  easy: 0,
  basic: 0,
  intermediate: 1,
  medium: 1,
  moderate: 1,
  advanced: 2,
  hard: 2,
  expert: 3,
};

function getCategoryMeta(category: string) {
  const normalized = category.toLowerCase();
  const meta = categoryMeta[normalized] ?? fallbackMeta;
  return {
    ...meta,
    label: categoryMeta[normalized]?.label ?? category,
  };
}

function getDifficultyRank(difficulty: string) {
  return difficultyOrder[difficulty.toLowerCase()] ?? 99;
}

function getDifficultyClass(difficulty: string) {
  const normalized = difficulty.toLowerCase();
  if (['beginner', 'easy', 'basic'].includes(normalized)) {
    return 'border-[#00ca8e]/25 bg-[#00ca8e]/10 text-[#00ca8e]';
  }
  if (['advanced', 'hard', 'expert'].includes(normalized)) {
    return 'border-[#e62b1e]/25 bg-[#e62b1e]/10 text-[#ff8a82]';
  }
  return 'border-[#ffcf25]/25 bg-[#ffcf25]/10 text-[#ffcf25]';
}

function sortLabsByDifficulty(a: Lab, b: Lab) {
  const difficultyDelta = getDifficultyRank(a.difficulty) - getDifficultyRank(b.difficulty);
  if (difficultyDelta !== 0) return difficultyDelta;
  return a.name.localeCompare(b.name);
}

export default function Dashboard() {
  const [labs, setLabs] = useState<Lab[]>([]);
  const [loading, setLoading] = useState(true);
  const [completedLabs] = useState<string[]>(() => {
    const stored = localStorage.getItem('completedLabs');
    return stored ? JSON.parse(stored) : [];
  });
  const [activeCategory, setActiveCategory] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState<string>('');
  const navigate = useNavigate();

  useEffect(() => {
    const fetchLabs = async () => {
      try {
        const res = await fetch('/api/labs');
        if (res.ok) {
          const data = await res.json();
          setLabs(data);
        }
      } catch (err) {
        console.log('Using fallback data', err);
        setLabs([
          {
            id: 'nginx-broken',
            name: 'Nginx Service Down',
            category: 'linux',
            difficulty: 'beginner',
            description: { summary: 'Nginx is not running after reboot' },
          },
        ]);
      } finally {
        setLoading(false);
      }
    };
    fetchLabs();
  }, []);

  const categories = Array.from(new Set(labs.map((lab) => lab.category))).sort((a, b) => a.localeCompare(b));

  const filteredLabs = labs.filter((lab) => {
    const query = searchQuery.trim().toLowerCase();
    const matchesCategory = activeCategory === 'all' || lab.category === activeCategory;
    const matchesSearch =
      !query ||
      lab.name.toLowerCase().includes(query) ||
      lab.description.summary.toLowerCase().includes(query) ||
      lab.id.toLowerCase().includes(query) ||
      lab.category.toLowerCase().includes(query) ||
      lab.difficulty.toLowerCase().includes(query);
    return matchesCategory && matchesSearch;
  });

  const groupedLabs = categories
    .filter((category) => activeCategory === 'all' || activeCategory === category)
    .map((category) => ({
      category,
      labs: filteredLabs.filter((lab) => lab.category === category).sort(sortLabsByDifficulty),
    }))
    .filter((group) => group.labs.length > 0);

  return (
    <div className="min-h-screen bg-[#000000] text-white selection:bg-[#2b89ff]/30">
      <nav className="sticky top-0 z-40 border-b border-[#252830] bg-black/95">
        <div className="mx-auto flex h-16 max-w-[1280px] items-center justify-between px-5 lg:px-8">
          <button
            type="button"
            onClick={() => navigate('/')}
            className="flex items-center gap-3 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#2b89ff]"
          >
            <span className="relative flex h-9 w-9 items-center justify-center rounded-lg border border-[#3b3d45] bg-[#15181e]">
              <span className="absolute h-2.5 w-2.5 rounded-full bg-[#14c6cb] left-2 top-2" />
              <span className="absolute h-2.5 w-2.5 rounded-full bg-[#ffcf25] right-2 top-3" />
              <span className="absolute bottom-2 h-2.5 w-2.5 rounded-full bg-[#e62b1e]" />
              <span className="h-px w-5 rotate-45 bg-[#656a76]" />
            </span>
            <span>
              <span className="block text-sm font-semibold leading-none text-white">BrokenOps</span>
              <span className="mt-1 block text-xs font-medium leading-none text-[#656a76]">Lab control plane</span>
            </span>
          </button>

          <div className="hidden items-center gap-6 text-sm font-medium text-[#b2b6bd] md:flex">
            <span>{labs.length} labs indexed</span>
            <span>{completedLabs.length} completed</span>
          </div>
        </div>
      </nav>

      <main className="mx-auto max-w-[1280px] px-5 py-8 lg:px-8 lg:py-10">
        <section className="border-b border-[#252830] pb-8">
          <div className="text-xs font-semibold uppercase tracking-[0.06em] text-[#14c6cb]">Operations lab inventory</div>
          <div className="grid gap-6 lg:grid-cols-[minmax(0,1fr)_420px] lg:items-end">
            <div>
              <h1 className="mt-3 max-w-3xl text-4xl font-bold leading-[1.18] tracking-normal text-white md:text-5xl">
                Practice incident response inside disposable Linux systems.
              </h1>
              <p className="mt-4 max-w-2xl text-base font-medium leading-7 text-[#b2b6bd] md:text-lg">
                Pick a broken service, launch an isolated VM, diagnose from the shell, and verify the repair against the lab checks.
              </p>
            </div>

            <div className="rounded-xl border border-[#252830] bg-[#15181e] p-4">
              <div className="grid grid-cols-3 gap-3">
                <Metric value={labs.length} label="Labs" />
                <Metric value={categories.length} label="Domains" />
                <Metric value={completedLabs.length} label="Solved" />
              </div>
            </div>
          </div>
        </section>

        <section className="py-6">
          <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
            <div className="relative w-full lg:max-w-md">
              <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-[#656a76]" />
              <input
                type="text"
                placeholder="Search labs, categories, difficulty, or IDs"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="h-11 w-full rounded-lg border border-[#3b3d45] bg-[#15181e] pl-10 pr-4 text-sm font-medium text-white outline-none transition-colors placeholder:text-[#656a76] focus:border-[#2b89ff]"
              />
            </div>

            {!loading && labs.length > 0 && (
              <div className="flex flex-wrap gap-2">
                {['all', ...categories].map((category) => {
                  const active = activeCategory === category;
                  const meta = category === 'all' ? null : getCategoryMeta(category);
                  const Icon = meta?.Icon;
                  return (
                    <button
                      key={category}
                      type="button"
                      onClick={() => setActiveCategory(category)}
                      className={`inline-flex h-10 items-center gap-2 rounded-lg border px-3 text-sm font-semibold capitalize transition-colors ${
                        active
                          ? 'border-white bg-white text-black'
                          : 'border-[#3b3d45] bg-[#15181e] text-[#b2b6bd] hover:border-[#656a76] hover:text-white'
                      }`}
                    >
                      {Icon && <Icon className="h-4 w-4" />}
                      {category}
                    </button>
                  );
                })}
              </div>
            )}
          </div>
        </section>

        {loading ? (
          <div className="flex items-center justify-center rounded-xl border border-[#252830] bg-[#15181e] py-28">
            <RefreshCw className="h-7 w-7 animate-spin text-[#14c6cb]" />
          </div>
        ) : (
          <section className="space-y-5">
            {groupedLabs.map(({ category, labs: labsInCategory }) => {
              const meta = getCategoryMeta(category);
              const Icon = meta.Icon;

              return (
                <div key={category} className="overflow-hidden rounded-xl border border-[#252830] bg-[#15181e]">
                  <div className="flex flex-wrap items-center justify-between gap-3 border-b border-[#252830] px-4 py-4 md:px-5">
                    <div className="flex items-center gap-3">
                      <span className={`flex h-10 w-10 items-center justify-center rounded-lg border ${meta.accent}`}>
                        <Icon className="h-5 w-5" />
                      </span>
                      <div>
                        <h2 className="text-lg font-semibold capitalize leading-tight text-white">{meta.label}</h2>
                        <p className="mt-1 text-xs font-medium text-[#656a76]">
                          {labsInCategory.length} {labsInCategory.length === 1 ? 'lab' : 'labs'} sorted easy to hard
                        </p>
                      </div>
                    </div>
                  </div>

                  <div className="divide-y divide-[#252830]">
                    {labsInCategory.map((lab) => {
                      const completed = completedLabs.includes(lab.id);
                      return (
                        <article
                          key={lab.id}
                          className="group grid cursor-pointer gap-4 px-4 py-4 transition-colors hover:bg-[#1b1f26] md:grid-cols-[minmax(0,1fr)_auto] md:items-center md:px-5"
                          onClick={() => navigate(`/labs/${lab.id}?autoLaunch=true`)}
                        >
                          <div className="flex min-w-0 gap-4">
                            <div className={`mt-1 h-12 w-1.5 shrink-0 rounded-full ${meta.rail}`} />
                            <div className="min-w-0">
                              <div className="flex flex-wrap items-center gap-2">
                                <h3 className="text-base font-semibold leading-6 text-white">{lab.name}</h3>
                                {completed && (
                                  <span className="inline-flex h-7 items-center gap-1.5 rounded-md border border-[#00ca8e]/25 bg-[#00ca8e]/10 px-2 text-xs font-semibold text-[#00ca8e]">
                                    <CheckCircle2 className="h-3.5 w-3.5" />
                                    Done
                                  </span>
                                )}
                              </div>
                              <p className="mt-1 text-sm font-medium leading-6 text-[#b2b6bd]">{lab.description.summary}</p>
                              <div className="mt-3 flex flex-wrap items-center gap-2">
                                <span className={`rounded-md border px-2.5 py-1 text-xs font-semibold capitalize ${getDifficultyClass(lab.difficulty)}`}>
                                  {lab.difficulty}
                                </span>
                                <span className="rounded-md border border-[#3b3d45] bg-black px-2.5 py-1 text-xs font-semibold text-[#656a76]">
                                  {lab.id}
                                </span>
                              </div>
                            </div>
                          </div>

                          <button
                            type="button"
                            className="inline-flex h-10 w-full items-center justify-center gap-2 rounded-lg bg-white px-3 text-sm font-semibold text-black transition-colors hover:bg-[#e7e9ee] md:w-auto"
                            onClick={(event) => {
                              event.stopPropagation();
                              navigate(`/labs/${lab.id}?autoLaunch=true`);
                            }}
                          >
                            <Play className="h-4 w-4" />
                            Launch
                          </button>
                        </article>
                      );
                    })}
                  </div>
                </div>
              );
            })}
          </section>
        )}

        {!loading && filteredLabs.length === 0 && (
          <div className="rounded-xl border border-[#252830] bg-[#15181e] p-10 text-center">
            <p className="text-sm font-medium text-[#b2b6bd]">No labs match the current filters.</p>
          </div>
        )}
      </main>
    </div>
  );
}

function Metric({ value, label }: { value: number; label: string }) {
  return (
    <div className="rounded-lg border border-[#252830] bg-black p-3">
      <div className="text-2xl font-semibold text-white">{value}</div>
      <div className="mt-1 text-xs font-medium text-[#656a76]">{label}</div>
    </div>
  );
}
