const db = require('../config/db');
const { successResponse, errorResponse } = require('../utils/response');

const getDashboard = async (req, res) => {
  try {
    const { role, warehouse_id, user_id } = req.user;

    if (role === 'SUPER_ADMIN') {
      const [[{ total: total_warehouse }]] = await db.query('SELECT COUNT(*) AS total FROM warehouses');
      const [[{ total: total_user }]] = await db.query('SELECT COUNT(*) AS total FROM users');
      const [[{ total: total_paket_aktif }]] = await db.query(
        "SELECT COUNT(*) AS total FROM packages WHERE current_status NOT IN ('Delivered', 'Failed Delivery')"
      );
      const [[{ total: total_delivered }]] = await db.query(
        "SELECT COUNT(*) AS total FROM packages WHERE current_status = 'Delivered'"
      );

      const [paket_per_warehouse] = await db.query(
        `SELECT w.warehouse_id, w.nama_gudang, COUNT(p.package_id) AS total
         FROM warehouses w
         LEFT JOIN packages p ON w.warehouse_id = p.current_warehouse_id
         GROUP BY w.warehouse_id, w.nama_gudang`
      );

      const [paket_per_status] = await db.query(
        `SELECT current_status AS status, COUNT(*) AS total
         FROM packages
         GROUP BY current_status`
      );

      return successResponse(res, {
        total_warehouse,
        total_user,
        total_paket_aktif,
        total_delivered,
        paket_per_warehouse,
        paket_per_status
      }, 'Dashboard SUPER_ADMIN');
    }

    if (role === 'WAREHOUSE_ADMIN') {
      const [[{ total: paket_di_warehouse }]] = await db.query(
        "SELECT COUNT(*) AS total FROM packages WHERE current_warehouse_id = ? AND current_status NOT IN ('Delivered', 'Failed Delivery')",
        [warehouse_id]
      );

      const [[{ total: menunggu_linehaul }]] = await db.query(
        "SELECT COUNT(*) AS total FROM packages WHERE current_warehouse_id = ? AND current_status = 'Assigned to Linehaul'",
        [warehouse_id]
      );

      const [[{ total: menunggu_courier }]] = await db.query(
        "SELECT COUNT(*) AS total FROM packages WHERE current_warehouse_id = ? AND current_status = 'Assigned to Courier'",
        [warehouse_id]
      );

      const [[{ total: delivered_hari_ini }]] = await db.query(
        `SELECT COUNT(*) AS total FROM packages
         WHERE current_warehouse_id = ?
           AND current_status = 'Delivered'
           AND DATE(created_at) = CURDATE()`,
        [warehouse_id]
      );

      return successResponse(res, {
        paket_di_warehouse,
        menunggu_linehaul,
        menunggu_courier,
        delivered_hari_ini
      }, 'Dashboard WAREHOUSE_ADMIN');
    }

    if (role === 'LINEHAUL') {
      const [[{ total: total_ditugaskan }]] = await db.query(
        'SELECT COUNT(*) AS total FROM packages WHERE assigned_user_id = ?',
        [user_id]
      );

      const [[{ total: sedang_dikerjakan }]] = await db.query(
        "SELECT COUNT(*) AS total FROM packages WHERE assigned_user_id = ? AND current_status IN ('Picked Up', 'In Transit')",
        [user_id]
      );

      const [[{ total: selesai_hari_ini }]] = await db.query(
        `SELECT COUNT(*) AS total FROM package_tracker
         WHERE created_by = ? AND status = 'Arrived at Warehouse'
           AND DATE(timestamp) = CURDATE()`,
        [user_id]
      );

      return successResponse(res, {
        total_ditugaskan,
        sedang_dikerjakan,
        selesai_hari_ini
      }, 'Dashboard LINEHAUL');
    }

    if (role === 'COURIER') {
      const [[{ total: total_ditugaskan }]] = await db.query(
        'SELECT COUNT(*) AS total FROM packages WHERE assigned_user_id = ?',
        [user_id]
      );

      const [[{ total: sedang_dikerjakan }]] = await db.query(
        "SELECT COUNT(*) AS total FROM packages WHERE assigned_user_id = ? AND current_status = 'Out For Delivery'",
        [user_id]
      );

      const [[{ total: selesai_hari_ini }]] = await db.query(
        `SELECT COUNT(*) AS total FROM package_tracker
         WHERE created_by = ? AND status = 'Delivered'
           AND DATE(timestamp) = CURDATE()`,
        [user_id]
      );

      return successResponse(res, {
        total_ditugaskan,
        sedang_dikerjakan,
        selesai_hari_ini
      }, 'Dashboard COURIER');
    }

    return errorResponse(res, 'Role tidak dikenali', 403);
  } catch (error) {
    console.error('getDashboard error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

module.exports = { getDashboard };
