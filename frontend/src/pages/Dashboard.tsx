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
  }, []);

  const CategoryIcon = ({ category }: { category: string }) => {
    switch (category) {
      case 'linux': return <Server className="w-5 h-5 text-blue-600" />;
      case 'security': return <Shield className="w-5 h-5 text-red-600" />;
      case 'networking': return <Network className="w-5 h-5 text-purple-600" />;
      default: return <Terminal className="w-5 h-5 text-gray-600" />;
    }
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
        <div className="mb-12 flex flex-col md:flex-row md:items-end justify-between gap-6">
          <div>
            <h1 className="text-4xl font-extrabold tracking-tight text-slate-900 mb-3">
              DevOps Training Labs
            </h1>
            <p className="text-slate-600 text-lg max-w-2xl font-medium">
              Launch intentionally broken environments. Troubleshoot real system issues. Verify your fixes in a reproducible sandbox.
            </p>
          </div>
        </div>

        {loading ? (
          <div className="flex items-center justify-center py-32">
            <RefreshCw className="w-8 h-8 text-blue-600 animate-spin" />
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {labs.map((lab) => (
              <div 
                key={lab.id} 
                className="group relative bg-white border border-slate-200 hover:border-blue-200 rounded-2xl p-6 transition-all duration-300 hover:-translate-y-1 shadow-sm hover:shadow-xl hover:shadow-blue-900/5 cursor-pointer"
                onClick={() => navigate(`/labs/${lab.id}?autoLaunch=true`)}
              >
                <div className="flex justify-between items-start mb-4">
                  <div className="flex items-center gap-3">
                    <div className="p-2.5 rounded-xl bg-slate-50 group-hover:bg-blue-50 group-hover:scale-110 transition-all duration-300">
                      <CategoryIcon category={lab.category} />
                    </div>
                    <div>
                      <h3 className="font-bold text-slate-800 group-hover:text-blue-700 transition-colors">{lab.name}</h3>
                      <span className="text-xs uppercase tracking-wider text-slate-500 font-bold">{lab.category}</span>
                    </div>
                  </div>
                  <span className={`text-xs px-2.5 py-1 rounded-full font-bold ${
                    lab.difficulty === 'beginner' ? 'bg-emerald-100 text-emerald-700 border border-emerald-200' : 
                    'bg-orange-100 text-orange-700 border border-orange-200'
                  }`}>
                    {lab.difficulty}
                  </span>
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
