import { useState, useEffect, useRef, useCallback } from 'react';
import { useParams, useNavigate, useSearchParams } from 'react-router-dom';
import { ArrowLeft, Square, RotateCcw, CheckCircle, Loader2, Timer } from 'lucide-react';
import ReactMarkdown from 'react-markdown';
import TerminalWindow from '../TerminalWindow';

interface LabDetails {
  id: string;
  name: string;
  category: string;
  question: string;
  solution: string;
  exposed_ports: number[];
  verify_script?: string;
}

interface PortMapping {
  [vmPort: number]: number; // vm_port: host_port
}

interface LabStatus {
  status: string;
  ip: string | null;
  port_mappings?: PortMapping;
  host_ip?: string;
  hostname?: string;
  remaining_seconds?: number;
}

export default function LabView() {
  const { labId } = useParams();
  const navigate = useNavigate();
  const [searchParams, setSearchParams] = useSearchParams();
  const [lab, setLab] = useState<LabDetails | null>(null);
  const [loading, setLoading] = useState(true);
  const [showSolution, setShowSolution] = useState(false);
  const [actionLoading, setActionLoading] = useState<string | null>(null);
  
  // Provisioning state
  const [hasAutoLaunched, setHasAutoLaunched] = useState(false);
  const [provisioningStatus, setProvisioningStatus] = useState<'idle'|'launching'|'waiting_ip'|'provisioning'|'ready'>('idle');
  const [vmIp, setVmIp] = useState<string | null>(null);
  const [remainingSeconds, setRemainingSeconds] = useState<number | null>(null);
  const [portMappings, setPortMappings] = useState<PortMapping>({});
  
  // Verify state
  const [verifyResult, setVerifyResult] = useState<{score: string, output: string} | null>(null);
  const [isVerifying, setIsVerifying] = useState(false);

  // Split pane state
  const [leftWidth, setLeftWidth] = useState(50); // percentage
  const containerRef = useRef<HTMLDivElement>(null);
  const isDragging = useRef(false);

  useEffect(() => {
    const fetchLab = async () => {
      try {
        const res = await fetch(`/api/labs/${labId}`);
        if (res.ok) {
          const data = await res.json();
          setLab(data);
        }
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };
    fetchLab();
  }, [labId]);

  // Poll for status and IP
  useEffect(() => {
    const interval = setInterval(async () => {
      try {
        const res = await fetch(`/api/labs/${labId}/status`);
        if (res.ok) {
          const data: LabStatus = await res.json();
          setVmIp(data.ip);
          if (data.port_mappings) {
            setPortMappings(data.port_mappings);
          }
          if (data.status === 'running') {
            setProvisioningStatus('ready');
            if (data.remaining_seconds !== undefined) {
              setRemainingSeconds(data.remaining_seconds);
            }
          } else if (data.status === 'stopped') {
            setProvisioningStatus('idle');
            setVmIp(null);
            setRemainingSeconds(null);
            setPortMappings({});
            // If the lab expired and stopped behind our back, send them to dashboard
            if (provisioningStatus === 'ready') {
              alert('Lab time has expired! The environment was automatically destroyed.');
              navigate('/');
            }
          } else if (data.status === 'provisioning') {
            setProvisioningStatus('provisioning');
          }
        }
      } catch (e) {}
    }, 2000);
    return () => clearInterval(interval);
  }, [labId, provisioningStatus, navigate]);

  // Local timer for smooth countdown
  useEffect(() => {
    if (remainingSeconds === null || remainingSeconds <= 0) return;
    const interval = setInterval(() => {
      setRemainingSeconds(prev => prev !== null && prev > 0 ? prev - 1 : 0);
    }, 1000);
    return () => clearInterval(interval);
  }, [remainingSeconds !== null]);

  // Format time
  const formatTime = (secs: number) => {
    const m = Math.floor(secs / 60).toString().padStart(2, '0');
    const s = (secs % 60).toString().padStart(2, '0');
    return `${m}:${s}`;
  };

  const handleAction = async (action: 'launch' | 'stop' | 'reset') => {
    setActionLoading(action);
    if (action === 'launch' || action === 'reset') setProvisioningStatus('launching');
    
    try {
      const method = action === 'stop' ? 'DELETE' : 'POST';
      const res = await fetch(`/api/labs/${labId}/${action}`, { method });
      
      if (res.ok) {
        if (action === 'stop') {
          navigate('/');
        } else if (action === 'launch' || action === 'reset') {
          setProvisioningStatus('waiting_ip');
        }
      } else {
        const error = await res.json();
        alert(`Failed to ${action} lab: ${error.detail}`);
        setProvisioningStatus('idle');
      }
    } catch (err) {
      alert(`Network error during ${action}.`);
      setProvisioningStatus('idle');
    } finally {
      setActionLoading(null);
      if (action === 'stop' || action === 'reset') {
        setVerifyResult(null);
        setVmIp(null);
        setPortMappings({});
      }
    }
  };

  const handleVerify = async () => {
    setIsVerifying(true);
    try {
      const res = await fetch(`/api/labs/${labId}/verify`, { method: 'POST' });
      if (res.ok) {
        const data = await res.json();
        setVerifyResult(data);
        
        // Save completion status to localStorage
        if (data.score === '100') {
          const stored = JSON.parse(localStorage.getItem('completedLabs') || '[]');
          if (!stored.includes(labId)) {
            stored.push(labId);
            localStorage.setItem('completedLabs', JSON.stringify(stored));
          }
        }
      } else {
        const error = await res.json();
        alert(`Failed to verify: ${error.detail}`);
      }
    } catch (err) {
      alert('Network error during verification.');
    } finally {
      setIsVerifying(false);
    }
  };

  useEffect(() => {
    if (!loading && lab && searchParams.get('autoLaunch') === 'true' && !hasAutoLaunched) {
      setHasAutoLaunched(true);
      searchParams.delete('autoLaunch');
      setSearchParams(searchParams, { replace: true });
      handleAction('launch');
    }
  }, [loading, lab, searchParams, hasAutoLaunched, setSearchParams]);

  const startDragging = useCallback((e: React.MouseEvent) => {
    e.preventDefault();
    isDragging.current = true;
    document.body.style.cursor = 'col-resize';
  }, []);

  const onDrag = useCallback((e: MouseEvent) => {
    if (!isDragging.current || !containerRef.current) return;
    const containerRect = containerRef.current.getBoundingClientRect();
    const newLeftWidth = ((e.clientX - containerRect.left) / containerRect.width) * 100;
    
    if (newLeftWidth > 20 && newLeftWidth < 80) {
      setLeftWidth(newLeftWidth);
    }
  }, []);

  const stopDragging = useCallback(() => {
    isDragging.current = false;
    document.body.style.cursor = 'default';
  }, []);

  useEffect(() => {
    document.addEventListener('mousemove', onDrag);
    document.addEventListener('mouseup', stopDragging);
    return () => {
      document.removeEventListener('mousemove', onDrag);
      document.removeEventListener('mouseup', stopDragging);
    };
  }, [onDrag, stopDragging]);

  if (loading) return <div className="p-12 text-center">Loading lab...</div>;
  if (!lab) return <div className="p-12 text-center text-red-500">Lab not found.</div>;

  return (
    <div className="h-screen bg-slate-50 text-slate-900 flex flex-col overflow-hidden">
      {/* Navbar */}
      <nav className="border-b border-slate-200 bg-white px-6 h-16 flex items-center justify-between shadow-sm shrink-0 z-10">
        <div className="flex items-center gap-4">
          <button onClick={() => navigate('/')} className="p-2 hover:bg-slate-100 rounded-lg text-slate-600 transition-colors">
            <ArrowLeft className="w-5 h-5" />
          </button>
          <h1 className="text-xl font-bold text-slate-800">{lab.name}</h1>
        </div>
        <div className="flex items-center gap-3">
          {remainingSeconds !== null && provisioningStatus === 'ready' && (
            <div className={`flex items-center gap-2 px-3 py-1.5 rounded-md text-sm font-bold border ${remainingSeconds < 300 ? 'bg-red-50 text-red-600 border-red-200' : 'bg-slate-100 text-slate-700 border-slate-200'}`}>
              <Timer className="w-4 h-4" /> {formatTime(remainingSeconds)}
            </div>
          )}
          <button 
            onClick={handleVerify} disabled={isVerifying || provisioningStatus !== 'ready'}
            className="flex items-center gap-2 px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-md text-sm font-semibold transition-colors disabled:opacity-50"
          >
            <CheckCircle className="w-4 h-4" /> {isVerifying ? 'Verifying...' : 'Verify'}
          </button>
          <button 
            onClick={() => handleAction('stop')} disabled={!!actionLoading}
            className="flex items-center gap-2 px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-md text-sm font-semibold transition-colors disabled:opacity-50"
          >
            <Square className="w-4 h-4" /> {actionLoading === 'stop' ? 'Stopping...' : 'Stop'}
          </button>
          <button 
            onClick={() => handleAction('reset')} disabled={!!actionLoading}
            className="flex items-center gap-2 px-4 py-2 bg-amber-600 hover:bg-amber-700 text-white rounded-md text-sm font-semibold transition-colors disabled:opacity-50"
          >
            <RotateCcw className="w-4 h-4" /> {actionLoading === 'reset' ? 'Resetting...' : 'Reset'}
          </button>
        </div>
      </nav>

      {/* Split Pane Container */}
      <div className="flex-1 flex overflow-hidden min-h-0 min-w-0" ref={containerRef}>
        
        {/* Left Pane (Documentation) */}
        <div 
          className="h-full overflow-y-auto bg-slate-50 p-8 min-h-0"
          style={{ width: `${leftWidth}%` }}
        >
          <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-8 prose prose-slate max-w-none">
            <h2>Task Description</h2>
            {lab.question ? (
              <ReactMarkdown>{lab.question}</ReactMarkdown>
            ) : (
              <p>No specific markdown question provided for this lab.</p>
            )}

            {lab.exposed_ports && lab.exposed_ports.length > 0 && vmIp && provisioningStatus === 'ready' && (
              <div className="mt-8 p-4 bg-blue-50 border border-blue-100 rounded-lg">
                <p className="text-sm font-semibold text-blue-800 m-0 mb-3">🌐 Exposed Services (Remotely Accessible)</p>
                <div className="flex flex-wrap gap-3">
                  {lab.exposed_ports.map(vmPort => {
                    const hostPort = portMappings[vmPort];
                    // Use proxy endpoint for secure access without elevated privileges
                    const accessUrl = `/api/labs/${labId}/proxy/${vmPort}/`;
                    
                    return (
                      <div key={vmPort} className="flex flex-col gap-2">
                        <a 
                          href={accessUrl} 
                          target="_blank" 
                          rel="noopener noreferrer"
                          className="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white no-underline rounded-md text-sm font-semibold transition-colors"
                        >
                          Open Port {vmPort}
                        </a>
                        {hostPort && (
                          <span className="text-xs text-slate-600 text-center">
                            Proxied via Backend
                          </span>
                        )}
                      </div>
                    );
                  })}
                </div>
                <p className="text-xs text-slate-600 mt-3 mb-0">
                  ✓ These services are accessible from any device via secure reverse proxy
                </p>
              </div>
            )}

            <div className="mt-12 border-t border-slate-200 pt-8">
              {verifyResult && (
                <div className={`mb-6 p-6 border rounded-lg ${verifyResult.score === '100' ? 'bg-emerald-50 border-emerald-200 text-emerald-800' : 'bg-red-50 border-red-200 text-red-800'}`}>
                  <h3 className="mt-0">Verification Result: {verifyResult.score}/100</h3>
                  <pre className="mt-2 text-sm whitespace-pre-wrap font-mono bg-white p-4 rounded border border-slate-200 text-slate-900 font-bold shadow-sm">{verifyResult.output}</pre>
                </div>
              )}
              
              {verifyResult ? (
                <>
                  <button 
                    onClick={() => setShowSolution(!showSolution)}
                    className="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-800 rounded-md text-sm font-semibold transition-colors"
                  >
                    {showSolution ? 'Hide Solution' : 'Reveal Solution'}
                  </button>

                  {showSolution && (
                    <div className="mt-6 p-6 bg-amber-50 border border-amber-200 rounded-lg">
                      <h3 className="text-amber-800 mt-0">Solution Guide</h3>
                      {lab.solution ? (
                        <ReactMarkdown>{lab.solution}</ReactMarkdown>
                      ) : (
                        <p className="text-amber-700">No solution provided for this lab.</p>
                      )}
                    </div>
                  )}
                </>
              ) : (
                <div className="p-6 bg-slate-100 rounded-lg text-slate-600 text-sm text-center font-medium">
                  Submit verification to unlock the solution.
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Resizer Handle */}
        <div 
          className="w-1.5 bg-slate-200 hover:bg-blue-400 cursor-col-resize transition-colors shrink-0 z-10"
          onMouseDown={startDragging}
        />

        {/* Right Pane (Terminal / Loading) */}
        <div 
          className="h-full bg-slate-900 overflow-hidden relative min-h-0 min-w-0"
          style={{ width: `${100 - leftWidth}%` }}
        >
          {provisioningStatus !== 'ready' ? (
            <div className="absolute inset-0 flex flex-col items-center justify-center bg-slate-900 text-white z-20">
              <Loader2 className="w-12 h-12 text-blue-500 animate-spin mb-6" />
              <h3 className="text-xl font-bold text-slate-100 mb-2">
                {provisioningStatus === 'launching' ? 'Provisioning Environment' 
                 : provisioningStatus === 'provisioning' ? 'Configuring System' 
                 : 'Acquiring IP Address'}
              </h3>
              <p className="text-slate-400 text-sm">
                {provisioningStatus === 'launching' 
                  ? 'Allocating compute resources and attaching overlays...' 
                  : provisioningStatus === 'provisioning'
                  ? 'Waiting for cloud-init to install packages and configure the lab...'
                  : 'Waiting for network connectivity...'}
              </p>
            </div>
          ) : (
            <TerminalWindow labId={labId!} />
          )}
        </div>

      </div>
    </div>
  );
}
