import { formatDate } from '../../utils/formatDate';
import { statusColor } from '../../utils/statusColor';

export default function PackageStatusTimeline({ entries = [] }) {
  if (!entries.length) {
    return <p className="text-gray-500 text-sm">Belum ada riwayat status.</p>;
  }

  return (
    <div className="relative border-l border-gray-200 ml-3 space-y-6">
      {entries.map((entry, index) => {
        const isLatest = index === 0;
        return (
          <div key={entry.tracker_id || index} className="relative pl-6">
            <span className={`absolute -left-[9px] top-1 h-4 w-4 rounded-full border-2 border-white ${isLatest ? 'bg-navy-900 ring-4 ring-navy-100' : 'bg-gray-300'}`}></span>
            
            <div className="flex flex-col sm:flex-row sm:items-baseline gap-1 sm:gap-4 mb-1">
              <span className={`inline-flex px-2 py-0.5 rounded text-xs font-medium border ${statusColor(entry.status)}`}>
                {entry.status}
              </span>
              <time className="text-xs text-gray-500">{formatDate(entry.timestamp)}</time>
            </div>
            
            {entry.notes && (
              <p className="text-sm text-gray-700 mt-1">{entry.notes}</p>
            )}
            
            <div className="mt-2 text-xs text-gray-500">
              {entry.User ? `Oleh: ${entry.User.nama} (${entry.User.role})` : 'Sistem'} 
              {entry.Warehouse && ` • Lokasi: ${entry.Warehouse.nama_gudang}`}
            </div>
          </div>
        );
      })}
    </div>
  );
}
