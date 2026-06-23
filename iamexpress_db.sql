-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 10 Jun 2026 pada 12.04
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
-- Database: `iamexpress_db`
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

--
-- Dumping data untuk tabel `packages`
--

INSERT INTO `packages` (`package_id`, `resi`, `nama_paket`, `alamat_pengirim`, `alamat_tujuan`, `no_hp_pengirim`, `no_hp_penerima`, `deskripsi_barang`, `berat`, `jenis_layanan`, `ongkos_kirim`, `sender_lat`, `sender_lng`, `receiver_lat`, `receiver_lng`, `current_warehouse_id`, `destination_warehouse_id`, `current_status`, `assigned_user_id`, `created_at`) VALUES
(1, 'IAM000001', 'Dokumen Penting', 'Jl. Sudirman, Jakarta', 'Jl. Diponegoro, Surabaya', '081234567890', '089876543210', 'Dokumen kontrak', 2.50, 'standar', 25000.00, NULL, NULL, -7.2650000, 112.7400000, 1, NULL, 'Assigned to Linehaul', 4, '2026-06-10 03:53:25'),
(2, 'IAM000002', 'Pakaian', 'Jl. Braga, Bandung', 'Jl. Thamrin, Jakarta', '08111222333', '08444555666', 'Kaos dan kemeja', 1.00, 'express', 15000.00, NULL, NULL, -6.1900000, 106.8200000, 3, NULL, 'Arrived at Warehouse', 9, '2026-06-10 03:53:25'),
(3, 'IAM000003', 'Elektronik', 'Jl. Ahmad Yani, Surabaya', 'Jl. Gatot Subroto, Jakarta', '08777888999', '08222333444', 'Laptop bekas', 5.00, 'kargo', 50000.00, NULL, NULL, -6.2300000, 106.8300000, 1, NULL, 'Out For Delivery', NULL, '2026-06-10 03:53:25'),
(4, 'IAM000004', 'Pakaian', 'Blok M Jakarta', 'Gang Kruwing 1 no 7 Janti Caturtunggal Sleman', '08111222333', '08444555666', 'Kaos dan kemeja', 1.00, 'standar', 10000.00, -6.1944491, 106.8229198, -7.7860909, 110.4109827, 1, NULL, 'Delivered', 6, '2026-06-10 07:38:59'),
(5, 'IAM000005', 'Duit', 'Halim Kusuma Jakarta Timur', 'Gang Kruwing 1 no 7 Janti Caturtunggal Sleman', '08111222333', '089876543210', 'Duit Palsu 1Kg', 1.00, 'standar', 10000.00, -6.2653379, 106.8855528, -7.7860909, 110.4109827, 1, 1, 'Delivered', 6, '2026-06-10 07:58:21'),
(6, 'IAM000006', 'Pakaian', 'Jakarta Timur', 'Dago Bandung', '08111222333', '08444555666', 'Kaos dan kemeja', 1.00, 'standar', 10000.00, -6.2126204, 106.9434084, -6.8772577, 107.6174119, 1, 3, 'Assigned to Linehaul', 4, '2026-06-10 09:42:18'),
(7, 'IAM000007', 'Pakaian', 'Dago Bandung', 'Surabaya', '08111222333', '08444555666', 'Kaos dan kemeja', 2.00, 'standar', 20000.00, -6.8772577, 107.6174119, -7.2574719, 112.7520883, 3, 2, 'Received at Warehouse', NULL, '2026-06-10 09:49:54'),
(8, 'IAM000008', 'Pakaian', 'Braga Bandung', 'UNAIR surabaya', '08111222333', '08444555666', 'Kaos dan kemeja', 2.00, 'standar', 20000.00, -6.9192652, 107.6082150, -7.2686917, 112.7842194, 2, 2, 'Arrived at Warehouse', 9, '2026-06-10 09:55:35');

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

--
-- Dumping data untuk tabel `package_tracker`
--

INSERT INTO `package_tracker` (`track_id`, `package_id`, `warehouse_id`, `status`, `notes`, `created_by`, `timestamp`) VALUES
(1, 1, 1, 'Created', 'Paket telah dibuat oleh sistem', 1, '2026-06-10 03:53:25'),
(2, 2, 3, 'Created', 'Paket telah dibuat', 1, '2026-06-09 03:53:25'),
(3, 2, 3, 'Received at Warehouse', 'Paket tiba di Gudang Hub Bandung', 2, '2026-06-10 03:53:25'),
(4, 3, 2, 'Created', 'Paket telah dibuat', 1, '2026-06-08 03:53:25'),
(5, 3, 2, 'Received at Warehouse', 'Paket tiba di Gudang Utama Surabaya', 3, '2026-06-09 03:53:25'),
(6, 3, NULL, 'In Transit', 'Paket dalam perjalanan ke Jakarta', 4, '2026-06-09 15:53:25'),
(7, 3, 1, 'Arrived at Warehouse', 'Paket tiba di Gudang Pusat Jakarta', 2, '2026-06-09 23:53:25'),
(8, 3, 1, 'Assigned to Courier', 'Paket ditugaskan ke Kurir', 2, '2026-06-10 01:53:25'),
(9, 3, 1, 'Out For Delivery', 'Paket sedang diantar ke alamat tujuan', 5, '2026-06-10 03:53:25'),
(10, 4, 1, 'Created', 'Paket berhasil dibuat', 2, '2026-06-10 07:38:59'),
(11, 5, 1, 'Created', 'Paket berhasil dibuat', 2, '2026-06-10 07:58:21'),
(12, 4, 1, 'Received at Warehouse', 'Status diperbarui oleh Admin ke Received at Warehouse', 2, '2026-06-10 09:00:01'),
(13, 1, 1, 'Received at Warehouse', 'Status diperbarui oleh Admin ke Received at Warehouse', 2, '2026-06-10 09:06:58'),
(14, 4, 1, 'Assigned to Linehaul', 'Ditugaskan ke Linehaul Driver 1', 2, '2026-06-10 09:08:00'),
(15, 5, 1, 'Out For Delivery', NULL, 6, '2026-06-10 09:30:39'),
(16, 5, 1, 'Delivered', NULL, 6, '2026-06-10 09:30:48'),
(17, 4, 1, 'Picked Up', NULL, 4, '2026-06-10 09:31:38'),
(18, 4, 1, 'In Transit', NULL, 4, '2026-06-10 09:31:40'),
(19, 4, 1, 'Arrived at Warehouse', NULL, 4, '2026-06-10 09:31:43'),
(20, 4, 1, 'Assigned to Courier', 'Ditugaskan ke IAM', 2, '2026-06-10 09:32:19'),
(21, 4, 1, 'Out For Delivery', NULL, 6, '2026-06-10 09:33:11'),
(22, 4, 1, 'Delivered', NULL, 6, '2026-06-10 09:36:22'),
(23, 1, 1, 'Assigned to Linehaul', 'Ditugaskan ke Linehaul Driver 1', 2, '2026-06-10 09:40:29'),
(24, 6, 1, 'Created', 'Paket berhasil dibuat', 2, '2026-06-10 09:42:18'),
(25, 6, 1, 'Received at Warehouse', 'Status diperbarui oleh Admin ke Received at Warehouse', 2, '2026-06-10 09:42:30'),
(26, 6, 1, 'Assigned to Linehaul', 'Ditugaskan ke Linehaul Driver 1', 2, '2026-06-10 09:42:33'),
(27, 2, 3, 'Assigned to Linehaul', 'Ditugaskan ke Linehaul Jakarta Bandung', 8, '2026-06-10 09:46:06'),
(28, 2, 3, 'Picked Up', NULL, 9, '2026-06-10 09:46:43'),
(29, 2, 3, 'In Transit', NULL, 9, '2026-06-10 09:46:46'),
(30, 2, 3, 'Arrived at Warehouse', NULL, 9, '2026-06-10 09:46:49'),
(31, 7, 3, 'Created', 'Paket berhasil dibuat', 8, '2026-06-10 09:49:54'),
(32, 7, 3, 'Received at Warehouse', 'Status diperbarui oleh Admin ke Received at Warehouse', 8, '2026-06-10 09:49:58'),
(33, 8, 3, 'Created', 'Paket berhasil dibuat', 8, '2026-06-10 09:55:35'),
(34, 8, 3, 'Assigned to Linehaul', 'Ditugaskan ke Linehaul Jakarta Bandung', 8, '2026-06-10 09:55:46'),
(35, 8, 3, 'Picked Up', NULL, 9, '2026-06-10 09:55:56'),
(36, 8, 3, 'In Transit', 'Sedang dalam perjalanan menuju gudang tujuan', 9, '2026-06-10 09:56:00'),
(37, 8, 2, 'Arrived at Warehouse', 'Paket telah tiba dan diterima di gudang', 9, '2026-06-10 09:56:02');

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
(1, 'Super Administrator', 'admin_pusat@iamexpress.id', '$2b$10$bw1UGQ/e/X9u4TqcRo.wIubsCr2s0sVWPUQep70RkrmcItntvZsQq', 'SUPER_ADMIN', NULL, NULL, NULL, 0, '2026-06-10 03:53:25'),
(2, 'Admin Gudang JKT', 'admin_jkt@iamexpress.id', '$2b$10$4nG5ceQ1gS.RORnCl617CuTBkVzPyF4ebFHcRThieUjwitfOAY0mW', 'WAREHOUSE_ADMIN', NULL, 1, NULL, 0, '2026-06-10 03:53:25'),
(3, 'Admin Gudang SBY', 'admin_sby@iamexpress.id', '$2b$10$4nG5ceQ1gS.RORnCl617CuTBkVzPyF4ebFHcRThieUjwitfOAY0mW', 'WAREHOUSE_ADMIN', NULL, 2, NULL, 0, '2026-06-10 03:53:25'),
(4, 'Linehaul Driver 1', 'linehaul1@iamexpress.id', '$2b$10$4nG5ceQ1gS.RORnCl617CuTBkVzPyF4ebFHcRThieUjwitfOAY0mW', 'LINEHAUL', NULL, 1, NULL, 0, '2026-06-10 03:53:25'),
(5, 'Kurir JKT 1', 'courier_jkt1@iamexpress.id', '$2b$10$4nG5ceQ1gS.RORnCl617CuTBkVzPyF4ebFHcRThieUjwitfOAY0mW', 'COURIER', NULL, 1, NULL, 0, '2026-06-10 03:53:25'),
(6, 'IAM', 'courier_jkt2@iamexpress.id', '$2b$10$0Kn3tzZtDmIjzWWNfAIOneCfZI8pF5IdfSUKkKXf1wQN5Bx/QDy/W', 'COURIER', NULL, 1, 'fingerprint', 1, '2026-06-10 07:10:30'),
(7, 'Budi', 'courier_jkt3@iamexpress.id', '$2b$10$yc1SqSKLRjbXwgs.OO/mmuyW8WdPVTM2Yev7mPw3qoejFDUQWYSau', 'COURIER', NULL, 1, NULL, 0, '2026-06-10 07:41:28'),
(8, 'admin bandung', 'admin_bdg@iamexpress.id', '$2b$10$Omtq4Fal7eBNGOxcXSn7MOYdMXaKoioodDZ4ac4QNn8sFK.K4lSAS', 'WAREHOUSE_ADMIN', NULL, 3, NULL, 0, '2026-06-10 09:43:36'),
(9, 'Linehaul Jakarta Bandung', 'linehaul2@iamexpress.id', '$2b$10$vFTKyAX.PYe.RoraGR.Ese5.FUw4ollJds9A/kosfjCGL6BiCzuPG', 'LINEHAUL', NULL, 3, NULL, 0, '2026-06-10 09:45:03'),
(10, 'Linehaul Surabaya Jakarta', 'linehaul3@iamexpress.id', '$2b$10$7XfOd.iMYTUVsgmC0kObauitoEQRWZyXpMiFL0yBPSyowDDRENODu', 'LINEHAUL', NULL, 2, NULL, 0, '2026-06-10 10:03:06');

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
-- Dumping data untuk tabel `warehouses`
--

INSERT INTO `warehouses` (`warehouse_id`, `nama_gudang`, `alamat`, `lat`, `lng`, `created_at`) VALUES
(1, 'Gudang Pusat Jakarta', 'Jl. Merdeka No. 1, Jakarta Pusat', -6.2000000, 106.8166660, '2026-06-10 03:53:25'),
(2, 'Gudang Utama Surabaya', 'Jl. Pahlawan No. 2, Surabaya', -7.2504450, 112.7688450, '2026-06-10 03:53:25'),
(3, 'Gudang Hub Bandung', 'Jl. Asia Afrika No. 3, Bandung', -6.9147440, 107.6098100, '2026-06-10 03:53:25');

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
  MODIFY `package_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT untuk tabel `package_tracker`
--
ALTER TABLE `package_tracker`
  MODIFY `track_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT untuk tabel `warehouses`
--
ALTER TABLE `warehouses`
  MODIFY `warehouse_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

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
