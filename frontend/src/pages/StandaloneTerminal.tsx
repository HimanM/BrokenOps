import { useParams } from 'react-router-dom';
import TerminalWindow from '../TerminalWindow';

export default function StandaloneTerminal() {
  const { labId } = useParams();

  return (
    <div className="w-screen h-screen">
      {labId ? <TerminalWindow labId={labId} /> : <div>No Lab ID provided</div>}
    </div>
  );
}
