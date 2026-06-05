import { useEffect, useRef } from 'react';
import { Terminal } from '@xterm/xterm';
import { FitAddon } from '@xterm/addon-fit';
import '@xterm/xterm/css/xterm.css';
import { ExternalLink } from 'lucide-react';

interface TerminalWindowProps {
  labId: string;
}

export default function TerminalWindow({ labId }: TerminalWindowProps) {
  const terminalRef = useRef<HTMLDivElement>(null);
  const socketRef = useRef<WebSocket | null>(null);
  const termRef = useRef<Terminal | null>(null);
  const fitAddonRef = useRef<FitAddon | null>(null);

  useEffect(() => {
    if (!terminalRef.current) return;

    const term = new Terminal({
      cursorBlink: true,
      theme: {
        background: '#0f172a',
        foreground: '#f8fafc',
        cursor: '#3b82f6',
      },
      fontFamily: '"FiraCode Nerd Font", "Hack Nerd Font", "MesloLGS NF", Menlo, Monaco, "Courier New", monospace',
      fontSize: 14,
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
      } catch (e) {}
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
    <div className="w-full h-full bg-slate-900 flex flex-col min-h-0 min-w-0">
      <div className="h-8 bg-slate-800 border-b border-slate-700 flex items-center justify-between px-4 select-none shrink-0">
        <span className="text-xs font-medium text-slate-400">root@{labId}:~</span>
        <button 
          onClick={() => window.open(`/labs/${labId}/terminal`, '_blank')}
          className="text-slate-400 hover:text-white transition-colors"
          title="Open in new tab"
        >
          <ExternalLink className="w-3.5 h-3.5" />
        </button>
      </div>
      <div className="flex-1 min-h-0 min-w-0 pl-4 pr-6 pb-6 pt-2 overflow-hidden" ref={terminalRef}></div>
    </div>
  );
}
