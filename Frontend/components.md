# Components — IAMExpress Web Admin

Daftar component penting, props, dan contoh pemakaian.

---

## Layout Components

### `AppLayout`

Wrapper utama halaman yang sudah login. Berisi sidebar, topbar, dan `<Outlet />` dari React Router.

```jsx
// Tidak perlu props — otomatis render child route via Outlet
<AppLayout />
```

### `Sidebar`

Navigasi kiri. Menu yang tampil berbeda per role (diambil dari `authStore`).

```
SUPER_ADMIN melihat: Dashboard, Users, Warehouses, Packages
WAREHOUSE_ADMIN melihat: Dashboard, Packages, Profile
```

Props: tidak ada (baca role dari `useAuthStore`)

### `Topbar`

Header atas. Berisi: nama user, foto profil, tombol logout.

Props: tidak ada

---

## Common Components

### `DataTable`

Generic tabel dengan support sort header dan slot action column.

```jsx
import DataTable from '../components/common/DataTable';

<DataTable
  data={packages}          // array of objects
  columns={[
    { header: 'Resi',      accessor: 'resi' },
    { header: 'Nama',      accessor: 'nama_paket' },
    { header: 'Status',    render: (row) => <StatusBadge status={row.current_status} /> },
    { header: 'Aksi',      render: (row) => (
        <button onClick={() => navigate(`/packages/${row.package_id}`)}>Detail</button>
      )
    },
  ]}
  isLoading={isLoading}    // tampilkan skeleton saat true
  emptyMessage="Tidak ada paket"
/>
```

| Prop | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `data` | `array` | ✓ | Data yang ditampilkan |
| `columns` | `array` | ✓ | Definisi kolom (lihat contoh) |
| `isLoading` | `boolean` | — | Tampilkan skeleton |
| `emptyMessage` | `string` | — | Teks saat data kosong |

Setiap item `columns`:
- `header` (string) — judul kolom
- `accessor` (string) — key dari object data, atau
- `render` (function `(row) => ReactNode`) — untuk kolom custom

---

### `StatusBadge`

Badge berwarna sesuai status paket.

```jsx
import StatusBadge from '../components/common/StatusBadge';

<StatusBadge status="In Transit" />
<StatusBadge status="Delivered" />
<StatusBadge status="Failed Delivery" />
```

| Prop | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `status` | `string` | ✓ | Nilai current_status dari backend |

Warna per status (dari `src/utils/statusColor.js`):

| Status | Warna |
|---|---|
| Created | Abu-abu |
| Received at Warehouse | Biru muda |
| Assigned to Linehaul | Biru |
| Picked Up | Indigo |
| In Transit | Kuning |
| Arrived at Warehouse | Teal |
| Assigned to Courier | Oranye |
| Out For Delivery | Oranye tua |
| Delivered | Hijau |
| Failed Delivery | Merah |

---

### `ConfirmDialog`

Modal konfirmasi sebelum aksi destructive (delete, dll).

```jsx
import ConfirmDialog from '../components/common/ConfirmDialog';

<ConfirmDialog
  open={showConfirm}
  title="Hapus Paket"
  description="Paket IAM000001 akan dihapus permanen. Lanjutkan?"
  onConfirm={handleDelete}
  onCancel={() => setShowConfirm(false)}
  confirmLabel="Hapus"      // default: "Konfirmasi"
  variant="destructive"     // default: "default"
/>
```

| Prop | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `open` | `boolean` | ✓ | Tampil/tidak |
| `title` | `string` | ✓ | Judul modal |
| `description` | `string` | ✓ | Teks konfirmasi |
| `onConfirm` | `function` | ✓ | Callback tombol konfirmasi |
| `onCancel` | `function` | ✓ | Callback tombol batal |
| `confirmLabel` | `string` | — | Label tombol konfirmasi |
| `variant` | `'default'` \| `'destructive'` | — | Warna tombol konfirmasi |

---

### `PageHeader`

Header standar halaman dengan judul dan breadcrumb opsional.

```jsx
<PageHeader
  title="Daftar Paket"
  breadcrumb={[
    { label: 'Dashboard', href: '/' },
    { label: 'Paket' },
  ]}
  action={
    <button onClick={() => navigate('/packages/new')}>+ Tambah Paket</button>
  }
/>
```

| Prop | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `title` | `string` | ✓ | Judul halaman |
| `breadcrumb` | `array` | — | Navigasi crumb, item terakhir tanpa `href` |
| `action` | `ReactNode` | — | Tombol/elemen di kanan |

---

## Dashboard Components

### `StatsCard`

Kartu statistik angka di dashboard.

```jsx
<StatsCard
  title="Total Paket Aktif"
  value={47}
  icon="package"
  trend="+12 dari kemarin"
  color="blue"
/>
```

| Prop | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `title` | `string` | ✓ | Label kartu |
| `value` | `number \| string` | ✓ | Angka utama |
| `icon` | `string` | — | Nama icon dari lucide-react |
| `trend` | `string` | — | Teks kecil di bawah angka |
| `color` | `'blue'\|'green'\|'amber'\|'red'` | — | Warna aksen kartu |

---

### `PackageStatusChart`

Pie chart distribusi paket per status. Menggunakan Recharts.

```jsx
import { useQuery } from '@tanstack/react-query';
import PackageStatusChart from '../components/dashboard/PackageStatusChart';

// data dari GET /dashboard (field paket_per_status)
// Hanya tersedia di SUPER_ADMIN dan WAREHOUSE_ADMIN dashboard
<PackageStatusChart data={dashboardData.paket_per_status} />
```

| Prop | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `data` | `Array<{ status: string, total: number }>` | ✓ | Data dari dashboard API |

> **Catatan:** Dashboard SUPER_ADMIN tidak memiliki data tren harian. Chart yang tersedia hanya breakdown per status (`paket_per_status`) dan per warehouse (`paket_per_warehouse`). Tidak ada `DeliveryTrendChart`.

---

## Package Components

### `PackageStatusTimeline`

Timeline vertikal riwayat perjalanan paket dari `package_tracker`.

```jsx
import { usePackageTracker } from '../../hooks/usePackages';
import PackageStatusTimeline from '../components/packages/PackageStatusTimeline';

const { data } = usePackageTracker(packageId);

<PackageStatusTimeline entries={data?.data?.tracker ?? []} />
```

| Prop | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `entries` | `array` | ✓ | Array dari `package_tracker` dengan join user & warehouse |

Setiap entry ditampilkan dengan: ikon status, label status, nama gudang, nama user yang ubah, dan timestamp.

---

### `AssignModal`

Modal untuk assign Linehaul atau Courier ke paket.

```jsx
import AssignModal from '../components/packages/AssignModal';

<AssignModal
  open={showAssign}
  packageId={selectedPackageId}
  type="courier"             // 'linehaul' atau 'courier'
  warehouseId={warehouseId}  // untuk filter user sesuai gudang
  onSuccess={() => {
    setShowAssign(false);
    refetchPackages();
  }}
  onClose={() => setShowAssign(false)}
/>
```

| Prop | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `open` | `boolean` | ✓ | Tampil/tidak |
| `packageId` | `number` | ✓ | ID paket yang akan di-assign |
| `type` | `'linehaul'\|'courier'` | ✓ | Role yang akan di-assign |
| `warehouseId` | `number` | ✓ | Filter user sesuai gudang |
| `onSuccess` | `function` | ✓ | Callback setelah assign berhasil |
| `onClose` | `function` | ✓ | Callback tombol tutup/batal |

Modal akan menampilkan dropdown user dengan role sesuai `type` dan `warehouseId` yang diberikan.

---

## Map Components

### `WarehouseMap`

Peta Leaflet menampilkan pin semua gudang.

```jsx
import WarehouseMap from '../components/maps/WarehouseMap';

<WarehouseMap warehouses={warehouses} height="400px" />
```

| Prop | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `warehouses` | `array` | ✓ | Array warehouse dengan field `lat`, `lng`, `nama_gudang` |
| `height` | `string` | — | CSS height container, default `'350px'` |

Klik pin → tooltip nama gudang + alamat.

---

### `PackageMap`

Peta Leaflet menampilkan pin tujuan paket yang dipilih.

```jsx
<PackageMap
  receiverLat={pkg.receiver_lat}
  receiverLng={pkg.receiver_lng}
  label={pkg.alamat_tujuan}
  height="300px"
/>
```

| Prop | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `receiverLat` | `number` | ✓ | Latitude tujuan |
| `receiverLng` | `number` | ✓ | Longitude tujuan |
| `label` | `string` | — | Tooltip teks di atas pin |
| `height` | `string` | — | CSS height, default `'300px'` |

> **Penting:** Leaflet membutuhkan CSS di-import di `main.jsx`:
> ```javascript
> import 'leaflet/dist/leaflet.css';
> ```
> Dan icon marker Leaflet perlu dipatch agar tidak blank di Vite:
> ```javascript
> import L from 'leaflet';
> import markerIcon from 'leaflet/dist/images/marker-icon.png';
> import markerShadow from 'leaflet/dist/images/marker-shadow.png';
> delete L.Icon.Default.prototype._getIconUrl;
> L.Icon.Default.mergeOptions({ iconUrl: markerIcon, shadowUrl: markerShadow });
> ```

---

## Utility Functions

### `formatCurrency(amount)`

Format angka ke Rupiah.

```javascript
import { formatCurrency } from '../utils/formatCurrency';

formatCurrency(37500)  // → "Rp 37.500"
formatCurrency(225000) // → "Rp 225.000"
```

### `formatDate(timestamp)`

Format timestamp ke format Indonesia.

```javascript
import { formatDate } from '../utils/formatDate';

formatDate('2026-06-01T08:00:00.000Z') // → "1 Jun 2026, 15:00 WIB"
```

### `statusColor(status)`

Mapping status → class Tailwind untuk badge.

```javascript
import { statusColor } from '../utils/statusColor';

statusColor('Delivered')     // → "bg-green-100 text-green-800"
statusColor('In Transit')    // → "bg-yellow-100 text-yellow-800"
statusColor('Failed Delivery') // → "bg-red-100 text-red-800"
```
