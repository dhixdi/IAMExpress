import { useParams, useNavigate } from 'react-router-dom';
import { useUser, useDeleteUser } from '../../hooks/useUsers';
import PageHeader from '../../components/common/PageHeader';
import ConfirmDialog from '../../components/common/ConfirmDialog';
import { useState } from 'react';
import { User, Edit2, Trash2 } from 'lucide-react';
import { formatDate } from '../../utils/formatDate';

export default function UserDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { data: user, isLoading } = useUser(id);
  const { mutate: deleteUser } = useDeleteUser();
  const [showConfirm, setShowConfirm] = useState(false);

  if (isLoading) return <div>Loading...</div>;
  if (!user) return <div>User tidak ditemukan</div>;

  const handleDelete = () => {
    deleteUser(id, {
      onSuccess: () => navigate('/users')
    });
  };

  return (
    <div className="max-w-3xl mx-auto">
      <PageHeader 
        title="Detail User" 
        breadcrumb={[{ label: 'Dashboard', href: '/' }, { label: 'Users', href: '/users' }, { label: user.nama }]}
        action={
          <div className="flex gap-2">
            <button onClick={() => navigate(`/users/${id}/edit`)} className="bg-white border border-gray-300 text-gray-700 px-4 py-2 rounded-md hover:bg-gray-50 flex items-center gap-2 text-sm font-medium">
              <Edit2 size={16} /> Edit
            </button>
            <button onClick={() => setShowConfirm(true)} className="bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700 flex items-center gap-2 text-sm font-medium">
              <Trash2 size={16} /> Hapus
            </button>
          </div>
        }
      />

      <div className="bg-white rounded-xl shadow-card border border-gray-200 overflow-hidden">
        <div className="p-6 sm:p-8 flex flex-col sm:flex-row items-center sm:items-start gap-6">
          <div className="h-24 w-24 rounded-full bg-navy-950 text-white flex items-center justify-center overflow-hidden border-4 border-gray-50 shadow-sm shrink-0">
            {user.photo_url ? (
              <img src={user.photo_url} alt={user.nama} className="h-full w-full object-cover" />
            ) : (
              <User size={40} />
            )}
          </div>
          
          <div className="flex-1 text-center sm:text-left">
            <h2 className="text-2xl font-bold text-gray-900">{user.nama}</h2>
            <p className="text-gray-500">{user.email}</p>
            <div className="mt-4 inline-flex px-3 py-1 rounded-full text-sm font-medium bg-navy-50 text-navy-900 border border-navy-200">
              {user.role}
            </div>
          </div>
        </div>
        
        <div className="border-t border-gray-100 px-6 py-6 sm:px-8 grid grid-cols-1 sm:grid-cols-2 gap-6">
          <div>
            <h3 className="text-xs font-medium text-gray-500 uppercase tracking-wider mb-1">Gudang Penugasan</h3>
            <p className="text-gray-900 font-medium">{user.Warehouse ? user.Warehouse.nama_gudang : '-'}</p>
          </div>
          <div>
            <h3 className="text-xs font-medium text-gray-500 uppercase tracking-wider mb-1">Status Biometrik</h3>
            <p className="text-gray-900 font-medium">{user.biometrics_enabled ? `Aktif (${user.biometrics_type})` : 'Tidak Aktif'}</p>
          </div>
          <div>
            <h3 className="text-xs font-medium text-gray-500 uppercase tracking-wider mb-1">Tanggal Bergabung</h3>
            <p className="text-gray-900 font-medium">{formatDate(user.created_at)}</p>
          </div>
        </div>
      </div>

      <ConfirmDialog 
        open={showConfirm}
        title="Hapus User"
        description={`Apakah Anda yakin ingin menghapus user ${user.nama}?`}
        onConfirm={handleDelete}
        onCancel={() => setShowConfirm(false)}
        variant="destructive"
      />
    </div>
  );
}
