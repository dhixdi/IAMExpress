import { useParams, useNavigate } from 'react-router-dom';
import { usePackage } from '../../hooks/usePackages';
import PageHeader from '../../components/common/PageHeader';
import StatusBadge from '../../components/common/StatusBadge';
import PackageMap from '../../components/maps/PackageMap';
import { formatDate } from '../../utils/formatDate';
import { formatCurrency } from '../../utils/formatCurrency';

export default function PackageDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { data: pkg, isLoading } = usePackage(id);

  if (isLoading) return <div>Loading...</div>;
  if (!pkg) return <div>Paket tidak ditemukan</div>;

  return (
    <div className="max-w-5xl mx-auto space-y-6">
      <PageHeader 
        title={`Detail Paket ${pkg.resi}`} 
        breadcrumb={[{ label: 'Dashboard', href: '/' }, { label: 'Packages', href: '/packages' }, { label: pkg.resi }]}
      />

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 space-y-6">
          <div className="bg-white rounded-xl shadow-card border border-gray-200 overflow-hidden">
            <div className="p-6 border-b border-gray-100 flex justify-between items-center bg-gray-50">
              <div>
                <p className="text-sm text-gray-500">Resi</p>
                <h2 className="text-2xl font-bold tracking-tight text-gray-900">{pkg.resi}</h2>
              </div>
              <div className="text-right">
                <StatusBadge status={pkg.current_status} />
                <p className="text-xs text-gray-500 mt-1">Dibuat: {formatDate(pkg.created_at)}</p>
              </div>
            </div>
            
            <div className="p-6 grid grid-cols-1 sm:grid-cols-2 gap-8">
              <div>
                <h3 className="text-sm font-semibold text-gray-900 uppercase tracking-wider mb-3">Pengirim</h3>
                <p className="font-medium text-gray-900">{pkg.no_hp_pengirim}</p>
                <p className="text-gray-600 text-sm mt-1">{pkg.alamat_pengirim}</p>
              </div>
              <div>
                <h3 className="text-sm font-semibold text-gray-900 uppercase tracking-wider mb-3">Penerima</h3>
                <p className="font-medium text-gray-900">{pkg.no_hp_penerima}</p>
                <p className="text-gray-600 text-sm mt-1">{pkg.alamat_tujuan}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-xl shadow-card border border-gray-200 p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Informasi Paket</h3>
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
              <div><p className="text-xs text-gray-500">Berat</p><p className="font-medium">{pkg.berat} kg</p></div>
              <div><p className="text-xs text-gray-500">Jenis Layanan</p><p className="font-medium">{pkg.jenis_layanan || '-'}</p></div>
              <div><p className="text-xs text-gray-500">Biaya</p><p className="font-medium">{formatCurrency(pkg.ongkos_kirim)}</p></div>
              <div><p className="text-xs text-gray-500">Gudang Saat Ini</p><p className="font-medium truncate" title={pkg.current_warehouse_name}>{pkg.current_warehouse_name || '-'}</p></div>
            </div>
            {pkg.deskripsi_barang && (
              <div className="mt-4 pt-4 border-t border-gray-100">
                <p className="text-xs text-gray-500">Catatan</p>
                <p className="text-sm text-gray-800">{pkg.deskripsi_barang}</p>
              </div>
            )}
          </div>
        </div>

        <div>
          <div className="bg-white rounded-xl shadow-card border border-gray-200 p-4 sticky top-6">
            <h3 className="text-sm font-semibold text-gray-900 mb-3">Lokasi Penerima</h3>
            <PackageMap 
              receiverLat={pkg.receiver_lat} 
              receiverLng={pkg.receiver_lng} 
              label={pkg.alamat_tujuan} 
              height="250px" 
            />
            
            <div className="mt-6 pt-4 border-t border-gray-100 space-y-2">
              <button onClick={() => navigate(`/packages/${id}/tracker`)} className="w-full text-center py-2 bg-navy-50 text-navy-900 font-medium rounded-md hover:bg-navy-100 transition-colors">
                Lihat Tracker
              </button>
              <button onClick={() => navigate(`/packages/${id}/assign`)} className="w-full text-center py-2 border border-gray-300 text-gray-700 font-medium rounded-md hover:bg-gray-50 transition-colors">
                Assign Kurir/Linehaul
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
