const express = require('express');
const router = express.Router();
const packageController = require('../../controllers/packageController');
const trackerController = require('../../controllers/trackerController');
const { authMiddleware } = require('../../middleware/authMiddleware');
const { roleMiddleware } = require('../../middleware/roleMiddleware');
const { handleDeliveryUpload } = require('../../middleware/uploadMiddleware');

// /track/:resi MUST be defined BEFORE /:id to avoid conflict
router.get('/track/:resi', authMiddleware, packageController.trackByResi);

// Collection routes
router.get('/', authMiddleware, packageController.getPackages);
router.post('/', authMiddleware, roleMiddleware(['WAREHOUSE_ADMIN']), packageController.createPackage);

// /:id routes
router.get('/:id', authMiddleware, packageController.getPackageById);
router.get('/:id/tracker', authMiddleware, trackerController.getTracker);
router.put('/:id', authMiddleware, roleMiddleware(['WAREHOUSE_ADMIN']), packageController.updatePackage);
router.delete('/:id', authMiddleware, roleMiddleware(['SUPER_ADMIN', 'WAREHOUSE_ADMIN']), packageController.deletePackage);
router.patch('/:id/status', authMiddleware, roleMiddleware(['WAREHOUSE_ADMIN', 'LINEHAUL', 'COURIER']), handleDeliveryUpload, packageController.updateStatus);
router.patch('/:id/assign', authMiddleware, roleMiddleware(['WAREHOUSE_ADMIN']), packageController.assignPackage);

module.exports = router;
