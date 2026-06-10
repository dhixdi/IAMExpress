# DATABASE — IAMExpress

Dokumentasi lengkap skema database MySQL untuk proyek IAMExpress.

> **Database:** `iamexpress_db`
> **Charset:** `utf8mb4`
> **Engine:** InnoDB

---

## Gambaran Umum

IAMExpress menggunakan **4 tabel utama** dengan relasi sebagai berikut:

```
warehouses
    │
    ├── users (warehouse_id FK)
    │
    └── packages (current_warehouse_id FK, destination_warehouse_id FK)
            │
            ├── users (assigned_user_id FK)
            │
            └── package_tracker
                    ├── packages (package_id FK)
                    ├── warehouses (warehouse_id FK)
                    └── users (created_by FK)
```

---

## DDL Lengkap (schema.sql)

```sql
-- ============================================================
-- IAMExpress Database Schema
-- ============================================================

CREATE DATABASE IF NOT EXISTS iamexpress_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE iamexpress_db;

-- ============================================================
-- Tabel 1: warehouses
-- Dibuat duluan karena direferensi oleh tabel lain
-- ============================================================
CREATE TABLE warehouses (
  warehouse_id  INT           NOT NULL AUTO_INCREMENT,
  nama_gudang   VARCHAR(100)  NOT NULL,
  alamat        TEXT          NOT NULL,
  lat           DECIMAL(10,7) NULL        COMMENT 'Latitude dari geocoding alamat',
  lng           DECIMAL(10,7) NULL        COMMENT 'Longitude dari geocoding alamat',
  created_at    TIMESTAMP     NOT NULL    DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (warehouse_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- Tabel 2: users
-- ============================================================
CREATE TABLE users (
  user_id            INT          NOT NULL AUTO_INCREMENT,
  nama               VARCHAR(100) NOT NULL,
  email              VARCHAR(100) NOT NULL,
  password_hash      VARCHAR(255) NOT NULL  COMMENT 'bcrypt hash',
  role               ENUM(
                       'SUPER_ADMIN',
                       'WAREHOUSE_ADMIN',
                       'LINEHAUL',
                       'COURIER'
                     )            NOT NULL,
  photo_url          VARCHAR(255) NULL,
  warehouse_id       INT          NULL      COMMENT 'NULL untuk SUPER_ADMIN',
  biometrics_type    ENUM('fingerprint','face') NULL,
  biometrics_enabled TINYINT(1)   NOT NULL  DEFAULT 0,
  created_at         TIMESTAMP    NOT NULL  DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (user_id),
  UNIQUE  KEY uq_users_email (email),
  INDEX   idx_users_role (role),
  INDEX   idx_users_warehouse (warehouse_id),

  CONSTRAINT fk_users_warehouse
    FOREIGN KEY (warehouse_id)
    REFERENCES warehouses (warehouse_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- Tabel 3: packages
-- ============================================================
CREATE TABLE packages (
  package_id              INT            NOT NULL AUTO_INCREMENT,
  resi                    VARCHAR(20)    NOT NULL  COMMENT 'Format: IAM + 6 digit, e.g. IAM000001',
  nama_paket              VARCHAR(150)   NOT NULL,
  alamat_pengirim         TEXT           NOT NULL,
  alamat_tujuan           TEXT           NOT NULL,
  no_hp_pengirim          VARCHAR(20)    NOT NULL,
  no_hp_penerima          VARCHAR(20)    NOT NULL,
  deskripsi_barang        TEXT           NULL,
  berat                   DECIMAL(8,2)   NOT NULL  COMMENT 'Dalam kilogram',
  jenis_layanan           ENUM(
                            'standar',
                            'express',
                            'kargo'
                          )              NOT NULL,
  ongkos_kirim            DECIMAL(12,2)  NOT NULL  COMMENT 'Dihitung otomatis saat insert',
  sender_lat              DECIMAL(10,7)  NULL      COMMENT 'Geocoding dari alamat_pengirim',
  sender_lng              DECIMAL(10,7)  NULL,
  receiver_lat            DECIMAL(10,7)  NULL      COMMENT 'Geocoding dari alamat_tujuan',
  receiver_lng            DECIMAL(10,7)  NULL,
  current_warehouse_id    INT            NOT NULL,
  destination_warehouse_id INT           NULL,
  current_status          ENUM(
                            'Created',
                            'Received at Warehouse',
                            'Assigned to Linehaul',
                            'Picked Up',
                            'In Transit',
                            'Arrived at Warehouse',
                            'Assigned to Courier',
                            'Out For Delivery',
                            'Delivered',
                            'Failed Delivery'
                          )              NOT NULL   DEFAULT 'Created',
  assigned_user_id        INT            NULL       COMMENT 'Linehaul atau Courier yang ditugaskan',
  created_at              TIMESTAMP      NOT NULL   DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (package_id),
  UNIQUE  KEY uq_packages_resi (resi),
  INDEX   idx_packages_status (current_status),
  INDEX   idx_packages_layanan (jenis_layanan),
  INDEX   idx_packages_current_wh (current_warehouse_id),
  INDEX   idx_packages_assigned (assigned_user_id),

  CONSTRAINT fk_packages_current_warehouse
    FOREIGN KEY (current_warehouse_id)
    REFERENCES warehouses (warehouse_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,

  CONSTRAINT fk_packages_destination_warehouse
    FOREIGN KEY (destination_warehouse_id)
    REFERENCES warehouses (warehouse_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,

  CONSTRAINT fk_packages_assigned_user
    FOREIGN KEY (assigned_user_id)
    REFERENCES users (user_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- Tabel 4: package_tracker
-- ============================================================
CREATE TABLE package_tracker (
  track_id    INT          NOT NULL AUTO_INCREMENT,
  package_id  INT          NOT NULL,
  warehouse_id INT         NULL     COMMENT 'Gudang tempat status diubah',
  status      VARCHAR(50)  NOT NULL,
  notes       TEXT         NULL,
  created_by  INT          NOT NULL COMMENT 'user_id yang mengubah status',
  timestamp   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (track_id),
  INDEX idx_tracker_package (package_id),
  INDEX idx_tracker_timestamp (timestamp),

  CONSTRAINT fk_tracker_package
    FOREIGN KEY (package_id)
    REFERENCES packages (package_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT fk_tracker_warehouse
    FOREIGN KEY (warehouse_id)
    REFERENCES warehouses (warehouse_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,

  CONSTRAINT fk_tracker_created_by
    FOREIGN KEY (created_by)
    REFERENCES users (user_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

## Data Seed (seed.sql)

```sql
USE iamexpress_db;

-- ============================================================
-- Seed Warehouses
-- ============================================================
INSERT INTO warehouses (nama_gudang, alamat, lat, lng) VALUES
('Gudang Yogyakarta', 'Jl. Ring Road Utara No. 88, Sleman, Yogyakarta', -7.7593, 110.3868),
('Gudang Jakarta',    'Jl. Raya Bekasi KM 18, Pulogadung, Jakarta Timur', -6.1944, 107.0220),
('Gudang Surabaya',  'Jl. Margomulyo No. 55, Asemrowo, Surabaya', -7.2459, 112.6794);


-- ============================================================
-- Seed Users (password semua = bcrypt dari "admin123" atau "user123")
-- Gunakan bcrypt.hash("admin123", 10) dan bcrypt.hash("user123", 10) di Node.js
-- lalu ganti placeholder di bawah dengan hash asli
-- ============================================================

-- SUPER_ADMIN (warehouse_id = NULL)
INSERT INTO users (nama, email, password_hash, role, warehouse_id) VALUES
('Super Administrator', 'superadmin@iamexpress.id', '$2b$10$PLACEHOLDER_ADMIN123_HASH', 'SUPER_ADMIN', NULL);

-- WAREHOUSE_ADMIN
INSERT INTO users (nama, email, password_hash, role, warehouse_id) VALUES
('Admin Gudang Jogja',    'admin.jogja@iamexpress.id',    '$2b$10$PLACEHOLDER_ADMIN123_HASH', 'WAREHOUSE_ADMIN', 1),
('Admin Gudang Jakarta',  'admin.jakarta@iamexpress.id',  '$2b$10$PLACEHOLDER_ADMIN123_HASH', 'WAREHOUSE_ADMIN', 2),
('Admin Gudang Surabaya', 'admin.surabaya@iamexpress.id', '$2b$10$PLACEHOLDER_ADMIN123_HASH', 'WAREHOUSE_ADMIN', 3);

-- LINEHAUL
INSERT INTO users (nama, email, password_hash, role, warehouse_id) VALUES
('Agus Linehaul',  'linehaul1@iamexpress.id', '$2b$10$PLACEHOLDER_USER123_HASH', 'LINEHAUL', 1),
('Dedi Linehaul',  'linehaul2@iamexpress.id', '$2b$10$PLACEHOLDER_USER123_HASH', 'LINEHAUL', 2);

-- COURIER
INSERT INTO users (nama, email, password_hash, role, warehouse_id) VALUES
('Budi Kurir',   'kurir1@iamexpress.id', '$2b$10$PLACEHOLDER_USER123_HASH', 'COURIER', 1),
('Sari Kurir',   'kurir2@iamexpress.id', '$2b$10$PLACEHOLDER_USER123_HASH', 'COURIER', 2),
('Tono Kurir',   'kurir3@iamexpress.id', '$2b$10$PLACEHOLDER_USER123_HASH', 'COURIER', 3);


-- ============================================================
-- Seed Packages (contoh berbagai status & layanan)
-- ============================================================
INSERT INTO packages (
  resi, nama_paket, alamat_pengirim, alamat_tujuan,
  no_hp_pengirim, no_hp_penerima, deskripsi_barang,
  berat, jenis_layanan, ongkos_kirim,
  sender_lat, sender_lng, receiver_lat, receiver_lng,
  current_warehouse_id, destination_warehouse_id,
  current_status, assigned_user_id
) VALUES
('IAM000001', 'Laptop ASUS',
  'Jl. Malioboro No. 1, Yogyakarta', 'Jl. Sudirman No. 50, Jakarta Pusat',
  '08111111111', '08222222222', 'Laptop gaming harap hati-hati',
  2.5, 'express', 37500.00,
  -7.7956, 110.3695, -6.2088, 106.8456,
  1, 2, 'In Transit', 5),

('IAM000002', 'Pakaian Batik',
  'Jl. Prawirotaman No. 10, Yogyakarta', 'Jl. Pemuda No. 22, Surabaya',
  '08333333333', '08444444444', 'Batik premium pesanan',
  0.8, 'standar', 8000.00,
  -7.8195, 110.3765, -7.2575, 112.7521,
  1, 3, 'Created', NULL),

('IAM000003', 'Mesin Industri',
  'Jl. Magelang KM 5, Yogyakarta', 'Jl. Gatot Subroto No. 30, Jakarta',
  '08555555555', '08666666666', 'Mesin berat, pallet khusus',
  45.0, 'kargo', 225000.00,
  -7.7341, 110.3572, -6.2297, 106.8180,
  1, 2, 'Delivered', 7),

('IAM000004', 'Dokumen Penting',
  'Jl. Kaliurang KM 8, Sleman', 'Jl. Ahmad Yani No. 5, Jakarta Timur',
  '08777777777', '08888888888', 'Dokumen legal notaris',
  0.2, 'express', 3000.00,
  -7.7249, 110.3860, -6.2175, 106.8910,
  1, 2, 'Assigned to Courier', 8);


-- ============================================================
-- Seed Package Tracker (riwayat untuk IAM000001 dan IAM000003)
-- ============================================================

-- Riwayat IAM000001 (In Transit)
INSERT INTO package_tracker (package_id, warehouse_id, status, notes, created_by) VALUES
(1, 1, 'Created',               'Paket dibuat oleh admin gudang Jogja', 2),
(1, 1, 'Received at Warehouse', 'Paket diterima di gudang Jogja',       2),
(1, 1, 'Assigned to Linehaul',  'Assigned ke Agus untuk transit ke Jakarta', 2),
(1, 1, 'Picked Up',             'Paket dijemput dari gudang Jogja',     5),
(1, NULL,'In Transit',          'Dalam perjalanan ke Jakarta',          5);

-- Riwayat IAM000003 (Delivered)
INSERT INTO package_tracker (package_id, warehouse_id, status, notes, created_by) VALUES
(3, 1, 'Created',               'Paket dibuat admin Jogja',             2),
(3, 1, 'Received at Warehouse', NULL,                                   2),
(3, 1, 'Assigned to Linehaul',  NULL,                                   2),
(3, 1, 'Picked Up',             NULL,                                   5),
(3, NULL,'In Transit',          NULL,                                   5),
(3, 2, 'Arrived at Warehouse',  'Tiba di gudang Jakarta',               5),
(3, 2, 'Assigned to Courier',   'Assigned ke Sari untuk delivery',      3),
(3, 2, 'Out For Delivery',      'Kurir berangkat',                      8),
(3, 2, 'Delivered',             'Diterima langsung pemilik',            8);
```

> **Penting:** Ganti semua `$2b$10$PLACEHOLDER_ADMIN123_HASH` dan `$2b$10$PLACEHOLDER_USER123_HASH` dengan hash bcrypt asli sebelum menjalankan seed. Generate di Node.js:
> ```javascript
> const bcrypt = require('bcrypt');
> console.log(await bcrypt.hash('admin123', 10));
> console.log(await bcrypt.hash('user123', 10));
> ```

---

## Penjelasan Kolom Penting

### Kolom Auto-generate di `packages`

| Kolom | Siapa yang Generate | Cara |
|---|---|---|
| `package_id` | MySQL | AUTO_INCREMENT |
| `resi` | Backend (Node.js) | `'IAM' + package_id.toString().padStart(6, '0')` — di-UPDATE setelah INSERT |
| `ongkos_kirim` | Backend (shippingService.js) | `berat × tarif_per_kg` |
| `sender_lat/lng` | Backend (geocodingService.js) | Nominatim API dari `alamat_pengirim` |
| `receiver_lat/lng` | Backend (geocodingService.js) | Nominatim API dari `alamat_tujuan` |
| `current_status` | Backend (default) | `'Created'` |
| `current_warehouse_id` | Backend | `warehouse_id` dari user yang login |

### Tarif Ongkos Kirim

| Jenis Layanan | Tarif | Minimum |
|---|---|---|
| `standar` | Rp 10.000 / kg | Tidak ada |
| `express` | Rp 15.000 / kg | Tidak ada |
| `kargo` | Rp 5.000 / kg | 10 kg (tolak jika kurang) |

Contoh perhitungan:
- Standar 2 kg = Rp 20.000
- Express 2.5 kg = Rp 37.500
- Kargo 45 kg = Rp 225.000

### Alur Status & Siapa yang Boleh Set

```
[Created]                  ← Auto saat package dibuat
    ↓
[Received at Warehouse]    ← WAREHOUSE_ADMIN
    ↓
[Assigned to Linehaul]     ← WAREHOUSE_ADMIN (via endpoint /assign)
    ↓
[Picked Up]                ← LINEHAUL
    ↓
[In Transit]               ← LINEHAUL
    ↓
[Arrived at Warehouse]     ← LINEHAUL
    ↓
[Assigned to Courier]      ← WAREHOUSE_ADMIN (via endpoint /assign)
    ↓
[Out For Delivery]         ← COURIER
    ↓
[Delivered]                ← COURIER
    atau
[Failed Delivery]          ← COURIER
```

Status tidak boleh mundur atau loncat sembarangan. Validasi ada di `src/utils/statusValidator.js`.

### Relasi Antar Tabel

```sql
-- Semua user (kecuali SUPER_ADMIN) terikat ke 1 warehouse
users.warehouse_id → warehouses.warehouse_id

-- Paket berada di warehouse tertentu saat ini
packages.current_warehouse_id → warehouses.warehouse_id

-- Paket menuju warehouse tujuan (opsional, bisa NULL jika langsung ke penerima)
packages.destination_warehouse_id → warehouses.warehouse_id

-- Paket ditugaskan ke 1 user (linehaul atau courier)
packages.assigned_user_id → users.user_id

-- Setiap baris tracker: paket + status + siapa yang ubah + di gudang mana
package_tracker.package_id  → packages.package_id
package_tracker.warehouse_id → warehouses.warehouse_id (nullable)
package_tracker.created_by   → users.user_id
```

### Catatan ON DELETE

| Tabel | Kolom | ON DELETE |
|---|---|---|
| `users` | `warehouse_id` | SET NULL (user tetap ada, warehouse_id jadi NULL) |
| `packages` | `current_warehouse_id` | RESTRICT (tidak bisa hapus warehouse yang masih ada paket) |
| `packages` | `destination_warehouse_id` | SET NULL |
| `packages` | `assigned_user_id` | SET NULL (paket tidak terhapus jika user dihapus) |
| `package_tracker` | `package_id` | CASCADE (tracker ikut terhapus jika paket dihapus) |
| `package_tracker` | `warehouse_id` | SET NULL |
| `package_tracker` | `created_by` | RESTRICT |

---

## Query Umum yang Dipakai Backend

### Ambil paket beserta nama gudang dan assigned user

```sql
SELECT
  p.*,
  wc.nama_gudang AS current_warehouse_name,
  wd.nama_gudang AS destination_warehouse_name,
  u.nama         AS assigned_user_name,
  u.role         AS assigned_user_role
FROM packages p
LEFT JOIN warehouses wc ON p.current_warehouse_id = wc.warehouse_id
LEFT JOIN warehouses wd ON p.destination_warehouse_id = wd.warehouse_id
LEFT JOIN users u ON p.assigned_user_id = u.user_id
WHERE p.package_id = ?
```

### Ambil tracker lengkap satu paket (urut dari terlama)

```sql
SELECT
  pt.*,
  u.nama     AS changed_by_name,
  u.role     AS changed_by_role,
  w.nama_gudang AS warehouse_name
FROM package_tracker pt
LEFT JOIN users u ON pt.created_by = u.user_id
LEFT JOIN warehouses w ON pt.warehouse_id = w.warehouse_id
WHERE pt.package_id = ?
ORDER BY pt.timestamp ASC
```

### Dashboard SUPER_ADMIN

```sql
-- Total warehouse
SELECT COUNT(*) AS total_warehouse FROM warehouses;

-- Total user per role
SELECT role, COUNT(*) AS total FROM users GROUP BY role;

-- Total paket aktif (belum Delivered)
SELECT COUNT(*) AS total_aktif
FROM packages
WHERE current_status NOT IN ('Delivered', 'Failed Delivery');

-- Total delivered
SELECT COUNT(*) AS total_delivered
FROM packages
WHERE current_status = 'Delivered';

-- Paket per warehouse
SELECT w.warehouse_id, w.nama_gudang, COUNT(p.package_id) AS total
FROM warehouses w
LEFT JOIN packages p ON p.current_warehouse_id = w.warehouse_id
GROUP BY w.warehouse_id, w.nama_gudang;
```

### Dashboard WAREHOUSE_ADMIN

```sql
-- Paket saat ini di gudang
SELECT COUNT(*) FROM packages
WHERE current_warehouse_id = ? AND current_status NOT IN ('Delivered','Failed Delivery');

-- Menunggu linehaul
SELECT COUNT(*) FROM packages
WHERE current_warehouse_id = ? AND current_status = 'Assigned to Linehaul';

-- Menunggu courier
SELECT COUNT(*) FROM packages
WHERE current_warehouse_id = ? AND current_status = 'Assigned to Courier';

-- Delivered hari ini
SELECT COUNT(*) FROM packages
WHERE current_warehouse_id = ?
  AND current_status = 'Delivered'
  AND DATE(created_at) = CURDATE();
```

### Generate resi setelah insert

```sql
-- Insert package (resi diisi placeholder dulu)
INSERT INTO packages (resi, nama_paket, ...) VALUES ('PENDING', ...);

-- Ambil ID baru
-- const newId = result.insertId;

-- Update resi dengan format IAMxxxxxx
UPDATE packages
SET resi = CONCAT('IAM', LPAD(?, 6, '0'))
WHERE package_id = ?;
-- params: [newId, newId]
```

---

## Tips Implementasi

- Selalu wrap operasi create package dalam **satu transaksi MySQL** (`BEGIN` → INSERT packages → UPDATE resi → geocoding async → `COMMIT`) untuk konsistensi data.
- Geocoding berjalan **asynchronous** — panggil setelah commit, update koordinat terpisah jika Nominatim lambat.
- Setiap `PATCH /packages/:id/status` dan `/assign` harus **otomatis INSERT** satu baris ke `package_tracker`.
- Gunakan **connection pool** (`mysql2/promise.createPool()`) bukan single connection agar handle concurrent request dengan baik.
- Index yang sudah dibuat di schema (`idx_packages_status`, `idx_packages_current_wh`, dll) akan mempercepat query filter umum.
