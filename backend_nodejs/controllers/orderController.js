// controllers/orderController.js
const { query } = require('../config/db');
const { v4: uuidv4 } = require('uuid');
const PDFDocument = require('pdfkit');

// ─── Cart ──────────────────────────────────────────────────────────────────

// GET /api/orders/cart
exports.getCart = async (req, res, next) => {
  try {
    const result = await query(`
      SELECT
        ci.id, ci.quantity, ci.added_at,
        json_build_object(
          'id', p.id, 'name', p.name, 'unit', p.unit,
          'price_per_unit', p.price_per_unit, 'stock_quantity', p.stock_quantity,
          'image_urls', p.image_urls, 'is_organic', p.is_organic,
          'farmer_name', u.full_name, 'farm_name', f.farm_name
        ) AS product
      FROM cart_items ci
      JOIN products p ON ci.product_id = p.id
      JOIN farmers f ON p.farmer_id = f.id
      JOIN users u ON f.user_id = u.id
      WHERE ci.user_id = $1
    `, [req.user.id]);

    const items = result.rows;
    const subtotal = items.reduce((sum, item) => sum + (item.quantity * item.product.price_per_unit), 0);
    const deliveryCharge = subtotal >= parseFloat(process.env.FREE_DELIVERY_ABOVE || 500) ? 0 : parseFloat(process.env.DELIVERY_CHARGE_DEFAULT || 40);
    const taxAmount = subtotal * (parseFloat(process.env.GST_RATE || 5) / 100);
    const total = subtotal + deliveryCharge + taxAmount;

    res.json({ items, subtotal, deliveryCharge, taxAmount, total });
  } catch (err) { next(err); }
};

// POST /api/orders/cart
exports.addToCart = async (req, res, next) => {
  try {
    const { product_id, quantity } = req.body;
    if (!product_id || !quantity) return res.status(400).json({ error: 'product_id and quantity required' });

    await query(`
      INSERT INTO cart_items (id, user_id, product_id, quantity)
      VALUES ($1, $2, $3, $4)
      ON CONFLICT (user_id, product_id)
      DO UPDATE SET quantity = $4, added_at = NOW()
    `, [uuidv4(), req.user.id, product_id, quantity]);

    res.json({ message: 'Cart updated' });
  } catch (err) { next(err); }
};

// DELETE /api/orders/cart/:product_id
exports.removeFromCart = async (req, res, next) => {
  try {
    await query(`DELETE FROM cart_items WHERE user_id = $1 AND product_id = $2`, [req.user.id, req.params.product_id]);
    res.json({ message: 'Item removed from cart' });
  } catch (err) { next(err); }
};

// DELETE /api/orders/cart (clear cart)
exports.clearCart = async (req, res, next) => {
  try {
    await query(`DELETE FROM cart_items WHERE user_id = $1`, [req.user.id]);
    res.json({ message: 'Cart cleared' });
  } catch (err) { next(err); }
};

// ─── Orders ────────────────────────────────────────────────────────────────

// POST /api/orders
exports.placeOrder = async (req, res, next) => {
  try {
    const { delivery_address_id, special_instructions, coupon_code, expected_delivery_date } = req.body;

    // Get customer
    const custResult = await query(`SELECT id FROM customers WHERE user_id = $1`, [req.user.id]);
    if (!custResult.rows.length) return res.status(403).json({ error: 'Customer record not found' });
    const customerId = custResult.rows[0].id;

    // Get cart
    const cartResult = await query(`
      SELECT ci.quantity, p.id AS product_id, p.price_per_unit, p.name AS product_name, p.unit,
             f.id AS farmer_id, p.bulk_discount_threshold, p.bulk_discount_percent, p.stock_quantity
      FROM cart_items ci
      JOIN products p ON ci.product_id = p.id
      JOIN farmers f ON p.farmer_id = f.id
      WHERE ci.user_id = $1
    `, [req.user.id]);

    if (!cartResult.rows.length) return res.status(400).json({ error: 'Cart is empty' });

    // Validate stock
    for (const item of cartResult.rows) {
      if (item.quantity > item.stock_quantity) {
        return res.status(400).json({ error: `Insufficient stock for ${item.product_name}` });
      }
    }

    // Compute totals
    let subtotal = 0;
    const orderItems = cartResult.rows.map(item => {
      let discount = 0;
      if (item.bulk_discount_threshold && item.quantity >= item.bulk_discount_threshold) {
        discount = parseFloat(item.bulk_discount_percent || 0);
      }
      const lineTotal = item.quantity * item.price_per_unit * (1 - discount / 100);
      subtotal += lineTotal;
      return { ...item, discount_percent: discount, line_total: lineTotal };
    });

    // Coupon
    let discountAmount = 0;
    let couponId = null;
    if (coupon_code) {
      const couponResult = await query(
        `SELECT * FROM coupons WHERE code = $1 AND is_active = true AND (valid_until IS NULL OR valid_until > NOW()) AND (usage_limit IS NULL OR used_count < usage_limit)`,
        [coupon_code]
      );
      if (couponResult.rows.length) {
        const coupon = couponResult.rows[0];
        if (subtotal >= coupon.min_order_amount) {
          discountAmount = coupon.discount_type === 'percent'
            ? Math.min(subtotal * coupon.discount_value / 100, coupon.max_discount_amount || Infinity)
            : coupon.discount_value;
          couponId = coupon.id;
        }
      }
    }

    const deliveryCharge = subtotal >= parseFloat(process.env.FREE_DELIVERY_ABOVE || 500) ? 0 : parseFloat(process.env.DELIVERY_CHARGE_DEFAULT || 40);
    const taxAmount = subtotal * (parseFloat(process.env.GST_RATE || 5) / 100);
    const totalAmount = subtotal + deliveryCharge - discountAmount + taxAmount;

    // Create order
    const orderId = uuidv4();
    await query(`
      INSERT INTO orders (id, customer_id, delivery_address_id, subtotal, delivery_charge, discount_amount, tax_amount, total_amount, coupon_id, special_instructions, expected_delivery_date)
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
    `, [orderId, customerId, delivery_address_id, subtotal, deliveryCharge, discountAmount, taxAmount, totalAmount, couponId, special_instructions, expected_delivery_date]);

    // Insert order items & update stock
    for (const item of orderItems) {
      await query(`
        INSERT INTO order_items (id, order_id, product_id, farmer_id, product_name, unit, quantity, unit_price, discount_percent, line_total)
        VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
      `, [uuidv4(), orderId, item.product_id, item.farmer_id, item.product_name, item.unit, item.quantity, item.price_per_unit, item.discount_percent, item.line_total]);

      await query(`UPDATE products SET stock_quantity = stock_quantity - $1 WHERE id = $2`, [item.quantity, item.product_id]);
    }

    // Clear cart & update coupon usage
    await query(`DELETE FROM cart_items WHERE user_id = $1`, [req.user.id]);
    if (couponId) await query(`UPDATE coupons SET used_count = used_count + 1 WHERE id = $1`, [couponId]);

    // Add order tracking entry
    await query(`INSERT INTO order_tracking (id, order_id, status) VALUES ($1,$2,'pending')`, [uuidv4(), orderId]);

    // Get order number
    const orderResult = await query(`SELECT order_number, total_amount FROM orders WHERE id = $1`, [orderId]);
    res.status(201).json({ orderId, orderNumber: orderResult.rows[0].order_number, totalAmount, message: 'Order placed successfully' });
  } catch (err) { next(err); }
};

// GET /api/orders
exports.getOrders = async (req, res, next) => {
  try {
    const custResult = await query(`SELECT id FROM customers WHERE user_id = $1`, [req.user.id]);
    if (!custResult.rows.length) return res.json([]);

    const result = await query(`
      SELECT
        o.id, o.order_number, o.status, o.subtotal, o.total_amount, o.created_at,
        o.expected_delivery_date, o.delivery_charge, o.discount_amount, o.tax_amount,
        (SELECT json_agg(json_build_object(
          'product_name', oi.product_name, 'quantity', oi.quantity,
          'unit', oi.unit, 'unit_price', oi.unit_price, 'line_total', oi.line_total
        )) FROM order_items oi WHERE oi.order_id = o.id) AS items,
        (SELECT json_build_object('status', ot.status, 'updated_at', ot.updated_at)
         FROM order_tracking ot WHERE ot.order_id = o.id ORDER BY ot.updated_at DESC LIMIT 1) AS latest_tracking
      FROM orders o
      WHERE o.customer_id = $1
      ORDER BY o.created_at DESC
    `, [custResult.rows[0].id]);

    res.json(result.rows);
  } catch (err) { next(err); }
};

// GET /api/orders/:id
exports.getOrderById = async (req, res, next) => {
  try {
    const result = await query(`
      SELECT o.*,
        (SELECT json_agg(json_build_object(
          'product_name', oi.product_name, 'quantity', oi.quantity,
          'unit', oi.unit, 'unit_price', oi.unit_price, 'line_total', oi.line_total,
          'discount_percent', oi.discount_percent
        )) FROM order_items oi WHERE oi.order_id = o.id) AS items,
        (SELECT json_agg(json_build_object('status', ot.status, 'note', ot.note, 'updated_at', ot.updated_at) ORDER BY ot.updated_at)
         FROM order_tracking ot WHERE ot.order_id = o.id) AS tracking_history,
        (SELECT json_build_object('label', a.label, 'full_address', a.full_address, 'city', a.city)
         FROM addresses a WHERE a.id = o.delivery_address_id) AS delivery_address,
        (SELECT json_build_object('status', p.status, 'method', p.method, 'paid_at', p.paid_at)
         FROM payments p WHERE p.order_id = o.id LIMIT 1) AS payment
      FROM orders o
      WHERE o.id = $1
    `, [req.params.id]);

    if (!result.rows.length) return res.status(404).json({ error: 'Order not found' });
    res.json(result.rows[0]);
  } catch (err) { next(err); }
};

// PATCH /api/orders/:id/cancel
exports.cancelOrder = async (req, res, next) => {
  try {
    const result = await query(`SELECT status FROM orders WHERE id = $1`, [req.params.id]);
    if (!result.rows.length) return res.status(404).json({ error: 'Order not found' });
    if (!['pending','confirmed'].includes(result.rows[0].status)) {
      return res.status(400).json({ error: 'Order cannot be cancelled at this stage' });
    }
    await query(`UPDATE orders SET status = 'cancelled', updated_at = NOW() WHERE id = $1`, [req.params.id]);
    await query(`INSERT INTO order_tracking (id, order_id, status, note) VALUES ($1,$2,'cancelled',$3)`,
      [uuidv4(), req.params.id, req.body.reason || 'Cancelled by customer']);
    res.json({ message: 'Order cancelled' });
  } catch (err) { next(err); }
};

// GET /api/orders/:id/invoice (generate PDF)
exports.downloadInvoice = async (req, res, next) => {
  try {
    const result = await query(`
      SELECT o.*, o.order_number,
        (SELECT json_agg(json_build_object('product_name', oi.product_name, 'quantity', oi.quantity, 'unit', oi.unit, 'unit_price', oi.unit_price, 'line_total', oi.line_total))
         FROM order_items oi WHERE oi.order_id = o.id) AS items,
        u.full_name AS customer_name, u.phone AS customer_phone, u.email AS customer_email,
        a.full_address AS delivery_address
      FROM orders o
      JOIN customers c ON o.customer_id = c.id
      JOIN users u ON c.user_id = u.id
      LEFT JOIN addresses a ON o.delivery_address_id = a.id
      WHERE o.id = $1
    `, [req.params.id]);

    if (!result.rows.length) return res.status(404).json({ error: 'Order not found' });
    const order = result.rows[0];

    const doc = new PDFDocument({ margin: 50 });
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename=invoice-${order.order_number}.pdf`);
    doc.pipe(res);

    // Header
    doc.fontSize(24).fillColor('#2e7d32').text('AgriLink', 50, 50);
    doc.fontSize(10).fillColor('#666').text('Farm Fresh. Delivered Fast.', 50, 80);
    doc.fontSize(18).fillColor('#333').text('INVOICE', 400, 50, { align: 'right' });
    doc.fontSize(10).fillColor('#555').text(`Order: ${order.order_number}`, 400, 80, { align: 'right' });
    doc.text(`Date: ${new Date(order.created_at).toLocaleDateString('en-IN')}`, 400, 95, { align: 'right' });

    doc.moveDown(3);
    doc.fontSize(11).fillColor('#333').text(`Customer: ${order.customer_name}`);
    doc.text(`Phone: ${order.customer_phone}`);
    if (order.delivery_address) doc.text(`Delivery: ${order.delivery_address}`);

    doc.moveDown(1);
    doc.moveTo(50, doc.y).lineTo(550, doc.y).stroke('#ccc');
    doc.moveDown(0.5);

    // Table header
    doc.font('Helvetica-Bold').fontSize(10);
    doc.text('Product', 50, doc.y); doc.text('Qty', 280, doc.y - 12); doc.text('Unit Price', 340, doc.y - 12); doc.text('Total', 460, doc.y - 12);
    doc.moveDown(0.3);
    doc.moveTo(50, doc.y).lineTo(550, doc.y).stroke('#ddd');

    // Table rows
    doc.font('Helvetica').fontSize(10);
    (order.items || []).forEach(item => {
      doc.moveDown(0.3);
      doc.text(`${item.product_name} (${item.unit})`, 50, doc.y);
      doc.text(`${item.quantity}`, 280, doc.y - 12);
      doc.text(`₹${parseFloat(item.unit_price).toFixed(2)}`, 340, doc.y - 12);
      doc.text(`₹${parseFloat(item.line_total).toFixed(2)}`, 460, doc.y - 12);
    });

    doc.moveDown(1);
    doc.moveTo(50, doc.y).lineTo(550, doc.y).stroke('#ccc');
    doc.moveDown(0.5);

    // Totals
    doc.font('Helvetica').fontSize(10).fillColor('#555');
    doc.text(`Subtotal:`, 380, doc.y); doc.text(`₹${parseFloat(order.subtotal).toFixed(2)}`, 480, doc.y - 12, { align: 'right' });
    doc.moveDown(0.3);
    doc.text(`Delivery:`, 380, doc.y); doc.text(`₹${parseFloat(order.delivery_charge).toFixed(2)}`, 480, doc.y - 12, { align: 'right' });
    if (order.discount_amount > 0) {
      doc.moveDown(0.3);
      doc.text(`Discount:`, 380, doc.y); doc.text(`-₹${parseFloat(order.discount_amount).toFixed(2)}`, 480, doc.y - 12, { align: 'right' });
    }
    doc.moveDown(0.3);
    doc.text(`Tax (GST ${process.env.GST_RATE || 5}%):`, 380, doc.y); doc.text(`₹${parseFloat(order.tax_amount).toFixed(2)}`, 480, doc.y - 12, { align: 'right' });
    doc.moveDown(0.5);
    doc.font('Helvetica-Bold').fontSize(12).fillColor('#2e7d32');
    doc.text(`TOTAL:`, 380, doc.y); doc.text(`₹${parseFloat(order.total_amount).toFixed(2)}`, 480, doc.y - 14, { align: 'right' });

    doc.moveDown(3);
    doc.font('Helvetica').fontSize(9).fillColor('#999').text('Thank you for choosing AgriLink – supporting local farmers!', { align: 'center' });

    doc.end();
  } catch (err) { next(err); }
};
