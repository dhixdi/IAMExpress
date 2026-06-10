USE iamexpress_db;

-- ============================================================
-- Seed Users — HANYA 1 SUPER_ADMIN (minimal seed)
-- Password: admin123
-- Bcrypt hash generated via: bcrypt.hash('admin123', 10)
-- ============================================================

INSERT INTO users (nama, email, password_hash, role, warehouse_id) VALUES
('Super Administrator', 'admin_pusat@iamexpress.id', '$2b$10$gJjUxnGmibjqQuhunwo8.OXXKk3RAQPeX225l8ccFOlpcBpnTUoqy', 'SUPER_ADMIN', NULL);
