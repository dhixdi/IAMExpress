const express = require('express');
const router = express.Router();

router.use('/auth', require('./auth.routes'));
router.use('/users', require('./user.routes'));
router.use('/warehouses', require('./warehouse.routes'));
router.use('/packages', require('./package.routes'));
router.use('/dashboard', require('./dashboard.routes'));
router.use('/ai', require('./ai.routes'));

module.exports = router;
