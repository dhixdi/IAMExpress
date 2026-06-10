# Endpoint Test Checklist — IAMExpress Backend

Gunakan file ini untuk mengecek endpoint satu per satu. Centang setelah berhasil diuji.

## Prasyarat

- [ ] MySQL sudah berjalan
- [ ] `schema.sql` sudah dijalankan
- [ ] `seed.sql` sudah dijalankan (data dummy tersedia)
- [ ] Backend sudah jalan di `http://localhost:3000`
- [ ] Token untuk masing-masing role sudah disimpan

## Token yang Dibutuhkan

Simpan token terpisah untuk testing role enforcement:

```
TOKEN_SUPER   = token dari superadmin@iamexpress.id
TOKEN_WA      = token dari admin.jogja@iamexpress.id (WAREHOUSE_ADMIN)
TOKEN_LH      = token dari linehaul1@iamexpress.id (LINEHAUL)
TOKEN_CR      = token dari kurir1@iamexpress.id (COURIER)
```

---

## 1. Auth

- [ ] `POST /api/v1/auth/login` — Login berhasil, token diterima
- [ ] `GET /api/v1/auth/me` — Data user kembali dengan benar
- [ ] `POST /api/v1/auth/logout` — Token ter-invalidate

Checklist validasi:
- [ ] Login dengan password salah → `401`
- [ ] `GET /auth/me` tanpa token → `401`
- [ ] `GET /auth/me` setelah logout → `401`

---

## 2. User Management

- [ ] `GET /api/v1/users` (TOKEN_SUPER) — List user dengan pagination
- [ ] `GET /api/v1/users?q=budi` (TOKEN_SUPER) — Search berhasil
- [ ] `GET /api/v1/users?role=COURIER` (TOKEN_SUPER) — Filter by role berhasil
- [ ] `GET /api/v1/users/:id` (TOKEN_SUPER) — Detail user
- [ ] `POST /api/v1/users` (TOKEN_SUPER) — Tambah WAREHOUSE_ADMIN baru
- [ ] `POST /api/v1/users` (TOKEN_SUPER) — Tambah LINEHAUL baru
- [ ] `POST /api/v1/users` (TOKEN_SUPER) — Tambah COURIER baru
- [ ] `PUT /api/v1/users/:id` (TOKEN_SUPER) — Update nama user
- [ ] `PATCH /api/v1/users/:id/role` (TOKEN_SUPER) — Ubah role user
- [ ] `DELETE /api/v1/users/:id` (TOKEN_SUPER) — Hapus user
- [ ] `PATCH /api/v1/users/me/password` (TOKEN_CR) — Ganti password kurir
- [ ] `PATCH /api/v1/users/me/photo` (TOKEN_LH) — Update foto profil
- [ ] `PATCH /api/v1/users/me/biometrics` (TOKEN_CR) — Toggle biometrik

Checklist validasi:
- [ ] `GET /users` dengan TOKEN_WA → `403` (hanya SUPER_ADMIN)
- [ ] `GET /users` dengan TOKEN_LH → `403`
- [ ] `POST /users` tanpa `warehouse_id` untuk COURIER → `400`
- [ ] `POST /users` dengan email duplikat → `409`
- [ ] `PATCH /users/:id/role` dengan TOKEN_WA → `403`
- [ ] `DELETE /users/:id` dengan TOKEN_WA → `403`

---

## 3. Warehouse Management

- [ ] `GET /api/v1/warehouses` (TOKEN_CR) — List gudang (semua role bisa)
- [ ] `GET /api/v1/warehouses/:id` (TOKEN_LH) — Detail gudang
- [ ] `POST /api/v1/warehouses` (TOKEN_SUPER) — Tambah gudang, lat/lng tergenerate otomatis
- [ ] `PUT /api/v1/warehouses/:id` (TOKEN_SUPER) — Update nama dan alamat gudang
- [ ] `DELETE /api/v1/warehouses/:id` (TOKEN_SUPER) — Hapus gudang

Checklist validasi:
- [ ] `POST /warehouses` dengan TOKEN_WA → `403`
- [ ] `PUT /warehouses/:id` dengan TOKEN_LH → `403`
- [ ] `DELETE /warehouses/:id` dengan TOKEN_CR → `403`
- [ ] Cek bahwa `lat` dan `lng` terisi setelah POST (geocoding berjalan)

---

## 4. Package Management

- [ ] `POST /api/v1/packages` (TOKEN_WA) — Buat paket baru
  - [ ] Verifikasi `resi` digenerate format `IAMxxxxxx`
  - [ ] Verifikasi `ongkos_kirim` dihitung otomatis
  - [ ] Verifikasi `sender_lat/lng` dan `receiver_lat/lng` terisi
  - [ ] Verifikasi `current_status = Created`
- [ ] `GET /api/v1/packages` (TOKEN_SUPER) — Lihat semua paket
- [ ] `GET /api/v1/packages` (TOKEN_WA) — Hanya paket di gudangnya
- [ ] `GET /api/v1/packages` (TOKEN_LH) — Hanya paket yang di-assign ke dia
- [ ] `GET /api/v1/packages` (TOKEN_CR) — Hanya paket yang di-assign ke dia
- [ ] `GET /api/v1/packages?q=IAM000001` — Search by resi berhasil
- [ ] `GET /api/v1/packages?current_status=In+Transit` — Filter by status berhasil
- [ ] `GET /api/v1/packages?jenis_layanan=express` — Filter by layanan berhasil
- [ ] `GET /api/v1/packages/:id` — Detail paket
- [ ] `GET /api/v1/packages/track/IAM000001` — Track by resi berhasil
- [ ] `PUT /api/v1/packages/:id` (TOKEN_WA) — Edit nama & deskripsi paket
- [ ] `DELETE /api/v1/packages/:id` (TOKEN_WA) — Hapus paket milik gudangnya
- [ ] `DELETE /api/v1/packages/:id` (TOKEN_SUPER) — SUPER_ADMIN bisa hapus paket manapun

Checklist validasi:
- [ ] `POST /packages` dengan TOKEN_LH → `403`
- [ ] `POST /packages` dengan `jenis_layanan = kargo` dan `berat < 10` → `400`
- [ ] `PUT /packages/:id` dari WAREHOUSE_ADMIN lain (beda gudang) → `403`

---

## 5. Package Status Update

Test alur status secara berurutan:

- [ ] `PATCH /packages/:id/status` → `Received at Warehouse` (TOKEN_WA)
- [ ] `PATCH /packages/:id/assign` → assign ke LINEHAUL (TOKEN_WA)
  - [ ] Verifikasi `current_status` berubah ke `Assigned to Linehaul`
- [ ] `PATCH /packages/:id/status` → `Picked Up` (TOKEN_LH)
- [ ] `PATCH /packages/:id/status` → `In Transit` (TOKEN_LH)
- [ ] `PATCH /packages/:id/status` → `Arrived at Warehouse` (TOKEN_LH)
- [ ] `PATCH /packages/:id/assign` → assign ke COURIER (TOKEN_WA)
  - [ ] Verifikasi `current_status` berubah ke `Assigned to Courier`
- [ ] `PATCH /packages/:id/status` → `Out For Delivery` (TOKEN_CR)
  - [ ] Verifikasi di mobile: 3 tombol muncul — [Peta], [Selesai], [Gagal Antar]
  - [ ] Test tap [Peta] → navigasi ke halaman Peta dengan fokus ke koordinat penerima
- [ ] `PATCH /packages/:id/status` → `Delivered` (TOKEN_CR)
- [ ] Test alur `Failed Delivery`: TOKEN_CR set ke `Failed Delivery`, lalu TOKEN_WA assign ulang → status kembali ke `Assigned to Courier`

Checklist validasi:
- [ ] `POST /packages` — `current_status` otomatis = `Created` (tidak perlu dikirim dari frontend)
- [ ] `PATCH /packages/:id/status` dengan `status = Created` → `400` (tidak boleh set Created via PATCH)

Checklist validasi:
- [ ] LINEHAUL tidak bisa set status `Delivered` → `403`
- [ ] COURIER tidak bisa set status `Picked Up` → `403`
- [ ] WAREHOUSE_ADMIN tidak bisa set status `Out For Delivery` → `403`
- [ ] Set status yang tidak valid (e.g. loncat) → `400`
- [ ] Setiap perubahan status tercatat otomatis di `package_tracker` — cek via `GET /packages/:id/tracker`

---

## 6. Package Tracker

- [ ] `GET /api/v1/packages/:id/tracker` — Riwayat lengkap paket
  - [ ] Verifikasi semua perubahan status dari langkah 5 muncul di sini
  - [ ] Verifikasi `created_by` menampilkan user yang mengubah status
  - [ ] Verifikasi `timestamp` urut dari terlama ke terbaru (sort_by=timestamp&order=asc)

---

## 7. Dashboard

- [ ] `GET /api/v1/dashboard` (TOKEN_SUPER) — Response berisi global stats
  - [ ] Verifikasi field: `total_warehouse`, `total_user`, `total_paket_aktif`, `total_delivered`
  - [ ] Verifikasi `paket_per_warehouse` adalah array
- [ ] `GET /api/v1/dashboard` (TOKEN_WA) — Response berisi warehouse stats
  - [ ] Verifikasi field: `paket_di_warehouse`, `menunggu_linehaul`, `menunggu_courier`, `delivered_hari_ini`
- [ ] `GET /api/v1/dashboard` (TOKEN_LH) — Response berisi personal stats
- [ ] `GET /api/v1/dashboard` (TOKEN_CR) — Response berisi personal stats
  - [ ] Verifikasi field: `total_ditugaskan`, `sedang_dikerjakan`, `selesai_hari_ini`

---

## 8. AI Chat

- [ ] `POST /api/v1/ai/chat` (TOKEN_CR) — Chat berhasil

Skenario test:
- [ ] `"Berapa paket saya yang masih aktif?"` → AI merespons dengan data relevan
- [ ] `"Cari paket IAM000001"` → AI merespons dengan info paket
- [ ] `"Paket mana yang harus saya antar dulu?"` → AI memberikan rekomendasi

Checklist validasi:
- [ ] Chat tanpa token → `401`
- [ ] Chat dengan `message` kosong → `400`

---

## 9. Validasi Umum

- [ ] Semua endpoint protected → `401` tanpa token
- [ ] Semua endpoint protected → `401` dengan token expired
- [ ] Token yang sudah di-logout → `401`
- [ ] Response format konsisten: selalu ada `success`, `message`, dan `data`
- [ ] Endpoint list selalu ada `meta` dengan `page`, `per_page`, `total`, `total_pages`
- [ ] Error response selalu ada `errors` array (bisa kosong)

---

## 10. Rekomendasi Urutan Test

1. Login semua akun — simpan 4 token berbeda
2. Test `GET /auth/me` untuk semua token
3. Test `GET /warehouses` — pastikan semua role bisa akses
4. Buat 1 paket baru sebagai WAREHOUSE_ADMIN
5. Test alur status lengkap (bagian 5 di atas) step by step
6. Cek tracker setelah semua status berubah
7. Test dashboard per role
8. Test AI chat
9. Test semua negative case (403, 400, 404, 409)

---

## 11. Catatan Cepat

- Pakai Postman atau `curl` untuk test manual.
- Simpan environment variable di Postman: `BASE_URL`, `TOKEN_SUPER`, `TOKEN_WA`, `TOKEN_LH`, `TOKEN_CR`.
- Untuk test resi, gunakan resi yang dibuat dari seed data atau hasil `POST /packages`.
- Geocoding Nominatim mungkin lambat — test dengan sabar atau pakai mock di development.
- Biometrics flag bisa di-toggle bebas karena validasi sesungguhnya ada di device.
