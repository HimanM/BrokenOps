import { useParams } from 'react-router-dom';
import TerminalWindow from '../TerminalWindow';

export default function StandaloneTerminal() {
  const { labId } = useParams();

  return (
    <div className="h-screen w-screen bg-black text-white">
      {labId ? (
        <TerminalWindow labId={labId} />
      ) : (
        <div className="flex h-full items-center justify-center">
          <div className="rounded-xl border border-[#252830] bg-[#15181e] p-6 text-sm font-medium text-[#b2b6bd]">
            No lab ID provided.
          </div>
        </div>
      )}
    </div>
  );
}
