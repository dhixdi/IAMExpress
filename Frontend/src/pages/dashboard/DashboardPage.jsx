import { useDashboard } from '../../hooks/useDashboard';
import { useAuthStore } from '../../store/authStore';
import PageHeader from '../../components/common/PageHeader';
import StatsCard from '../../components/dashboard/StatsCard';
import PackageStatusChart from '../../components/dashboard/PackageStatusChart';
import DataTable from '../../components/common/DataTable';
import { ROLES } from '../../constants/roles';

export default function DashboardPage() {
  const { data: dashboardResp, isLoading } = useDashboard();
  const { user } = useAuthStore();
  const isSuperAdmin = user?.role === ROLES.SUPER_ADMIN;

  const data = dashboardResp?.data || {};

  if (isLoading) {
    return <div className="animate-pulse space-y-6">
      <div className="h-10 w-48 bg-gray-200 rounded"></div>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {[1,2,3,4].map(i => <div key={i} className="h-28 bg-white rounded-lg border border-gray-100"></div>)}
      </div>
    </div>;
  }

  return (
    <div>
      <PageHeader title={`Selamat Datang, ${user?.nama}`} />

      {isSuperAdmin ? (
        <>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <StatsCard title="Total Gudang" value={data.total_warehouse || 0} icon="Warehouse" color="blue" />
            <StatsCard title="Total Staff" value={data.total_user || 0} icon="Users" color="green" />
            <StatsCard title="Paket Aktif" value={data.total_paket_aktif || 0} icon="Package" color="amber" />
            <StatsCard title="Total Terkirim" value={data.total_delivered || 0} icon="CheckCircle2" color="blue" />
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <div className="lg:col-span-2 bg-white rounded-xl shadow-card border border-gray-200 p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Breakdown per Gudang</h3>
              <DataTable 
                data={data.paket_per_warehouse || []}
                columns={[
                  { header: 'Nama Gudang', accessor: 'nama_gudang' },
                  { header: 'Total Paket Aktif', accessor: 'total' },
                ]}
              />
            </div>
            <div className="bg-white rounded-xl shadow-card border border-gray-200 p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Status Paket Aktif</h3>
              <PackageStatusChart data={data.paket_per_status || []} />
            </div>
          </div>
        </>
      ) : (
        <>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <StatsCard title="Paket di Gudang" value={data.paket_di_warehouse || 0} icon="Package" color="blue" />
            <StatsCard title="Menunggu Linehaul" value={data.menunggu_linehaul || 0} icon="Truck" color="amber" />
            <StatsCard title="Menunggu Courier" value={data.menunggu_courier || 0} icon="Bike" color="amber" />
            <StatsCard title="Terkirim Hari Ini" value={data.delivered_hari_ini || 0} icon="CheckCircle2" color="green" />
          </div>
        </>
      )}
    </div>
  );
}
