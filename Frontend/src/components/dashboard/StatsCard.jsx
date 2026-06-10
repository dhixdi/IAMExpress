import * as Icons from 'lucide-react';

export default function StatsCard({ title, value, icon, trend, color = 'blue' }) {
  const IconComponent = Icons[icon] || Icons.Box;

  const colorStyles = {
    blue: 'bg-blue-100 text-blue-600',
    green: 'bg-green-100 text-green-600',
    amber: 'bg-amber-100 text-amber-600',
    red: 'bg-red-100 text-red-600',
  };

  return (
    <div className="bg-white rounded-lg p-6 shadow-card border border-gray-200">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm font-medium text-gray-500 truncate">{title}</p>
          <div className="mt-1 flex items-baseline gap-2">
            <p className="text-3xl font-bold text-gray-950">{value}</p>
          </div>
        </div>
        <div className={`p-3 rounded-full ${colorStyles[color] || colorStyles.blue}`}>
          <IconComponent size={24} />
        </div>
      </div>
      {trend && (
        <div className="mt-4">
          <span className="text-sm text-gray-500">{trend}</span>
        </div>
      )}
    </div>
  );
}
