import { useParams, useNavigate } from 'react-router-dom';
import { useWarehouse, useDeleteWarehouse } from '../../hooks/useWarehouses';
import PageHeader from '../../components/common/PageHeader';
import ConfirmDialog from '../../components/common/ConfirmDialog';
import WarehouseMap from '../../components/maps/WarehouseMap';
import { useState } from 'react';
import { Edit2, Trash2, MapPin } from 'lucide-react';

export default function WarehouseDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { data: warehouse, isLoading } = useWarehouse(id);
  const { mutate: deleteWarehouse } = useDeleteWarehouse();
  const [showConfirm, setShowConfirm] = useState(false);

  if (isLoading) return <div>Loading...</div>;
  if (!warehouse) return <div>Gudang tidak ditemukan</div>;

  const handleDelete = () => {
    deleteWarehouse(id, {
      onSuccess: () => navigate('/warehouses')
    });
  };

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <PageHeader 
        title="Detail Gudang" 
        breadcrumb={[{ label: 'Dashboard', href: '/' }, { label: 'Warehouses', href: '/warehouses' }, { label: warehouse.nama_gudang }]}
        action={
          <div className="flex gap-2">
            <button onClick={() => navigate(`/warehouses/${id}/edit`)} className="bg-white border border-gray-300 text-gray-700 px-4 py-2 rounded-md hover:bg-gray-50 flex items-center gap-2 text-sm font-medium">
              <Edit2 size={16} /> Edit
            </button>
            <button onClick={() => setShowConfirm(true)} className="bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700 flex items-center gap-2 text-sm font-medium">
              <Trash2 size={16} /> Hapus
            </button>
          </div>
        }
      />

      <div className="bg-white rounded-xl shadow-card border border-gray-200 overflow-hidden">
        <div className="p-6">
          <div className="flex items-center gap-3 mb-4">
            <div className="p-3 bg-navy-50 rounded-full text-navy-900">
              <MapPin size={24} />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-gray-900">{warehouse.nama_gudang}</h2>
              <p className="text-gray-500 text-sm">ID: {warehouse.warehouse_id}</p>
            </div>
          </div>
          
          <div className="mt-6 border-t border-gray-100 pt-6">
            <h3 className="text-sm font-medium text-gray-500 uppercase tracking-wider mb-2">Alamat Lengkap</h3>
            <p className="text-gray-900 leading-relaxed max-w-2xl">{warehouse.alamat}</p>
            
            <div className="mt-4 flex gap-6 text-sm text-gray-600">
              <div><span className="font-medium text-gray-500">Latitude:</span> {warehouse.lat || '-'}</div>
              <div><span className="font-medium text-gray-500">Longitude:</span> {warehouse.lng || '-'}</div>
            </div>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-xl shadow-card border border-gray-200 p-4">
        <h3 className="text-lg font-semibold text-gray-900 mb-4 px-2">Lokasi Peta</h3>
        <WarehouseMap warehouses={[warehouse]} height="400px" />
      </div>

      <ConfirmDialog 
        open={showConfirm}
        title="Hapus Gudang"
        description={`Apakah Anda yakin ingin menghapus ${warehouse.nama_gudang}? Pastikan tidak ada paket di gudang ini.`}
        onConfirm={handleDelete}
        onCancel={() => setShowConfirm(false)}
        variant="destructive"
      />
    </div>
  );
}
