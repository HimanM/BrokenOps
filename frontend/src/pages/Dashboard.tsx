import { useState, useEffect } from 'react';
import { Terminal, Server, Shield, Network, RefreshCw, Search, Filter, Play } from 'lucide-react';
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

export default function Dashboard() {
  const [labs, setLabs] = useState<Lab[]>([]);
  const [loading, setLoading] = useState(true);
  const [completedLabs, setCompletedLabs] = useState<string[]>([]);
  const [activeCategory, setActiveCategory] = useState<string>('all');
  const navigate = useNavigate();

  useEffect(() => {
    const fetchLabs = async () => {
      try {
        const res = await fetch('http://localhost:8080/labs');
        if (res.ok) {
          const data = await res.json();
          setLabs(data);
        }
      } catch (err) {
        console.log("Using fallback data");
        setLabs([
          {
            id: 'nginx-broken',
            name: 'Nginx Service Down',
            category: 'linux',
            difficulty: 'beginner',
            description: { summary: 'Nginx is not running after reboot' }
          }
        ]);
      } finally {
        setLoading(false);
      }
    };
    fetchLabs();

    const stored = localStorage.getItem('completedLabs');
    if (stored) {
      setCompletedLabs(JSON.parse(stored));
    }
  }, []);

  const getCategoryIcon = (category: string) => {
    switch (category) {
      case 'linux': return <Server className="w-5 h-5" />;
      case 'security': return <Shield className="w-5 h-5" />;
      case 'networking': return <Network className="w-5 h-5" />;
      default: return <Terminal className="w-5 h-5" />;
    }
  };

  const getDifficultyColor = (difficulty: string) => {
    return difficulty === 'beginner'
      ? 'bg-emerald-100 text-emerald-700'
      : 'bg-orange-100 text-orange-700';
  };

  return (
    <div className="min-h-screen bg-slate-50 text-slate-900 font-sans selection:bg-blue-500/20">
      <div className="fixed inset-0 overflow-hidden pointer-events-none -z-10">
        <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] rounded-full bg-blue-400/20 blur-[120px]"></div>
        <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] rounded-full bg-indigo-400/20 blur-[120px]"></div>
      </div>

      <nav className="sticky top-0 z-50 border-b border-slate-200/50 bg-white/70 backdrop-blur-xl shadow-sm">
        <div className="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-blue-600 to-indigo-600 flex items-center justify-center shadow-lg shadow-blue-500/20">
              <Terminal className="w-5 h-5 text-white" />
            </div>
            <span className="text-xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-blue-700 to-indigo-700">
              BrokenOps
            </span>
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto px-6 py-12">
        <div className="mb-12 flex flex-col lg:flex-row lg:items-end justify-between gap-6">
          <div>
            <h1 className="text-4xl font-extrabold tracking-tight text-slate-900 mb-3">
              DevOps Training Labs
            </h1>
            <p className="text-slate-600 text-lg max-w-2xl font-medium">
              Launch intentionally broken environments. Troubleshoot real system issues. Verify your fixes in a reproducible sandbox.
            </p>
          </div>

          {!loading && labs.length > 0 && (
            <div className="flex flex-wrap gap-2 bg-slate-100/80 backdrop-blur p-1.5 rounded-xl border border-slate-200/60">
              {['all', ...Array.from(new Set(labs.map(lab => lab.category)))].map(category => (
                <button
                  key={category}
                  onClick={() => setActiveCategory(category)}
                  className={`px-4 py-2 rounded-lg text-sm font-bold uppercase tracking-wider transition-all ${activeCategory === category
                      ? 'bg-white shadow-sm text-blue-700 border border-slate-200/50'
                      : 'text-slate-500 hover:text-slate-800 hover:bg-slate-200/50 border border-transparent'
                    }`}
                >
                  {category}
                </button>
              ))}
            </div>
          )}
        </div>

        {loading ? (
          <div className="flex items-center justify-center py-32">
            <RefreshCw className="w-8 h-8 text-blue-600 animate-spin" />
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {(activeCategory === 'all' ? labs : labs.filter(lab => lab.category === activeCategory)).map((lab) => (
              <div
                key={lab.id}
                className="group relative bg-white border border-slate-200 hover:border-blue-200 rounded-2xl p-6 transition-all duration-300 hover:-translate-y-1 shadow-sm hover:shadow-xl hover:shadow-blue-900/5 cursor-pointer"
                onClick={() => navigate(`/labs/${lab.id}?autoLaunch=true`)}
              >
                <div className="flex justify-between items-start mb-4">
                  <div className="flex items-center gap-3">
                    <div className="p-3 bg-blue-50 text-blue-600 rounded-xl group-hover:bg-blue-600 group-hover:text-white transition-colors duration-300">
                      {getCategoryIcon(lab.category)}
                    </div>
                    <div>
                      <h3 className="font-bold text-slate-800 text-lg mb-1">{lab.name}</h3>
                      <div className="flex items-center gap-2">
                        <span className="text-xs font-semibold px-2.5 py-1 bg-slate-100 text-slate-600 rounded-md uppercase tracking-wider">
                          {lab.category}
                        </span>
                        <span className={`text-xs font-semibold px-2.5 py-1 rounded-md uppercase tracking-wider ${getDifficultyColor(lab.difficulty)}`}>
                          {lab.difficulty}
                        </span>
                      </div>
                    </div>
                  </div>
                  {completedLabs.includes(lab.id) && (
                    <div className="flex items-center gap-1.5 px-3 py-1.5 bg-emerald-100 text-emerald-700 rounded-full text-xs font-bold shadow-sm border border-emerald-200">
                      <svg className="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={3}>
                        <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                      </svg>
                      COMPLETED
                    </div>
                  )}
                </div>

                <p className="text-sm text-slate-600 mb-6 font-medium">
                  {lab.description.summary}
                </p>

                <div className="pt-4 border-t border-slate-100 flex gap-3">
                  <button className="flex-1 flex items-center justify-center gap-2 bg-slate-100 group-hover:bg-blue-600 group-hover:text-white text-slate-700 py-2.5 rounded-lg text-sm font-bold transition-all">
                    <Play className="w-4 h-4" /> View Lab
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>
    </div>
  );
}
