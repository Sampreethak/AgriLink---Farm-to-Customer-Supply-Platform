// routes/users.js
const router = require('express').Router();
const ctrl = require('../controllers/userController');
const auth = require('../middleware/auth');

router.get('/profile', auth, ctrl.getProfile);
router.put('/profile', auth, ctrl.updateProfile);
router.get('/addresses', auth, ctrl.getAddresses);
router.post('/addresses', auth, ctrl.addAddress);
router.put('/addresses/:id', auth, ctrl.updateAddress);
router.delete('/addresses/:id', auth, ctrl.deleteAddress);
router.get('/notifications', auth, ctrl.getNotifications);
router.patch('/notifications/:id/read', auth, ctrl.markNotificationRead);

module.exports = router;
