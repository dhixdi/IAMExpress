-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 04 Bulan Mei 2026 pada 18.23
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
-- Struktur dari tabel `paket`
--

CREATE TABLE `paket` (
  `id` int(11) NOT NULL,
  `no_resi` varchar(50) NOT NULL,
  `deskripsi_barang` varchar(255) DEFAULT NULL,
  `nama_pengirim` varchar(100) DEFAULT NULL,
  `nama_penerima` varchar(100) NOT NULL,
  `alamat_penerima` text NOT NULL,
  `lat_penerima` decimal(10,8) DEFAULT NULL,
  `lng_penerima` decimal(11,8) DEFAULT NULL,
  `id_warehouse` int(11) NOT NULL,
  `id_kurir` int(11) DEFAULT NULL,
  `status` enum('Di Gudang','Sedang Diantar','Selesai') DEFAULT 'Di Gudang',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `paket`
--

INSERT INTO `paket` (`id`, `no_resi`, `deskripsi_barang`, `nama_pengirim`, `nama_penerima`, `alamat_penerima`, `lat_penerima`, `lng_penerima`, `id_warehouse`, `id_kurir`, `status`, `created_at`, `updated_at`) VALUES
(1, 'GPX-20260501', 'Laptop Asus', 'Toko Komputer Jogja', 'Dhimas Rizky', 'Janti, Caturtunggal, Kec. Depok, Kabupaten Sleman, Daerah Istimewa Yogyakarta 55281', -7.78195374, 110.41623670, 2, 2, 'Di Gudang', '2026-05-04 16:23:04', '2026-05-04 16:23:14'),
(2, 'GPX-20260502', 'Dokumen Kontrak', 'PT Maju Mundur', 'Andiya', 'Jl Kaliurang Km 5, Caturtunggal, Kabupaten Sleman, Daerah Istimewa Yogyakarta', -7.75650000, 110.38230000, 2, 2, 'Sedang Diantar', '2026-05-04 16:23:04', '2026-05-04 16:23:14'),
(3, 'GPX-20260503', 'Pakaian', 'Toko Baju Online', 'Sekar', 'Bangunharjo, Kabupaten Bantul, Daerah Istimewa Yogyakarta', -7.85900000, 110.36300000, 3, 2, 'Selesai', '2026-05-04 16:23:04', '2026-05-04 16:23:14');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','kurir') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `role`) VALUES
(1, 'admin_siti', '827ccb0eea8a706c4c34a16891f84e7b', 'admin'),
(2, 'kurir_budi', '827ccb0eea8a706c4c34a16891f84e7b', 'kurir');

-- --------------------------------------------------------

--
-- Struktur dari tabel `warehouse`
--

CREATE TABLE `warehouse` (
  `id` int(11) NOT NULL,
  `nama_gudang` varchar(100) NOT NULL,
  `alamat` text NOT NULL,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `warehouse`
--

INSERT INTO `warehouse` (`id`, `nama_gudang`, `alamat`, `latitude`, `longitude`) VALUES
(1, 'Gudang Pusat Yogyakarta', 'Jl. Doktor Sutomo No.26, Bausasran, Kec. Danurejan, Kota Yogyakarta, Daerah Istimewa Yogyakarta 55225', -7.79360762, 110.37760010),
(2, 'Gudang Hub Banguntapan', 'Sorowajan, Banguntapan, Kec. Banguntapan, Kabupaten Bantul, Daerah Istimewa Yogyakarta 55198', -7.81285203, 110.40998188),
(3, 'Gudang Sortir Sleman', 'Jl. Tasura, Jenengan, Maguwoharjo, Kec. Depok, Kabupaten Sleman, Daerah Istimewa Yogyakarta 55281', -7.76310618, 110.42228992);

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `paket`
--
ALTER TABLE `paket`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `no_resi` (`no_resi`),
  ADD KEY `id_warehouse` (`id_warehouse`),
  ADD KEY `fk_kurir` (`id_kurir`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indeks untuk tabel `warehouse`
--
ALTER TABLE `warehouse`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `paket`
--
ALTER TABLE `paket`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `warehouse`
--
ALTER TABLE `warehouse`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `paket`
--
ALTER TABLE `paket`
  ADD CONSTRAINT `fk_kurir` FOREIGN KEY (`id_kurir`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `paket_ibfk_1` FOREIGN KEY (`id_warehouse`) REFERENCES `warehouse` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
