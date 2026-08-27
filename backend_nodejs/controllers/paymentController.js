// controllers/paymentController.js
const { query } = require('../config/db');
const { v4: uuidv4 } = require('uuid');
const crypto = require('crypto');

function getRazorpay() {
  const Razorpay = require('razorpay');
  return new Razorpay({
    key_id: process.env.RAZORPAY_KEY_ID,
    key_secret: process.env.RAZORPAY_KEY_SECRET,
  });
}

// POST /api/payments/create-order
exports.createPaymentOrder = async (req, res, next) => {
  try {
    const { order_id } = req.body;
    const result = await query(`SELECT id, total_amount, order_number FROM orders WHERE id = $1`, [order_id]);
    if (!result.rows.length) return res.status(404).json({ error: 'Order not found' });
    const order = result.rows[0];

    const razorpay = getRazorpay();
    const rzpOrder = await razorpay.orders.create({
      amount: Math.round(parseFloat(order.total_amount) * 100), // paise
      currency: 'INR',
      receipt: order.order_number,
      notes: { agrilink_order_id: order_id },
    });

    await query(
      `INSERT INTO payments (id, order_id, razorpay_order_id, amount, status)
       VALUES ($1,$2,$3,$4,'pending')`,
      [uuidv4(), order_id, rzpOrder.id, order.total_amount]
    );

    res.json({
      razorpay_order_id: rzpOrder.id,
      amount: rzpOrder.amount,
      currency: rzpOrder.currency,
      key_id: process.env.RAZORPAY_KEY_ID,
    });
  } catch (err) { next(err); }
};

// POST /api/payments/verify
exports.verifyPayment = async (req, res, next) => {
  try {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature, order_id, method } = req.body;

    // Verify signature
    const body = razorpay_order_id + '|' + razorpay_payment_id;
    const expectedSignature = crypto.createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(body).digest('hex');

    if (expectedSignature !== razorpay_signature) {
      return res.status(400).json({ error: 'Payment verification failed: invalid signature' });
    }

    // Update payment record
    await query(
      `UPDATE payments SET razorpay_payment_id = $1, razorpay_signature = $2, status = 'paid', method = $3, paid_at = NOW()
       WHERE razorpay_order_id = $4`,
      [razorpay_payment_id, razorpay_signature, method || 'upi', razorpay_order_id]
    );

    // Update order status
    await query(`UPDATE orders SET status = 'confirmed', updated_at = NOW() WHERE id = $1`, [order_id]);
    await query(`INSERT INTO order_tracking (id, order_id, status, note) VALUES ($1,$2,'confirmed','Payment confirmed')`,
      [uuidv4(), order_id]);

    res.json({ message: 'Payment verified successfully' });
  } catch (err) { next(err); }
};

// GET /api/payments/:order_id
exports.getPaymentStatus = async (req, res, next) => {
  try {
    const result = await query(
      `SELECT id, razorpay_order_id, razorpay_payment_id, amount, status, method, paid_at FROM payments WHERE order_id = $1 ORDER BY created_at DESC LIMIT 1`,
      [req.params.order_id]
    );
    if (!result.rows.length) return res.status(404).json({ error: 'Payment not found' });
    res.json(result.rows[0]);
  } catch (err) { next(err); }
};

// POST /api/payments/refund
exports.refundPayment = async (req, res, next) => {
  try {
    const { order_id, amount } = req.body;
    const payResult = await query(`SELECT razorpay_payment_id, amount FROM payments WHERE order_id = $1 AND status = 'paid'`, [order_id]);
    if (!payResult.rows.length) return res.status(404).json({ error: 'No paid payment found for this order' });

    const razorpay = getRazorpay();
    const refund = await razorpay.payments.refund(payResult.rows[0].razorpay_payment_id, {
      amount: Math.round((amount || payResult.rows[0].amount) * 100),
    });

    await query(`UPDATE payments SET status = 'refunded', refund_id = $1, refund_amount = $2 WHERE order_id = $3`,
      [refund.id, amount || payResult.rows[0].amount, order_id]);
    await query(`UPDATE orders SET status = 'refunded', updated_at = NOW() WHERE id = $1`, [order_id]);

    res.json({ message: 'Refund initiated', refund_id: refund.id });
  } catch (err) { next(err); }
};
