import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { usePackages, useDeletePackage } from '../../hooks/usePackages';
import PageHeader from '../../components/common/PageHeader';
import DataTable from '../../components/common/DataTable';
import StatusBadge from '../../components/common/StatusBadge';
import ConfirmDialog from '../../components/common/ConfirmDialog';
import { Plus, Edit2, Trash2, Eye, Map, UserPlus } from 'lucide-react';
import { PACKAGE_STATUS } from '../../constants/packageStatus';
import { formatDate } from '../../utils/formatDate';

export default function PackageListPage() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [deleteId, setDeleteId] = useState(null);
  
  const navigate = useNavigate();
  
  const { data, isLoading } = usePackages({
    page,
    per_page: 10,
    q: search || undefined,
    status: statusFilter || undefined,
  });
  
  const { mutate: deletePackage } = useDeletePackage();

  const handleDelete = () => {
    if (deleteId) {
      deletePackage(deleteId, {
        onSuccess: () => setDeleteId(null),
      });
    }
  };

  const packages = data?.data?.packages || [];
  const meta = data?.meta || { total_pages: 1 };

  return (
    <div>
      <PageHeader 
        title="Manajemen Paket" 
        breadcrumb={[{ label: 'Dashboard', href: '/' }, { label: 'Packages' }]}
        action={
          <button onClick={() => navigate('/packages/new')} className="bg-navy-950 text-white px-4 py-2 rounded-md hover:bg-navy-900 flex items-center gap-2 text-sm font-medium">
            <Plus size={16} /> Buat Paket
          </button>
        }
      />

      <div className="bg-white p-4 rounded-t-lg border border-gray-200 border-b-0 flex flex-col sm:flex-row gap-4">
        <input 
          type="text" 
          placeholder="Cari resi, pengirim, penerima..." 
          className="border border-gray-300 rounded-md p-2 text-sm flex-1"
          value={search}
          onChange={e => { setSearch(e.target.value); setPage(1); }}
        />
        <select 
          className="border border-gray-300 rounded-md p-2 text-sm"
          value={statusFilter}
          onChange={e => { setStatusFilter(e.target.value); setPage(1); }}
        >
          <option value="">Semua Status</option>
          {Object.values(PACKAGE_STATUS).map(s => <option key={s} value={s}>{s}</option>)}
        </select>
      </div>

      <DataTable 
        data={packages}
        isLoading={isLoading}
        columns={[
          { header: 'No. Resi', accessor: 'resi' },
          { header: 'Pengirim', accessor: 'sender_name' },
          { header: 'Penerima', accessor: 'receiver_name' },
          { header: 'Status', render: (row) => <StatusBadge status={row.status} /> },
          { header: 'Dibuat', render: (row) => formatDate(row.created_at) },
          { 
            header: 'Aksi', 
            render: (row) => (
              <div className="flex gap-2">
                <button title="Detail" onClick={() => navigate(`/packages/${row.package_id}`)} className="p-1 text-gray-500 hover:text-navy-900"><Eye size={18}/></button>
                <button title="Tracker" onClick={() => navigate(`/packages/${row.package_id}/tracker`)} className="p-1 text-gray-500 hover:text-blue-600"><Map size={18}/></button>
                <button title="Assign" onClick={() => navigate(`/packages/${row.package_id}/assign`)} className="p-1 text-gray-500 hover:text-amber-600"><UserPlus size={18}/></button>
                <button title="Edit" onClick={() => navigate(`/packages/${row.package_id}/edit`)} className="p-1 text-gray-500 hover:text-green-600"><Edit2 size={18}/></button>
                <button title="Hapus" onClick={() => setDeleteId(row.package_id)} className="p-1 text-gray-500 hover:text-red-600"><Trash2 size={18}/></button>
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
        title="Hapus Paket"
        description="Apakah Anda yakin ingin menghapus paket ini? Data riwayat tracking juga akan terhapus."
        onConfirm={handleDelete}
        onCancel={() => setDeleteId(null)}
        variant="destructive"
        confirmLabel="Hapus"
      />
    </div>
  );
}
