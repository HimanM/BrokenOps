import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Dashboard from './pages/Dashboard';
import LabView from './pages/LabView';
import StandaloneTerminal from './pages/StandaloneTerminal';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Dashboard />} />
        <Route path="/labs/:labId" element={<LabView />} />
        <Route path="/labs/:labId/terminal" element={<StandaloneTerminal />} />
      </Routes>
    </BrowserRouter>
  );
}
