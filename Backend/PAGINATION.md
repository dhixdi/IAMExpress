# Pagination Guide — IAMExpress Backend

Dokumen ini menjelaskan cara memakai pagination di API IAMExpress.

## Ringkasan

Semua endpoint list mendukung parameter query berikut:

| Parameter | Default | Keterangan |
|---|---|---|
| `page` | `1` | Nomor halaman |
| `per_page` | `10` | Jumlah data per halaman (maksimal 100) |
| `sort_by` | Tergantung resource | Kolom untuk sorting |
| `order` | `desc` | Arah sorting: `asc` atau `desc` |

## Endpoint yang Mendukung Pagination

| Endpoint | sort_by yang tersedia |
|---|---|
| `GET /api/v1/users` | `nama`, `email`, `role`, `created_at` |
| `GET /api/v1/warehouses` | `nama_gudang`, `created_at` |
| `GET /api/v1/packages` | `resi`, `nama_paket`, `berat`, `ongkos_kirim`, `current_status`, `jenis_layanan`, `created_at` |
| `GET /api/v1/packages/:id/tracker` | `timestamp` |

## Cara Kerja

Backend menghitung:

```
offset = (page - 1) * per_page
limit  = per_page
```

Data diambil dengan `LIMIT limit OFFSET offset` pada query MySQL.

Response sukses akan menyertakan `meta`:

```json
{
  "meta": {
    "page": 1,
    "per_page": 10,
    "total": 47,
    "total_pages": 5
  }
}
```

## Parameter

### `page`

Nomor halaman yang ingin diambil. Harus bilangan bulat positif.

```
?page=1
?page=3
```

### `per_page`

Jumlah data per halaman. Maksimal 100 — lebih dari itu akan dipaksa ke 100.

```
?per_page=10
?per_page=50
```

### `sort_by`

Kolom yang dipakai untuk sorting. Nilai yang tidak dikenali akan diabaikan dan pakai default.

```
?sort_by=created_at
?sort_by=nama_paket
```

### `order`

Arah sorting. Nilai selain `asc` akan dianggap `desc`.

```
?order=asc
?order=desc
```

---

## Contoh Pemakaian per Endpoint

### Users

```bash
GET /api/v1/users?page=1&per_page=10&sort_by=nama&order=asc
```

Filter yang tersedia:

| Parameter | Deskripsi |
|---|---|
| `q` | Search nama atau email |
| `role` | Filter by role (`SUPER_ADMIN`, `WAREHOUSE_ADMIN`, `LINEHAUL`, `COURIER`) |
| `warehouse_id` | Filter by gudang |

### Warehouses

```bash
GET /api/v1/warehouses?page=1&per_page=10&sort_by=nama_gudang&order=asc
```

Filter yang tersedia:

| Parameter | Deskripsi |
|---|---|
| `q` | Search nama gudang atau alamat |

### Packages

```bash
GET /api/v1/packages?page=1&per_page=10&current_status=In+Transit&sort_by=created_at&order=desc
```

Filter yang tersedia:

| Parameter | Deskripsi |
|---|---|
| `q` | Search resi, nama paket, atau no HP |
| `current_status` | Filter by status paket |
| `jenis_layanan` | `standar`, `express`, `kargo` |
| `warehouse_id` | Filter by current_warehouse_id (SUPER_ADMIN only) |

> **Catatan:** Untuk WAREHOUSE_ADMIN, filter `warehouse_id` otomatis diisi dengan warehouse miliknya. Untuk LINEHAUL dan COURIER, hasil otomatis difilter ke paket yang di-assign ke mereka.

### Package Tracker

```bash
GET /api/v1/packages/3/tracker?sort_by=timestamp&order=asc
```

---

## Format Response List Lengkap

```json
{
  "success": true,
  "message": "Daftar paket berhasil diambil",
  "data": {
    "packages": [
      {
        "package_id": 1,
        "resi": "IAM000001",
        "nama_paket": "Elektronik - Laptop ASUS",
        "current_status": "In Transit",
        "jenis_layanan": "express",
        "berat": 2.5,
        "ongkos_kirim": 37500,
        "created_at": "2026-06-01T08:00:00.000Z"
      }
    ]
  },
  "meta": {
    "page": 1,
    "per_page": 10,
    "total": 47,
    "total_pages": 5
  }
}
```

---

## Tips Frontend

- Simpan `page` aktif di state React supaya tombol next/prev konsisten.
- Gunakan `meta.total_pages` untuk tahu kapan pagination selesai.
- Reset `page` ke `1` setiap kali filter atau search berubah.
- Untuk mobile (Flutter), pertimbangkan infinite scroll dengan append data saat `page` bertambah.
- Untuk tabel admin, `per_page=20` biasanya cukup. Untuk dropdown/select, bisa pakai `per_page=100`.

## Implementasi Backend

Logika pagination ada di `src/utils/pagination.js`:

```javascript
// Contoh penggunaan di controller
const { page, per_page, offset, limit } = getPaginationParams(req.query);
const { sort_by, order } = getSortParams(req.query, ['resi', 'nama_paket', 'created_at']);

const [rows] = await db.query(
  `SELECT * FROM packages WHERE ... ORDER BY ${sort_by} ${order} LIMIT ? OFFSET ?`,
  [limit, offset]
);

const [[{ total }]] = await db.query(`SELECT COUNT(*) as total FROM packages WHERE ...`);

res.json({
  success: true,
  data: { packages: rows },
  meta: buildPaginationMeta(page, per_page, total)
});
```

Helper functions:
- `getPaginationParams(query)` → `{ page, per_page, offset, limit }`
- `getSortParams(query, allowedColumns)` → `{ sort_by, order }`
- `buildPaginationMeta(page, per_page, total)` → `{ page, per_page, total, total_pages }`
