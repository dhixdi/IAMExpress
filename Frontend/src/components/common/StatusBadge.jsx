import { statusColor } from '../../utils/statusColor';

export default function StatusBadge({ status }) {
  if (!status) return null;
  const colorClass = statusColor(status);

  return (
    <span className={`inline-flex items-center px-2 py-0.5 rounded text-xs font-medium border ${colorClass}`}>
      {status}
    </span>
  );
}
