import { useState, useEffect, useRef, useCallback, type ComponentType, type ReactNode } from 'react';
import { useParams, useNavigate, useSearchParams } from 'react-router-dom';
import {
  ArrowLeft,
  CheckCircle2,
  Clock3,
  ExternalLink,
  Loader2,
  PanelLeft,
  RotateCcw,
  Square,
  Terminal,
} from 'lucide-react';
import { FaGithub, FaLinux, FaNetworkWired } from 'react-icons/fa';
import { SiDocker, SiGnubash, SiHackthebox, SiKubernetes } from 'react-icons/si';
import { TbDatabase, TbWorldWww } from 'react-icons/tb';
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

type ProvisioningStatus = 'idle' | 'launching' | 'waiting_ip' | 'provisioning' | 'ready';
type DialogVariant = 'info' | 'success' | 'error';

interface AppDialog {
  title: string;
  message: string;
  variant: DialogVariant;
  confirmLabel?: string;
  onConfirm?: () => void;
}

const categoryIcons: Record<string, ComponentType<{ className?: string }>> = {
  linux: FaLinux,
  security: SiHackthebox,
  networking: FaNetworkWired,
  docker: SiDocker,
  containers: SiDocker,
  databases: TbDatabase,
  web: TbWorldWww,
  kubernetes: SiKubernetes,
};

const repoUrl = 'https://github.com/HimanM/BrokenOps';

const statusCopy: Record<ProvisioningStatus, { title: string; body: string }> = {
  idle: {
    title: 'Environment idle',
    body: 'Launch the lab to create a disposable VM.',
  },
  launching: {
    title: 'Provisioning environment',
    body: 'Creating the overlay disk, cloud-init ISO, and libvirt domain.',
  },
  waiting_ip: {
    title: 'Waiting for network',
    body: 'The VM is booting and waiting for a DHCP lease.',
  },
  provisioning: {
    title: 'Configuring system',
    body: 'Cloud-init is installing packages and applying the broken state.',
  },
  ready: {
    title: 'Terminal ready',
    body: 'Connected to the lab VM.',
  },
};

export default function LabView() {
  const { labId } = useParams();
  const navigate = useNavigate();
  const [searchParams, setSearchParams] = useSearchParams();
  const [lab, setLab] = useState<LabDetails | null>(null);
  const [loading, setLoading] = useState(true);
  const [showSolution, setShowSolution] = useState(false);
  const [actionLoading, setActionLoading] = useState<string | null>(null);
  const [showStopConfirm, setShowStopConfirm] = useState(false);
  const [dialog, setDialog] = useState<AppDialog | null>(null);
  const manualStopInProgress = useRef(false);

  const hasAutoLaunched = useRef(false);
  const [provisioningStatus, setProvisioningStatus] = useState<ProvisioningStatus>('idle');
  const [vmIp, setVmIp] = useState<string | null>(null);
  const [remainingSeconds, setRemainingSeconds] = useState<number | null>(null);

  const [verifyResult, setVerifyResult] = useState<{ score: string; output: string } | null>(null);
  const [isVerifying, setIsVerifying] = useState(false);

  const [leftWidth, setLeftWidth] = useState(46);
  const containerRef = useRef<HTMLDivElement>(null);
  const isDragging = useRef(false);

  const showDialog = useCallback((nextDialog: AppDialog) => {
    setDialog(nextDialog);
  }, []);

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

  useEffect(() => {
    const interval = setInterval(async () => {
      try {
        const res = await fetch(`/api/labs/${labId}/status`);
        if (res.ok) {
          const data = await res.json();
          setVmIp(data.ip);
          if (data.status === 'running' && data.ip) {
            setProvisioningStatus('ready');
            if (data.remaining_seconds !== undefined) {
              setRemainingSeconds(data.remaining_seconds);
            }
          } else if (data.status === 'stopped') {
            setProvisioningStatus('idle');
            setVmIp(null);
            setRemainingSeconds(null);
            if (provisioningStatus === 'ready' && !manualStopInProgress.current) {
              showDialog({
                title: 'Lab time expired',
                message: 'The environment was automatically destroyed.',
                variant: 'info',
                confirmLabel: 'Back to inventory',
                onConfirm: () => navigate('/'),
              });
            }
          } else if (data.status === 'provisioning') {
            setProvisioningStatus('provisioning');
          } else if (data.status === 'running' && provisioningStatus !== 'launching') {
            setProvisioningStatus('waiting_ip');
          }
        }
      } catch (error) {
        console.error('Failed to fetch lab status', error);
      }
    }, 2000);
    return () => clearInterval(interval);
  }, [labId, provisioningStatus, navigate, showDialog]);

  const hasCountdown = remainingSeconds !== null && remainingSeconds > 0;

  useEffect(() => {
    if (!hasCountdown) return;
    const interval = setInterval(() => {
      setRemainingSeconds((prev) => (prev !== null && prev > 0 ? prev - 1 : 0));
    }, 1000);
    return () => clearInterval(interval);
  }, [hasCountdown]);

  const formatTime = (secs: number) => {
    const m = Math.floor(secs / 60).toString().padStart(2, '0');
    const s = (secs % 60).toString().padStart(2, '0');
    return `${m}:${s}`;
  };

  const handleAction = useCallback(
    async (action: 'launch' | 'stop' | 'reset') => {
      setActionLoading(action);
      if (action === 'launch' || action === 'reset') setProvisioningStatus('launching');

      try {
        const method = action === 'stop' ? 'DELETE' : 'POST';
        const res = await fetch(`/api/labs/${labId}/${action}`, { method });

        if (res.ok) {
          if (action === 'stop') {
            showDialog({
              title: 'Lab stopped',
              message: 'The environment was manually destroyed.',
              variant: 'success',
              confirmLabel: 'Back to inventory',
              onConfirm: () => navigate('/'),
            });
          } else if (action === 'launch' || action === 'reset') {
            setProvisioningStatus('waiting_ip');
          }
        } else {
          const error = await res.json();
          showDialog({
            title: `Failed to ${action} lab`,
            message: String(error.detail ?? 'The backend returned an unexpected error.'),
            variant: 'error',
          });
          setProvisioningStatus('idle');
        }
      } catch (err) {
        console.error(`Network error during ${action}`, err);
        showDialog({
          title: `Network error during ${action}`,
          message: 'The request could not reach the backend. Check the stack and try again.',
          variant: 'error',
        });
        setProvisioningStatus('idle');
      } finally {
        setActionLoading(null);
        if (action === 'stop') {
          manualStopInProgress.current = false;
        }
        if (action === 'stop' || action === 'reset') {
          setVerifyResult(null);
          setVmIp(null);
        }
      }
    },
    [labId, navigate, showDialog],
  );

  const confirmStopLab = () => {
    manualStopInProgress.current = true;
    setShowStopConfirm(false);
    handleAction('stop');
  };

  const handleVerify = async () => {
    setIsVerifying(true);
    try {
      const res = await fetch(`/api/labs/${labId}/verify`, { method: 'POST' });
      if (res.ok) {
        const data = await res.json();
        setVerifyResult(data);

        if (data.score === '100') {
          const stored = JSON.parse(localStorage.getItem('completedLabs') || '[]');
          if (!stored.includes(labId)) {
            stored.push(labId);
            localStorage.setItem('completedLabs', JSON.stringify(stored));
          }
        }
      } else {
        const error = await res.json();
        showDialog({
          title: 'Verification failed',
          message: String(error.detail ?? 'The backend returned an unexpected verification error.'),
          variant: 'error',
        });
      }
    } catch (err) {
      console.error('Network error during verification', err);
      showDialog({
        title: 'Network error during verification',
        message: 'The request could not reach the backend. Check the stack and try again.',
        variant: 'error',
      });
    } finally {
      setIsVerifying(false);
    }
  };

  useEffect(() => {
    if (!loading && lab && searchParams.get('autoLaunch') === 'true' && !hasAutoLaunched.current) {
      hasAutoLaunched.current = true;
      searchParams.delete('autoLaunch');
      setSearchParams(searchParams, { replace: true });
      handleAction('launch');
    }
  }, [loading, lab, searchParams, setSearchParams, handleAction]);

  const startDragging = useCallback((e: React.MouseEvent) => {
    e.preventDefault();
    isDragging.current = true;
    document.body.style.cursor = 'col-resize';
  }, []);

  const onDrag = useCallback((e: MouseEvent) => {
    if (!isDragging.current || !containerRef.current) return;
    const containerRect = containerRef.current.getBoundingClientRect();
    const newLeftWidth = ((e.clientX - containerRect.left) / containerRect.width) * 100;

    if (newLeftWidth > 28 && newLeftWidth < 68) {
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

  if (loading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-black text-white">
        <RefreshState label="Loading lab" />
      </div>
    );
  }

  if (!lab) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-black px-6 text-center text-white">
        <div className="max-w-md rounded-xl border border-[#252830] bg-[#15181e] p-8">
          <h1 className="text-xl font-semibold">Lab not found</h1>
          <button
            type="button"
            onClick={() => navigate('/')}
            className="mt-6 h-10 rounded-lg bg-white px-4 text-sm font-semibold text-black"
          >
            Back to inventory
          </button>
        </div>
      </div>
    );
  }

  const status = statusCopy[provisioningStatus];
  const ready = provisioningStatus === 'ready';
  const verifyPassed = verifyResult?.score === '100';
  const CategoryIcon = categoryIcons[lab.category.toLowerCase()] ?? SiGnubash;

  return (
    <div className="flex h-screen flex-col overflow-hidden bg-black text-white">
      {showStopConfirm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 px-4 backdrop-blur-sm" role="dialog" aria-modal="true">
          <div className="w-full max-w-md rounded-xl border border-[#3b3d45] bg-[#15181e] p-6">
            <h2 className="text-xl font-semibold leading-tight text-white">Stop this lab?</h2>
            <p className="mt-3 text-sm font-medium leading-6 text-[#b2b6bd]">
              The VM will be destroyed and any unsaved work inside the environment will be lost.
            </p>
            <div className="mt-6 flex justify-end gap-3">
              <button
                type="button"
                onClick={() => setShowStopConfirm(false)}
                className="h-10 rounded-lg border border-[#3b3d45] bg-[#1f232b] px-4 text-sm font-semibold text-white"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={confirmStopLab}
                className="h-10 rounded-lg bg-[#e62b1e] px-4 text-sm font-semibold text-white"
              >
                Stop lab
              </button>
            </div>
          </div>
        </div>
      )}

      {dialog && (
        <AppModal
          dialog={dialog}
          onClose={() => {
            const onConfirm = dialog.onConfirm;
            setDialog(null);
            onConfirm?.();
          }}
        />
      )}

      <nav className="z-20 flex h-16 shrink-0 items-center justify-between border-b border-[#252830] bg-black px-4 lg:px-6">
        <div className="flex min-w-0 items-center gap-3">
          <button
            type="button"
            onClick={() => navigate('/')}
            className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg border border-[#3b3d45] bg-[#15181e] text-[#b2b6bd] transition-colors hover:text-white"
            title="Back to inventory"
          >
            <ArrowLeft className="h-4 w-4" />
          </button>
          <div className="min-w-0">
            <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-[0.06em] text-[#14c6cb]">
              <CategoryIcon className="h-3.5 w-3.5" />
              {lab.category}
            </div>
            <h1 className="truncate text-base font-semibold leading-6 text-white md:text-lg">{lab.name}</h1>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <a
            href={repoUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="hidden h-10 items-center gap-2 rounded-lg border border-[#3b3d45] bg-[#15181e] px-3 text-sm font-semibold text-[#b2b6bd] transition-colors hover:text-white md:inline-flex"
          >
            <FaGithub className="h-4 w-4" />
            Repo
          </a>
          {remainingSeconds !== null && ready && (
            <div
              className={`hidden h-10 items-center gap-2 rounded-lg border px-3 text-sm font-semibold md:flex ${
                remainingSeconds < 300
                  ? 'border-[#e62b1e]/30 bg-[#e62b1e]/10 text-[#ff8a82]'
                  : 'border-[#3b3d45] bg-[#15181e] text-[#b2b6bd]'
              }`}
            >
              <Clock3 className="h-4 w-4" />
              {formatTime(remainingSeconds)}
            </div>
          )}
          <CommandButton
            icon={<CheckCircle2 className="h-4 w-4" />}
            label={isVerifying ? 'Verifying' : 'Verify'}
            disabled={isVerifying || !ready}
            onClick={handleVerify}
            variant="primary"
          />
          <CommandButton
            icon={<Square className="h-4 w-4" />}
            label={actionLoading === 'stop' ? 'Stopping' : 'Stop'}
            disabled={!!actionLoading}
            onClick={() => setShowStopConfirm(true)}
            variant="danger"
          />
          <CommandButton
            icon={<RotateCcw className="h-4 w-4" />}
            label={actionLoading === 'reset' ? 'Resetting' : 'Reset'}
            disabled={!!actionLoading}
            onClick={() => handleAction('reset')}
            variant="secondary"
          />
        </div>
      </nav>

      <div ref={containerRef} className="flex min-h-0 min-w-0 flex-1 flex-col overflow-hidden lg:flex-row">
        <section
          className="min-h-0 w-full overflow-y-auto border-b border-[#252830] bg-black lg:h-full lg:border-b-0"
          style={{ flexBasis: `${leftWidth}%` }}
        >
          <div className="space-y-5 p-4 lg:p-6">
            <div className="rounded-xl border border-[#252830] bg-[#15181e]">
              <div className="flex items-center justify-between border-b border-[#252830] px-5 py-4">
                <div>
                  <div className="text-xs font-semibold uppercase tracking-[0.06em] text-[#656a76]">Brief</div>
                  <h2 className="mt-1 text-xl font-semibold leading-tight text-white">Task description</h2>
                </div>
                <PanelLeft className="h-5 w-5 text-[#656a76]" />
              </div>
              <div className="prose prose-invert max-w-none p-5 prose-headings:tracking-normal prose-p:text-[#d6d8dc] prose-li:text-[#d6d8dc] prose-strong:text-white prose-code:text-[#14c6cb] prose-pre:border prose-pre:border-[#252830] prose-pre:bg-black">
                {lab.question ? <ReactMarkdown>{lab.question}</ReactMarkdown> : <p>No task brief was provided for this lab.</p>}
              </div>
            </div>

            {lab.exposed_ports && lab.exposed_ports.length > 0 && vmIp && ready && (
              <div className="rounded-xl border border-[#14c6cb]/20 bg-[#14c6cb]/10 p-5">
                <div className="text-xs font-semibold uppercase tracking-[0.06em] text-[#14c6cb]">Exposed services</div>
                <div className="mt-4 flex flex-wrap gap-3">
                  {lab.exposed_ports.map((port) => (
                    <a
                      key={port}
                      href={`/labs/${lab.id}/port${port}/`}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex h-10 items-center gap-2 rounded-lg bg-white px-3 text-sm font-semibold text-black no-underline"
                    >
                      Port {port}
                      <ExternalLink className="h-4 w-4" />
                    </a>
                  ))}
                </div>
              </div>
            )}

            <div className="rounded-xl border border-[#252830] bg-[#15181e] p-5">
              <div className="flex items-start justify-between gap-4">
                <div>
                  <div className="text-xs font-semibold uppercase tracking-[0.06em] text-[#656a76]">Verification</div>
                  <h2 className="mt-1 text-xl font-semibold leading-tight text-white">
                    {verifyResult ? `Score ${verifyResult.score}/100` : 'Solution locked'}
                  </h2>
                </div>
                {verifyResult && (
                  <span
                    className={`rounded-lg border px-3 py-1 text-xs font-semibold ${
                      verifyPassed ? 'border-[#00ca8e]/25 bg-[#00ca8e]/10 text-[#00ca8e]' : 'border-[#e62b1e]/25 bg-[#e62b1e]/10 text-[#ff8a82]'
                    }`}
                  >
                    {verifyPassed ? 'Passed' : 'Needs work'}
                  </span>
                )}
              </div>

              {verifyResult ? (
                <div className="mt-5">
                  <pre className="max-h-56 overflow-auto rounded-lg border border-[#252830] bg-black p-4 text-sm font-medium leading-6 text-[#d6d8dc]">
                    {verifyResult.output}
                  </pre>
                  <button
                    type="button"
                    onClick={() => setShowSolution(!showSolution)}
                    className="mt-4 h-10 rounded-lg border border-[#3b3d45] bg-[#1f232b] px-4 text-sm font-semibold text-white"
                  >
                    {showSolution ? 'Hide solution' : 'Reveal solution'}
                  </button>
                </div>
              ) : (
                <p className="mt-4 text-sm font-medium leading-6 text-[#b2b6bd]">
                  Run verification after you repair the system. The solution guide becomes available after a verification attempt.
                </p>
              )}

              {verifyResult && showSolution && (
                <div className="prose prose-invert mt-5 max-w-none rounded-lg border border-[#ffcf25]/20 bg-[#ffcf25]/10 p-5 prose-headings:text-white prose-p:text-[#fbeabf] prose-li:text-[#fbeabf] prose-code:text-[#ffcf25]">
                  {lab.solution ? <ReactMarkdown>{lab.solution}</ReactMarkdown> : <p>No solution guide was provided for this lab.</p>}
                </div>
              )}
            </div>
          </div>
        </section>

        <div
          className="hidden w-1.5 shrink-0 cursor-col-resize bg-[#252830] transition-colors hover:bg-[#2b89ff] lg:block"
          onMouseDown={startDragging}
        />

        <section className="min-h-[45vh] min-w-0 flex-1 bg-black px-0 pb-4 lg:h-full lg:px-0 lg:pb-5" style={{ flexBasis: `${100 - leftWidth}%` }}>
          <div className="flex h-full flex-col overflow-hidden rounded-t-none rounded-b-none border-l border-[#252830] bg-black">
            <div className="flex h-12 shrink-0 items-center justify-between border-b border-[#252830] bg-[#15181e] px-4">
            <div className="flex items-center gap-2">
              <Terminal className="h-4 w-4 text-[#14c6cb]" />
              <span className="text-sm font-semibold text-white">root@{lab.id}</span>
            </div>
            <span className="hidden text-xs font-medium text-[#656a76] md:inline">{vmIp || 'No IP lease'}</span>
            </div>

            <div className="relative min-h-0 flex-1 overflow-hidden bg-black">
              {!ready ? (
                <div className="absolute inset-0 flex flex-col items-center justify-center bg-black px-6 text-center">
                  <RefreshState label={status.title} />
                  <p className="mt-3 max-w-md text-sm font-medium leading-6 text-[#b2b6bd]">{status.body}</p>
                </div>
              ) : (
                <TerminalWindow labId={labId!} embedded />
              )}
            </div>
          </div>
        </section>
      </div>
    </div>
  );
}

function CommandButton({
  icon,
  label,
  disabled,
  onClick,
  variant,
}: {
  icon: ReactNode;
  label: string;
  disabled?: boolean;
  onClick: () => void;
  variant: 'primary' | 'secondary' | 'danger';
}) {
  const variants = {
    primary: 'bg-white text-black hover:bg-[#e7e9ee]',
    secondary: 'border border-[#3b3d45] bg-[#1f232b] text-white hover:border-[#656a76]',
    danger: 'bg-[#e62b1e] text-white hover:bg-[#c92419]',
  };

  return (
    <button
      type="button"
      onClick={onClick}
      disabled={disabled}
      className={`inline-flex h-10 items-center gap-2 rounded-lg px-3 text-sm font-semibold transition-colors disabled:cursor-not-allowed disabled:opacity-45 ${variants[variant]}`}
    >
      {icon}
      <span className="hidden sm:inline">{label}</span>
    </button>
  );
}

function AppModal({ dialog, onClose }: { dialog: AppDialog; onClose: () => void }) {
  const variantClasses: Record<DialogVariant, string> = {
    info: 'border-[#14c6cb]/25 bg-[#14c6cb]/10 text-[#14c6cb]',
    success: 'border-[#00ca8e]/25 bg-[#00ca8e]/10 text-[#00ca8e]',
    error: 'border-[#e62b1e]/25 bg-[#e62b1e]/10 text-[#ff8a82]',
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 px-4 backdrop-blur-sm" role="dialog" aria-modal="true">
      <div className="w-full max-w-md rounded-xl border border-[#3b3d45] bg-[#15181e] p-6 shadow-2xl shadow-black/50">
        <div className={`mb-4 h-1.5 w-16 rounded-full ${variantClasses[dialog.variant]}`} />
        <h2 className="text-xl font-semibold leading-tight text-white">{dialog.title}</h2>
        <p className="mt-3 text-sm font-medium leading-6 text-[#b2b6bd]">{dialog.message}</p>
        <div className="mt-6 flex justify-end">
          <button type="button" onClick={onClose} className="h-10 rounded-lg bg-white px-4 text-sm font-semibold text-black">
            {dialog.confirmLabel ?? 'Close'}
          </button>
        </div>
      </div>
    </div>
  );
}

function RefreshState({ label }: { label: string }) {
  return (
    <div className="flex items-center gap-3">
      <Loader2 className="h-5 w-5 animate-spin text-[#14c6cb]" />
      <span className="text-sm font-semibold text-white">{label}</span>
    </div>
  );
}
