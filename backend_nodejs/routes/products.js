// routes/products.js
const router = require('express').Router();
const ctrl = require('../controllers/productController');
const auth = require('../middleware/auth');

router.get('/categories', ctrl.getCategories);
router.get('/', ctrl.getProducts);
router.get('/:id', ctrl.getProductById);
router.post('/', auth, ctrl.createProduct);
router.put('/:id', auth, ctrl.updateProduct);
router.patch('/:id/stock', auth, ctrl.updateStock);

module.exports = router;
