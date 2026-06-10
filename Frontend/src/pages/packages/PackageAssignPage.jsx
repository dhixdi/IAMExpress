import { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { usePackage, useUpdatePackageStatus } from '../../hooks/usePackages';
import PageHeader from '../../components/common/PageHeader';
import AssignModal from '../../components/packages/AssignModal';
import StatusBadge from '../../components/common/StatusBadge';
import { PACKAGE_STATUS } from '../../constants/packageStatus';

export default function PackageAssignPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { data: pkg, isLoading } = usePackage(id);
  const { mutate: updateStatus, isPending } = useUpdatePackageStatus();

  const [modalType, setModalType] = useState(null); // 'linehaul' | 'courier' | null

  if (isLoading) return <div>Loading...</div>;
  if (!pkg) return <div>Paket tidak ditemukan</div>;

  const handleUpdateStatus = (newStatus) => {
    updateStatus({ id, status: newStatus, notes: `Status diperbarui oleh Admin ke ${newStatus}` });
  };

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <PageHeader 
        title={`Penugasan & Status Paket: ${pkg.resi}`} 
        breadcrumb={[{ label: 'Dashboard', href: '/' }, { label: 'Packages', href: '/packages' }, { label: 'Assign' }]}
      />

      <div className="bg-white p-6 rounded-xl shadow-card border border-gray-200">
        <div className="flex justify-between items-center mb-6 border-b pb-4">
          <div>
            <p className="text-sm text-gray-500">Status Saat Ini</p>
            <div className="mt-1"><StatusBadge status={pkg.current_status} /></div>
          </div>
          <div className="text-right">
            <p className="text-sm text-gray-500">Gudang Saat Ini</p>
            <p className="font-medium">{pkg.CurrentWarehouse?.nama_gudang || '-'}</p>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="space-y-4 border p-4 rounded-lg bg-gray-50">
            <h3 className="font-semibold text-gray-900">Linehaul (Antar Gudang)</h3>
            <p className="text-sm text-gray-600">Assign ke driver linehaul untuk pengiriman antar warehouse.</p>
            <button 
              onClick={() => setModalType('linehaul')}
              disabled={!pkg.current_warehouse_id}
              className="w-full py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700 disabled:opacity-50"
            >
              Pilih Linehaul
            </button>
          </div>

          <div className="space-y-4 border p-4 rounded-lg bg-gray-50">
            <h3 className="font-semibold text-gray-900">Courier (Last Mile)</h3>
            <p className="text-sm text-gray-600">Assign ke kurir untuk pengiriman ke alamat tujuan.</p>
            <button 
              onClick={() => setModalType('courier')}
              disabled={!pkg.current_warehouse_id || pkg.current_warehouse_id !== pkg.destination_warehouse_id}
              className="w-full py-2 bg-amber-600 text-white rounded hover:bg-amber-700 disabled:opacity-50"
            >
              Pilih Courier
            </button>
            {pkg.current_warehouse_id !== pkg.destination_warehouse_id && (
              <p className="text-xs text-red-500 font-medium">Kurir hanya bisa di-assign jika paket sudah berada di Gudang Tujuan.</p>
            )}
          </div>
        </div>

        <div className="mt-8 pt-6 border-t border-gray-200">
          <h3 className="font-semibold text-gray-900 mb-4">Update Status Manual</h3>
          <div className="flex flex-wrap gap-2">
            {[PACKAGE_STATUS.RECEIVED_AT_WAREHOUSE, PACKAGE_STATUS.ARRIVED_AT_WAREHOUSE, PACKAGE_STATUS.FAILED_DELIVERY].map(s => (
              <button 
                key={s} onClick={() => handleUpdateStatus(s)} disabled={isPending || pkg.current_status === s}
                className="px-3 py-1.5 border border-gray-300 rounded text-sm hover:bg-gray-100 disabled:opacity-50"
              >
                Set: {s}
              </button>
            ))}
          </div>
        </div>
      </div>

      <AssignModal 
        open={!!modalType}
        type={modalType}
        packageId={id}
        warehouseId={pkg.current_warehouse_id}
        onClose={() => setModalType(null)}
        onSuccess={() => setModalType(null)}
      />
    </div>
  );
}
