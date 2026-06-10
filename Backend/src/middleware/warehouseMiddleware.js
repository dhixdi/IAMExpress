const pool = require('../config/db');
const { errorResponse } = require('../utils/response');

/**
 * Middleware that verifies the package (by req.params.id) belongs
 * to the same warehouse as the authenticated user.
 * SUPER_ADMIN bypasses this check.
 */
const warehouseOwnerMiddleware = async (req, res, next) => {
  try {
    if (req.user.role === 'SUPER_ADMIN') return next();

    const packageId = req.params.id;

    const [rows] = await pool.query(
      'SELECT current_warehouse_id FROM packages WHERE package_id = ?',
      [packageId],
    );

    if (rows.length === 0) {
      return errorResponse(res, 'Paket tidak ditemukan', 404);
    }

    const pkg = rows[0];

    if (pkg.current_warehouse_id !== req.user.warehouse_id) {
      return errorResponse(res, 'Akses ditolak, paket bukan milik warehouse Anda', 403);
    }

    next();
  } catch (error) {
    console.error('warehouseOwnerMiddleware error:', error);
    return errorResponse(res, 'Terjadi kesalahan pada server', 500);
  }
};

/**
 * Middleware that verifies the package (by req.params.id) is assigned
 * to the authenticated user.
 * SUPER_ADMIN and WAREHOUSE_ADMIN bypass this check.
 */
const packageAssigneeMiddleware = async (req, res, next) => {
  try {
    if (req.user.role === 'SUPER_ADMIN' || req.user.role === 'WAREHOUSE_ADMIN') {
      return next();
    }

    const packageId = req.params.id;

    const [rows] = await pool.query(
      'SELECT assigned_user_id FROM packages WHERE package_id = ?',
      [packageId],
    );

    if (rows.length === 0) {
      return errorResponse(res, 'Paket tidak ditemukan', 404);
    }

    const pkg = rows[0];

    if (pkg.assigned_user_id !== req.user.user_id) {
      return errorResponse(res, 'Akses ditolak, paket tidak ditugaskan kepada Anda', 403);
    }

    next();
  } catch (error) {
    console.error('packageAssigneeMiddleware error:', error);
    return errorResponse(res, 'Terjadi kesalahan pada server', 500);
  }
};

module.exports = { warehouseOwnerMiddleware, packageAssigneeMiddleware };
