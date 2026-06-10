import { useState } from 'react';
import { useUsers } from '../../hooks/useUsers';
import { useAssignPackage } from '../../hooks/usePackages';
import { useWarehouses } from '../../hooks/useWarehouses';
import { X } from 'lucide-react';
import { ROLES } from '../../constants/roles';

export default function AssignModal({ open, packageId, type, warehouseId, onSuccess, onClose }) {
  const [selectedUser, setSelectedUser] = useState('');
  const [selectedDestWarehouse, setSelectedDestWarehouse] = useState('');
  const [error, setError] = useState(null);
  
  const roleToFetch = type === 'linehaul' ? ROLES.LINEHAUL : ROLES.COURIER;
  
  const { data: usersData, isLoading: isLoadingUsers } = useUsers({
    role: roleToFetch,
    warehouse_id: warehouseId,
    per_page: 100,
  });

  const { data: whResp, isLoading: isLoadingWh } = useWarehouses(
    { per_page: 100 }, 
    { enabled: type === 'linehaul' }
  );
  
  const { mutate: assignPackage, isPending } = useAssignPackage();

  if (!open) return null;

  const users = usersData?.data?.users || [];
  const warehouses = whResp?.data?.warehouses || [];

  const handleAssign = () => {
    if (!selectedUser) return;
    if (type === 'linehaul' && !selectedDestWarehouse) {
      setError('Pilih Gudang Tujuan untuk Linehaul.');
      return;
    }
    setError(null);
    assignPackage(
      { 
        id: packageId, 
        user_id: Number(selectedUser), 
        type, 
        ...(type === 'linehaul' && selectedDestWarehouse ? { destination_warehouse_id: Number(selectedDestWarehouse) } : {}) 
      },
      {
        onSuccess: () => {
          onSuccess();
          setSelectedUser('');
          setError(null);
        },
        onError: (err) => {
          const msg = err?.response?.data?.message || 'Gagal assign paket. Coba lagi.';
          setError(msg);
        },
      }
    );
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
      <div className="bg-white rounded-xl shadow-modal w-full max-w-md overflow-hidden">
        <div className="flex items-center justify-between p-4 border-b border-gray-100">
          <h2 className="text-lg font-semibold text-gray-900">
            Assign {type === 'linehaul' ? 'Linehaul' : 'Courier'}
          </h2>
          <button onClick={onClose} className="p-1 text-gray-500 hover:text-gray-700 rounded-md hover:bg-gray-100 transition-colors">
            <X size={20} />
          </button>
        </div>
        
        <div className="p-4 space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Pilih {type === 'linehaul' ? 'Linehaul' : 'Courier'}
            </label>
            <select
              className="w-full border border-gray-300 rounded-md shadow-sm p-2 focus:ring-navy-900 focus:border-navy-900"
              value={selectedUser}
              onChange={(e) => setSelectedUser(e.target.value)}
              disabled={isLoadingUsers}
            >
              <option value="">-- Pilih --</option>
              {users.map(u => (
                <option key={u.user_id} value={u.user_id}>{u.nama} ({u.email})</option>
              ))}
            </select>
            {users.length === 0 && !isLoadingUsers && (
              <p className="mt-2 text-sm text-amber-600">Tidak ada {type} di gudang ini.</p>
            )}
          </div>

          {type === 'linehaul' && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Gudang Tujuan (Berikutnya)
              </label>
              <select
                className="w-full border border-gray-300 rounded-md shadow-sm p-2 focus:ring-navy-900 focus:border-navy-900"
                value={selectedDestWarehouse}
                onChange={(e) => setSelectedDestWarehouse(e.target.value)}
                disabled={isLoadingWh}
              >
                <option value="">-- Pilih Gudang Tujuan --</option>
                {warehouses.filter(w => w.warehouse_id !== warehouseId).map(w => (
                  <option key={w.warehouse_id} value={w.warehouse_id}>{w.nama_gudang}</option>
                ))}
              </select>
            </div>
          )}

          {error && (
            <div className="p-3 bg-red-50 border border-red-200 rounded-md">
              <p className="text-sm text-red-700">{error}</p>
            </div>
          )}
        </div>

        <div className="flex items-center justify-end gap-3 p-4 bg-gray-50 border-t border-gray-100">
          <button
            onClick={onClose}
            className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none"
            disabled={isPending}
          >
            Batal
          </button>
          <button
            onClick={handleAssign}
            disabled={!selectedUser || isPending}
            className="px-4 py-2 text-sm font-medium text-white rounded-md bg-navy-950 hover:bg-navy-900 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isPending ? 'Menyimpan...' : 'Assign'}
          </button>
        </div>
      </div>
    </div>
  );
}

