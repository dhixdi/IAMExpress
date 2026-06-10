# IAMExpress Backend API

Backend REST API untuk IAMExpress — Sistem Manajemen Pengiriman Paket & Gudang

## Setup Development

### 1. Install Dependencies

```bash
npm install
```

Dependencies utama yang digunakan:

```
express          ← HTTP framework
mysql2           ← MySQL driver (raw query, bukan ORM)
jsonwebtoken     ← JWT auth
bcrypt           ← Password hashing
dotenv           ← Environment config
cors             ← CORS middleware
helmet           ← Security headers
morgan           ← Request logger
axios            ← HTTP client (untuk geocoding & Gemini)
```

### 2. Setup Database MySQL

```bash
# Buat database baru
mysql -u root -p -e "CREATE DATABASE iamexpress_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Jalankan schema
mysql -u root -p iamexpress_db < database/schema.sql

# Masukkan data seed (opsional tapi direkomendasikan)
mysql -u root -p iamexpress_db < database/seed.sql
```

### 3. Konfigurasi Environment

Salin `.env.example` ke `.env` dan isi nilainya:

```bash
cp .env.example .env
```

```env
NODE_ENV=development
PORT=3000
DB_HOST=localhost
DB_PORT=3306
DB_NAME=iamexpress_db
DB_USER=root
DB_PASSWORD=your_password
JWT_SECRET=your_very_strong_secret_here
JWT_EXPIRES_IN=24h
GEMINI_API_KEY=your_gemini_api_key
ALLOWED_ORIGINS=http://localhost:5173
```

### 4. Jalankan Development Server

```bash
npm run dev
```

Server berjalan di `http://localhost:3000`

---

## API Documentation

Untuk detail role dan contoh body request, lihat [ROLE_ENDPOINTS.md](ROLE_ENDPOINTS.md).
Untuk pagination, lihat [PAGINATION.md](PAGINATION.md).
Untuk test checklist manual, lihat [TEST_ENDPOINT_CHECKLIST.md](TEST_ENDPOINT_CHECKLIST.md).

### Base URL

```
http://localhost:3000/api/v1
```

### Roles

| Role | Deskripsi | warehouse_id |
|---|---|---|
| `SUPER_ADMIN` | Kelola sistem global | NULL |
| `WAREHOUSE_ADMIN` | Kelola paket di gudangnya | Wajib |
| `LINEHAUL` | Kirim paket antar gudang | Wajib |
| `COURIER` | Kirim paket ke penerima akhir | Wajib |

### Authentication

Semua endpoint kecuali `POST /auth/login` membutuhkan JWT token:

```http
Authorization: Bearer <token>
Content-Type: application/json
```

### Response Format

Success:

```json
{
  "success": true,
  "message": "Berhasil",
  "data": {},
  "meta": {
    "page": 1,
    "per_page": 10,
    "total": 100,
    "total_pages": 10
  }
}
```

Error:

```json
{
  "success": false,
  "message": "Pesan error",
  "errors": [
    { "field": "email", "message": "Email sudah digunakan" }
  ]
}
```

---

### Endpoint Reference

#### Auth

| Method | Endpoint | Akses | Body |
|---|---|---|---|
| POST | `/auth/login` | Public | `email`, `password` |
| GET | `/auth/me` | Auth | — |
| POST | `/auth/logout` | Auth | — |

#### User

| Method | Endpoint | Akses | Body / Query |
|---|---|---|---|
| GET | `/users` | SUPER_ADMIN | `page?`, `per_page?`, `q?`, `role?`, `warehouse_id?`, `sort_by?`, `order?` |
| GET | `/users/:id` | SUPER_ADMIN, Self | — |
| POST | `/users` | SUPER_ADMIN | `nama`, `email`, `password`, `role`, `warehouse_id?`, `photo_url?` |
| PUT | `/users/:id` | SUPER_ADMIN, Self | `nama?`, `photo_url?` |
| DELETE | `/users/:id` | SUPER_ADMIN | — |
| PATCH | `/users/:id/role` | SUPER_ADMIN | `role` |
| PATCH | `/users/me/password` | Auth | `old_password`, `new_password` |
| PATCH | `/users/me/photo` | Auth | `photo_url` |
| PATCH | `/users/me/biometrics` | Auth | `biometrics_enabled`, `biometrics_type?` |

#### Warehouse

| Method | Endpoint | Akses | Body / Query |
|---|---|---|---|
| GET | `/warehouses` | Auth | `page?`, `per_page?`, `q?`, `sort_by?`, `order?` |
| GET | `/warehouses/:id` | Auth | — |
| POST | `/warehouses` | SUPER_ADMIN | `nama_gudang`, `alamat` |
| PUT | `/warehouses/:id` | SUPER_ADMIN | `nama_gudang?`, `alamat?` |
| DELETE | `/warehouses/:id` | SUPER_ADMIN | — |

#### Package

| Method | Endpoint | Akses | Body / Query |
|---|---|---|---|
| GET | `/packages` | Auth (role-filtered) | `page?`, `per_page?`, `q?`, `current_status?`, `jenis_layanan?`, `warehouse_id?`, `sort_by?`, `order?` |
| GET | `/packages/:id` | Auth | — |
| GET | `/packages/track/:resi` | Auth | — |
| POST | `/packages` | WAREHOUSE_ADMIN | `nama_paket`, `alamat_pengirim`, `alamat_tujuan`, `no_hp_pengirim`, `no_hp_penerima`, `deskripsi_barang?`, `berat`, `jenis_layanan`, `destination_warehouse_id?` |
| PUT | `/packages/:id` | WAREHOUSE_ADMIN | `nama_paket?`, `deskripsi_barang?`, `no_hp_pengirim?`, `no_hp_penerima?` |
| DELETE | `/packages/:id` | **WAREHOUSE_ADMIN, SUPER_ADMIN** | — |
| PATCH | `/packages/:id/status` | WAREHOUSE_ADMIN, LINEHAUL, COURIER | `status`, `notes?` |
| PATCH | `/packages/:id/assign` | WAREHOUSE_ADMIN | `user_id`, `type` (`linehaul` atau `courier`) |

#### Tracker

| Method | Endpoint | Akses | Keterangan |
|---|---|---|---|
| GET | `/packages/:id/tracker` | Auth | Riwayat perjalanan lengkap satu paket |

#### Dashboard

| Method | Endpoint | Akses | Keterangan |
|---|---|---|---|
| GET | `/dashboard` | Auth | Response berbeda per role |

#### AI

| Method | Endpoint | Akses | Body |
|---|---|---|---|
| POST | `/ai/chat` | Auth | `message` |

---

### Contoh Request

Login:

```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"superadmin@iamexpress.id","password":"admin123"}'
```

Buat paket baru (sebagai WAREHOUSE_ADMIN):

```bash
curl -X POST http://localhost:3000/api/v1/packages \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "nama_paket": "Elektronik - Laptop ASUS",
    "alamat_pengirim": "Jl. Malioboro No. 1, Yogyakarta",
    "alamat_tujuan": "Jl. Sudirman No. 50, Jakarta Pusat",
    "no_hp_pengirim": "08123456789",
    "no_hp_penerima": "08987654321",
    "berat": 2.5,
    "jenis_layanan": "express"
  }'
```

Cari paket via resi:

```bash
curl http://localhost:3000/api/v1/packages/track/IAM000001 \
  -H "Authorization: Bearer <token>"
```

Update status paket (sebagai COURIER):

```bash
curl -X PATCH http://localhost:3000/api/v1/packages/1/status \
  -H "Authorization: Bearer <token-courier>" \
  -H "Content-Type: application/json" \
  -d '{"status": "Delivered", "notes": "Diterima oleh pemilik langsung"}'
```

Assign paket ke Courier:

```bash
curl -X PATCH http://localhost:3000/api/v1/packages/1/assign \
  -H "Authorization: Bearer <token-warehouse-admin>" \
  -H "Content-Type: application/json" \
  -d '{"user_id": 5, "type": "courier"}'
```

Chat AI:

```bash
curl -X POST http://localhost:3000/api/v1/ai/chat \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"message": "Paket mana yang harus saya antar dulu?"}'
```

---

## Default Demo Users

| Email | Password | Role |
|---|---|---|
| superadmin@iamexpress.id | admin123 | SUPER_ADMIN |
| admin.jogja@iamexpress.id | admin123 | WAREHOUSE_ADMIN (Gudang Jogja) |
| admin.jakarta@iamexpress.id | admin123 | WAREHOUSE_ADMIN (Gudang Jakarta) |
| linehaul1@iamexpress.id | user123 | LINEHAUL |
| kurir1@iamexpress.id | user123 | COURIER |

---

## Project Structure

```
src/
├── server.js               ← Entry point
├── app.js                  ← Express setup
├── config/
│   └── db.js               ← MySQL connection pool
├── controllers/            ← Business logic per resource
├── middleware/             ← Auth, role, warehouse checks
├── routes/v1/              ← Route definitions
├── services/               ← Geocoding, resi, shipping, Gemini
└── utils/                  ← Pagination, response helper, status validator
database/
├── schema.sql              ← DDL semua tabel
└── seed.sql                ← Data dummy
```

## Tech Stack

- **Framework**: Express.js
- **Database**: MySQL (`mysql2/promise`, raw query)
- **Auth**: JWT + bcrypt
- **AI**: Google Gemini API
- **Geocoding**: OpenStreetMap Nominatim (gratis) / Google Maps API
- **Security**: helmet, cors, morgan

## Catatan Penting

- `POST /auth/login` adalah satu-satunya endpoint public
- Semua perubahan status paket secara otomatis mencatat entry baru di `package_tracker`
- `resi` digenerate otomatis — frontend tidak perlu mengirimkan nilai ini
- `ongkos_kirim`, `sender_lat/lng`, `receiver_lat/lng` semuanya dihitung/generate otomatis di backend
- `current_status = 'Created'` di-set otomatis saat `POST /packages` — **tidak bisa di-set via PATCH**
- Token yang di-logout disimpan di blacklist (in-memory Set atau Redis) sampai expired
- Biometric hanya flag device-side — tidak ada data biometrik yang dikirim ke backend
- SUPER_ADMIN **dapat menghapus paket manapun** di semua gudang
- **Design System:** Lihat `DESIGN_SYSTEM.md` untuk panduan warna, tipografi, dan komponen

## Troubleshooting

- **Koneksi database gagal**: Pastikan MySQL sudah running dan kredensial `.env` benar
- **JWT error**: Cek `JWT_SECRET` di `.env`
- **Geocoding lambat/gagal**: Nominatim punya rate limit 1 req/detik — tambah delay atau ganti ke Google Maps API
- **CORS error**: Tambah URL frontend ke `ALLOWED_ORIGINS` di `.env`
- **Gemini error**: Pastikan `GEMINI_API_KEY` valid dan quota API belum habis
