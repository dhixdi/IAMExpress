const db = require('../config/db');
const { successResponse, errorResponse } = require('../utils/response');
const { getPaginationParams, getSortParams, buildPaginationMeta } = require('../utils/pagination');

const getTracker = async (req, res) => {
  try {
    const { id } = req.params;

    // Check package exists
    const [packageExists] = await db.query(
      'SELECT package_id, resi FROM packages WHERE package_id = ?',
      [id]
    );
    if (packageExists.length === 0) {
      return errorResponse(res, 'Paket tidak ditemukan', 404);
    }

    const { page, limit, offset } = getPaginationParams(req.query);
    const { sort_by, order } = getSortParams(req.query, ['timestamp'], 'timestamp');

    const [countResult] = await db.query(
      'SELECT COUNT(*) AS total FROM package_tracker WHERE package_id = ?',
      [id]
    );
    const total = countResult[0].total;

    const [rows] = await db.query(
      `SELECT pt.track_id, pt.package_id, pt.status, pt.notes, pt.timestamp,
              pt.created_by, u.nama AS changed_by_name, u.role AS changed_by_role,
              pt.warehouse_id, w.nama_gudang AS warehouse_name
       FROM package_tracker pt
       LEFT JOIN users u ON pt.created_by = u.user_id
       LEFT JOIN warehouses w ON pt.warehouse_id = w.warehouse_id
       WHERE pt.package_id = ?
       ORDER BY pt.timestamp ${order}
       LIMIT ? OFFSET ?`,
      [id, limit, offset]
    );

    const meta = buildPaginationMeta(page, limit, total);
    return successResponse(res, {
      package: packageExists[0],
      tracking: rows
    }, 'Data tracker berhasil diambil', 200, meta);
  } catch (error) {
    console.error('getTracker error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

module.exports = { getTracker };
