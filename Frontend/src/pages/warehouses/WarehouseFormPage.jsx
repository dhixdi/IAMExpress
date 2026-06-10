import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useCreateWarehouse, useUpdateWarehouse, useWarehouse } from '../../hooks/useWarehouses';
import PageHeader from '../../components/common/PageHeader';

export default function WarehouseFormPage() {
  const { id } = useParams();
  const isEdit = !!id;
  const navigate = useNavigate();

  const [formData, setFormData] = useState({
    nama_gudang: '',
    alamat: '',
  });
  const [errorMsg, setErrorMsg] = useState('');

  const { data: warehouse, isLoading: isLoadingWh } = useWarehouse(id);
  const { mutate: createWh, isPending: isCreating } = useCreateWarehouse();
  const { mutate: updateWh, isPending: isUpdating } = useUpdateWarehouse();

  useEffect(() => {
    if (isEdit && warehouse) {
      setFormData({
        nama_gudang: warehouse.nama_gudang || '',
        alamat: warehouse.alamat || '',
      });
    }
  }, [isEdit, warehouse]);

  const handleSubmit = (e) => {
    e.preventDefault();
    setErrorMsg('');

    if (isEdit) {
      updateWh({ id, payload: formData }, {
        onSuccess: () => navigate('/warehouses'),
        onError: (err) => setErrorMsg(err.response?.data?.message || 'Gagal update gudang')
      });
    } else {
      createWh(formData, {
        onSuccess: () => navigate('/warehouses'),
        onError: (err) => setErrorMsg(err.response?.data?.message || 'Gagal membuat gudang')
      });
    }
  };

  if (isEdit && isLoadingWh) return <div>Loading...</div>;

  const isPending = isCreating || isUpdating;

  return (
    <div className="max-w-2xl mx-auto">
      <PageHeader 
        title={isEdit ? 'Edit Gudang' : 'Tambah Gudang'} 
        breadcrumb={[{ label: 'Dashboard', href: '/' }, { label: 'Warehouses', href: '/warehouses' }, { label: isEdit ? 'Edit' : 'Baru' }]}
      />

      <div className="bg-white p-6 rounded-xl shadow-card border border-gray-200">
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Nama Gudang</label>
            <input 
              type="text" required 
              value={formData.nama_gudang} onChange={e => setFormData({...formData, nama_gudang: e.target.value})}
              className="w-full border border-gray-300 rounded-md p-2 focus:ring-navy-900 focus:border-navy-900"
              placeholder="Contoh: Gudang Yogyakarta"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Alamat Lengkap</label>
            <textarea 
              required rows={4}
              value={formData.alamat} onChange={e => setFormData({...formData, alamat: e.target.value})}
              className="w-full border border-gray-300 rounded-md p-2 focus:ring-navy-900 focus:border-navy-900"
              placeholder="Alamat lengkap (digunakan untuk geocoding otomatis)"
            />
          </div>

          <div className="bg-blue-50 p-3 rounded-md border border-blue-100 mt-2">
            <p className="text-sm text-blue-800 flex items-center gap-2">
              <span className="text-xl">ℹ️</span> Koordinat latitude dan longitude akan digenerate otomatis oleh sistem berdasarkan alamat yang dimasukkan.
            </p>
          </div>

          {errorMsg && <div className="text-red-600 text-sm mt-2">{errorMsg}</div>}

          <div className="pt-4 flex justify-end gap-3">
            <button type="button" onClick={() => navigate('/warehouses')} className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50">Batal</button>
            <button type="submit" disabled={isPending} className="px-4 py-2 bg-navy-950 text-white rounded-md hover:bg-navy-900 disabled:opacity-50">
              {isPending ? 'Menyimpan...' : 'Simpan'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
