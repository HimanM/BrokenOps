import { useEffect, useRef, useState } from 'react';
import { Terminal } from '@xterm/xterm';
import { FitAddon } from '@xterm/addon-fit';
import { AttachAddon } from '@xterm/addon-attach';
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
      fontFamily: 'Menlo, Monaco, "Courier New", monospace',
      fontSize: 14,
    });
    
    const fitAddon = new FitAddon();
    term.loadAddon(fitAddon);
    
    term.open(terminalRef.current);
    fitAddon.fit();
    
    termRef.current = term;
    fitAddonRef.current = fitAddon;

    term.writeln('\x1b[1;34m[BrokenOps]\x1b[0m Starting terminal connection...');

    const ws = new WebSocket(`ws://localhost:8080/labs/${labId}/terminal`);
    socketRef.current = ws;

    ws.onopen = () => {
      const attachAddon = new AttachAddon(ws);
      term.loadAddon(attachAddon);
    };

    ws.onclose = () => {
      term.writeln('\r\n\x1b[1;31m[BrokenOps]\x1b[0m Connection closed.');
    };

    ws.onerror = () => {
      term.writeln('\r\n\x1b[1;31m[BrokenOps]\x1b[0m Connection error.');
    };

    const resizeObserver = new ResizeObserver(() => {
      fitAddon.fit();
    });
    resizeObserver.observe(terminalRef.current);

    return () => {
      resizeObserver.disconnect();
      if (ws.readyState === WebSocket.OPEN) {
        ws.close();
      }
      term.dispose();
    };
  }, [labId]);

  return (
    <div className="w-full h-full bg-slate-900 flex flex-col">
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
      <div className="flex-1 p-2 min-h-0 overflow-hidden" ref={terminalRef}></div>
    </div>
  );
}
