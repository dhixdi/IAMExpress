const db = require('../config/db');
const { successResponse, errorResponse } = require('../utils/response');
const { getPaginationParams, getSortParams, buildPaginationMeta } = require('../utils/pagination');
const { geocodeAddress } = require('../services/geocodingService');

const getWarehouses = async (req, res) => {
  try {
    const { page, limit, offset } = getPaginationParams(req.query);
    const { sort_by, order } = getSortParams(req.query, ['nama_gudang', 'created_at'], 'created_at');
    const { q } = req.query;

    let whereClause = '1=1';
    const params = [];

    if (q) {
      whereClause += ' AND (nama_gudang LIKE ? OR alamat LIKE ?)';
      params.push(`%${q}%`, `%${q}%`);
    }

    const [countResult] = await db.query(
      `SELECT COUNT(*) AS total FROM warehouses WHERE ${whereClause}`,
      params
    );
    const total = countResult[0].total;

    const [rows] = await db.query(
      `SELECT * FROM warehouses WHERE ${whereClause} ORDER BY ${sort_by} ${order} LIMIT ? OFFSET ?`,
      [...params, limit, offset]
    );

    const meta = buildPaginationMeta(page, limit, total);
    return successResponse(res, { warehouses: rows }, 'Data warehouses berhasil diambil', 200, meta);
  } catch (error) {
    console.error('getWarehouses error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

const getWarehouseById = async (req, res) => {
  try {
    const { id } = req.params;

    const [rows] = await db.query('SELECT * FROM warehouses WHERE warehouse_id = ?', [id]);

    if (rows.length === 0) {
      return errorResponse(res, 'Warehouse tidak ditemukan', 404);
    }

    return successResponse(res, rows[0], 'Data warehouse berhasil diambil');
  } catch (error) {
    console.error('getWarehouseById error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

const createWarehouse = async (req, res) => {
  try {
    if (req.user.role !== 'SUPER_ADMIN') {
      return errorResponse(res, 'Akses ditolak', 403);
    }

    const { nama_gudang, alamat } = req.body;

    if (!nama_gudang || !alamat) {
      return errorResponse(res, 'Nama gudang dan alamat harus diisi', 400);
    }

    const [result] = await db.query(
      'INSERT INTO warehouses (nama_gudang, alamat) VALUES (?, ?)',
      [nama_gudang, alamat]
    );

    const warehouseId = result.insertId;

    // Fire-and-forget geocoding
    geocodeAddress(alamat).then(async (coords) => {
      if (coords) {
        try {
          await db.query(
            'UPDATE warehouses SET lat = ?, lng = ? WHERE warehouse_id = ?',
            [coords.lat, coords.lng, warehouseId]
          );
        } catch (err) {
          console.error('Geocode warehouse update error:', err.message);
        }
      }
    }).catch(err => console.error('Geocode error:', err.message));

    const [rows] = await db.query('SELECT * FROM warehouses WHERE warehouse_id = ?', [warehouseId]);

    return successResponse(res, rows[0], 'Warehouse berhasil dibuat', 201);
  } catch (error) {
    console.error('createWarehouse error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

const updateWarehouse = async (req, res) => {
  try {
    if (req.user.role !== 'SUPER_ADMIN') {
      return errorResponse(res, 'Akses ditolak', 403);
    }

    const { id } = req.params;
    const { nama_gudang, alamat } = req.body;

    const [existing] = await db.query('SELECT * FROM warehouses WHERE warehouse_id = ?', [id]);
    if (existing.length === 0) {
      return errorResponse(res, 'Warehouse tidak ditemukan', 404);
    }

    const updates = [];
    const values = [];

    if (nama_gudang !== undefined) {
      updates.push('nama_gudang = ?');
      values.push(nama_gudang);
    }

    if (alamat !== undefined) {
      updates.push('alamat = ?');
      values.push(alamat);
    }

    if (updates.length === 0) {
      return errorResponse(res, 'Tidak ada data yang diupdate', 400);
    }

    values.push(id);
    await db.query(`UPDATE warehouses SET ${updates.join(', ')} WHERE warehouse_id = ?`, values);

    // Re-geocode if alamat changes
    if (alamat && alamat !== existing[0].alamat) {
      geocodeAddress(alamat).then(async (coords) => {
        if (coords) {
          try {
            await db.query(
              'UPDATE warehouses SET lat = ?, lng = ? WHERE warehouse_id = ?',
              [coords.lat, coords.lng, id]
            );
          } catch (err) {
            console.error('Geocode warehouse update error:', err.message);
          }
        }
      }).catch(err => console.error('Geocode error:', err.message));
    }

    const [rows] = await db.query('SELECT * FROM warehouses WHERE warehouse_id = ?', [id]);

    return successResponse(res, rows[0], 'Warehouse berhasil diupdate');
  } catch (error) {
    console.error('updateWarehouse error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

const deleteWarehouse = async (req, res) => {
  try {
    if (req.user.role !== 'SUPER_ADMIN') {
      return errorResponse(res, 'Akses ditolak', 403);
    }

    const { id } = req.params;

    const [existing] = await db.query('SELECT warehouse_id FROM warehouses WHERE warehouse_id = ?', [id]);
    if (existing.length === 0) {
      return errorResponse(res, 'Warehouse tidak ditemukan', 404);
    }

    // Check if any packages reference this warehouse
    const [packages] = await db.query(
      'SELECT package_id FROM packages WHERE current_warehouse_id = ? LIMIT 1',
      [id]
    );

    if (packages.length > 0) {
      return errorResponse(res, 'Tidak dapat menghapus warehouse yang masih memiliki paket', 400);
    }

    await db.query('DELETE FROM warehouses WHERE warehouse_id = ?', [id]);

    return successResponse(res, null, 'Warehouse berhasil dihapus', 204);
  } catch (error) {
    console.error('deleteWarehouse error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

module.exports = {
  getWarehouses,
  getWarehouseById,
  createWarehouse,
  updateWarehouse,
  deleteWarehouse
};
