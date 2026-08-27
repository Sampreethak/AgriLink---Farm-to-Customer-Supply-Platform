// routes/auth.js
const router = require('express').Router();
const ctrl = require('../controllers/authController');
const auth = require('../middleware/auth');

router.post('/send-otp', ctrl.sendOTP);
router.post('/verify-otp', ctrl.verifyOTP);
router.post('/register', ctrl.register);
router.post('/login', ctrl.login);
router.post('/logout', auth, ctrl.logout);

module.exports = router;
