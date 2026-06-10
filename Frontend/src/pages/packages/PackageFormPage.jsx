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
    nama_paket: '', alamat_pengirim: '', alamat_tujuan: '',
    no_hp_pengirim: '', no_hp_penerima: '', deskripsi_barang: '',
    berat: '', jenis_layanan: 'standar', destination_warehouse_id: ''
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
        nama_paket: pkg.nama_paket || '', 
        alamat_pengirim: pkg.alamat_pengirim || '', 
        alamat_tujuan: pkg.alamat_tujuan || '',
        no_hp_pengirim: pkg.no_hp_pengirim || '', 
        no_hp_penerima: pkg.no_hp_penerima || '', 
        deskripsi_barang: pkg.deskripsi_barang || '',
        berat: pkg.berat || '', 
        jenis_layanan: pkg.jenis_layanan || 'standar', 
        destination_warehouse_id: pkg.destination_warehouse_id || ''
      });
    }
  }, [isEdit, pkg]);

  const handleChange = (e) => setFormData({ ...formData, [e.target.name]: e.target.value });

  const handleSubmit = (e) => {
    e.preventDefault();
    setErrorMsg('');

    const payload = { ...formData, berat: Number(formData.berat) || 0, destination_warehouse_id: Number(formData.destination_warehouse_id) };

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
            <div><label className="block text-sm mb-1">No. HP Pengirim</label><input required name="no_hp_pengirim" value={formData.no_hp_pengirim} onChange={handleChange} className="w-full border rounded-md p-2" /></div>
            <div><label className="block text-sm mb-1">Alamat Pengirim</label><textarea required name="alamat_pengirim" value={formData.alamat_pengirim} onChange={handleChange} className="w-full border rounded-md p-2" rows={3} /></div>
          </div>

          <div className="bg-white p-6 rounded-xl shadow-card border border-gray-200 space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 border-b pb-2">Data Penerima</h3>
            <div><label className="block text-sm mb-1">No. HP Penerima</label><input required name="no_hp_penerima" value={formData.no_hp_penerima} onChange={handleChange} className="w-full border rounded-md p-2" /></div>
            <div><label className="block text-sm mb-1">Alamat Tujuan (Geocoded)</label><textarea required name="alamat_tujuan" value={formData.alamat_tujuan} onChange={handleChange} className="w-full border rounded-md p-2" rows={3} /></div>
          </div>
        </div>

        {/* Package details */}
        <div className="bg-white p-6 rounded-xl shadow-card border border-gray-200 space-y-4">
          <h3 className="text-lg font-semibold text-gray-900 border-b pb-2">Detail Paket</h3>
          <div><label className="block text-sm mb-1">Nama Paket</label><input required name="nama_paket" value={formData.nama_paket} onChange={handleChange} className="w-full border rounded-md p-2" /></div>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div><label className="block text-sm mb-1">Berat (kg)</label><input required type="number" step="0.1" name="berat" value={formData.berat} onChange={handleChange} className="w-full border rounded-md p-2" /></div>
            <div>
              <label className="block text-sm mb-1">Jenis Layanan</label>
              <select required name="jenis_layanan" value={formData.jenis_layanan} onChange={handleChange} className="w-full border rounded-md p-2">
                <option value="standar">Standar</option>
                <option value="express">Express</option>
                <option value="kargo">Kargo</option>
              </select>
            </div>
          </div>
          <div><label className="block text-sm mb-1">Deskripsi Barang</label><input name="deskripsi_barang" value={formData.deskripsi_barang} onChange={handleChange} className="w-full border rounded-md p-2" /></div>
          
          {!isEdit && (
            <div>
              <label className="block text-sm mb-1">Gudang Tujuan</label>
              <select required name="destination_warehouse_id" value={formData.destination_warehouse_id} onChange={handleChange} className="w-full border rounded-md p-2" disabled={isLoadingWh}>
                <option value="">-- Pilih Gudang Tujuan --</option>
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
