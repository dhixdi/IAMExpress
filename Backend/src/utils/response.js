/**
 * Send a success response.
 *
 * @param {import('express').Response} res
 * @param {*}      data       — payload (default null)
 * @param {string} message    — human-readable message
 * @param {number} statusCode — HTTP status (default 200)
 * @param {object} meta       — pagination meta (optional)
 */
const successResponse = (
  res,
  data = null,
  message = 'Berhasil',
  statusCode = 200,
  meta = null,
) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
    ...(meta && { meta }),
  });
};

/**
 * Send an error response.
 *
 * @param {import('express').Response} res
 * @param {string} message    — human-readable error message
 * @param {number} statusCode — HTTP status (default 500)
 * @param {*}      errors     — validation errors (optional)
 */
const errorResponse = (
  res,
  message = 'Terjadi kesalahan',
  statusCode = 500,
  errors = null,
) => {
  return res.status(statusCode).json({
    success: false,
    message,
    ...(errors && { errors }),
  });
};

module.exports = { successResponse, errorResponse };
