const express = require('express');
const router = express.Router();
const userController = require('../../controllers/userController');
const { authMiddleware } = require('../../middleware/authMiddleware');
const { roleMiddleware } = require('../../middleware/roleMiddleware');

// /me routes MUST be defined BEFORE /:id routes to avoid conflict
router.patch('/me/password', authMiddleware, userController.changePassword);
router.patch('/me/photo', authMiddleware, userController.updatePhoto);
router.patch('/me/biometrics', authMiddleware, userController.updateBiometrics);

// Collection routes
router.get('/', authMiddleware, roleMiddleware(['SUPER_ADMIN', 'WAREHOUSE_ADMIN']), userController.getUsers);
router.post('/', authMiddleware, roleMiddleware(['SUPER_ADMIN']), userController.createUser);

// /:id routes
router.get('/:id', authMiddleware, userController.getUserById);
router.put('/:id', authMiddleware, userController.updateUser);
router.delete('/:id', authMiddleware, roleMiddleware(['SUPER_ADMIN']), userController.deleteUser);
router.patch('/:id/role', authMiddleware, roleMiddleware(['SUPER_ADMIN']), userController.changeRole);

module.exports = router;
