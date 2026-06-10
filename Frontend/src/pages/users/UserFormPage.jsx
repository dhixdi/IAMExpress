import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useCreateUser, useUpdateUser, useUser } from '../../hooks/useUsers';
import { useWarehouses } from '../../hooks/useWarehouses';
import PageHeader from '../../components/common/PageHeader';
import { ROLES } from '../../constants/roles';

export default function UserFormPage() {
  const { id } = useParams();
  const isEdit = !!id;
  const navigate = useNavigate();

  const [formData, setFormData] = useState({
    nama: '',
    email: '',
    password: '',
    role: ROLES.WAREHOUSE_ADMIN,
    warehouse_id: '',
  });
  const [errorMsg, setErrorMsg] = useState('');

  const { data: userResp, isLoading: isLoadingUser } = useUser(id);
  const { data: whResp, isLoading: isLoadingWh } = useWarehouses({ per_page: 100 });
  const { mutate: createUser, isPending: isCreating } = useCreateUser();
  const { mutate: updateUser, isPending: isUpdating } = useUpdateUser();

  const warehouses = whResp?.data?.warehouses || [];

  useEffect(() => {
    if (isEdit && userResp) {
      const u = userResp;
      setFormData({
        nama: u.nama || '',
        email: u.email || '',
        password: '',
        role: u.role || ROLES.WAREHOUSE_ADMIN,
        warehouse_id: u.warehouse_id || '',
      });
    }
  }, [isEdit, userResp]);

  const handleSubmit = (e) => {
    e.preventDefault();
    setErrorMsg('');

    if (formData.role !== ROLES.SUPER_ADMIN && !formData.warehouse_id) {
      setErrorMsg('Warehouse ID wajib diisi untuk role ini');
      return;
    }

    const payload = { ...formData };
    if (!payload.password) delete payload.password; // Don't send empty password on edit
    if (payload.role === ROLES.SUPER_ADMIN) payload.warehouse_id = null;

    if (isEdit) {
      updateUser({ id, payload }, {
        onSuccess: () => navigate('/users'),
        onError: (err) => setErrorMsg(err.response?.data?.message || 'Gagal update user')
      });
    } else {
      createUser(payload, {
        onSuccess: () => navigate('/users'),
        onError: (err) => setErrorMsg(err.response?.data?.message || 'Gagal membuat user')
      });
    }
  };

  if (isEdit && isLoadingUser) return <div>Loading...</div>;

  const isPending = isCreating || isUpdating;

  return (
    <div className="max-w-2xl mx-auto">
      <PageHeader 
        title={isEdit ? 'Edit User' : 'Tambah User'} 
        breadcrumb={[{ label: 'Dashboard', href: '/' }, { label: 'Users', href: '/users' }, { label: isEdit ? 'Edit' : 'Baru' }]}
      />

      <div className="bg-white p-6 rounded-xl shadow-card border border-gray-200">
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Nama Lengkap</label>
            <input 
              type="text" required 
              value={formData.nama} onChange={e => setFormData({...formData, nama: e.target.value})}
              className="w-full border border-gray-300 rounded-md p-2 focus:ring-navy-900 focus:border-navy-900"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
            <input 
              type="email" required 
              value={formData.email} onChange={e => setFormData({...formData, email: e.target.value})}
              className="w-full border border-gray-300 rounded-md p-2 focus:ring-navy-900 focus:border-navy-900"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Password {isEdit && <span className="text-gray-400 font-normal">(Kosongkan jika tidak ingin diubah)</span>}</label>
            <input 
              type="password" required={!isEdit} minLength={6}
              value={formData.password} onChange={e => setFormData({...formData, password: e.target.value})}
              className="w-full border border-gray-300 rounded-md p-2 focus:ring-navy-900 focus:border-navy-900"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Role</label>
            <select 
              value={formData.role} onChange={e => setFormData({...formData, role: e.target.value})}
              className="w-full border border-gray-300 rounded-md p-2 focus:ring-navy-900 focus:border-navy-900"
            >
              {Object.values(ROLES).map(r => <option key={r} value={r}>{r}</option>)}
            </select>
          </div>

          {formData.role !== ROLES.SUPER_ADMIN && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Penugasan Gudang</label>
              <select 
                required
                value={formData.warehouse_id} onChange={e => setFormData({...formData, warehouse_id: e.target.value})}
                className="w-full border border-gray-300 rounded-md p-2 focus:ring-navy-900 focus:border-navy-900"
                disabled={isLoadingWh}
              >
                <option value="">-- Pilih Gudang --</option>
                {warehouses.map(w => <option key={w.warehouse_id} value={w.warehouse_id}>{w.nama_gudang}</option>)}
              </select>
            </div>
          )}

          {errorMsg && <div className="text-red-600 text-sm mt-2">{errorMsg}</div>}

          <div className="pt-4 flex justify-end gap-3">
            <button type="button" onClick={() => navigate('/users')} className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50">Batal</button>
            <button type="submit" disabled={isPending} className="px-4 py-2 bg-navy-950 text-white rounded-md hover:bg-navy-900 disabled:opacity-50">
              {isPending ? 'Menyimpan...' : 'Simpan'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
