-- 1. Insert Warehouses
INSERT INTO warehouses (nama_gudang, alamat, lat, lng, created_at) VALUES 
('Gudang Pusat Jakarta', 'Jl. Merdeka No. 1, Jakarta Pusat', -6.200000, 106.816666, NOW()),
('Gudang Utama Surabaya', 'Jl. Pahlawan No. 2, Surabaya', -7.250445, 112.768845, NOW()),
('Gudang Hub Bandung', 'Jl. Asia Afrika No. 3, Bandung', -6.914744, 107.609810, NOW());

-- 2. Insert Users
-- SUPER_ADMIN (admin123)
-- WAREHOUSE_ADMIN (password123)
-- LINEHAUL (password123)
-- COURIER (password123)
-- Asumsi ID warehouse berurutan 1, 2, 3
INSERT INTO users (nama, email, password_hash, role, warehouse_id, biometrics_enabled, biometrics_type, created_at) VALUES 
('Super Administrator', 'admin_pusat@iamexpress.id', '$2b$10$bw1UGQ/e/X9u4TqcRo.wIubsCr2s0sVWPUQep70RkrmcItntvZsQq', 'SUPER_ADMIN', NULL, 0, NULL, NOW()),
('Admin Gudang JKT', 'admin_jkt@iamexpress.id', '$2b$10$4nG5ceQ1gS.RORnCl617CuTBkVzPyF4ebFHcRThieUjwitfOAY0mW', 'WAREHOUSE_ADMIN', 1, 0, NULL, NOW()),
('Admin Gudang SBY', 'admin_sby@iamexpress.id', '$2b$10$4nG5ceQ1gS.RORnCl617CuTBkVzPyF4ebFHcRThieUjwitfOAY0mW', 'WAREHOUSE_ADMIN', 2, 0, NULL, NOW()),
('Linehaul Driver 1', 'linehaul1@iamexpress.id', '$2b$10$4nG5ceQ1gS.RORnCl617CuTBkVzPyF4ebFHcRThieUjwitfOAY0mW', 'LINEHAUL', 1, 0, NULL, NOW()),
('Courier JKT 1', 'courier_jkt1@iamexpress.id', '$2b$10$4nG5ceQ1gS.RORnCl617CuTBkVzPyF4ebFHcRThieUjwitfOAY0mW', 'COURIER', 1, 0, NULL, NOW());

-- 3. Insert Packages
-- Asumsi package_id 1, 2, 3
INSERT INTO packages (resi, nama_paket, alamat_pengirim, alamat_tujuan, no_hp_pengirim, no_hp_penerima, deskripsi_barang, berat, jenis_layanan, ongkos_kirim, current_status, current_warehouse_id, receiver_lat, receiver_lng, created_at) VALUES 
('IAM000001', 'Dokumen Penting', 'Jl. Sudirman, Jakarta', 'Jl. Diponegoro, Surabaya', '081234567890', '089876543210', 'Dokumen kontrak', 2.5, 'standar', 25000, 'Created', 1, -7.265, 112.74, NOW()),
('IAM000002', 'Pakaian', 'Jl. Braga, Bandung', 'Jl. Thamrin, Jakarta', '08111222333', '08444555666', 'Kaos dan kemeja', 1.0, 'express', 15000, 'Received at Warehouse', 3, -6.19, 106.82, NOW()),
('IAM000003', 'Elektronik', 'Jl. Ahmad Yani, Surabaya', 'Jl. Gatot Subroto, Jakarta', '08777888999', '08222333444', 'Laptop bekas', 5.0, 'kargo', 50000, 'Out For Delivery', 1, -6.23, 106.83, NOW());

-- 4. Insert Package Trackers
INSERT INTO package_tracker (package_id, status, notes, created_by, warehouse_id, timestamp) VALUES 
(1, 'Created', 'Paket telah dibuat oleh sistem', 1, 1, NOW()),
(2, 'Created', 'Paket telah dibuat', 1, 3, DATE_SUB(NOW(), INTERVAL 1 DAY)),
(2, 'Received at Warehouse', 'Paket tiba di Gudang Hub Bandung', 2, 3, NOW()),
(3, 'Created', 'Paket telah dibuat', 1, 2, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(3, 'Received at Warehouse', 'Paket tiba di Gudang Utama Surabaya', 3, 2, DATE_SUB(NOW(), INTERVAL 1 DAY)),
(3, 'In Transit', 'Paket dalam perjalanan ke Jakarta', 4, NULL, DATE_SUB(NOW(), INTERVAL 12 HOUR)),
(3, 'Arrived at Warehouse', 'Paket tiba di Gudang Pusat Jakarta', 2, 1, DATE_SUB(NOW(), INTERVAL 4 HOUR)),
(3, 'Assigned to Courier', 'Paket ditugaskan ke Kurir', 2, 1, DATE_SUB(NOW(), INTERVAL 2 HOUR)),
(3, 'Out For Delivery', 'Paket sedang diantar ke alamat tujuan', 5, 1, NOW());
