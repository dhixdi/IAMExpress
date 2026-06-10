const db = require('../config/db');
const { successResponse, errorResponse } = require('../utils/response');
const { chatWithGemini } = require('../services/geminiService');

const chat = async (req, res) => {
  try {
    const { message } = req.body;

    if (!message || !message.trim()) {
      return errorResponse(res, 'Message harus diisi', 400);
    }

    // Build context from user data
    const context = {
      role: req.user.role,
      warehouse_id: req.user.warehouse_id,
      warehouse_name: null
    };

    // Get warehouse name if user has one
    if (req.user.warehouse_id) {
      const [warehouse] = await db.query(
        'SELECT nama_gudang FROM warehouses WHERE warehouse_id = ?',
        [req.user.warehouse_id]
      );
      if (warehouse.length > 0) {
        context.warehouse_name = warehouse[0].nama_gudang;
      }
    }

    const response = await chatWithGemini(message.trim(), context);

    return successResponse(res, { response }, 'AI response berhasil');
  } catch (error) {
    console.error('AI chat error:', error);
    return errorResponse(res, 'Internal server error', 500);
  }
};

module.exports = { chat };
