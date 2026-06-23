-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 10 Jun 2026 pada 03.28
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_gudangpintar`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `packages`
--

CREATE TABLE `packages` (
  `package_id` int(11) NOT NULL,
  `resi` varchar(20) NOT NULL COMMENT 'Format: IAM + 6 digit, e.g. IAM000001',
  `nama_paket` varchar(150) NOT NULL,
  `alamat_pengirim` text NOT NULL,
  `alamat_tujuan` text NOT NULL,
  `no_hp_pengirim` varchar(20) NOT NULL,
  `no_hp_penerima` varchar(20) NOT NULL,
  `deskripsi_barang` text DEFAULT NULL,
  `berat` decimal(8,2) NOT NULL COMMENT 'Dalam kilogram',
  `jenis_layanan` enum('standar','express','kargo') NOT NULL,
  `ongkos_kirim` decimal(12,2) NOT NULL COMMENT 'Dihitung otomatis saat insert',
  `sender_lat` decimal(10,7) DEFAULT NULL COMMENT 'Geocoding dari alamat_pengirim',
  `sender_lng` decimal(10,7) DEFAULT NULL,
  `receiver_lat` decimal(10,7) DEFAULT NULL COMMENT 'Geocoding dari alamat_tujuan',
  `receiver_lng` decimal(10,7) DEFAULT NULL,
  `current_warehouse_id` int(11) NOT NULL,
  `destination_warehouse_id` int(11) DEFAULT NULL,
  `current_status` enum('Created','Received at Warehouse','Assigned to Linehaul','Picked Up','In Transit','Arrived at Warehouse','Assigned to Courier','Out For Delivery','Delivered','Failed Delivery') NOT NULL DEFAULT 'Created',
  `assigned_user_id` int(11) DEFAULT NULL COMMENT 'Linehaul atau Courier yang ditugaskan',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `package_tracker`
--

CREATE TABLE `package_tracker` (
  `track_id` int(11) NOT NULL,
  `package_id` int(11) NOT NULL,
  `warehouse_id` int(11) DEFAULT NULL COMMENT 'Gudang tempat status diubah',
  `status` varchar(50) NOT NULL,
  `notes` text DEFAULT NULL,
  `created_by` int(11) NOT NULL COMMENT 'user_id yang mengubah status',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL COMMENT 'bcrypt hash',
  `role` enum('SUPER_ADMIN','WAREHOUSE_ADMIN','LINEHAUL','COURIER') NOT NULL,
  `photo_url` varchar(255) DEFAULT NULL,
  `warehouse_id` int(11) DEFAULT NULL COMMENT 'NULL untuk SUPER_ADMIN',
  `biometrics_type` enum('fingerprint','face') DEFAULT NULL,
  `biometrics_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`user_id`, `nama`, `email`, `password_hash`, `role`, `photo_url`, `warehouse_id`, `biometrics_type`, `biometrics_enabled`, `created_at`) VALUES
(1, 'Super Administrator', 'admin_pusat@iamexpress.id', '$2b$10$gJjUxnGmibjqQuhunwo8.OXXKk3RAQPeX225l8ccFOlpcBpnTUoqy', 'SUPER_ADMIN', NULL, NULL, NULL, 0, '2026-06-10 01:27:34');

-- --------------------------------------------------------

--
-- Struktur dari tabel `warehouses`
--

CREATE TABLE `warehouses` (
  `warehouse_id` int(11) NOT NULL,
  `nama_gudang` varchar(100) NOT NULL,
  `alamat` text NOT NULL,
  `lat` decimal(10,7) DEFAULT NULL COMMENT 'Latitude dari geocoding alamat',
  `lng` decimal(10,7) DEFAULT NULL COMMENT 'Longitude dari geocoding alamat',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `packages`
--
ALTER TABLE `packages`
  ADD PRIMARY KEY (`package_id`),
  ADD UNIQUE KEY `uq_packages_resi` (`resi`),
  ADD KEY `idx_packages_status` (`current_status`),
  ADD KEY `idx_packages_layanan` (`jenis_layanan`),
  ADD KEY `idx_packages_current_wh` (`current_warehouse_id`),
  ADD KEY `idx_packages_assigned` (`assigned_user_id`),
  ADD KEY `fk_packages_destination_warehouse` (`destination_warehouse_id`);

--
-- Indeks untuk tabel `package_tracker`
--
ALTER TABLE `package_tracker`
  ADD PRIMARY KEY (`track_id`),
  ADD KEY `idx_tracker_package` (`package_id`),
  ADD KEY `idx_tracker_timestamp` (`timestamp`),
  ADD KEY `fk_tracker_warehouse` (`warehouse_id`),
  ADD KEY `fk_tracker_created_by` (`created_by`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `uq_users_email` (`email`),
  ADD KEY `idx_users_role` (`role`),
  ADD KEY `idx_users_warehouse` (`warehouse_id`);

--
-- Indeks untuk tabel `warehouses`
--
ALTER TABLE `warehouses`
  ADD PRIMARY KEY (`warehouse_id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `packages`
--
ALTER TABLE `packages`
  MODIFY `package_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `package_tracker`
--
ALTER TABLE `package_tracker`
  MODIFY `track_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `warehouses`
--
ALTER TABLE `warehouses`
  MODIFY `warehouse_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `packages`
--
ALTER TABLE `packages`
  ADD CONSTRAINT `fk_packages_assigned_user` FOREIGN KEY (`assigned_user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_packages_current_warehouse` FOREIGN KEY (`current_warehouse_id`) REFERENCES `warehouses` (`warehouse_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_packages_destination_warehouse` FOREIGN KEY (`destination_warehouse_id`) REFERENCES `warehouses` (`warehouse_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `package_tracker`
--
ALTER TABLE `package_tracker`
  ADD CONSTRAINT `fk_tracker_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_tracker_package` FOREIGN KEY (`package_id`) REFERENCES `packages` (`package_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_tracker_warehouse` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_users_warehouse` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
