import { useEffect, useState, type ComponentType, type ReactNode } from 'react';
import { CheckCircle2, Play, RefreshCw, Search } from 'lucide-react';
import { FaGithub, FaLinux, FaNetworkWired } from 'react-icons/fa';
import { SiDocker, SiHackthebox } from 'react-icons/si';
import { TbDatabase, TbWorldWww } from 'react-icons/tb';
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

const repoUrl = 'https://github.com/HimanM/BrokenOps';

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
  containers: {
    label: 'Containers',
    accent: 'text-[#2b89ff] bg-[#2b89ff]/10 border-[#2b89ff]/25',
    rail: 'bg-[#2b89ff]',
    Icon: SiDocker,
  },
  databases: {
    label: 'Databases',
    accent: 'text-[#c084fc] bg-[#c084fc]/10 border-[#c084fc]/25',
    rail: 'bg-[#c084fc]',
    Icon: TbDatabase,
  },
  web: {
    label: 'Web',
    accent: 'text-[#fb7185] bg-[#fb7185]/10 border-[#fb7185]/25',
    rail: 'bg-[#fb7185]',
    Icon: TbWorldWww,
  },
};

const fallbackMeta: CategoryMeta = {
  label: 'Operations',
  accent: 'text-[#d6d8dc] bg-[#1f232b] border-[#3b3d45]',
  rail: 'bg-[#656a76]',
  Icon: FaNetworkWired,
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

  const totalSolved = completedLabs.length;
  const activeLabel = activeCategory === 'all' ? 'All categories' : getCategoryMeta(activeCategory).label;
  const categoryCounts = new Map<string, number>();
  for (const lab of labs) {
    categoryCounts.set(lab.category, (categoryCounts.get(lab.category) ?? 0) + 1);
  }

  return (
    <div className="min-h-screen bg-[#050608] text-white selection:bg-[#2b89ff]/30">
      <nav className="sticky top-0 z-40 border-b border-[#252830] bg-black/90 backdrop-blur">
        <div className="mx-auto flex h-16 w-full max-w-[1900px] items-center justify-between px-6 xl:px-10">
          <button
            type="button"
            onClick={() => navigate('/')}
            className="flex items-center gap-3 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#2b89ff]"
          >
            <img src="/brokenops-mark.png" alt="BrokenOps" className="h-8 w-8" />
            <span>
              <span className="block text-sm font-semibold leading-none text-white">BrokenOps</span>
              <span className="mt-1 block text-xs font-medium leading-none text-[#656a76]">
                Hands-on lab control plane
                <span className="mx-1 text-[#3b3d45]">/</span>
                by <span className="text-[#b2b6bd]">HimanM</span>
              </span>
            </span>
          </button>

          <div className="hidden items-center gap-4 md:flex">
            <span className="text-sm font-medium text-[#656a76]">{labs.length} labs indexed</span>
            <span className="text-sm font-medium text-[#656a76]">{totalSolved} completed</span>
          </div>
        </div>
      </nav>

      <main className="mx-auto w-full max-w-[1900px] px-6 py-6 xl:px-10 xl:py-8">
        <div className="grid gap-6 xl:grid-cols-[minmax(240px,1fr)_minmax(920px,1040px)_minmax(240px,1fr)]">
          <aside className="hidden xl:block">
            <div className="sticky top-24 space-y-4">
              <div className="rounded-2xl border border-[#252830] bg-[#12151b] p-4">
                <div className="text-xs font-semibold uppercase tracking-[0.08em] text-[#14c6cb]">Browse</div>
                <div className="mt-4 space-y-2">
                  <FilterButton
                    active={activeCategory === 'all'}
                    label="All categories"
                    count={labs.length}
                    onClick={() => setActiveCategory('all')}
                  />
                  {categories.map((category) => {
                    const meta = getCategoryMeta(category);
                    return (
                      <FilterButton
                        key={category}
                        active={activeCategory === category}
                        label={meta.label}
                        count={categoryCounts.get(category) ?? 0}
                        icon={<meta.Icon className="h-4 w-4" />}
                        onClick={() => setActiveCategory(category)}
                      />
                    );
                  })}
                </div>
              </div>

              <div className="rounded-2xl border border-[#252830] bg-[#12151b] p-4">
                <div className="text-xs font-semibold uppercase tracking-[0.08em] text-[#656a76]">Current filter</div>
                <p className="mt-3 text-sm font-semibold text-white">{activeLabel}</p>
                <p className="mt-2 text-sm leading-6 text-[#8d93a1]">
                  {filteredLabs.length} matching labs ordered by difficulty so you can move from quick wins into sharper failure modes.
                </p>
              </div>

              <div className="rounded-2xl border border-[#252830] bg-[#12151b] p-4">
                <div className="text-xs font-semibold uppercase tracking-[0.08em] text-[#656a76]">Difficulty ladder</div>
                <div className="mt-4 space-y-3">
                  <DifficultyRow tone="easy" label="Beginner" body="Fast repair loops and first-pass service failures." />
                  <DifficultyRow tone="mid" label="Intermediate" body="Root-cause hunting across config, permissions, and state." />
                  <DifficultyRow tone="hard" label="Advanced" body="Multi-step breakage where the first symptom is not the real issue." />
                </div>
              </div>
            </div>
          </aside>

          <section className="min-w-0">
            <div className="rounded-[28px] border border-[#252830] bg-[linear-gradient(180deg,#12151b_0%,#0b0d11_100%)] p-5 shadow-[0_24px_80px_rgba(0,0,0,0.28)] lg:p-6">
              <div className="max-w-3xl">
                <div className="text-xs font-semibold uppercase tracking-[0.08em] text-[#14c6cb]">Operations lab inventory</div>
                <h1 className="mt-3 text-3xl font-bold leading-[1.08] tracking-normal text-white md:text-5xl">
                  Practice incident response inside disposable Linux systems.
                </h1>
                <p className="mt-4 max-w-2xl text-base leading-7 text-[#b2b6bd]">
                  Launch intentionally broken environments, debug from the shell, and verify repairs against the lab checks without polluting your host.
                </p>
              </div>

              <div className="mt-6 grid gap-4 border-t border-[#252830] pt-5 lg:grid-cols-[minmax(0,1fr)_240px] lg:items-end">
                <div className="min-w-0">
                  <div className="relative w-full">
                    <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-[#656a76]" />
                    <input
                      type="text"
                      placeholder="Search labs, categories, difficulty, or IDs"
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      className="h-12 w-full rounded-xl border border-[#3b3d45] bg-[#15181e] pl-10 pr-4 text-sm font-medium text-white outline-none transition-colors placeholder:text-[#656a76] focus:border-[#2b89ff]"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-3 gap-3">
                  <Metric value={labs.length} label="Labs" compact />
                  <Metric value={categories.length} label="Domains" compact />
                  <Metric value={totalSolved} label="Solved" compact />
                </div>
              </div>

              {!loading && labs.length > 0 && (
                <div className="mt-4 flex items-center justify-between gap-3 border-t border-[#252830] pt-4 text-sm">
                  <div className="text-[#8d93a1]">Showing {filteredLabs.length} of {labs.length} labs</div>
                  <div className="text-[#8d93a1]">{activeLabel}</div>
                </div>
              )}

              {!loading && labs.length > 0 && (
                <div className="mt-4 flex gap-2 overflow-x-auto pb-1 xl:hidden">
                  <MobileChip active={activeCategory === 'all'} label="All" onClick={() => setActiveCategory('all')} />
                  {categories.map((category) => {
                    const meta = getCategoryMeta(category);
                    return (
                      <MobileChip
                        key={category}
                        active={activeCategory === category}
                        label={meta.label}
                        icon={<meta.Icon className="h-4 w-4" />}
                        onClick={() => setActiveCategory(category)}
                      />
                    );
                  })}
                </div>
              )}
            </div>

            {loading ? (
              <div className="mt-6 flex items-center justify-center rounded-2xl border border-[#252830] bg-[#12151b] py-28">
                <RefreshCw className="h-7 w-7 animate-spin text-[#14c6cb]" />
              </div>
            ) : groupedLabs.length > 0 ? (
              <div className={`mt-6 grid gap-5 ${activeCategory === 'all' ? '2xl:grid-cols-2' : ''}`}>
                {groupedLabs.map(({ category, labs: labsInCategory }) => {
                  const meta = getCategoryMeta(category);
                  const Icon = meta.Icon;

                  return (
                    <div key={category} className="overflow-hidden rounded-2xl border border-[#252830] bg-[#12151b]">
                      <div className="flex items-center justify-between gap-3 border-b border-[#252830] px-4 py-4 lg:px-5">
                        <div className="flex min-w-0 items-center gap-3">
                          <span className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-xl border ${meta.accent}`}>
                            <Icon className="h-5 w-5" />
                          </span>
                          <div className="min-w-0">
                            <h2 className="text-lg font-semibold leading-tight text-white">{meta.label}</h2>
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
                              className="group grid gap-4 px-4 py-4 transition-colors hover:bg-[#181b21] md:grid-cols-[minmax(0,1fr)_auto] md:items-center lg:px-5"
                            >
                              <button
                                type="button"
                                onClick={() => navigate(`/labs/${lab.id}?autoLaunch=true`)}
                                className="flex min-w-0 items-start gap-4 text-left"
                              >
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
                                  <p className="mt-1 text-sm leading-6 text-[#b2b6bd]">{lab.description.summary}</p>
                                  <div className="mt-3 flex flex-wrap items-center gap-2">
                                    <span className={`rounded-md border px-2.5 py-1 text-xs font-semibold capitalize ${getDifficultyClass(lab.difficulty)}`}>
                                      {lab.difficulty}
                                    </span>
                                    <span className="rounded-md border border-[#3b3d45] bg-black px-2.5 py-1 text-xs font-semibold text-[#656a76]">
                                      {lab.id}
                                    </span>
                                  </div>
                                </div>
                              </button>

                              <button
                                type="button"
                                className="inline-flex h-10 items-center justify-center gap-2 rounded-lg bg-white px-3 text-sm font-semibold text-black transition-colors hover:bg-[#e7e9ee]"
                                onClick={() => navigate(`/labs/${lab.id}?autoLaunch=true`)}
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
              </div>
            ) : (
              <div className="mt-6 rounded-2xl border border-[#252830] bg-[#12151b] p-10 text-center">
                <p className="text-sm font-medium text-[#b2b6bd]">No labs match the current filters.</p>
              </div>
            )}

            <footer className="mt-8 border-t border-[#252830] pt-5 text-sm text-[#656a76] xl:hidden">
              <p>BrokenOps is built for realistic Linux, network, platform, and service troubleshooting practice.</p>
            </footer>
          </section>

          <aside className="hidden xl:block">
            <div className="sticky top-24 space-y-4">
              <div className="rounded-2xl border border-[#252830] bg-[#12151b] p-4">
                <div className="text-xs font-semibold uppercase tracking-[0.08em] text-[#656a76]">Inventory</div>
                <div className="mt-4 grid gap-3">
                  <Metric value={labs.length} label="Labs" />
                  <Metric value={categories.length} label="Domains" />
                </div>
              </div>

              <div className="rounded-2xl border border-[#252830] bg-[#12151b] p-4">
                <div className="text-xs font-semibold uppercase tracking-[0.08em] text-[#656a76]">Progress</div>
                <p className="mt-3 text-3xl font-semibold text-white">{totalSolved}</p>
                <p className="mt-1 text-sm leading-6 text-[#8d93a1]">Completed labs tracked locally in this browser profile.</p>
              </div>

              <div className="rounded-2xl border border-[#252830] bg-[#12151b] p-4">
                <div className="text-xs font-semibold uppercase tracking-[0.08em] text-[#656a76]">Project</div>
                <a
                  href={repoUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="mt-3 inline-flex h-10 items-center gap-2 rounded-lg border border-[#3b3d45] bg-[#15181e] px-3 text-sm font-semibold text-[#b2b6bd] transition-colors hover:border-[#656a76] hover:text-white"
                >
                  <FaGithub className="h-4 w-4" />
                  HimanM/BrokenOps
                </a>
                <p className="mt-3 text-sm leading-6 text-[#8d93a1]">
                  Open the repository for setup docs, lab sources, and the host-side tooling behind the platform.
                </p>
              </div>

              <div className="rounded-2xl border border-[#252830] bg-[#12151b] p-4 text-sm text-[#656a76]">
                <p>BrokenOps is built for realistic Linux, network, platform, and service troubleshooting practice.</p>
              </div>
            </div>
          </aside>
        </div>
      </main>
    </div>
  );
}

function FilterButton({
  active,
  label,
  count,
  icon,
  onClick,
}: {
  active: boolean;
  label: string;
  count: number;
  icon?: ReactNode;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={`flex w-full items-center justify-between rounded-xl border px-3 py-3 text-left text-sm font-semibold transition-colors ${
        active
          ? 'border-white bg-white text-black'
          : 'border-[#252830] bg-[#0b0d11] text-[#b2b6bd] hover:border-[#3b3d45] hover:text-white'
      }`}
    >
      <span className="flex items-center gap-2">
        {icon}
        {label}
      </span>
      <span className={`${active ? 'text-black/70' : 'text-[#656a76]'}`}>{count}</span>
    </button>
  );
}

function MobileChip({
  active,
  label,
  icon,
  onClick,
}: {
  active: boolean;
  label: string;
  icon?: ReactNode;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={`inline-flex h-10 shrink-0 items-center gap-2 rounded-lg border px-3 text-sm font-semibold transition-colors ${
        active
          ? 'border-white bg-white text-black'
          : 'border-[#3b3d45] bg-[#15181e] text-[#b2b6bd] hover:border-[#656a76] hover:text-white'
      }`}
    >
      {icon}
      {label}
    </button>
  );
}

function DifficultyRow({
  tone,
  label,
  body,
}: {
  tone: 'easy' | 'mid' | 'hard';
  label: string;
  body: string;
}) {
  const tones = {
    easy: 'bg-[#00ca8e]',
    mid: 'bg-[#ffcf25]',
    hard: 'bg-[#e62b1e]',
  };

  return (
    <div className="rounded-xl border border-[#252830] bg-[#0b0d11] p-3">
      <div className="flex items-center gap-2 text-sm font-semibold text-white">
        <span className={`h-2.5 w-2.5 rounded-full ${tones[tone]}`} />
        {label}
      </div>
      <p className="mt-2 text-sm leading-6 text-[#8d93a1]">{body}</p>
    </div>
  );
}

function Metric({
  value,
  label,
  compact = false,
}: {
  value: number;
  label: string;
  compact?: boolean;
}) {
  return (
    <div
      className={`rounded-xl border border-[#252830] bg-black ${
        compact ? 'flex h-[74px] flex-col justify-between px-3 py-3' : 'p-4'
      }`}
    >
      <div className={`${compact ? 'text-[17px] leading-none' : 'text-2xl'} font-semibold tracking-normal text-white`}>{value}</div>
      <div className={`${compact ? 'text-[11px] leading-none' : 'text-xs'} font-medium text-[#6e7480]`}>{label}</div>
    </div>
  );
}
