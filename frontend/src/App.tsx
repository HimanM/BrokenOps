import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Dashboard from './pages/Dashboard';
import LabView from './pages/LabView';
import StandaloneTerminal from './pages/StandaloneTerminal';
import NotFound from './pages/NotFound';

export default function App() {
  return (
    <>
      <div className="flex min-h-screen items-center justify-center bg-black px-6 text-center text-white lg:hidden">
        <div className="max-w-sm rounded-2xl border border-[#252830] bg-[#12151b] p-8">
          <img src="/brokenops-mark.png" alt="BrokenOps" className="mx-auto h-12 w-12" />
          <h1 className="mt-5 text-2xl font-semibold">Desktop required</h1>
          <p className="mt-3 text-sm leading-6 text-[#8d93a1]">
            BrokenOps is currently optimized for desktop displays. Open the app on a larger screen to launch labs and use the terminal workspace.
          </p>
        </div>
      </div>

      <div className="hidden lg:block">
        <BrowserRouter>
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/labs/:labId" element={<LabView />} />
            <Route path="/labs/:labId/terminal" element={<StandaloneTerminal />} />
            <Route path="/404" element={<NotFound />} />
            <Route path="*" element={<NotFound />} />
          </Routes>
        </BrowserRouter>
      </div>
    </>
  );
}
