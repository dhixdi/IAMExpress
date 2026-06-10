const jwt = require('jsonwebtoken');
const { errorResponse } = require('../utils/response');
const { isBlacklisted } = require('../controllers/authController');

/**
 * Authentication middleware.
 * Extracts the Bearer token, verifies it, checks the blacklist,
 * and attaches the decoded payload to req.user.
 */
const authMiddleware = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return errorResponse(res, 'Token tidak ditemukan', 401);
    }

    const token = authHeader.split(' ')[1];

    if (isBlacklisted(token)) {
      return errorResponse(res, 'Token sudah tidak valid', 401);
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;

    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return errorResponse(res, 'Token sudah kadaluarsa', 401);
    }
    if (error.name === 'JsonWebTokenError') {
      return errorResponse(res, 'Token tidak valid', 401);
    }
    return errorResponse(res, 'Gagal melakukan autentikasi', 500);
  }
};

module.exports = { authMiddleware };
