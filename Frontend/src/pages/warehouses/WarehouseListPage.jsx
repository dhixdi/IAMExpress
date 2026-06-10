import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useWarehouses, useDeleteWarehouse } from '../../hooks/useWarehouses';
import PageHeader from '../../components/common/PageHeader';
import DataTable from '../../components/common/DataTable';
import ConfirmDialog from '../../components/common/ConfirmDialog';
import WarehouseMap from '../../components/maps/WarehouseMap';
import { Plus, Edit2, Trash2, Eye } from 'lucide-react';
import { formatDate } from '../../utils/formatDate';

export default function WarehouseListPage() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [deleteId, setDeleteId] = useState(null);
  
  const navigate = useNavigate();
  
  const { data, isLoading } = useWarehouses({
    page,
    per_page: 10,
    q: search || undefined,
  });
  
  const { mutate: deleteWarehouse } = useDeleteWarehouse();

  const handleDelete = () => {
    if (deleteId) {
      deleteWarehouse(deleteId, {
        onSuccess: () => setDeleteId(null),
      });
    }
  };

  const warehouses = data?.data?.warehouses || [];
  const meta = data?.meta || { total_pages: 1 };

  return (
    <div className="space-y-6">
      <PageHeader 
        title="Manajemen Gudang" 
        breadcrumb={[{ label: 'Dashboard', href: '/' }, { label: 'Warehouses' }]}
        action={
          <button onClick={() => navigate('/warehouses/new')} className="bg-navy-950 text-white px-4 py-2 rounded-md hover:bg-navy-900 flex items-center gap-2 text-sm font-medium">
            <Plus size={16} /> Tambah Gudang
          </button>
        }
      />

      {/* Map of all warehouses */}
      <div className="bg-white rounded-xl shadow-card border border-gray-200 p-4">
        <h3 className="text-lg font-semibold text-gray-900 mb-4 px-2">Peta Lokasi Gudang</h3>
        <WarehouseMap warehouses={warehouses} height="350px" />
      </div>

      <div>
        <div className="bg-white p-4 rounded-t-lg border border-gray-200 border-b-0 flex gap-4">
          <input 
            type="text" 
            placeholder="Cari nama gudang atau alamat..." 
            className="border border-gray-300 rounded-md p-2 text-sm flex-1 max-w-md"
            value={search}
            onChange={e => { setSearch(e.target.value); setPage(1); }}
          />
        </div>

        <DataTable 
          data={warehouses}
          isLoading={isLoading}
          columns={[
            { header: 'Nama Gudang', accessor: 'nama_gudang' },
            { header: 'Alamat', accessor: 'alamat' },
            { header: 'Dibuat Pada', render: (row) => formatDate(row.created_at) },
            { 
              header: 'Aksi', 
              render: (row) => (
                <div className="flex gap-2">
                  <button onClick={() => navigate(`/warehouses/${row.warehouse_id}`)} className="p-1 text-gray-500 hover:text-navy-900"><Eye size={18}/></button>
                  <button onClick={() => navigate(`/warehouses/${row.warehouse_id}/edit`)} className="p-1 text-gray-500 hover:text-amber-600"><Edit2 size={18}/></button>
                  <button onClick={() => setDeleteId(row.warehouse_id)} className="p-1 text-gray-500 hover:text-red-600"><Trash2 size={18}/></button>
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
      </div>

      <ConfirmDialog 
        open={!!deleteId}
        title="Hapus Gudang"
        description="Apakah Anda yakin ingin menghapus gudang ini? Pastikan tidak ada paket yang sedang berada di gudang ini."
        onConfirm={handleDelete}
        onCancel={() => setDeleteId(null)}
        variant="destructive"
        confirmLabel="Hapus"
      />
    </div>
  );
}
