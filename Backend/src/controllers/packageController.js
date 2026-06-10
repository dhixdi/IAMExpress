const db = require('../config/db');
const { successResponse, errorResponse } = require('../utils/response');
const { getPaginationParams, getSortParams, buildPaginationMeta } = require('../utils/pagination');
const { isValidTransition, canRoleSetStatus } = require('../utils/statusValidator');
const { calculateShippingCost } = require('../services/shippingService');
const { updateResi } = require('../services/resiService');
const { geocodePackageAddresses } = require('../services/geocodingService');

const getPackages = async (req, res) => {
  try {
    const { page, limit, offset } = getPaginationParams(req.query);
    const { sort_by, order } = getSortParams(req.query, ['resi', 'nama_paket', 'berat', 'ongkos_kirim', 'current_status', 'jenis_layanan', 'created_at'], 'created_at');
    const { q, current_status, jenis_layanan, warehouse_id } = req.query;
    const { role, user_id, warehouse_id: userWarehouseId } = req.user;

    let whereClause = '1=1';
    const params = [];

    // Role-based filtering
    if (role === 'WAREHOUSE_ADMIN') {
      whereClause += ' AND p.current_warehouse_id = ?';
      params.push(userWarehouseId);
    } else if (role === 'LINEHAUL' || role === 'COURIER') {
      whereClause += ' AND p.assigned_user_id = ?';
      params.push(user_id);
    } else if (role === 'SUPER_ADMIN' && warehouse_id) {
      whereClause += ' AND p.current_warehouse_id = ?';
      params.push(warehouse_id);
    }

    // Search filter
    if (q) {
      whereClause += ' AND (p.resi LIKE ? OR p.nama_paket LIKE ? OR p.no_hp_pengirim LIKE ? OR p.no_hp_penerima LIKE ?)';
      params.push(`%${q}%`, `%${q}%`, `%${q}%`, `%${q}%`);
    }

    if (current_status) {
      whereClause += ' AND p.current_status = ?';
      params.push(current_status);
    }

    if (jenis_layanan) {
      whereClause += ' AND p.jenis_layanan = ?';
      params.push(jenis_layanan);
    }

    const [countResult] = await db.query(
      `SELECT COUNT(*) AS total FROM packages p WHERE ${whereClause}`,
      params
    );
    const total = countResult[0].total;

    const [rows] = await db.query(
      `SELECT p.*,
              wc.nama_gudang AS current_warehouse_name,
              wd.nama_gudang AS destination_warehouse_name,
              u.nama AS assigned_user_name,
              u.role AS assigned_user_role
       FROM packages p
       LEFT JOIN warehouses wc ON p.current_warehouse_id = wc.warehouse_id
       LEFT JOIN warehouses wd ON p.destination_warehouse_id = wd.warehouse_id
       LEFT JOIN users u ON p.assigned_user_id = u.user_id
       WHERE ${whereClause}
       ORDER BY p.${sort_by} ${order}
       LIMIT ? OFFSET ?`,
      [...params, limit, offset]
    );

    const meta = buildPaginationMeta(page, limit, total);
    return successResponse(res, { packages: rows }, 'Daftar paket berhasil diambil', 200, meta);
  } catch (error) {
    console.error('getPackages error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

const getPackageById = async (req, res) => {
  try {
    const { id } = req.params;

    const [rows] = await db.query(
      `SELECT p.*,
              wc.nama_gudang AS current_warehouse_name,
              wd.nama_gudang AS destination_warehouse_name,
              u.nama AS assigned_user_name,
              u.role AS assigned_user_role
       FROM packages p
       LEFT JOIN warehouses wc ON p.current_warehouse_id = wc.warehouse_id
       LEFT JOIN warehouses wd ON p.destination_warehouse_id = wd.warehouse_id
       LEFT JOIN users u ON p.assigned_user_id = u.user_id
       WHERE p.package_id = ?`,
      [id]
    );

    if (rows.length === 0) {
      return errorResponse(res, 'Paket tidak ditemukan', 404);
    }

    return successResponse(res, rows[0], 'Detail paket berhasil diambil');
  } catch (error) {
    console.error('getPackageById error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

const trackByResi = async (req, res) => {
  try {
    const { resi } = req.params;

    const [packages] = await db.query(
      `SELECT p.*,
              wc.nama_gudang AS current_warehouse_name,
              wd.nama_gudang AS destination_warehouse_name
       FROM packages p
       LEFT JOIN warehouses wc ON p.current_warehouse_id = wc.warehouse_id
       LEFT JOIN warehouses wd ON p.destination_warehouse_id = wd.warehouse_id
       WHERE p.resi = ?`,
      [resi]
    );

    if (packages.length === 0) {
      return errorResponse(res, 'Paket dengan resi tersebut tidak ditemukan', 404);
    }

    const packageData = packages[0];

    // Get tracking history
    const [tracker] = await db.query(
      `SELECT pt.*,
              u.nama AS changed_by_name,
              u.role AS changed_by_role,
              w.nama_gudang AS warehouse_name
       FROM package_tracker pt
       LEFT JOIN users u ON pt.created_by = u.user_id
       LEFT JOIN warehouses w ON pt.warehouse_id = w.warehouse_id
       WHERE pt.package_id = ?
       ORDER BY pt.timestamp ASC`,
      [packageData.package_id]
    );

    packageData.tracking_history = tracker;

    return successResponse(res, packageData, 'Data tracking berhasil diambil');
  } catch (error) {
    console.error('trackByResi error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

const createPackage = async (req, res) => {
  try {
    const {
      nama_paket, alamat_pengirim, alamat_tujuan,
      no_hp_pengirim, no_hp_penerima, deskripsi_barang,
      berat, jenis_layanan, destination_warehouse_id
    } = req.body;

    // Validate required fields
    if (!nama_paket || !alamat_pengirim || !alamat_tujuan ||
        !no_hp_pengirim || !no_hp_penerima || !berat || !jenis_layanan) {
      return errorResponse(res, 'Semua field wajib harus diisi', 400);
    }

    // Calculate shipping cost
    let ongkos_kirim;
    try {
      ongkos_kirim = calculateShippingCost(parseFloat(berat), jenis_layanan);
    } catch (err) {
      return errorResponse(res, err.message, 400);
    }

    // Insert package with resi='PENDING'
    const [result] = await db.query(
      `INSERT INTO packages (
        resi, nama_paket, alamat_pengirim, alamat_tujuan,
        no_hp_pengirim, no_hp_penerima, deskripsi_barang,
        berat, jenis_layanan, ongkos_kirim,
        current_warehouse_id, destination_warehouse_id, current_status
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        'PENDING', nama_paket, alamat_pengirim, alamat_tujuan,
        no_hp_pengirim, no_hp_penerima, deskripsi_barang || null,
        parseFloat(berat), jenis_layanan, ongkos_kirim,
        req.user.warehouse_id, destination_warehouse_id || null, 'Created'
      ]
    );

    const packageId = result.insertId;

    // Update resi with generated number
    const resi = await updateResi(db, packageId);

    // Insert tracker entry for 'Created'
    await db.query(
      `INSERT INTO package_tracker (package_id, warehouse_id, status, notes, created_by)
       VALUES (?, ?, ?, ?, ?)`,
      [packageId, req.user.warehouse_id, 'Created', 'Paket berhasil dibuat', req.user.user_id]
    );

    // Fire-and-forget geocoding
    geocodePackageAddresses(db, packageId, alamat_pengirim, alamat_tujuan)
      .catch(err => console.error('Geocode async error:', err.message));

    // Return newly created package
    const [newPackage] = await db.query(
      `SELECT p.*,
              wc.nama_gudang AS current_warehouse_name,
              wd.nama_gudang AS destination_warehouse_name
       FROM packages p
       LEFT JOIN warehouses wc ON p.current_warehouse_id = wc.warehouse_id
       LEFT JOIN warehouses wd ON p.destination_warehouse_id = wd.warehouse_id
       WHERE p.package_id = ?`,
      [packageId]
    );

    return successResponse(res, newPackage[0], 'Paket berhasil dibuat', 201);
  } catch (error) {
    console.error('createPackage error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

const updatePackage = async (req, res) => {
  try {
    const { id } = req.params;

    // Check package exists and belongs to user's warehouse
    const [existing] = await db.query('SELECT * FROM packages WHERE package_id = ?', [id]);
    if (existing.length === 0) {
      return errorResponse(res, 'Paket tidak ditemukan', 404);
    }

    if (existing[0].current_warehouse_id !== req.user.warehouse_id) {
      return errorResponse(res, 'Akses ditolak. Paket bukan di warehouse Anda', 403);
    }

    const { nama_paket, deskripsi_barang, no_hp_pengirim, no_hp_penerima } = req.body;
    const updates = [];
    const values = [];

    if (nama_paket !== undefined) {
      updates.push('nama_paket = ?');
      values.push(nama_paket);
    }
    if (deskripsi_barang !== undefined) {
      updates.push('deskripsi_barang = ?');
      values.push(deskripsi_barang);
    }
    if (no_hp_pengirim !== undefined) {
      updates.push('no_hp_pengirim = ?');
      values.push(no_hp_pengirim);
    }
    if (no_hp_penerima !== undefined) {
      updates.push('no_hp_penerima = ?');
      values.push(no_hp_penerima);
    }

    if (updates.length === 0) {
      return errorResponse(res, 'Tidak ada data yang diupdate', 400);
    }

    values.push(id);
    await db.query(`UPDATE packages SET ${updates.join(', ')} WHERE package_id = ?`, values);

    const [rows] = await db.query(
      `SELECT p.*,
              wc.nama_gudang AS current_warehouse_name,
              wd.nama_gudang AS destination_warehouse_name
       FROM packages p
       LEFT JOIN warehouses wc ON p.current_warehouse_id = wc.warehouse_id
       LEFT JOIN warehouses wd ON p.destination_warehouse_id = wd.warehouse_id
       WHERE p.package_id = ?`,
      [id]
    );

    return successResponse(res, rows[0], 'Paket berhasil diupdate');
  } catch (error) {
    console.error('updatePackage error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

const deletePackage = async (req, res) => {
  try {
    const { id } = req.params;

    const [existing] = await db.query('SELECT * FROM packages WHERE package_id = ?', [id]);
    if (existing.length === 0) {
      return errorResponse(res, 'Paket tidak ditemukan', 404);
    }

    if (req.user.role === 'SUPER_ADMIN') {
      // SUPER_ADMIN can delete any package
    } else if (req.user.role === 'WAREHOUSE_ADMIN') {
      if (existing[0].current_warehouse_id !== req.user.warehouse_id) {
        return errorResponse(res, 'Akses ditolak. Paket bukan di warehouse Anda', 403);
      }
    } else {
      return errorResponse(res, 'Akses ditolak', 403);
    }

    // package_tracker has ON DELETE CASCADE, so it auto-deletes
    await db.query('DELETE FROM packages WHERE package_id = ?', [id]);

    return res.status(204).send();
  } catch (error) {
    console.error('deletePackage error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

const updateStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, notes } = req.body;

    if (!status) {
      return errorResponse(res, 'Status harus diisi', 400);
    }

    const [existing] = await db.query('SELECT * FROM packages WHERE package_id = ?', [id]);
    if (existing.length === 0) {
      return errorResponse(res, 'Paket tidak ditemukan', 404);
    }

    const currentStatus = existing[0].current_status;

    // Validate status transition
    if (!isValidTransition(currentStatus, status)) {
      return errorResponse(res, `Transisi status dari '${currentStatus}' ke '${status}' tidak valid`, 400);
    }

    // Validate role can set this status
    if (!canRoleSetStatus(req.user.role, status)) {
      return errorResponse(res, `Role ${req.user.role} tidak dapat mengubah status ke '${status}'`, 403);
    }

    const updateFields = ['current_status = ?'];
    const updateValues = [status];

    // If LINEHAUL marks as 'Arrived at Warehouse', update current_warehouse_id
    if (status === 'Arrived at Warehouse' && existing[0].destination_warehouse_id) {
      updateFields.push('current_warehouse_id = ?');
      updateValues.push(existing[0].destination_warehouse_id);
    }

    updateValues.push(id);
    await db.query(
      `UPDATE packages SET ${updateFields.join(', ')} WHERE package_id = ?`,
      updateValues
    );

    let trackerWarehouseId = existing[0].current_warehouse_id;
    if (status === 'Arrived at Warehouse' && existing[0].destination_warehouse_id) {
      trackerWarehouseId = existing[0].destination_warehouse_id;
    }

    let finalNotes = notes || null;
    if (status === 'In Transit' && !finalNotes) {
      finalNotes = 'Sedang dalam perjalanan menuju gudang tujuan';
    } else if (status === 'Arrived at Warehouse' && !finalNotes) {
      finalNotes = 'Paket telah tiba dan diterima di gudang';
    }

    // Insert tracker entry
    await db.query(
      `INSERT INTO package_tracker (package_id, warehouse_id, status, notes, created_by)
       VALUES (?, ?, ?, ?, ?)`,
      [id, trackerWarehouseId, status, finalNotes, req.user.user_id]
    );

    const [rows] = await db.query(
      `SELECT p.*,
              wc.nama_gudang AS current_warehouse_name,
              wd.nama_gudang AS destination_warehouse_name,
              u.nama AS assigned_user_name
       FROM packages p
       LEFT JOIN warehouses wc ON p.current_warehouse_id = wc.warehouse_id
       LEFT JOIN warehouses wd ON p.destination_warehouse_id = wd.warehouse_id
       LEFT JOIN users u ON p.assigned_user_id = u.user_id
       WHERE p.package_id = ?`,
      [id]
    );

    return successResponse(res, rows[0], 'Status berhasil diupdate');
  } catch (error) {
    console.error('updateStatus error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

const assignPackage = async (req, res) => {
  try {
    const { id } = req.params;
    const { user_id, type, destination_warehouse_id } = req.body;

    if (!user_id || !type) {
      return errorResponse(res, 'user_id dan type harus diisi', 400);
    }

    if (!['linehaul', 'courier'].includes(type)) {
      return errorResponse(res, "Type harus 'linehaul' atau 'courier'", 400);
    }

    // Check package exists and is in user's warehouse
    const [existing] = await db.query('SELECT * FROM packages WHERE package_id = ?', [id]);
    if (existing.length === 0) {
      return errorResponse(res, 'Paket tidak ditemukan', 404);
    }

    if (existing[0].current_warehouse_id !== req.user.warehouse_id) {
      return errorResponse(res, 'Akses ditolak. Paket bukan di warehouse Anda', 403);
    }

    // Validate assigned user exists and has correct role
    const expectedRole = type === 'linehaul' ? 'LINEHAUL' : 'COURIER';
    const [assignedUser] = await db.query(
      'SELECT user_id, role, nama FROM users WHERE user_id = ?',
      [user_id]
    );

    if (assignedUser.length === 0) {
      return errorResponse(res, 'User yang ditugaskan tidak ditemukan', 404);
    }

    if (assignedUser[0].role !== expectedRole) {
      return errorResponse(res, `User harus memiliki role ${expectedRole}`, 400);
    }

    const newStatus = type === 'linehaul' ? 'Assigned to Linehaul' : 'Assigned to Courier';

    if (type === 'courier' && existing[0].current_warehouse_id !== existing[0].destination_warehouse_id) {
      return errorResponse(res, 'Kurir hanya bisa di-assign jika paket sudah berada di Gudang Tujuan', 400);
    }

    // Validate status transition
    if (!isValidTransition(existing[0].current_status, newStatus)) {
      return errorResponse(res, `Tidak bisa assign. Status saat ini '${existing[0].current_status}' tidak dapat diubah ke '${newStatus}'`, 400);
    }

    // Prepare update
    let updateQuery = 'UPDATE packages SET assigned_user_id = ?, current_status = ?';
    let updateParams = [user_id, newStatus];

    if (type === 'linehaul' && destination_warehouse_id) {
      updateQuery += ', destination_warehouse_id = ?';
      updateParams.push(destination_warehouse_id);
    }

    updateQuery += ' WHERE package_id = ?';
    updateParams.push(id);

    // Update package
    await db.query(updateQuery, updateParams);

    // Insert tracker entry
    await db.query(
      `INSERT INTO package_tracker (package_id, warehouse_id, status, notes, created_by)
       VALUES (?, ?, ?, ?, ?)`,
      [id, req.user.warehouse_id, newStatus, `Ditugaskan ke ${assignedUser[0].nama}`, req.user.user_id]
    );

    const [rows] = await db.query(
      `SELECT p.*,
              wc.nama_gudang AS current_warehouse_name,
              wd.nama_gudang AS destination_warehouse_name,
              u.nama AS assigned_user_name,
              u.role AS assigned_user_role
       FROM packages p
       LEFT JOIN warehouses wc ON p.current_warehouse_id = wc.warehouse_id
       LEFT JOIN warehouses wd ON p.destination_warehouse_id = wd.warehouse_id
       LEFT JOIN users u ON p.assigned_user_id = u.user_id
       WHERE p.package_id = ?`,
      [id]
    );

    return successResponse(res, rows[0], `Paket berhasil ditugaskan ke ${assignedUser[0].nama}`);
  } catch (error) {
    console.error('assignPackage error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

module.exports = {
  getPackages,
  getPackageById,
  trackByResi,
  createPackage,
  updatePackage,
  deletePackage,
  updateStatus,
  assignPackage
};
