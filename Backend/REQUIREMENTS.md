# REQUIREMENTS — IAMExpress: Sistem Pelacakan Paket & Manajemen Gudang

> **Versi:** 1.0
> **Terakhir diperbarui:** 2026
> **Status:** Aktif

---

## 1. Ringkasan Proyek

### 1.1 Deskripsi

**IAMExpress** adalah sistem manajemen pengiriman paket berbasis mobile-first yang mensimulasikan operasional ekspedisi nyata. Sistem terdiri dari aplikasi mobile (Flutter) untuk Linehaul dan Courier, serta aplikasi web (React.js) untuk Super Admin dan Warehouse Admin.

### 1.2 Permasalahan yang Diselesaikan

- Tidak adanya visibilitas status paket secara realtime antar gudang
- Koordinasi antara kurir dan admin gudang yang tidak terstruktur
- Kesulitan melacak riwayat perjalanan paket dari asal ke tujuan
- Pengelolaan multi-warehouse yang terpusat dan terkontrol

### 1.3 Pengguna Utama

| Peran | Platform | Akses |
|---|---|---|
| Super Admin | Web (React.js) | CRUD User, CRUD Warehouse, monitoring seluruh paket |
| Warehouse Admin | Web (React.js) | CRUD Paket, assign Linehaul/Courier, tracking per gudang |
| Linehaul | Mobile (Flutter) | Lihat paket assigned, update status transit antar gudang |
| Courier | Mobile (Flutter) | Lihat paket assigned, update status delivery ke penerima |

---

## 2. Arsitektur Sistem

### 2.1 Deployment Target

```
Platform Cloud: Google Cloud Platform (GCP)
```

| Komponen | Deployment | Keterangan |
|---|---|---|
| Mobile App (Linehaul & Courier) | APK (internal distribution) | Flutter |
| Frontend Web (Admin) | Google App Engine | React.js |
| Backend API | Google Cloud Run | Node.js + Express (Docker) |
| Database | Google Compute Engine VM | MySQL |
| Auth | Stateless JWT | bcrypt hashing, local_auth biometric |
| Maps & LBS | Geocoding API | Konversi alamat ↔ koordinat |
| AI Assistant | Google Gemini API | Chat assistant berbasis LLM |

### 2.2 Tech Stack Final

> ⚠️ **Catatan:** Tech stack di bawah adalah keputusan final. Jangan ganti tanpa instruksi eksplisit.

```
Mobile App      : Flutter (Dart)
Web Admin       : React.js
Backend API     : Node.js + Express.js
Database        : MySQL (di GCE VM)
Auth            : JWT + bcrypt
Biometric       : Flutter local_auth (device-side, tidak disimpan di server)
Maps / LBS      : Geocoding OpenStreetMap Nominatim (gratis, no key)
                  Peta tile: OpenStreetMap via Leaflet (web) + flutter_map (mobile)
AI / LLM        : Google Gemini API (Gemini Flash, free tier)
Cuaca           : Open-Meteo API (gratis, tanpa API key)
Kurs Mata Uang  : ExchangeRate-API (free tier, 1500 req/bulan)
Sensor          : GPS + Accelerometer
Containerisasi  : Docker (untuk Cloud Run)
Design System   : Lihat DESIGN_SYSTEM.md — warna, tipografi, spacing terpusat
```

---

## 3. Database Design

### 3.1 Empat Tabel Utama (MySQL)

> Semua tabel menggunakan `snake_case`. Tidak menggunakan ORM — query raw MySQL dengan `mysql2` atau `mysql2/promise`.

#### Tabel 1: `users`

| Kolom | Tipe | Keterangan |
|---|---|---|
| `user_id` | INT, PK, AUTO_INCREMENT | |
| `nama` | VARCHAR(100), NOT NULL | |
| `email` | VARCHAR(100), UNIQUE, NOT NULL | |
| `password_hash` | VARCHAR(255), NOT NULL | Bcrypt hash |
| `role` | ENUM('SUPER_ADMIN','WAREHOUSE_ADMIN','LINEHAUL','COURIER') | |
| `photo_url` | VARCHAR(255), NULL | URL foto profil |
| `warehouse_id` | INT, FK → warehouses, NULL | NULL untuk SUPER_ADMIN |
| `biometrics_type` | ENUM('fingerprint','face'), NULL | Tipe biometrik yang didaftarkan |
| `biometrics_enabled` | TINYINT(1), DEFAULT 0 | 0 = off, 1 = on |
| `created_at` | TIMESTAMP, DEFAULT CURRENT_TIMESTAMP | |

**Catatan:**
- `SUPER_ADMIN`: `warehouse_id = NULL`, dibuat via seeder
- `WAREHOUSE_ADMIN`, `LINEHAUL`, `COURIER`: `warehouse_id` wajib diisi, didaftarkan oleh SUPER_ADMIN

#### Tabel 2: `warehouses`

| Kolom | Tipe | Keterangan |
|---|---|---|
| `warehouse_id` | INT, PK, AUTO_INCREMENT | |
| `nama_gudang` | VARCHAR(100), NOT NULL | |
| `alamat` | TEXT, NOT NULL | Alamat lengkap |
| `lat` | DECIMAL(10,7), NULL | Hasil geocoding dari alamat |
| `lng` | DECIMAL(10,7), NULL | Hasil geocoding dari alamat |
| `created_at` | TIMESTAMP, DEFAULT CURRENT_TIMESTAMP | |

#### Tabel 3: `packages`

| Kolom | Tipe | Keterangan |
|---|---|---|
| `package_id` | INT, PK, AUTO_INCREMENT | |
| `resi` | VARCHAR(20), UNIQUE, NOT NULL | Format: `IAM` + 6 digit angka (e.g. `IAM001234`) |
| `nama_paket` | VARCHAR(150), NOT NULL | Nama/deskripsi singkat |
| `alamat_pengirim` | TEXT, NOT NULL | |
| `alamat_tujuan` | TEXT, NOT NULL | |
| `no_hp_pengirim` | VARCHAR(20), NOT NULL | |
| `no_hp_penerima` | VARCHAR(20), NOT NULL | |
| `deskripsi_barang` | TEXT, NULL | |
| `berat` | DECIMAL(8,2), NOT NULL | Dalam kilogram |
| `jenis_layanan` | ENUM('standar','express','kargo') | standar=10rb/kg, express=15rb/kg, kargo=5rb/kg (min 10kg) |
| `ongkos_kirim` | DECIMAL(12,2), NOT NULL | Dihitung otomatis saat create |
| `sender_lat` | DECIMAL(10,7), NULL | Geocoding dari alamat pengirim |
| `sender_lng` | DECIMAL(10,7), NULL | |
| `receiver_lat` | DECIMAL(10,7), NULL | Geocoding dari alamat tujuan |
| `receiver_lng` | DECIMAL(10,7), NULL | |
| `current_warehouse_id` | INT, FK → warehouses, NOT NULL | Posisi paket saat ini |
| `destination_warehouse_id` | INT, FK → warehouses, NULL | Gudang tujuan (opsional) |
| `current_status` | ENUM (lihat bawah), NOT NULL, DEFAULT 'Created' | |
| `assigned_user_id` | INT, FK → users, NULL | Kurir/Linehaul yang ditugaskan |
| `created_at` | TIMESTAMP, DEFAULT CURRENT_TIMESTAMP | |

**Nilai ENUM `current_status`:**
```
'Created'
'Received at Warehouse'
'Assigned to Linehaul'
'Picked Up'
'In Transit'
'Arrived at Warehouse'
'Assigned to Courier'
'Out For Delivery'
'Delivered'
'Failed Delivery'
```

**Logika bisnis:**
- `resi` digenerate otomatis: `IAM` + `LPAD(package_id, 6, '0')` setelah insert
- `sender_lat/lng` dan `receiver_lat/lng` digenerate otomatis via geocoding saat create
- `ongkos_kirim` dihitung: `berat × harga_per_kg` sesuai `jenis_layanan`
- `kargo` minimum 10 kg, tolak jika kurang
- `current_status` di-set otomatis ke `Created` saat `POST /packages` — tidak di-set via PATCH

#### Tabel 4: `package_tracker`

| Kolom | Tipe | Keterangan |
|---|---|---|
| `track_id` | INT, PK, AUTO_INCREMENT | |
| `package_id` | INT, FK → packages, NOT NULL | |
| `warehouse_id` | INT, FK → warehouses, NULL | Gudang tempat status diubah |
| `status` | VARCHAR(50), NOT NULL | Status baru yang dicatat |
| `notes` | TEXT, NULL | Catatan tambahan |
| `created_by` | INT, FK → users, NOT NULL | User yang mengubah status |
| `timestamp` | TIMESTAMP, DEFAULT CURRENT_TIMESTAMP | |

---

## 4. Endpoint API (REST)

### 4.1 Base URL

```
Development : http://localhost:3000/api/v1
Production  : https://<cloud-run-url>/api/v1
```

### 4.2 Auth Endpoints

| Method | Endpoint | Akses | Deskripsi |
|---|---|---|---|
| POST | `/auth/login` | Public | Login email + password |
| GET | `/auth/me` | Auth | Ambil data user aktif |
| POST | `/auth/logout` | Auth | Invalidate token (blacklist) |

### 4.3 User Endpoints

| Method | Endpoint | Akses | Deskripsi |
|---|---|---|---|
| GET | `/users` | SUPER_ADMIN | List semua user (pagination + filter) |
| GET | `/users/:id` | SUPER_ADMIN, Self | Detail user |
| POST | `/users` | SUPER_ADMIN | Tambah user baru (semua role) |
| PUT | `/users/:id` | SUPER_ADMIN, Self | Update data user |
| DELETE | `/users/:id` | SUPER_ADMIN | Hapus user |
| PATCH | `/users/:id/role` | SUPER_ADMIN | Ubah role user |
| PATCH | `/users/me/password` | Auth (Self) | Ganti password sendiri |
| PATCH | `/users/me/photo` | Auth (Self) | Update foto profil |
| PATCH | `/users/me/biometrics` | Auth (Self) | Toggle biometric setting |

### 4.4 Warehouse Endpoints

| Method | Endpoint | Akses | Deskripsi |
|---|---|---|---|
| GET | `/warehouses` | Auth | List semua gudang |
| GET | `/warehouses/:id` | Auth | Detail gudang |
| POST | `/warehouses` | SUPER_ADMIN | Tambah gudang baru |
| PUT | `/warehouses/:id` | SUPER_ADMIN | Update data gudang |
| DELETE | `/warehouses/:id` | SUPER_ADMIN | Hapus gudang |

### 4.5 Package Endpoints

| Method | Endpoint | Akses | Deskripsi |
|---|---|---|---|
| GET | `/packages` | Auth (role-filtered) | List paket sesuai role |
| GET | `/packages/:id` | Auth | Detail paket |
| GET | `/packages/track/:resi` | Auth | Cari paket berdasarkan nomor resi |
| POST | `/packages` | WAREHOUSE_ADMIN | Buat paket baru (status `Created` di-set otomatis) |
| PUT | `/packages/:id` | WAREHOUSE_ADMIN | Edit data paket (sebelum diproses) |
| DELETE | `/packages/:id` | WAREHOUSE_ADMIN, SUPER_ADMIN | Hapus paket |
| PATCH | `/packages/:id/status` | WAREHOUSE_ADMIN, LINEHAUL, COURIER | Ubah status paket |
| PATCH | `/packages/:id/assign` | WAREHOUSE_ADMIN | Assign ke Linehaul atau Courier |

### 4.6 Tracker Endpoints

| Method | Endpoint | Akses | Deskripsi |
|---|---|---|---|
| GET | `/packages/:id/tracker` | Auth | Riwayat lengkap perjalanan paket |

### 4.7 Dashboard Endpoints

| Method | Endpoint | Akses | Deskripsi |
|---|---|---|---|
| GET | `/dashboard` | Auth (role-based) | Statistik sesuai role |

### 4.8 AI Endpoints

| Method | Endpoint | Akses | Deskripsi |
|---|---|---|---|
| POST | `/ai/chat` | Auth | Chat dengan AI assistant berbasis Gemini |

---

## 5. Alur Status Paket

```
[Created]
    ↓ (WAREHOUSE_ADMIN)
[Received at Warehouse]
    ↓ (WAREHOUSE_ADMIN)
[Assigned to Linehaul]
    ↓ (LINEHAUL)
[Picked Up]
    ↓ (LINEHAUL)
[In Transit]
    ↓ (LINEHAUL)
[Arrived at Warehouse]
    ↓ (WAREHOUSE_ADMIN)
[Assigned to Courier]
    ↓ (COURIER)
[Out For Delivery]
    ↓ (COURIER)
[Delivered] atau [Failed Delivery]
```

**Validasi transisi status** harus dilakukan di backend. Status tidak boleh mundur kecuali `Failed Delivery` → kembali ke `Assigned to Courier` (retry delivery).

---

## 6. Role & Hak Akses

### SUPER_ADMIN
- CRUD semua user (semua role)
- CRUD semua gudang
- Lihat semua paket (read-only, **plus bisa hapus paket**)
- Lihat semua tracking
- Dashboard global: total warehouse, total user, total paket aktif, total delivered, breakdown per status, breakdown per warehouse
- `warehouse_id = NULL`

### WAREHOUSE_ADMIN
- CRUD paket di gudangnya sendiri (`current_warehouse_id = warehouse_id miliknya`)
- Assign paket ke Linehaul
- Assign paket ke Courier
- Lihat tracking paket di gudangnya
- Dashboard: paket di gudang, menunggu linehaul, menunggu courier, delivered hari ini
- `warehouse_id` wajib diisi

### LINEHAUL
- Lihat paket yang di-assign kepadanya
- Update status: `Picked Up`, `In Transit`, `Arrived at Warehouse`
- Tidak bisa buat/edit/hapus paket
- `warehouse_id` wajib diisi (gudang asal)

### COURIER
- Lihat paket yang di-assign kepadanya
- Update status: `Out For Delivery`, `Delivered`, `Failed Delivery`
- Tidak bisa buat/edit/hapus paket
- `warehouse_id` wajib diisi (gudang asal)

---

## 7. Response Format

### 7.1 Success Response

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

`meta` hanya muncul di endpoint list dengan pagination.

### 7.2 Error Response

```json
{
  "success": false,
  "message": "Pesan error yang deskriptif",
  "errors": [
    { "field": "email", "message": "Email sudah digunakan" }
  ]
}
```

### 7.3 HTTP Status Code Convention

| Kode | Digunakan untuk |
|---|---|
| `200` | GET, PUT, PATCH sukses |
| `201` | POST sukses (resource dibuat) |
| `204` | DELETE sukses |
| `400` | Validasi gagal / bad request |
| `401` | Token tidak ada / expired |
| `403` | Role tidak punya izin |
| `404` | Resource tidak ditemukan |
| `409` | Conflict (e.g. email duplikat, resi duplikat) |
| `500` | Internal server error |

---

## 8. Autentikasi & Otorisasi

```
Metode    : JWT (JSON Web Token)
Expiry    : 24 jam
Algorithm : HS256
Blacklist : Disimpan di memori / Redis (token yang sudah logout)

Role Hierarchy:
  SUPER_ADMIN     → akses global
  WAREHOUSE_ADMIN → akses terbatas pada warehouse miliknya
  LINEHAUL        → akses terbatas pada paket assigned
  COURIER         → akses terbatas pada paket assigned
```

**Middleware yang wajib dibuat:**
- `authMiddleware` — verifikasi JWT token
- `roleMiddleware(roles[])` — cek apakah role user ada di array yang diizinkan
- `warehouseOwnerMiddleware` — cek apakah paket berada di warehouse user tersebut
- `packageAssigneeMiddleware` — cek apakah paket di-assign ke user tersebut

---

## 9. Environment Variables

> ⚠️ **JANGAN commit `.env` ke Git. Gunakan `.env.example` sebagai template.**

```env
# App
NODE_ENV=development
PORT=3000
APP_URL=http://localhost:3000

# Database MySQL
DB_HOST=localhost
DB_PORT=3306
DB_NAME=iamexpress_db
DB_USER=root
DB_PASSWORD=

# JWT
JWT_SECRET=your_very_strong_secret_here
JWT_EXPIRES_IN=24h

# Geocoding
GEOCODING_PROVIDER=nominatim
# Atau: GOOGLE_MAPS_API_KEY=... (jika pakai Google Maps)

# Google Gemini AI
GEMINI_API_KEY=

# CORS
ALLOWED_ORIGINS=http://localhost:5173

# GCS (opsional, untuk upload foto profil)
GCS_BUCKET_NAME=iamexpress-files
GCS_PROJECT_ID=
GOOGLE_APPLICATION_CREDENTIALS=./service-account.json
```

---

## 10. Struktur Folder Backend

```
backend/
├── src/
│   ├── server.js               ← Entry point, listen port
│   ├── app.js                  ← Express setup, middleware global, routing
│   ├── config/
│   │   └── db.js               ← MySQL connection pool (mysql2/promise)
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── userController.js
│   │   ├── warehouseController.js
│   │   ├── packageController.js
│   │   ├── trackerController.js
│   │   ├── dashboardController.js
│   │   └── aiController.js
│   ├── middleware/
│   │   ├── authMiddleware.js
│   │   ├── roleMiddleware.js
│   │   └── warehouseMiddleware.js
│   ├── routes/
│   │   └── v1/
│   │       ├── index.js
│   │       ├── auth.routes.js
│   │       ├── user.routes.js
│   │       ├── warehouse.routes.js
│   │       ├── package.routes.js
│   │       ├── tracker.routes.js
│   │       ├── dashboard.routes.js
│   │       └── ai.routes.js
│   ├── services/
│   │   ├── geocodingService.js  ← Konversi alamat ke koordinat
│   │   ├── resiService.js       ← Generate nomor resi IAMxxxxxx
│   │   ├── shippingService.js   ← Hitung ongkos kirim
│   │   └── geminiService.js     ← Integrasi Gemini AI
│   └── utils/
│       ├── pagination.js
│       ├── response.js          ← Helper success/error response
│       └── statusValidator.js   ← Validasi transisi status paket
├── database/
│   ├── schema.sql              ← DDL lengkap semua tabel
│   └── seed.sql                ← Data dummy untuk testing
├── .env.example
├── Dockerfile
└── package.json
```

---

## 11. Checklist Pengerjaan

### Setup Infrastruktur
- [ ] Setup GCP Project
- [ ] Setup MySQL di GCE VM
- [ ] Setup Cloud Run untuk backend API
- [ ] Setup App Engine untuk React web
- [ ] Aktifkan Gemini API di Google AI Studio
- [ ] Setup Geocoding API

### Backend
- [ ] Inisialisasi project (`npm init`, install dependencies)
- [ ] Setup koneksi MySQL (`mysql2/promise` connection pool)
- [ ] Buat file `schema.sql` dan jalankan di database
- [ ] Buat seed data (1 SUPER_ADMIN, 2-3 WAREHOUSE_ADMIN, 2 LINEHAUL, 3 COURIER, 2-3 warehouse, 10+ paket)
- [ ] Implementasi Auth (login, JWT, me, logout + blacklist)
- [ ] CRUD User (8 endpoint)
- [ ] CRUD Warehouse (5 endpoint)
- [ ] CRUD Package + status + assign (8 endpoint)
- [ ] Tracker (1 endpoint GET)
- [ ] Dashboard (1 endpoint, role-based response)
- [ ] AI Chat (1 endpoint)
- [ ] Middleware: auth, role, warehouse owner, assignee
- [ ] Service: geocoding, resi generator, shipping calculator, Gemini

### Database
- [ ] Buat schema.sql
- [ ] Buat seed.sql dengan data dummy lengkap

### Dokumentasi
- [ ] README.md
- [ ] ROLE_ENDPOINTS.md
- [ ] PAGINATION.md
- [ ] TEST_ENDPOINT_CHECKLIST.md

---

## 12. Catatan untuk AI Agent

1. **Selalu baca file ini sebelum membuat kode baru.** Jangan berasumsi tentang nama tabel, kolom, atau endpoint.
2. **Nama tabel dan kolom** harus persis seperti di Bagian 3. Gunakan `snake_case`.
3. **Tidak menggunakan Sequelize/ORM.** Semua query database menggunakan `mysql2/promise` raw query.
4. **Resi digenerate otomatis** setelah insert: format `IAM` + 6 digit angka dengan leading zero.
5. **Geocoding dipanggil otomatis** saat package dibuat — jangan minta user input koordinat.
6. **Ongkos kirim dihitung otomatis** di `shippingService.js`, tidak dikirim dari frontend.
7. **Validasi transisi status** wajib ada di `statusValidator.js`. Status tidak boleh loncat sembarang.
8. **Response format** harus selalu mengikuti Bagian 7.
9. **JWT validation** di `authMiddleware.js`. Semua route protected wajib pakai middleware ini.
10. **Role check** di `roleMiddleware.js`. Gunakan konstanta: `'SUPER_ADMIN'`, `'WAREHOUSE_ADMIN'`, `'LINEHAUL'`, `'COURIER'`.
11. **Perubahan schema** harus diupdate di `schema.sql`, bukan langsung di database production.
12. **Biometric** adalah fitur device-side (Flutter `local_auth`). Backend hanya menyimpan flag `biometrics_enabled` dan `biometrics_type`, tidak ada data biometrik yang dikirim ke server.

---

*Dokumen ini adalah sumber kebenaran tunggal (single source of truth) untuk proyek IAMExpress Backend.*
