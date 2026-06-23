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
  delivery_photo_url      VARCHAR(255)   NULL       COMMENT 'URL foto bukti pengiriman',
  delivered_at            TIMESTAMP      NULL       COMMENT 'Waktu paket diterima',
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
