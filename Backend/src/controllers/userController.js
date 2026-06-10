const bcrypt = require('bcrypt');
const db = require('../config/db');
const { successResponse, errorResponse } = require('../utils/response');
const { getPaginationParams, getSortParams, buildPaginationMeta } = require('../utils/pagination');

const VALID_ROLES = ['SUPER_ADMIN', 'WAREHOUSE_ADMIN', 'LINEHAUL', 'COURIER'];

const getUsers = async (req, res) => {
  try {
    if (req.user.role !== 'SUPER_ADMIN') {
      return errorResponse(res, 'Akses ditolak', 403);
    }

    const { page, limit, offset } = getPaginationParams(req.query);
    const { sort_by, order } = getSortParams(req.query, ['nama', 'email', 'role', 'created_at'], 'created_at');
    const { q, role, warehouse_id } = req.query;

    let whereClause = '1=1';
    const params = [];

    if (q) {
      whereClause += ' AND (u.nama LIKE ? OR u.email LIKE ?)';
      params.push(`%${q}%`, `%${q}%`);
    }

    if (role) {
      whereClause += ' AND u.role = ?';
      params.push(role);
    }

    if (warehouse_id) {
      whereClause += ' AND u.warehouse_id = ?';
      params.push(warehouse_id);
    }

    const [countResult] = await db.query(
      `SELECT COUNT(*) AS total FROM users u WHERE ${whereClause}`,
      params
    );
    const total = countResult[0].total;

    const [rows] = await db.query(
      `SELECT u.user_id, u.email, u.nama, u.role, u.warehouse_id, u.photo_url,
              u.biometrics_enabled, u.biometrics_type, u.created_at,
              w.nama_gudang AS warehouse_name
       FROM users u
       LEFT JOIN warehouses w ON u.warehouse_id = w.warehouse_id
       WHERE ${whereClause}
       ORDER BY u.${sort_by} ${order}
       LIMIT ? OFFSET ?`,
      [...params, limit, offset]
    );

    const meta = buildPaginationMeta(page, limit, total);
    return successResponse(res, rows, 'Data users berhasil diambil', 200, meta);
  } catch (error) {
    console.error('getUsers error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

const getUserById = async (req, res) => {
  try {
    const { id } = req.params;

    if (req.user.role !== 'SUPER_ADMIN' && req.user.user_id !== parseInt(id)) {
      return errorResponse(res, 'Akses ditolak', 403);
    }

    const [rows] = await db.query(
      `SELECT u.user_id, u.email, u.nama, u.role, u.warehouse_id, u.photo_url,
              u.biometrics_enabled, u.biometrics_type, u.created_at,
              w.nama_gudang AS warehouse_name
       FROM users u
       LEFT JOIN warehouses w ON u.warehouse_id = w.warehouse_id
       WHERE u.user_id = ?`,
      [id]
    );

    if (rows.length === 0) {
      return errorResponse(res, 'User tidak ditemukan', 404);
    }

    return successResponse(res, rows[0], 'Data user berhasil diambil');
  } catch (error) {
    console.error('getUserById error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

const createUser = async (req, res) => {
  try {
    if (req.user.role !== 'SUPER_ADMIN') {
      return errorResponse(res, 'Akses ditolak', 403);
    }

    const { email, password, nama, role, warehouse_id } = req.body;

    if (!email || !password || !nama || !role) {
      return errorResponse(res, 'Email, password, nama, dan role harus diisi', 400);
    }

    if (!VALID_ROLES.includes(role)) {
      return errorResponse(res, `Role tidak valid. Pilihan: ${VALID_ROLES.join(', ')}`, 400);
    }

    if (role !== 'SUPER_ADMIN' && !warehouse_id) {
      return errorResponse(res, 'Warehouse ID harus diisi untuk role ini', 400);
    }

    const [existing] = await db.query('SELECT user_id FROM users WHERE email = ?', [email]);
    if (existing.length > 0) {
      return errorResponse(res, 'Email sudah terdaftar', 409);
    }

    const password_hash = await bcrypt.hash(password, 10);
    const finalWarehouseId = role === 'SUPER_ADMIN' ? null : warehouse_id;

    const [result] = await db.query(
      `INSERT INTO users (email, password_hash, nama, role, warehouse_id) VALUES (?, ?, ?, ?, ?)`,
      [email, password_hash, nama, role, finalWarehouseId]
    );

    const [newUser] = await db.query(
      `SELECT user_id, email, nama, role, warehouse_id, photo_url, created_at FROM users WHERE user_id = ?`,
      [result.insertId]
    );

    return successResponse(res, newUser[0], 'User berhasil dibuat', 201);
  } catch (error) {
    console.error('createUser error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

const updateUser = async (req, res) => {
  try {
    const { id } = req.params;

    if (req.user.role !== 'SUPER_ADMIN' && req.user.user_id !== parseInt(id)) {
      return errorResponse(res, 'Akses ditolak', 403);
    }

    const { nama, photo_url } = req.body;
    const updates = [];
    const values = [];

    if (nama !== undefined) {
      updates.push('nama = ?');
      values.push(nama);
    }

    if (photo_url !== undefined) {
      updates.push('photo_url = ?');
      values.push(photo_url);
    }

    if (updates.length === 0) {
      return errorResponse(res, 'Tidak ada data yang diupdate', 400);
    }

    values.push(id);
    await db.query(`UPDATE users SET ${updates.join(', ')} WHERE user_id = ?`, values);

    const [rows] = await db.query(
      `SELECT user_id, email, nama, role, warehouse_id, photo_url, created_at FROM users WHERE user_id = ?`,
      [id]
    );

    if (rows.length === 0) {
      return errorResponse(res, 'User tidak ditemukan', 404);
    }

    return successResponse(res, rows[0], 'User berhasil diupdate');
  } catch (error) {
    console.error('updateUser error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

const deleteUser = async (req, res) => {
  try {
    if (req.user.role !== 'SUPER_ADMIN') {
      return errorResponse(res, 'Akses ditolak', 403);
    }

    const { id } = req.params;

    if (req.user.user_id === parseInt(id)) {
      return errorResponse(res, 'Tidak dapat menghapus akun sendiri', 400);
    }

    const [existing] = await db.query('SELECT user_id FROM users WHERE user_id = ?', [id]);
    if (existing.length === 0) {
      return errorResponse(res, 'User tidak ditemukan', 404);
    }

    await db.query('DELETE FROM users WHERE user_id = ?', [id]);

    return successResponse(res, null, 'User berhasil dihapus', 204);
  } catch (error) {
    console.error('deleteUser error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

const changeRole = async (req, res) => {
  try {
    if (req.user.role !== 'SUPER_ADMIN') {
      return errorResponse(res, 'Akses ditolak', 403);
    }

    const { id } = req.params;
    const { role } = req.body;

    if (!role || !VALID_ROLES.includes(role)) {
      return errorResponse(res, `Role tidak valid. Pilihan: ${VALID_ROLES.join(', ')}`, 400);
    }

    const [existing] = await db.query('SELECT user_id FROM users WHERE user_id = ?', [id]);
    if (existing.length === 0) {
      return errorResponse(res, 'User tidak ditemukan', 404);
    }

    if (role === 'SUPER_ADMIN') {
      await db.query('UPDATE users SET role = ?, warehouse_id = NULL WHERE user_id = ?', [role, id]);
    } else {
      await db.query('UPDATE users SET role = ? WHERE user_id = ?', [role, id]);
    }

    const [rows] = await db.query(
      `SELECT user_id, email, nama, role, warehouse_id, created_at FROM users WHERE user_id = ?`,
      [id]
    );

    return successResponse(res, rows[0], 'Role berhasil diubah');
  } catch (error) {
    console.error('changeRole error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

const changePassword = async (req, res) => {
  try {
    const { old_password, new_password } = req.body;

    if (!old_password || !new_password) {
      return errorResponse(res, 'Password lama dan baru harus diisi', 400);
    }

    const [rows] = await db.query('SELECT password_hash FROM users WHERE user_id = ?', [req.user.user_id]);

    if (rows.length === 0) {
      return errorResponse(res, 'User tidak ditemukan', 404);
    }

    const isValid = await bcrypt.compare(old_password, rows[0].password_hash);
    if (!isValid) {
      return errorResponse(res, 'Password lama salah', 400);
    }

    const password_hash = await bcrypt.hash(new_password, 10);
    await db.query('UPDATE users SET password_hash = ? WHERE user_id = ?', [password_hash, req.user.user_id]);

    return successResponse(res, null, 'Password berhasil diubah');
  } catch (error) {
    console.error('changePassword error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

const updatePhoto = async (req, res) => {
  try {
    const { photo_url } = req.body;

    if (!photo_url) {
      return errorResponse(res, 'Photo URL harus diisi', 400);
    }

    await db.query('UPDATE users SET photo_url = ? WHERE user_id = ?', [photo_url, req.user.user_id]);

    return successResponse(res, { photo_url }, 'Foto berhasil diupdate');
  } catch (error) {
    console.error('updatePhoto error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

const updateBiometrics = async (req, res) => {
  try {
    const { biometrics_enabled, biometrics_type } = req.body;

    if (biometrics_enabled === undefined) {
      return errorResponse(res, 'biometrics_enabled harus diisi', 400);
    }

    await db.query(
      'UPDATE users SET biometrics_enabled = ?, biometrics_type = ? WHERE user_id = ?',
      [biometrics_enabled, biometrics_type || null, req.user.user_id]
    );

    return successResponse(res, { biometrics_enabled, biometrics_type: biometrics_type || null }, 'Biometrics berhasil diupdate');
  } catch (error) {
    console.error('updateBiometrics error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

module.exports = {
  getUsers,
  getUserById,
  createUser,
  updateUser,
  deleteUser,
  changeRole,
  changePassword,
  updatePhoto,
  updateBiometrics
};
