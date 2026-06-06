import { Link } from 'react-router-dom';
import { ShieldAlert } from 'lucide-react';

export default function NotFound() {
  return (
    <div className="min-h-screen bg-slate-50 flex flex-col items-center justify-center text-slate-900 p-4">
      <ShieldAlert className="w-24 h-24 text-blue-500 mb-6" />
      <h1 className="text-4xl font-bold mb-2">404 - Destination Not Found</h1>
      <p className="text-slate-500 text-lg mb-8 max-w-md text-center">
        The port or service you are trying to access is not exposed by this lab, or the page does not exist.
      </p>
      <Link 
        to="/" 
        className="px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-semibold transition-colors"
      >
        Return to Dashboard
      </Link>
    </div>
  );
}
