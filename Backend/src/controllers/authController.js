const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../config/db');
const { successResponse, errorResponse } = require('../utils/response');

const tokenBlacklist = new Set();

const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return errorResponse(res, 'Email dan password harus diisi', 400);
    }

    const [rows] = await db.query('SELECT * FROM users WHERE email = ?', [email]);

    if (rows.length === 0) {
      return errorResponse(res, 'Email atau password salah', 401);
    }

    const user = rows[0];
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);

    if (!isPasswordValid) {
      return errorResponse(res, 'Email atau password salah', 401);
    }

    const token = jwt.sign(
      {
        user_id: user.user_id,
        email: user.email,
        role: user.role,
        warehouse_id: user.warehouse_id
      },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '24h' }
    );

    return successResponse(res, {
      token,
      user: {
        user_id: user.user_id,
        email: user.email,
        nama: user.nama,
        role: user.role,
        warehouse_id: user.warehouse_id,
        photo_url: user.photo_url
      }
    }, 'Login berhasil');
  } catch (error) {
    console.error('Login error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

const me = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT u.user_id, u.email, u.nama, u.role, u.warehouse_id, u.photo_url, 
              u.biometrics_enabled, u.biometrics_type, u.created_at,
              w.nama_gudang AS warehouse_name
       FROM users u
       LEFT JOIN warehouses w ON u.warehouse_id = w.warehouse_id
       WHERE u.user_id = ?`,
      [req.user.user_id]
    );

    if (rows.length === 0) {
      return errorResponse(res, 'User tidak ditemukan', 404);
    }

    return successResponse(res, rows[0], 'Data user berhasil diambil');
  } catch (error) {
    console.error('Me error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

const logout = async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.split(' ')[1];
      tokenBlacklist.add(token);
    }

    return successResponse(res, null, 'Logout berhasil');
  } catch (error) {
    console.error('Logout error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

module.exports = {
  login,
  me,
  logout,
  addToBlacklist: (token) => tokenBlacklist.add(token),
  isBlacklisted: (token) => tokenBlacklist.has(token)
};
