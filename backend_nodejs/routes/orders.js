// routes/orders.js
const router = require('express').Router();
const ctrl = require('../controllers/orderController');
const auth = require('../middleware/auth');

// Cart
router.get('/cart', auth, ctrl.getCart);
router.post('/cart', auth, ctrl.addToCart);
router.delete('/cart/:product_id', auth, ctrl.removeFromCart);
router.delete('/cart', auth, ctrl.clearCart);

// Orders
router.post('/', auth, ctrl.placeOrder);
router.get('/', auth, ctrl.getOrders);
router.get('/:id', auth, ctrl.getOrderById);
router.patch('/:id/cancel', auth, ctrl.cancelOrder);
router.get('/:id/invoice', auth, ctrl.downloadInvoice);

module.exports = router;
