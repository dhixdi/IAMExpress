const { errorResponse } = require('../utils/response');

/**
 * Factory function that returns middleware restricting access
 * to users whose role is included in the allowedRoles array.
 *
 * @param {string[]} allowedRoles — e.g. ['SUPER_ADMIN', 'WAREHOUSE_ADMIN']
 * @returns {import('express').RequestHandler}
 */
const roleMiddleware = (allowedRoles) => {
  return (req, res, next) => {
    if (!req.user || !allowedRoles.includes(req.user.role)) {
      return errorResponse(res, 'Akses ditolak, role tidak memiliki izin', 403);
    }
    next();
  };
};

module.exports = { roleMiddleware };
