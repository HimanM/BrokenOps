import { Link } from 'react-router-dom';
import { ArrowLeft, ShieldAlert } from 'lucide-react';

export default function NotFound() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-black px-5 text-white">
      <div className="w-full max-w-lg rounded-xl border border-[#252830] bg-[#15181e] p-8">
        <div className="mb-6 flex h-12 w-12 items-center justify-center rounded-lg border border-[#e62b1e]/25 bg-[#e62b1e]/10 text-[#ff8a82]">
          <ShieldAlert className="h-6 w-6" />
        </div>
        <div className="text-xs font-semibold uppercase tracking-[0.06em] text-[#656a76]">404</div>
        <h1 className="mt-2 text-3xl font-bold leading-tight tracking-normal text-white">Destination not found</h1>
        <p className="mt-4 text-sm font-medium leading-6 text-[#b2b6bd]">
          The route is unavailable, or the requested lab service is not exposed by the current environment.
        </p>
        <Link
          to="/"
          className="mt-8 inline-flex h-10 items-center gap-2 rounded-lg bg-white px-4 text-sm font-semibold text-black no-underline transition-colors hover:bg-[#e7e9ee]"
        >
          <ArrowLeft className="h-4 w-4" />
          Return to inventory
        </Link>
      </div>
    </div>
  );
}
