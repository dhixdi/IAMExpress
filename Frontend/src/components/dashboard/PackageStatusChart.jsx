import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip, Legend } from 'recharts';
import { PACKAGE_STATUS } from '../../constants/packageStatus';

// Mapping color similar to statusColor logic but for chart
const CHART_COLORS = {
  [PACKAGE_STATUS.CREATED]: '#D1D5DB', // gray
  [PACKAGE_STATUS.RECEIVED_AT_WAREHOUSE]: '#93C5FD', // light blue
  [PACKAGE_STATUS.ASSIGNED_TO_LINEHAUL]: '#A78BFA', // purple
  [PACKAGE_STATUS.PICKED_UP]: '#818CF8', // indigo
  [PACKAGE_STATUS.IN_TRANSIT]: '#FCD34D', // yellow
  [PACKAGE_STATUS.ARRIVED_AT_WAREHOUSE]: '#5EEAD4', // teal
  [PACKAGE_STATUS.ASSIGNED_TO_COURIER]: '#FDBA74', // orange light
  [PACKAGE_STATUS.OUT_FOR_DELIVERY]: '#FB923C', // orange
  [PACKAGE_STATUS.DELIVERED]: '#86EFAC', // green
  [PACKAGE_STATUS.FAILED_DELIVERY]: '#FCA5A5', // red
};

export default function PackageStatusChart({ data = [] }) {
  if (!data.length) {
    return <div className="flex items-center justify-center h-64 text-gray-500">Belum ada data</div>;
  }

  return (
    <div className="h-[300px] w-full">
      <ResponsiveContainer width="100%" height="100%">
        <PieChart>
          <Pie
            data={data}
            cx="50%"
            cy="50%"
            innerRadius={60}
            outerRadius={100}
            paddingAngle={2}
            dataKey="total"
            nameKey="status"
          >
            {data.map((entry, index) => (
              <Cell key={`cell-${index}`} fill={CHART_COLORS[entry.status] || '#CBD5E1'} />
            ))}
          </Pie>
          <Tooltip 
            formatter={(value) => [`${value} Paket`, 'Total']}
            contentStyle={{ borderRadius: '8px', border: '1px solid #E5E7EB', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
          />
          <Legend layout="vertical" verticalAlign="middle" align="right" />
        </PieChart>
      </ResponsiveContainer>
    </div>
  );
}
