import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useUsers, useDeleteUser } from '../../hooks/useUsers';
import PageHeader from '../../components/common/PageHeader';
import DataTable from '../../components/common/DataTable';
import ConfirmDialog from '../../components/common/ConfirmDialog';
import { Plus, Edit2, Trash2, Eye } from 'lucide-react';
import { ROLES } from '../../constants/roles';
import { formatDate } from '../../utils/formatDate';

export default function UserListPage() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState('');
  const [deleteId, setDeleteId] = useState(null);
  
  const navigate = useNavigate();
  
  const { data, isLoading } = useUsers({
    page,
    per_page: 10,
    q: search || undefined,
    role: roleFilter || undefined,
  });
  
  const { mutate: deleteUser } = useDeleteUser();

  const handleDelete = () => {
    if (deleteId) {
      deleteUser(deleteId, {
        onSuccess: () => setDeleteId(null),
      });
    }
  };

  const users = data?.data?.users || [];
  const meta = data?.meta || { total_pages: 1 };

  return (
    <div>
      <PageHeader 
        title="Manajemen Pengguna" 
        breadcrumb={[{ label: 'Dashboard', href: '/' }, { label: 'Users' }]}
        action={
          <button onClick={() => navigate('/users/new')} className="bg-navy-950 text-white px-4 py-2 rounded-md hover:bg-navy-900 flex items-center gap-2 text-sm font-medium">
            <Plus size={16} /> Tambah User
          </button>
        }
      />

      <div className="bg-white p-4 rounded-t-lg border border-gray-200 border-b-0 flex flex-col sm:flex-row gap-4">
        <input 
          type="text" 
          placeholder="Cari nama atau email..." 
          className="border border-gray-300 rounded-md p-2 text-sm flex-1"
          value={search}
          onChange={e => { setSearch(e.target.value); setPage(1); }}
        />
        <select 
          className="border border-gray-300 rounded-md p-2 text-sm"
          value={roleFilter}
          onChange={e => { setRoleFilter(e.target.value); setPage(1); }}
        >
          <option value="">Semua Role</option>
          {Object.values(ROLES).map(r => <option key={r} value={r}>{r}</option>)}
        </select>
      </div>

      <DataTable 
        data={users}
        isLoading={isLoading}
        columns={[
          { header: 'Nama', accessor: 'nama' },
          { header: 'Email', accessor: 'email' },
          { header: 'Role', accessor: 'role' },
          { header: 'Dibuat Pada', render: (row) => formatDate(row.created_at) },
          { 
            header: 'Aksi', 
            render: (row) => (
              <div className="flex gap-2">
                <button onClick={() => navigate(`/users/${row.user_id}`)} className="p-1 text-gray-500 hover:text-navy-900"><Eye size={18}/></button>
                <button onClick={() => navigate(`/users/${row.user_id}/edit`)} className="p-1 text-gray-500 hover:text-amber-600"><Edit2 size={18}/></button>
                <button onClick={() => setDeleteId(row.user_id)} className="p-1 text-gray-500 hover:text-red-600"><Trash2 size={18}/></button>
              </div>
            ) 
          }
        ]}
      />

      <div className="mt-4 flex items-center justify-between bg-white p-4 border border-gray-200 rounded-lg">
        <button 
          disabled={page === 1} 
          onClick={() => setPage(p => p - 1)}
          className="px-3 py-1 border rounded disabled:opacity-50"
        >Prev</button>
        <span className="text-sm text-gray-600">Halaman {page} dari {meta.total_pages}</span>
        <button 
          disabled={page >= meta.total_pages} 
          onClick={() => setPage(p => p + 1)}
          className="px-3 py-1 border rounded disabled:opacity-50"
        >Next</button>
      </div>

      <ConfirmDialog 
        open={!!deleteId}
        title="Hapus User"
        description="Apakah Anda yakin ingin menghapus user ini? Tindakan ini tidak dapat dibatalkan."
        onConfirm={handleDelete}
        onCancel={() => setDeleteId(null)}
        variant="destructive"
        confirmLabel="Hapus"
      />
    </div>
  );
}
