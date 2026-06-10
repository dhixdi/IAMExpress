# Role Endpoints Reference — IAMExpress Backend

Dokumen ini merangkum endpoint berdasarkan role, hak akses, dan contoh body request.

## Base URL

```
http://localhost:3000/api/v1
```

## JWT Header

```http
Authorization: Bearer <token>
Content-Type: application/json
```

---

## Access Matrix

### Auth

| Method | Endpoint | SUPER_ADMIN | WAREHOUSE_ADMIN | LINEHAUL | COURIER | Public |
|---|---|---|---|---|---|---|
| POST | `/auth/login` | ✓ | ✓ | ✓ | ✓ | ✓ |
| GET | `/auth/me` | ✓ | ✓ | ✓ | ✓ | — |
| POST | `/auth/logout` | ✓ | ✓ | ✓ | ✓ | — |

### User

| Method | Endpoint | SUPER_ADMIN | WAREHOUSE_ADMIN | LINEHAUL | COURIER |
|---|---|---|---|---|---|
| GET | `/users` | ✓ | — | — | — |
| GET | `/users/:id` | ✓ (semua) | Self only | Self only | Self only |
| POST | `/users` | ✓ | — | — | — |
| PUT | `/users/:id` | ✓ (semua) | Self only | Self only | Self only |
| DELETE | `/users/:id` | ✓ | — | — | — |
| PATCH | `/users/:id/role` | ✓ | — | — | — |
| PATCH | `/users/me/password` | ✓ | ✓ | ✓ | ✓ |
| PATCH | `/users/me/photo` | ✓ | ✓ | ✓ | ✓ |
| PATCH | `/users/me/biometrics` | ✓ | ✓ | ✓ | ✓ |

### Warehouse

| Method | Endpoint | SUPER_ADMIN | WAREHOUSE_ADMIN | LINEHAUL | COURIER |
|---|---|---|---|---|---|
| GET | `/warehouses` | ✓ | ✓ | ✓ | ✓ |
| GET | `/warehouses/:id` | ✓ | ✓ | ✓ | ✓ |
| POST | `/warehouses` | ✓ | — | — | — |
| PUT | `/warehouses/:id` | ✓ | — | — | — |
| DELETE | `/warehouses/:id` | ✓ | — | — | — |

### Package

| Method | Endpoint | SUPER_ADMIN | WAREHOUSE_ADMIN | LINEHAUL | COURIER |
|---|---|---|---|---|---|
| GET | `/packages` | ✓ (semua) | ✓ (gudang sendiri) | ✓ (assigned) | ✓ (assigned) |
| GET | `/packages/:id` | ✓ | ✓ (gudang sendiri) | ✓ (assigned) | ✓ (assigned) |
| GET | `/packages/track/:resi` | ✓ | ✓ | ✓ | ✓ |
| POST | `/packages` | — | ✓ | — | — |
| PUT | `/packages/:id` | — | ✓ (gudang sendiri) | — | — |
| DELETE | `/packages/:id` | ✓ (semua paket) | ✓ (gudang sendiri) | — | — |
| PATCH | `/packages/:id/status` | — | ✓ (status WA) | ✓ (status LH) | ✓ (status CR) |
| PATCH | `/packages/:id/assign` | — | ✓ | — | — |

**Status yang boleh diset per role:**

| Role | Status yang Bisa Diset |
|---|---|
| WAREHOUSE_ADMIN | `Received at Warehouse`, `Assigned to Linehaul`, `Assigned to Courier` |
| LINEHAUL | `Picked Up`, `In Transit`, `Arrived at Warehouse` |
| COURIER | `Out For Delivery`, `Delivered`, `Failed Delivery` |

> **Catatan:** Status `Created` di-set **otomatis** oleh backend saat `POST /packages` berhasil — tidak perlu (dan tidak bisa) di-set via `PATCH /packages/:id/status`. Ini berlaku untuk semua role.

### Tracker

| Method | Endpoint | SUPER_ADMIN | WAREHOUSE_ADMIN | LINEHAUL | COURIER |
|---|---|---|---|---|---|
| GET | `/packages/:id/tracker` | ✓ | ✓ (gudang sendiri) | ✓ (assigned) | ✓ (assigned) |

### Dashboard

| Method | Endpoint | SUPER_ADMIN | WAREHOUSE_ADMIN | LINEHAUL | COURIER |
|---|---|---|---|---|---|
| GET | `/dashboard` | ✓ (global stats) | ✓ (warehouse stats) | ✓ (personal stats) | ✓ (personal stats) |

### AI

| Method | Endpoint | Semua Role |
|---|---|---|
| POST | `/ai/chat` | ✓ |

---

## Example Request Bodies

### 1. Login

```json
{
  "email": "superadmin@iamexpress.id",
  "password": "admin123"
}
```

### 2. Tambah User Baru (SUPER_ADMIN)

```json
{
  "nama": "Budi Santoso",
  "email": "budi@iamexpress.id",
  "password": "user123",
  "role": "WAREHOUSE_ADMIN",
  "warehouse_id": 1
}
```

Catatan: `photo_url` bersifat opsional. `warehouse_id` wajib untuk semua role kecuali `SUPER_ADMIN`.

### 3. Ganti Password

```json
{
  "old_password": "user123",
  "new_password": "newpassword456"
}
```

### 4. Toggle Biometrik (Mobile — Flutter)

```json
{
  "biometrics_enabled": true,
  "biometrics_type": "fingerprint"
}
```

Nilai `biometrics_type`: `fingerprint` atau `face`.

### 5. Tambah Warehouse (SUPER_ADMIN)

```json
{
  "nama_gudang": "Gudang Yogyakarta",
  "alamat": "Jl. Ring Road Utara No. 88, Sleman, Yogyakarta"
}
```

Catatan: `lat` dan `lng` akan digenerate otomatis dari `alamat` via geocoding.

### 6. Update Warehouse

```json
{
  "nama_gudang": "Gudang Yogyakarta - Revisi",
  "alamat": "Jl. Ring Road Utara No. 100, Sleman, Yogyakarta"
}
```

### 7. Buat Paket Baru (WAREHOUSE_ADMIN)

```json
{
  "nama_paket": "Elektronik - Laptop ASUS",
  "alamat_pengirim": "Jl. Malioboro No. 1, Yogyakarta",
  "alamat_tujuan": "Jl. Sudirman No. 50, Jakarta Pusat",
  "no_hp_pengirim": "08123456789",
  "no_hp_penerima": "08987654321",
  "deskripsi_barang": "Laptop gaming, harap hati-hati",
  "berat": 2.5,
  "jenis_layanan": "express",
  "destination_warehouse_id": 2
}
```

Yang digenerate otomatis oleh backend:
- `resi` (format `IAMxxxxxx`)
- `ongkos_kirim` (2.5 × 15.000 = 37.500)
- `sender_lat`, `sender_lng` (geocoding dari alamat pengirim)
- `receiver_lat`, `receiver_lng` (geocoding dari alamat tujuan)
- `current_status` = `Created`
- `current_warehouse_id` = warehouse_id user yang login

### 8. Update Paket

```json
{
  "nama_paket": "Elektronik - Laptop ASUS VivoBook",
  "deskripsi_barang": "Laptop gaming baru dalam box",
  "no_hp_penerima": "08911111111"
}
```

Catatan: `berat`, `jenis_layanan`, dan `alamat` tidak bisa diubah setelah paket dibuat karena mempengaruhi harga dan koordinat.

### 9. Update Status Paket

**Sebagai WAREHOUSE_ADMIN:**

```json
{
  "status": "Assigned to Linehaul",
  "notes": "Siap dijemput linehaul besok pagi"
}
```

**Sebagai LINEHAUL:**

```json
{
  "status": "In Transit",
  "notes": "Berangkat dari Gudang Yogyakarta menuju Jakarta"
}
```

**Sebagai COURIER:**

```json
{
  "status": "Delivered",
  "notes": "Diterima langsung oleh pemilik"
}
```

### 10. Assign Paket ke Linehaul

```json
{
  "user_id": 4,
  "type": "linehaul"
}
```

### 11. Assign Paket ke Courier

```json
{
  "user_id": 6,
  "type": "courier"
}
```

Setelah assign ke linehaul, `current_status` otomatis berubah ke `Assigned to Linehaul`.
Setelah assign ke courier, `current_status` otomatis berubah ke `Assigned to Courier`.

### 12. Chat AI

```json
{
  "message": "Paket mana yang harus saya antar dulu?"
}
```

Contoh pertanyaan lain:
- `"Berapa paket saya yang masih aktif?"`
- `"Cari paket tujuan Sleman"`
- `"Paket IAM000003 sudah sampai mana?"`

---

## Dashboard Response per Role

### SUPER_ADMIN

```json
{
  "success": true,
  "data": {
    "total_warehouse": 3,
    "total_user": 12,
    "total_paket_aktif": 47,
    "total_delivered": 128,
    "paket_per_warehouse": [
      { "warehouse_id": 1, "nama_gudang": "Gudang Yogyakarta", "total": 15 }
    ],
    "paket_per_status": [
      { "status": "In Transit", "total": 12 },
      { "status": "Out For Delivery", "total": 8 }
    ]
  }
}
```

### WAREHOUSE_ADMIN

```json
{
  "success": true,
  "data": {
    "paket_di_warehouse": 12,
    "menunggu_linehaul": 3,
    "menunggu_courier": 4,
    "delivered_hari_ini": 7
  }
}
```

### LINEHAUL / COURIER

```json
{
  "success": true,
  "data": {
    "total_ditugaskan": 10,
    "sedang_dikerjakan": 4,
    "selesai_hari_ini": 6
  }
}
```

---

## Catatan Penting untuk Frontend

- Semua endpoint protected wajib kirim `Authorization: Bearer <token>`.
- Response `GET /packages` secara otomatis difilter sesuai role — WAREHOUSE_ADMIN hanya melihat paket di gudangnya, LINEHAUL/COURIER hanya melihat paket yang di-assign ke mereka.
- `GET /packages/track/:resi` bisa dipakai untuk search publik antar-role.
- Setiap perubahan status via `PATCH /packages/:id/status` otomatis mencatat log di `package_tracker` — frontend tidak perlu POST ke tracker secara terpisah.
- Endpoint `/dashboard` mengembalikan struktur data yang berbeda per role — pastikan frontend handle dengan baik.
- Biometric toggle hanya mengubah flag di server — validasi biometrik sesungguhnya dilakukan di device via `local_auth`.
