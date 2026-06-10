-- 1. Insert Warehouses
INSERT INTO warehouses (warehouse_id, nama_gudang, alamat, lat, lng, created_at, updated_at) VALUES 
('W-JKT-01', 'Gudang Pusat Jakarta', 'Jl. Merdeka No. 1, Jakarta Pusat', -6.200000, 106.816666, NOW(), NOW()),
('W-SBY-01', 'Gudang Utama Surabaya', 'Jl. Pahlawan No. 2, Surabaya', -7.250445, 112.768845, NOW(), NOW()),
('W-BDG-01', 'Gudang Hub Bandung', 'Jl. Asia Afrika No. 3, Bandung', -6.914744, 107.609810, NOW(), NOW());

-- 2. Insert Users
-- SUPER_ADMIN (admin123)
-- WAREHOUSE_ADMIN (password123)
-- LINEHAUL (password123)
-- COURIER (password123)
INSERT INTO users (nama, email, password, role, warehouse_id, biometrics_enabled, biometrics_type, created_at, updated_at) VALUES 
('Super Administrator', 'admin_pusat@iamexpress.id', '$2b$10$bw1UGQ/e/X9u4TqcRo.wIubsCr2s0sVWPUQep70RkrmcItntvZsQq', 'SUPER_ADMIN', NULL, FALSE, NULL, NOW(), NOW()),
('Admin Gudang JKT', 'admin_jkt@iamexpress.id', '$2b$10$4nG5ceQ1gS.RORnCl617CuTBkVzPyF4ebFHcRThieUjwitfOAY0mW', 'WAREHOUSE_ADMIN', 'W-JKT-01', FALSE, NULL, NOW(), NOW()),
('Admin Gudang SBY', 'admin_sby@iamexpress.id', '$2b$10$4nG5ceQ1gS.RORnCl617CuTBkVzPyF4ebFHcRThieUjwitfOAY0mW', 'WAREHOUSE_ADMIN', 'W-SBY-01', FALSE, NULL, NOW(), NOW()),
('Linehaul Driver 1', 'linehaul1@iamexpress.id', '$2b$10$4nG5ceQ1gS.RORnCl617CuTBkVzPyF4ebFHcRThieUjwitfOAY0mW', 'LINEHAUL', 'W-JKT-01', FALSE, NULL, NOW(), NOW()),
('Courier JKT 1', 'courier_jkt1@iamexpress.id', '$2b$10$4nG5ceQ1gS.RORnCl617CuTBkVzPyF4ebFHcRThieUjwitfOAY0mW', 'COURIER', 'W-JKT-01', FALSE, NULL, NOW(), NOW());

-- 3. Insert Packages
INSERT INTO packages (resi, status, sender_name, sender_phone, sender_address, receiver_name, receiver_phone, receiver_address, receiver_lat, receiver_lng, current_warehouse_id, weight, dimensions, shipping_cost, created_at, updated_at) VALUES 
('IAM-1000000001', 'Created', 'Budi Santoso', '081234567890', 'Jl. Sudirman, Jakarta', 'Andi Wijaya', '089876543210', 'Jl. Diponegoro, Surabaya', -7.265, 112.74, 'W-JKT-01', 2.5, '20x20x10', 25000, NOW(), NOW()),
('IAM-1000000002', 'Received at Warehouse', 'Citra Lestari', '08111222333', 'Jl. Braga, Bandung', 'Dian Sastro', '08444555666', 'Jl. Thamrin, Jakarta', -6.19, 106.82, 'W-BDG-01', 1.0, '10x10x5', 15000, NOW(), NOW()),
('IAM-1000000003', 'Out For Delivery', 'Eko Purnomo', '08777888999', 'Jl. Ahmad Yani, Surabaya', 'Fajar Sidik', '08222333444', 'Jl. Gatot Subroto, Jakarta', -6.23, 106.83, 'W-JKT-01', 5.0, '30x30x30', 50000, NOW(), NOW());

-- 4. Insert Package Trackers
INSERT INTO package_tracker (package_id, status, notes, changed_by, current_warehouse_id, timestamp) VALUES 
(1, 'Created', 'Paket telah dibuat oleh Budi Santoso', 1, 'W-JKT-01', NOW()),
(2, 'Created', 'Paket telah dibuat', 1, 'W-BDG-01', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(2, 'Received at Warehouse', 'Paket tiba di Gudang Hub Bandung', 2, 'W-BDG-01', NOW()),
(3, 'Created', 'Paket telah dibuat', 1, 'W-SBY-01', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(3, 'Received at Warehouse', 'Paket tiba di Gudang Utama Surabaya', 3, 'W-SBY-01', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(3, 'In Transit', 'Paket dalam perjalanan ke Jakarta', 4, NULL, DATE_SUB(NOW(), INTERVAL 12 HOUR)),
(3, 'Arrived at Warehouse', 'Paket tiba di Gudang Pusat Jakarta', 2, 'W-JKT-01', DATE_SUB(NOW(), INTERVAL 4 HOUR)),
(3, 'Assigned to Courier', 'Paket ditugaskan ke Kurir', 2, 'W-JKT-01', DATE_SUB(NOW(), INTERVAL 2 HOUR)),
(3, 'Out For Delivery', 'Paket sedang diantar ke alamat tujuan', 5, 'W-JKT-01', NOW());
