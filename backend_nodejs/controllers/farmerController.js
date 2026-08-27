// controllers/farmerController.js
const { query } = require('../config/db');
const { v4: uuidv4 } = require('uuid');

// GET /api/farmers/dashboard — Uses the farmer_dashboard_view JSON view
exports.getDashboard = async (req, res, next) => {
  try {
    const result = await query(
      `SELECT dashboard_json FROM farmer_dashboard_view WHERE farmer_id = (SELECT id FROM farmers WHERE user_id = $1)`,
      [req.user.id]
    );
    if (!result.rows.length) return res.status(404).json({ error: 'Farmer profile not found' });
    res.json(result.rows[0].dashboard_json);
  } catch (err) { next(err); }
};

// GET /api/farmers/profile
exports.getProfile = async (req, res, next) => {
  try {
    const result = await query(
      `SELECT f.*, u.full_name, u.phone, u.email, u.profile_image_url FROM farmers f JOIN users u ON f.user_id = u.id WHERE f.user_id = $1`,
      [req.user.id]
    );
    if (!result.rows.length) return res.status(404).json({ error: 'Farmer not found' });
    res.json(result.rows[0]);
  } catch (err) { next(err); }
};

// PUT /api/farmers/profile
exports.updateProfile = async (req, res, next) => {
  try {
    const { farm_name, farm_address, district, state, pincode, land_area_acres, farming_type, organic_certified, bank_account_number, bank_ifsc, bank_name, upi_id } = req.body;
    await query(
      `UPDATE farmers SET farm_name = COALESCE($1, farm_name), farm_address = COALESCE($2, farm_address),
       district = COALESCE($3, district), state = COALESCE($4, state), pincode = COALESCE($5, pincode),
       land_area_acres = COALESCE($6, land_area_acres), farming_type = COALESCE($7, farming_type),
       organic_certified = COALESCE($8, organic_certified), bank_account_number = COALESCE($9, bank_account_number),
       bank_ifsc = COALESCE($10, bank_ifsc), bank_name = COALESCE($11, bank_name), upi_id = COALESCE($12, upi_id)
       WHERE user_id = $13`,
      [farm_name, farm_address, district, state, pincode, land_area_acres, farming_type, organic_certified, bank_account_number, bank_ifsc, bank_name, upi_id, req.user.id]
    );
    res.json({ message: 'Farmer profile updated' });
  } catch (err) { next(err); }
};

// GET /api/farmers/orders — All orders containing this farmer's products
exports.getFarmerOrders = async (req, res, next) => {
  try {
    const result = await query(`
      SELECT
        o.id, o.order_number, o.status, o.created_at,
        json_build_object('name', u.full_name, 'phone', u.phone) AS customer,
        json_agg(json_build_object(
          'product_name', oi.product_name, 'quantity', oi.quantity,
          'unit', oi.unit, 'line_total', oi.line_total
        )) AS items,
        SUM(oi.line_total) AS farmer_subtotal
      FROM order_items oi
      JOIN orders o ON oi.order_id = o.id
      JOIN customers c ON o.customer_id = c.id
      JOIN users u ON c.user_id = u.id
      WHERE oi.farmer_id = (SELECT id FROM farmers WHERE user_id = $1)
      GROUP BY o.id, o.order_number, o.status, o.created_at, u.full_name, u.phone
      ORDER BY o.created_at DESC
    `, [req.user.id]);
    res.json(result.rows);
  } catch (err) { next(err); }
};

// PATCH /api/farmers/orders/:id/status
exports.updateOrderStatus = async (req, res, next) => {
  try {
    const { status, note } = req.body;
    const allowed = ['confirmed', 'processing', 'out_for_delivery', 'delivered'];
    if (!allowed.includes(status)) return res.status(400).json({ error: 'Invalid status' });

    await query(`UPDATE orders SET status = $1, updated_at = NOW() WHERE id = $2`, [status, req.params.id]);
    await query(`INSERT INTO order_tracking (id, order_id, status, note) VALUES ($1,$2,$3,$4)`,
      [uuidv4(), req.params.id, status, note || `Updated to ${status}`]);

    if (status === 'delivered') {
      await query(
        `UPDATE farmers SET total_orders_fulfilled = total_orders_fulfilled + 1 WHERE user_id = $1`,
        [req.user.id]
      );
    }

    res.json({ message: `Order status updated to ${status}` });
  } catch (err) { next(err); }
};
