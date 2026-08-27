// routes/payments.js
const router = require('express').Router();
const ctrl = require('../controllers/paymentController');
const auth = require('../middleware/auth');

router.post('/create-order', auth, ctrl.createPaymentOrder);
router.post('/verify', auth, ctrl.verifyPayment);
router.get('/:order_id', auth, ctrl.getPaymentStatus);
router.post('/refund', auth, ctrl.refundPayment);

module.exports = router;
