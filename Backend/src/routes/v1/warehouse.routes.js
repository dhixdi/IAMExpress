const express = require('express');
const router = express.Router();
const warehouseController = require('../../controllers/warehouseController');
const { authMiddleware } = require('../../middleware/authMiddleware');
const { roleMiddleware } = require('../../middleware/roleMiddleware');

router.get('/', authMiddleware, warehouseController.getWarehouses);
router.get('/:id', authMiddleware, warehouseController.getWarehouseById);
router.post('/', authMiddleware, roleMiddleware(['SUPER_ADMIN']), warehouseController.createWarehouse);
router.put('/:id', authMiddleware, roleMiddleware(['SUPER_ADMIN']), warehouseController.updateWarehouse);
router.delete('/:id', authMiddleware, roleMiddleware(['SUPER_ADMIN']), warehouseController.deleteWarehouse);

module.exports = router;
