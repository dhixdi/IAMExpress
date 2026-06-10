import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useCreatePackage, useUpdatePackage, usePackage } from '../../hooks/usePackages';
import { useWarehouses } from '../../hooks/useWarehouses';
import PageHeader from '../../components/common/PageHeader';

export default function PackageFormPage() {
  const { id } = useParams();
  const isEdit = !!id;
  const navigate = useNavigate();

  const [formData, setFormData] = useState({
    sender_name: '', sender_phone: '', sender_address: '',
    receiver_name: '', receiver_phone: '', receiver_address: '',
    weight: '', dimensions: '', notes: '', warehouse_id: ''
  });
  const [errorMsg, setErrorMsg] = useState('');

  const { data: pkg, isLoading: isLoadingPkg } = usePackage(id);
  const { data: whResp, isLoading: isLoadingWh } = useWarehouses({ per_page: 100 });
  
  const { mutate: createPkg, isPending: isCreating } = useCreatePackage();
  const { mutate: updatePkg, isPending: isUpdating } = useUpdatePackage();

  const warehouses = whResp?.data?.warehouses || [];

  useEffect(() => {
    if (isEdit && pkg) {
      setFormData({
        sender_name: pkg.sender_name || '', sender_phone: pkg.sender_phone || '', sender_address: pkg.sender_address || '',
        receiver_name: pkg.receiver_name || '', receiver_phone: pkg.receiver_phone || '', receiver_address: pkg.receiver_address || '',
        weight: pkg.weight || '', dimensions: pkg.dimensions || '', notes: pkg.notes || '',
        warehouse_id: pkg.current_warehouse_id || ''
      });
    }
  }, [isEdit, pkg]);

  const handleChange = (e) => setFormData({ ...formData, [e.target.name]: e.target.value });

  const handleSubmit = (e) => {
    e.preventDefault();
    setErrorMsg('');

    const payload = { ...formData, weight: Number(formData.weight) || 0 };

    if (isEdit) {
      updatePkg({ id, payload }, {
        onSuccess: () => navigate('/packages'),
        onError: (err) => setErrorMsg(err.response?.data?.message || 'Gagal update paket')
      });
    } else {
      createPkg(payload, {
        onSuccess: () => navigate('/packages'),
        onError: (err) => setErrorMsg(err.response?.data?.message || 'Gagal membuat paket')
      });
    }
  };

  if (isEdit && isLoadingPkg) return <div>Loading...</div>;

  const isPending = isCreating || isUpdating;

  return (
    <div className="max-w-4xl mx-auto">
      <PageHeader 
        title={isEdit ? 'Edit Paket' : 'Buat Paket Baru'} 
        breadcrumb={[{ label: 'Dashboard', href: '/' }, { label: 'Packages', href: '/packages' }, { label: isEdit ? 'Edit' : 'Baru' }]}
      />

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Origin & Dest */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="bg-white p-6 rounded-xl shadow-card border border-gray-200 space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 border-b pb-2">Data Pengirim</h3>
            <div><label className="block text-sm mb-1">Nama</label><input required name="sender_name" value={formData.sender_name} onChange={handleChange} className="w-full border rounded-md p-2" /></div>
            <div><label className="block text-sm mb-1">Telepon</label><input required name="sender_phone" value={formData.sender_phone} onChange={handleChange} className="w-full border rounded-md p-2" /></div>
            <div><label className="block text-sm mb-1">Alamat</label><textarea required name="sender_address" value={formData.sender_address} onChange={handleChange} className="w-full border rounded-md p-2" rows={3} /></div>
          </div>

          <div className="bg-white p-6 rounded-xl shadow-card border border-gray-200 space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 border-b pb-2">Data Penerima</h3>
            <div><label className="block text-sm mb-1">Nama</label><input required name="receiver_name" value={formData.receiver_name} onChange={handleChange} className="w-full border rounded-md p-2" /></div>
            <div><label className="block text-sm mb-1">Telepon</label><input required name="receiver_phone" value={formData.receiver_phone} onChange={handleChange} className="w-full border rounded-md p-2" /></div>
            <div><label className="block text-sm mb-1">Alamat (Geocoded)</label><textarea required name="receiver_address" value={formData.receiver_address} onChange={handleChange} className="w-full border rounded-md p-2" rows={3} /></div>
          </div>
        </div>

        {/* Package details */}
        <div className="bg-white p-6 rounded-xl shadow-card border border-gray-200 space-y-4">
          <h3 className="text-lg font-semibold text-gray-900 border-b pb-2">Detail Paket</h3>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div><label className="block text-sm mb-1">Berat (kg)</label><input required type="number" step="0.1" name="weight" value={formData.weight} onChange={handleChange} className="w-full border rounded-md p-2" /></div>
            <div><label className="block text-sm mb-1">Dimensi (PxLxT)</label><input name="dimensions" value={formData.dimensions} onChange={handleChange} className="w-full border rounded-md p-2" placeholder="contoh: 10x10x10" /></div>
          </div>
          <div><label className="block text-sm mb-1">Catatan</label><input name="notes" value={formData.notes} onChange={handleChange} className="w-full border rounded-md p-2" /></div>
          
          {!isEdit && (
            <div>
              <label className="block text-sm mb-1">Gudang Awal</label>
              <select required name="warehouse_id" value={formData.warehouse_id} onChange={handleChange} className="w-full border rounded-md p-2" disabled={isLoadingWh}>
                <option value="">-- Pilih Gudang --</option>
                {warehouses.map(w => <option key={w.warehouse_id} value={w.warehouse_id}>{w.nama_gudang}</option>)}
              </select>
            </div>
          )}
        </div>

        {errorMsg && <div className="text-red-600 text-sm">{errorMsg}</div>}

        <div className="flex justify-end gap-3">
          <button type="button" onClick={() => navigate('/packages')} className="px-4 py-2 border rounded-md">Batal</button>
          <button type="submit" disabled={isPending} className="px-4 py-2 bg-navy-950 text-white rounded-md">{isPending ? 'Menyimpan...' : 'Simpan'}</button>
        </div>
      </form>
    </div>
  );
}
