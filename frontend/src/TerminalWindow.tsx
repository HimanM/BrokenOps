import { useEffect, useRef } from 'react';
import { Terminal } from '@xterm/xterm';
import { FitAddon } from '@xterm/addon-fit';
import '@xterm/xterm/css/xterm.css';
import { ExternalLink } from 'lucide-react';

interface TerminalWindowProps {
  labId: string;
  embedded?: boolean;
}

export default function TerminalWindow({ labId, embedded = false }: TerminalWindowProps) {
  const terminalRef = useRef<HTMLDivElement>(null);
  const socketRef = useRef<WebSocket | null>(null);
  const termRef = useRef<Terminal | null>(null);
  const fitAddonRef = useRef<FitAddon | null>(null);

  useEffect(() => {
    if (!terminalRef.current) return;

    const term = new Terminal({
      cursorBlink: true,
      theme: {
        background: '#000000',
        foreground: '#f4f4f5',
        cursor: '#14c6cb',
        black: '#000000',
        blue: '#2b89ff',
        cyan: '#14c6cb',
        green: '#00ca8e',
        red: '#e62b1e',
        yellow: '#ffcf25',
      },
      fontFamily: '"JetBrains Mono", "FiraCode Nerd Font", "Hack Nerd Font", "MesloLGS NF", Menlo, Monaco, "Courier New", monospace',
      fontSize: 14,
      lineHeight: 1.2,
    });
    
    const fitAddon = new FitAddon();
    term.loadAddon(fitAddon);
    
    term.open(terminalRef.current);
    
    // Initial fit
    setTimeout(() => {
      fitAddon.fit();
    }, 50);
    
    termRef.current = term;
    fitAddonRef.current = fitAddon;

    term.writeln('\x1b[1;34m[BrokenOps]\x1b[0m Starting terminal connection...');

    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const wsUrl = `${protocol}//${window.location.host}/ws/labs/${labId}/terminal`;
    const ws = new WebSocket(wsUrl);
    socketRef.current = ws;

    ws.onopen = () => {
      term.onData((data) => {
        if (ws.readyState === WebSocket.OPEN) {
          ws.send(JSON.stringify({ type: 'data', data }));
        }
      });
      
      ws.onmessage = (event) => {
        term.write(event.data);
      };

      // Fit after connection and send initial size
      setTimeout(() => {
        fitAddon.fit();
        if (ws.readyState === WebSocket.OPEN && termRef.current) {
          ws.send(JSON.stringify({ 
            type: 'resize', 
            cols: termRef.current.cols, 
            rows: termRef.current.rows 
          }));
        }
      }, 100);
    };

    ws.onclose = () => {
      term.writeln('\r\n\x1b[1;31m[BrokenOps]\x1b[0m Connection closed.');
    };

    ws.onerror = () => {
      term.writeln('\r\n\x1b[1;31m[BrokenOps]\x1b[0m Connection error.');
    };

    // Robust resize handling
    const handleResize = () => {
      try {
        fitAddon.fit();
        if (ws.readyState === WebSocket.OPEN && termRef.current) {
          ws.send(JSON.stringify({ 
            type: 'resize', 
            cols: termRef.current.cols, 
            rows: termRef.current.rows 
          }));
        }
      } catch {
        return;
      }
    };

    const resizeObserver = new ResizeObserver(handleResize);
    resizeObserver.observe(terminalRef.current);
    window.addEventListener('resize', handleResize);

    return () => {
      resizeObserver.disconnect();
      window.removeEventListener('resize', handleResize);
      if (ws.readyState === WebSocket.OPEN) {
        ws.close();
      }
      term.dispose();
    };
  }, [labId]);

  return (
    <div className="flex h-full min-h-0 min-w-0 flex-col bg-black">
      {!embedded && (
        <div className="flex h-11 shrink-0 select-none items-center justify-between border-b border-[#252830] bg-[#15181e] px-4">
          <span className="text-xs font-semibold text-[#b2b6bd]">root@{labId}:~</span>
          <button
            type="button"
            onClick={() => window.open(`/labs/${labId}/terminal`, '_blank')}
            className="rounded-md p-1.5 text-[#656a76] transition-colors hover:bg-[#1f232b] hover:text-white"
            title="Open in new tab"
          >
            <ExternalLink className="h-3.5 w-3.5" />
          </button>
        </div>
      )}
      <div className="min-h-0 min-w-0 flex-1 overflow-hidden px-4 pb-8 pt-3">
        <div className="h-full w-full min-h-0 min-w-0" ref={terminalRef}></div>
      </div>
    </div>
  );
}
