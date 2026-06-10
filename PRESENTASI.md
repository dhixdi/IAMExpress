# 📦 IAMExpress

### Sistem Manajemen Pengiriman Paket & Gudang

> Platform digital untuk melacak, mengelola, dan mengoordinasikan pengiriman paket secara real-time antar gudang — dari penerimaan hingga sampai ke tangan penerima.

---

## 📌 Daftar Isi

1. [Latar Belakang & Tujuan](#-latar-belakang--tujuan)
2. [Fitur Utama](#-fitur-utama)
3. [Tech Stack](#-tech-stack)
4. [Arsitektur Sistem](#-arsitektur-sistem)
5. [Database Schema](#-database-schema)
6. [Role & Hak Akses](#-role--hak-akses)
7. [Alur Status Paket](#-alur-status-paket)
8. [API Endpoints](#-api-endpoints)
9. [Frontend (Web Admin)](#-frontend-web-admin)
10. [Mobile App (Flutter)](#-mobile-app-flutter)
11. [Integrasi Sensor & Hardware](#-integrasi-sensor--hardware)
12. [Integrasi API Eksternal](#-integrasi-api-eksternal)
13. [Keamanan (Security)](#-keamanan-security)
14. [Design System](#-design-system)
15. [Deployment & Infrastruktur](#-deployment--infrastruktur)
16. [Cara Menjalankan Lokal](#-cara-menjalankan-lokal)
17. [Akun Demo](#-akun-demo)
18. [Tim Pengembang](#-tim-pengembang)

---

## 🎯 Latar Belakang & Tujuan

### Permasalahan

Dalam industri logistik dan pengiriman paket, koordinasi antar gudang, kurir, dan admin seringkali dilakukan secara manual. Hal ini menyebabkan:

- ❌ Sulitnya melacak posisi dan status paket secara real-time
- ❌ Koordinasi yang tidak efisien antara kurir dan admin gudang
- ❌ Tidak ada visibilitas terpusat terhadap operasional multi-gudang
- ❌ Proses pencatatan dan pelacakan yang rawan kesalahan

### Solusi: IAMExpress

IAMExpress hadir sebagai **platform digital terpadu** yang menyediakan:

- ✅ **Pelacakan paket real-time** dari origin ke destination
- ✅ **Koordinasi terstruktur** antara kurir dan admin gudang
- ✅ **Dashboard terpusat** untuk monitoring seluruh operasional
- ✅ **Aplikasi mobile** untuk petugas lapangan (Linehaul & Courier)
- ✅ **AI Assistant** berbasis Google Gemini untuk bantuan operasional
- ✅ **Peta interaktif** untuk visualisasi lokasi gudang & tujuan paket

---

## ⭐ Fitur Utama

### 🌐 Web Admin (React.js)

| Fitur | Deskripsi |
|---|---|
| **Dashboard** | Statistik real-time (total paket, status, grafik) |
| **Manajemen User** | CRUD user dengan filter role & pagination |
| **Manajemen Gudang** | CRUD gudang dengan peta interaktif (Leaflet) |
| **Manajemen Paket** | CRUD paket, filter status, pencarian, assign ke petugas |
| **Tracking Paket** | Timeline perjalanan paket dari awal hingga akhir |
| **Auto-Geocoding** | Alamat otomatis dikonversi ke koordinat peta |
| **Auto-Resi** | Nomor resi otomatis di-generate (format: IAM000001) |
| **Auto-Ongkir** | Ongkos kirim dihitung otomatis berdasarkan berat & layanan |

### 📱 Mobile App (Flutter)

| Fitur | Deskripsi |
|---|---|
| **Dashboard** | Statistik tugas harian (assigned, in progress, selesai) |
| **Daftar Paket** | 4 tab filter + pencarian + infinite scroll |
| **Shake to Refresh** | Goyangkan HP untuk refresh daftar paket (Accelerometer) |
| **Peta Interaktif** | Lokasi tujuan paket + GPS real-time + navigasi Google Maps |
| **AI Chat** | Asisten AI berbasis Gemini dengan bubble chat UI |
| **Update Status** | Tombol kontekstual sesuai role & status paket |
| **Biometric Auth** | Login dengan sidik jari / Face ID |
| **Mini Game** | 3 Mode: Sortir (Tap), Sortir (Gyroscope), Hujan Paket (Accelerometer) |
| **Weather** | Cuaca terkini (Open-Meteo) + Reverse Geocoding Kota (Nominatim) |
| **Currency Converter** | Konversi IDR ke mata uang asing (open.er-api.com gratis) |
| **Timezone Converter** | Konversi waktu WIB/WITA/WIT/London |
| **Profil** | Kelola foto, password, pengaturan biometrik |

---

## 🛠 Tech Stack

### Backend

| Teknologi | Versi | Fungsi |
|---|---|---|
| **Node.js** | ≥ 20 | Runtime server |
| **Express.js** | 5.x | Web framework REST API |
| **MySQL** | 8.x | Database relasional |
| **mysql2/promise** | 3.x | MySQL driver (raw queries, no ORM) |
| **JWT** | 9.x | Autentikasi token |
| **bcrypt** | 6.x | Hashing password |
| **Helmet** | 8.x | Security headers |
| **CORS** | 2.x | Cross-Origin Resource Sharing |
| **Axios** | 1.x | HTTP client (geocoding, AI) |
| **Docker** | — | Containerization |

### Frontend (Web)

| Teknologi | Versi | Fungsi |
|---|---|---|
| **React** | 19 | UI library |
| **Vite** | 8 | Build tool & dev server |
| **Tailwind CSS** | 3 | Utility-first CSS |
| **shadcn/ui (Radix)** | — | Component library |
| **Zustand** | 5 | Client state management |
| **TanStack React Query** | 5 | Server state & caching |
| **React Router** | 7 | Client-side routing |
| **Recharts** | 3 | Grafik & chart |
| **Leaflet** | — | Peta interaktif (OpenStreetMap) |
| **Axios** | — | HTTP client |
| **Lucide React** | — | Icon library |

### Mobile (Flutter)

| Teknologi | Versi | Fungsi |
|---|---|---|
| **Flutter** | 3.x | Cross-platform framework |
| **Dart** | ≥ 3.0 | Programming language |
| **Riverpod** | 2.x | State management (code-gen) |
| **go_router** | 13 | Navigation & routing |
| **Dio** | 5 | HTTP client |
| **flutter_secure_storage** | 9 | Penyimpanan token terenkripsi |
| **local_auth** | 2 | Autentikasi biometrik |
| **flutter_map** | 6 | Peta interaktif (OpenStreetMap) |
| **geolocator** | 11 | GPS & lokasi |
| **sensors_plus** | 4 | Accelerometer & Gyroscope |
| **flutter_local_notifications** | 17 | Notifikasi lokal |
| **sqflite** | — | Database lokal |
| **google_fonts** | — | Font Inter |

---

## 🏗 Arsitektur Sistem

```
┌─────────────────────────────────────────────────────────┐
│                     CLIENT LAYER                        │
│                                                         │
│  ┌──────────────────┐      ┌──────────────────────┐     │
│  │   Web Admin       │      │   Mobile App          │    │
│  │   (React + Vite)  │      │   (Flutter)           │    │
│  │   Port: 5173      │      │   Android / iOS       │    │
│  └────────┬─────────┘      └──────────┬───────────┘     │
│           │ HTTP/REST                  │ HTTP/REST       │
└───────────┼────────────────────────────┼────────────────┘
            │                            │
            ▼                            ▼
┌─────────────────────────────────────────────────────────┐
│                     API LAYER                           │
│                                                         │
│  ┌─────────────────────────────────────────────────┐    │
│  │          Express.js REST API (Port: 3000)        │    │
│  │                                                   │    │
│  │  ┌─────────┐ ┌──────────┐ ┌───────────────────┐  │   │
│  │  │  Auth   │ │  CRUD    │ │  Business Logic   │  │   │
│  │  │Middleware│ │Controllers│ │  (Services)       │  │   │
│  │  └─────────┘ └──────────┘ └───────────────────┘  │   │
│  └──────────────────────┬──────────────────────────┘    │
│                         │                               │
└─────────────────────────┼───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                     DATA LAYER                          │
│                                                         │
│  ┌──────────────┐    ┌──────────────────────────────┐   │
│  │   MySQL DB    │    │   External APIs              │   │
│  │  (XAMPP Local │    │   • Google Gemini (AI)       │   │
│  │   / Cloud VM) │    │   • Nominatim (Geocoding)   │   │
│  │               │    │   • Open-Meteo (Weather)     │   │
│  │  4 Tables:    │    │   • ExchangeRate (Currency)  │   │
│  │  • warehouses │    │   • OpenStreetMap (Maps)     │   │
│  │  • users      │    └──────────────────────────────┘   │
│  │  • packages   │                                       │
│  │  • package_   │                                       │
│  │    tracker    │                                       │
│  └──────────────┘                                       │
└─────────────────────────────────────────────────────────┘
```

### Pola Arsitektur

| Layer | Pattern | Keterangan |
|---|---|---|
| **Backend** | MVC (Model-View-Controller) | Controller → Service → Database |
| **Frontend** | Component-based + Store | Zustand (client state) + React Query (server state) |
| **Mobile** | Feature-first + Riverpod | Arsitektur berbasis fitur dengan state management Riverpod |
| **API** | RESTful + Versioned | Semua endpoint di bawah `/api/v1/` |

---

## 🗄 Database Schema

### Entity Relationship Diagram

```
┌──────────────────┐       ┌──────────────────────────────────┐
│    warehouses     │       │              users               │
├──────────────────┤       ├──────────────────────────────────┤
│ PK warehouse_id  │◄──┐   │ PK user_id                      │
│    nama_gudang   │   │   │    nama                          │
│    alamat        │   ├───│ FK warehouse_id                  │
│    lat           │   │   │    email (UNIQUE)                │
│    lng           │   │   │    password_hash                 │
│    created_at    │   │   │    role (ENUM)                   │
└──────────────────┘   │   │    photo_url                     │
                       │   │    biometrics_type               │
                       │   │    biometrics_enabled            │
                       │   └──────────────┬───────────────────┘
                       │                  │
                       │                  │ assigned_user_id
                       │                  ▼
                       │   ┌──────────────────────────────────┐
                       │   │            packages              │
                       │   ├──────────────────────────────────┤
                       ├───│ FK current_warehouse_id          │
                       ├───│ FK destination_warehouse_id      │
                       │   │ PK package_id                    │
                       │   │    resi (UNIQUE, auto-generated) │
                       │   │    nama_paket                    │
                       │   │    alamat_pengirim / tujuan      │
                       │   │    no_hp_pengirim / penerima     │
                       │   │    berat, jenis_layanan          │
                       │   │    ongkos_kirim (auto-calculated)│
                       │   │    sender_lat/lng (auto-geocoded)│
                       │   │    receiver_lat/lng              │
                       │   │    current_status (ENUM 10 val)  │
                       │   └──────────────┬───────────────────┘
                       │                  │
                       │                  │ CASCADE
                       │                  ▼
                       │   ┌──────────────────────────────────┐
                       │   │         package_tracker          │
                       │   ├──────────────────────────────────┤
                       │   │ PK track_id                      │
                       ├───│ FK warehouse_id                  │
                       │   │ FK package_id                    │
                           │    status                        │
                           │    notes                         │
                           │ FK created_by (→ users)          │
                           │    timestamp                     │
                           └──────────────────────────────────┘
```

### Detail Tabel

| Tabel | Jumlah Kolom | Deskripsi |
|---|---|---|
| `warehouses` | 5 | Data gudang (nama, alamat, koordinat) |
| `users` | 9 | Data pengguna (nama, email, role, biometrik) |
| `packages` | 17 | Data paket lengkap (resi, alamat, berat, ongkir, status, koordinat) |
| `package_tracker` | 6 | Riwayat perjalanan paket (log setiap perubahan status) |

### Relasi Antar Tabel

| Relasi | Tipe | Keterangan |
|---|---|---|
| `users.warehouse_id` → `warehouses` | Many-to-One | Setiap user ditugaskan ke 1 gudang (kecuali SUPER_ADMIN) |
| `packages.current_warehouse_id` → `warehouses` | Many-to-One | Posisi paket saat ini (RESTRICT delete) |
| `packages.destination_warehouse_id` → `warehouses` | Many-to-One | Gudang tujuan (SET NULL on delete) |
| `packages.assigned_user_id` → `users` | Many-to-One | Petugas yang ditugaskan (SET NULL on delete) |
| `package_tracker.package_id` → `packages` | Many-to-One | Log tracker per paket (CASCADE delete) |
| `package_tracker.created_by` → `users` | Many-to-One | User yang membuat log |

---

## 👥 Role & Hak Akses

### Matriks Role

| Fitur | SUPER_ADMIN | WAREHOUSE_ADMIN | LINEHAUL | COURIER |
|---|---|---|---|---|
| **Platform** | Web | Web | Mobile | Mobile |
| CRUD Users | ✅ | ❌ | ❌ | ❌ |
| CRUD Gudang | ✅ | ❌ | ❌ | ❌ |
| CRUD Paket | ✅ (view) | ✅ (full) | ❌ | ❌ |
| Assign Linehaul | ❌ | ✅ | ❌ | ❌ |
| Assign Courier | ❌ | ✅ | ❌ | ❌ |
| Update Status Transit | ❌ | ❌ | ✅ | ❌ |
| Update Status Delivery | ❌ | ❌ | ❌ | ✅ |
| Dashboard | ✅ (global) | ✅ (per gudang) | ✅ (personal) | ✅ (personal) |
| AI Chat | ✅ | ✅ | ✅ | ✅ |
| Peta | ❌ | ✅ | ✅ | ✅ |

### Middleware Keamanan (Backend)

```
Request → authMiddleware (verify JWT)
        → roleMiddleware (check role permission)
        → warehouseOwnerMiddleware (verify warehouse ownership)
        → packageAssigneeMiddleware (verify package assignment)
        → Controller (execute logic)
```

---

## 📊 Alur Status Paket

Setiap paket melewati **10 status** yang tervalidasi di backend:

```
                    ┌─────────────────────┐
                    │      CREATED        │  ← Otomatis saat paket dibuat
                    │   (Paket Dibuat)    │
                    └─────────┬───────────┘
                              │ WAREHOUSE_ADMIN
                 ┌────────────┴────────────┐
                 ▼                         ▼
      ┌─────────────────────┐   ┌─────────────────────┐
      │  RECEIVED AT        │   │  ASSIGNED TO        │
      │  WAREHOUSE          │   │  LINEHAUL           │
      │ (Diterima di Gudang)│   │ (Ditugaskan)        │
      └─────────┬───────────┘   └─────────┬───────────┘
                │                         │
                └────────────┬────────────┘
                             │ LINEHAUL
                              ▼
                    ┌─────────────────────┐
                    │     PICKED UP       │
                    │   (Diambil)         │
                    └─────────┬───────────┘
                              │ LINEHAUL
                              ▼
                    ┌─────────────────────┐
                    │     IN TRANSIT      │
                    │   (Dalam Perjalanan)│
                    └─────────┬───────────┘
                              │ LINEHAUL
                              ▼
                    ┌─────────────────────┐
                    │  ARRIVED AT         │
                    │  WAREHOUSE          │
                    │ (Tiba di Gudang)    │
                    └─────────┬───────────┘
                              │ WAREHOUSE_ADMIN (assign)
                              ▼
                    ┌─────────────────────┐
                    │  ASSIGNED TO        │
                    │  COURIER            │
                    │ (Ditugaskan ke Kurir│
                    └─────────┬───────────┘
                              │ COURIER
                              ▼
                    ┌─────────────────────┐
                    │  OUT FOR DELIVERY   │
                    │ (Sedang Diantar)    │
                    └─────────┬───────────┘
                              │ COURIER
                     ┌────────┴────────┐
                     ▼                 ▼
          ┌──────────────┐   ┌────────────────┐
          │  DELIVERED   │   │ FAILED DELIVERY│
          │  (Terkirim)  │   │ (Gagal Kirim)  │
          └──────────────┘   └────────────────┘
                                     │
                                     │ (Dapat di-assign ulang)
                                     ▼
                              Kembali ke proses
```

### Perhitungan Ongkos Kirim (Otomatis)

| Jenis Layanan | Tarif per Kg | Minimum Berat |
|---|---|---|
| **Standar** | Rp 10.000 | - |
| **Express** | Rp 15.000 | - |
| **Kargo** | Rp 5.000 | 10 Kg |

> Formula: `ongkos_kirim = berat × tarif_per_kg`

---

## 🔌 API Endpoints

**Base URL:** `http://localhost:3000/api/v1`

### Autentikasi (3 endpoint)

| Method | Endpoint | Akses | Deskripsi |
|---|---|---|---|
| `POST` | `/auth/login` | Public | Login, mendapatkan JWT token |
| `GET` | `/auth/me` | Authenticated | Data user yang sedang login |
| `POST` | `/auth/logout` | Authenticated | Logout & blacklist token |

### Users (9 endpoint)

| Method | Endpoint | Akses | Deskripsi |
|---|---|---|---|
| `GET` | `/users` | SUPER_ADMIN | List semua user (pagination, filter) |
| `GET` | `/users/:id` | SUPER_ADMIN / Self | Detail user |
| `POST` | `/users` | SUPER_ADMIN | Buat user baru |
| `PUT` | `/users/:id` | SUPER_ADMIN | Update data user |
| `DELETE` | `/users/:id` | SUPER_ADMIN | Hapus user |
| `PATCH` | `/users/:id/role` | SUPER_ADMIN | Ubah role user |
| `PATCH` | `/users/me/password` | Authenticated | Ganti password sendiri |
| `PATCH` | `/users/me/photo` | Authenticated | Update foto profil |
| `PATCH` | `/users/me/biometrics` | Authenticated | Toggle biometrik |

### Gudang (5 endpoint)

| Method | Endpoint | Akses | Deskripsi |
|---|---|---|---|
| `GET` | `/warehouses` | Authenticated | List semua gudang |
| `GET` | `/warehouses/:id` | Authenticated | Detail gudang |
| `POST` | `/warehouses` | SUPER_ADMIN | Buat gudang (auto-geocode) |
| `PUT` | `/warehouses/:id` | SUPER_ADMIN | Update gudang |
| `DELETE` | `/warehouses/:id` | SUPER_ADMIN | Hapus gudang |

### Paket (8 endpoint)

| Method | Endpoint | Akses | Deskripsi |
|---|---|---|---|
| `GET` | `/packages` | Authenticated | List paket (role-filtered) |
| `GET` | `/packages/:id` | Authenticated | Detail paket |
| `GET` | `/packages/track/:resi` | Authenticated | Cari paket via no. resi |
| `POST` | `/packages` | WAREHOUSE_ADMIN | Buat paket baru (auto resi, ongkir, geocode) |
| `PUT` | `/packages/:id` | WAREHOUSE_ADMIN | Edit paket |
| `DELETE` | `/packages/:id` | WH_ADMIN + SUPER_ADMIN | Hapus paket |
| `PATCH` | `/packages/:id/status` | Role-validated | Update status paket |
| `PATCH` | `/packages/:id/assign` | WAREHOUSE_ADMIN | Assign ke Linehaul/Courier |

### Tracker, Dashboard, AI (3 endpoint)

| Method | Endpoint | Akses | Deskripsi |
|---|---|---|---|
| `GET` | `/packages/:id/tracker` | Authenticated | Riwayat perjalanan paket |
| `GET` | `/dashboard` | Authenticated | Dashboard (response berbeda per role) |
| `POST` | `/ai/chat` | Authenticated | Chat dengan AI Gemini |

> **Total: 28 API endpoint** dengan pagination, filtering, dan sorting yang konsisten.

### Format Response Standar

```json
{
  "success": true,
  "message": "Data retrieved successfully",
  "data": { ... },
  "meta": {
    "page": 1,
    "per_page": 10,
    "total": 50,
    "total_pages": 5
  }
}
```

---

## 💻 Frontend (Web Admin)

### Halaman & Fitur

| Halaman | Fitur Utama |
|---|---|
| **Login** | Form email/password, autentikasi JWT |
| **Dashboard** | 4 Stats Card + Grafik status paket (Recharts) |
| **Users** | Tabel CRUD + pagination + filter role + pencarian |
| **Gudang** | Tabel CRUD + Peta interaktif Leaflet |
| **Paket** | Tabel CRUD + filter status & layanan + pencarian |
| **Detail Paket** | Info lengkap + timeline tracker + assign modal |
| **Profil** | Ganti password, foto profil |

### State Management

```
┌────────────────────────┐     ┌─────────────────────────┐
│     Zustand Store      │     │  TanStack React Query   │
│  (Client-side State)   │     │  (Server-side State)    │
├────────────────────────┤     ├─────────────────────────┤
│ • authStore            │     │ • usePackages()         │
│   - user, token        │     │ • useWarehouses()       │
│   - isAuthenticated    │     │ • useUsers()            │
│   - persist localStorage│    │ • useDashboard()        │
│                        │     │ • Cache & auto-refresh  │
│ • uiStore              │     │ • Optimistic updates    │
│   - sidebar collapsed  │     │                         │
└────────────────────────┘     └─────────────────────────┘
```

### Komponen UI

| Komponen | Deskripsi |
|---|---|
| `DataTable` | Tabel reusable dengan sort, pagination, aksi |
| `StatusBadge` | Badge berwarna sesuai 10 status paket |
| `StatsCard` | Kartu statistik dengan ikon & angka |
| `PackageStatusChart` | Grafik distribusi status (Recharts) |
| `WarehouseMap` | Peta lokasi gudang (Leaflet) |
| `PackageMap` | Peta rute paket (origin → destination) |
| `AssignModal` | Modal assign paket ke petugas |
| `ConfirmDialog` | Dialog konfirmasi hapus/aksi |
| `PageHeader` | Header halaman konsisten |
| `EmptyState` | Placeholder saat data kosong |

---

## 📱 Mobile App (Flutter)

### Navigasi (Bottom Navigation — 5 Tab)

```
┌──────────┬──────────┬──────────┬──────────┬──────────┐
│ Dashboard│  Paket   │   Peta   │ AI Chat  │  Profil  │
│   🏠     │   📦     │   🗺     │   🤖     │   👤     │
└──────────┴──────────┴──────────┴──────────┴──────────┘
```

### Screen & Fitur Detail

| Screen | Fitur |
|---|---|
| **Dashboard** | Greeting + 3 StatsCard (total tugas, in progress, selesai hari ini) |
| **Paket** | 4 tab (Semua / Di Gudang / Diantar / Selesai) + search + infinite scroll + **shake to refresh** |
| **Detail Paket** | Info lengkap + status badge + tombol aksi kontekstual |
| **Tracker** | Timeline vertikal perjalanan paket |
| **Peta** | flutter_map + GPS lokasi + marker tujuan paket + navigasi ke Google Maps |
| **AI Chat** | Bubble chat UI + Google Gemini AI |
| **Profil** | Foto, nama, role, gudang |
| **Ganti Password** | Form validasi |
| **Biometrik** | Toggle sidik jari / Face ID |
| **Currency Converter** | Konversi IDR ↔ USD/EUR/SGD/JPY (open.er-api.com) |
| **Timezone Converter** | WIB/WITA/WIT/London real-time |
| **Weather** | Cuaca GPS-based (Open-Meteo) + Geocoding Kota (Nominatim) |
| **Mini Game** | "Sortir Paket" — 3 Mode: Sortir (Tap/Gyroscope), Hujan Paket (Accelerometer) |
| **Saran & Kesan** | Form feedback (SharedPreferences) |

### Struktur Folder (Feature-First)

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/     (app_constants, package_status, routes)
│   ├── network/       (dio_client, api_exception)
│   ├── storage/       (secure_storage)
│   ├── notifications/ (notification_service)
│   ├── sensors/       (shake_detector, gyroscope_service)
│   └── theme/         (app_theme, app_colors, app_text_styles)
├── features/
│   ├── auth/          (login screen, auth provider)
│   ├── dashboard/     (dashboard screen, stats)
│   ├── packages/      (list, detail, tracker)
│   ├── peta/          (map screen, markers)
│   ├── ai_chat/       (chat screen, Gemini integration)
│   ├── profile/       (profile, password, biometrics)
│   ├── tools_tpm/     (currency, timezone, weather)
│   ├── mini_game/     (sortir paket game)
│   └── saran_kesan/   (feedback form)
└── shared/
    ├── widgets/       (app_shell, status_badge, package_card, etc.)
    ├── utils/         (format_currency, format_date, status_color)
    └── models/        (pagination_meta)
```

---

## 📡 Integrasi Sensor & Hardware

| Sensor/Hardware | Teknologi | Implementasi |
|---|---|---|
| **Accelerometer** | `sensors_plus` | Shake to Refresh (List Paket) & Hujan Paket (Mini Game) & Rem Darurat (Sortir Mode) |
| **Gyroscope** | `sensors_plus` | Mengontrol arah jatuh paket di Mini Game "Sortir Paket" |
| **GPS** | `geolocator` | Deteksi lokasi real-time untuk peta, cuaca, dan navigasi |
| **Kamera** | `image_picker` | Ambil/pilih foto profil |
| **Biometrik** | `local_auth` | Autentikasi sidik jari / Face ID (device-side only) |
| **Notifikasi** | `flutter_local_notifications` | Notifikasi lokal saat ada perubahan status |

---

## 🌐 Integrasi API Eksternal

| API | Endpoint | Fungsi | Biaya |
|---|---|---|---|
| **Google Gemini** | `generativelanguage.googleapis.com` | AI Chat Assistant | Gratis (Flash tier) |
| **OpenStreetMap Nominatim** | `nominatim.openstreetmap.org` | Geocoding (kordinat GPS → Nama Kota) | Gratis (1 req/s) |
| **OpenStreetMap Tiles** | `tile.openstreetmap.org` | Tile peta interaktif (Map visual) | Gratis |
| **Open-Meteo** | `api.open-meteo.com` | Data cuaca real-time berdasarkan GPS | Gratis |
| **ExchangeRate API** | `open.er-api.com/v6/latest/IDR` | Konversi mata uang real-time | Gratis (Tanpa API Key) |
| **Google Maps** | `url_launcher` → Maps app | Navigasi arah kurir ke tujuan paket | Gratis (open link) |

---

## 🔒 Keamanan (Security)

| Fitur | Implementasi |
|---|---|
| **Autentikasi** | JWT Token (HS256, expired 24 jam) |
| **Password Hashing** | bcrypt (10 salt rounds) |
| **Token Blacklist** | Logout menginvalidasi token di server |
| **Role-Based Access** | 4-level role hierarchy dengan middleware validasi |
| **Security Headers** | Helmet.js (XSS, Clickjacking, MIME sniffing protection) |
| **CORS** | Konfigurasi allowed origins |
| **Biometric Auth** | Device-side (tidak ada data biometrik dikirim ke server) |
| **Secure Storage** | Token disimpan terenkripsi di mobile (flutter_secure_storage) |
| **Auto-Logout** | Otomatis logout saat menerima response 401 (web & mobile) |
| **Status Validation** | Backend memvalidasi transisi status yang sah |
| **Input Validation** | Validasi input di controller sebelum query |

---

## 🎨 Design System

### Warna Brand

| Warna | Hex | Penggunaan |
|---|---|---|
| **Navy Primary** | `#0F2D52` | Sidebar, header, tombol CTA |
| **Amber Accent** | `#E8A020` | Highlight, ikon navigasi aktif |

### Warna Status Paket (10 Status)

| Status | Warna Background | Keterangan |
|---|---|---|
| Created | `#EFF6FF` (biru muda) | Paket baru dibuat |
| Received at Warehouse | `#F0FDF4` (hijau muda) | Diterima di gudang |
| Assigned to Linehaul | `#FDF4FF` (ungu muda) | Ditugaskan ke linehaul |
| Picked Up | `#FFFBEB` (kuning muda) | Diambil oleh linehaul |
| In Transit | `#FFF7ED` (oranye muda) | Dalam perjalanan |
| Arrived at Warehouse | `#F0FDFA` (teal muda) | Tiba di gudang tujuan |
| Assigned to Courier | `#FDF2F8` (pink muda) | Ditugaskan ke kurir |
| Out For Delivery | `#FEFCE8` (lime muda) | Sedang diantar |
| Delivered | `#F0FDF4` (hijau) | Berhasil terkirim ✅ |
| Failed Delivery | `#FEF2F2` (merah muda) | Gagal kirim ❌ |

### Tipografi

- **Font:** Inter (Google Fonts) — konsisten di Web & Mobile
- **Scale:** 12px – 30px dengan weight 400–700

### Inspirasi Design

> Linear, Vercel Dashboard, Railway — utility-first, tipografi rapat, warna purposeful.

---

## ☁ Deployment & Infrastruktur

### Arsitektur Cloud (Google Cloud Platform)

```
┌─────────────────────────────────────────────────┐
│              Google Cloud Platform               │
│                                                   │
│  ┌─────────────────┐   ┌──────────────────────┐  │
│  │  Cloud Run       │   │  App Engine           │  │
│  │  (Backend API)   │   │  (Frontend Web)       │  │
│  │  Docker Container│   │  Static SPA           │  │
│  │  Port: 8080      │   │  Python39 runtime     │  │
│  └────────┬────────┘   └──────────────────────┘  │
│           │                                       │
│           ▼                                       │
│  ┌─────────────────┐                              │
│  │  Compute Engine  │                              │
│  │  VM (MySQL DB)   │                              │
│  │  IP: 34.50.86.15 │                              │
│  └─────────────────┘                              │
└─────────────────────────────────────────────────┘
```

### Arsitektur Lokal (Development)

```
┌─────────────────────────────────────────────────┐
│                   Laptop / PC                    │
│                                                   │
│  ┌──────────────┐   ┌───────────────────┐         │
│  │ Backend      │   │ Frontend          │         │
│  │ Node.js      │   │ Vite Dev Server   │         │
│  │ Port: 3000   │   │ Port: 5173        │         │
│  └──────┬───────┘   └───────────────────┘         │
│         │                                         │
│         ▼                                         │
│  ┌──────────────┐   ┌───────────────────┐         │
│  │ XAMPP MySQL  │   │ Flutter Mobile    │         │
│  │ Port: 3306   │   │ (via WiFi/USB)    │         │
│  │ localhost    │   │ IP: 192.168.80.125│         │
│  └──────────────┘   └───────────────────┘         │
└─────────────────────────────────────────────────┘
```

---

## 🚀 Cara Menjalankan Lokal

### Prasyarat

- [x] Node.js ≥ 20
- [x] XAMPP (MySQL running)
- [x] Flutter SDK ≥ 3.0
- [x] Git

### Langkah 1: Setup Database

1. Buka **XAMPP Control Panel** → Start **MySQL**
2. Buka **phpMyAdmin** (`http://localhost/phpmyadmin`)
3. Buat database baru: `iamexpress_db`
4. Import file `Database/schema.sql` (struktur tabel)
5. Import file `Database/seed.sql` (data awal)

### Langkah 2: Jalankan Backend

```bash
cd Backend
npm install
npm run dev
```

> Server berjalan di `http://localhost:3000`

### Langkah 3: Jalankan Frontend (Web)

```bash
cd Frontend
npm install
npm run dev
```

> Web Admin berjalan di `http://localhost:5173`

### Langkah 4: Jalankan Mobile (Flutter)

```bash
cd Mobile
flutter pub get
flutter run
```

> Pastikan HP dan laptop terhubung ke **WiFi yang sama**.
> Backend diakses melalui IP: `http://192.168.80.125:3000/api/v1`

---

## 🔑 Akun Demo

Setelah import `seed.sql`, tersedia akun berikut:

| Role | Email | Password | Platform |
|---|---|---|---|
| **SUPER_ADMIN** | `superadmin@iamexpress.id` | `password123` | Web |
| **WAREHOUSE_ADMIN** (Jakarta) | `admin.jakarta@iamexpress.id` | `password123` | Web |
| **WAREHOUSE_ADMIN** (Surabaya) | `admin.surabaya@iamexpress.id` | `password123` | Web |
| **LINEHAUL** | `linehaul1@iamexpress.id` | `password123` | Mobile |
| **COURIER** | `courier1@iamexpress.id` | `password123` | Mobile |

### Data Awal (Seed)

- **3 Gudang:** Jakarta Pusat, Surabaya, Bandung
- **5 User:** 1 Super Admin, 2 Warehouse Admin, 1 Linehaul, 1 Courier
- **3 Paket:** Dengan berbagai status (Created, In Transit, Delivered)
- **9 Tracker Entry:** Riwayat perjalanan paket lengkap

---

## 👨‍💻 Tim Pengembang

| Nama | NIM | Role |
|---|---|---|
| | | |
| | | |
| | | |

---

## 📋 Ringkasan Teknis

| Aspek | Detail |
|---|---|
| **Total API Endpoint** | 28 endpoint RESTful |
| **Total Tabel Database** | 4 tabel (warehouses, users, packages, package_tracker) |
| **Total Status Paket** | 10 status dengan transisi tervalidasi |
| **Total Role** | 4 role (Super Admin, Warehouse Admin, Linehaul, Courier) |
| **Total Sensor** | 3 sensor (Accelerometer, Gyroscope, GPS) |
| **Total API Eksternal** | 5 API (Gemini, Nominatim, Open-Meteo, ExchangeRate, OSM) |
| **Autentikasi** | JWT + Biometric (Fingerprint / Face ID) |
| **Arsitektur** | MVC (Backend) + Component-based (Frontend) + Feature-first (Mobile) |
| **Database** | MySQL (InnoDB, utf8mb4) |
| **Cloud** | GCP (Cloud Run + App Engine + Compute Engine) |
| **Lokal** | XAMPP MySQL + Node.js + Vite + Flutter |

---

<p align="center">
  <strong>📦 IAMExpress</strong> — Sistem Manajemen Pengiriman Paket & Gudang<br>
  <em>Built with ❤️ using Express.js, React, Flutter & MySQL</em>
</p>
