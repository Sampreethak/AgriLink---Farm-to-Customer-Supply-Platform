// controllers/deliveryController.js
const { query } = require('../config/db');
const { v4: uuidv4 } = require('uuid');

// GET /api/delivery/assignments - Get pending deliveries assigned to this partner
exports.getAssignments = async (req, res, next) => {
  try {
    const dpResult = await query(`SELECT id FROM delivery_partners WHERE user_id = $1`, [req.user.id]);
    if (!dpResult.rows.length) return res.status(403).json({ error: 'Not a delivery partner' });

    const result = await query(`
      SELECT
        o.id, o.order_number, o.status, o.total_amount, o.special_instructions,
        json_build_object('full_address', a.full_address, 'city', a.city,
          'pincode', a.pincode, 'latitude', a.latitude, 'longitude', a.longitude) AS delivery_address,
        json_build_object('name', u.full_name, 'phone', u.phone) AS customer,
        ot.updated_at AS assigned_at
      FROM order_tracking ot
      JOIN orders o ON ot.order_id = o.id
      JOIN customers c ON o.customer_id = c.id
      JOIN users u ON c.user_id = u.id
      LEFT JOIN addresses a ON o.delivery_address_id = a.id
      WHERE ot.delivery_partner_id = $1
        AND o.status NOT IN ('delivered', 'cancelled', 'refunded')
      ORDER BY ot.updated_at DESC
    `, [dpResult.rows[0].id]);

    res.json(result.rows);
  } catch (err) { next(err); }
};

// PATCH /api/delivery/orders/:id/update - Update delivery status
exports.updateDeliveryStatus = async (req, res, next) => {
  try {
    const { status, note, latitude, longitude } = req.body;
    const dpResult = await query(`SELECT id FROM delivery_partners WHERE user_id = $1`, [req.user.id]);
    if (!dpResult.rows.length) return res.status(403).json({ error: 'Not a delivery partner' });

    const allowed = ['out_for_delivery', 'delivered'];
    if (!allowed.includes(status)) return res.status(400).json({ error: 'Invalid delivery status' });

    await query(`UPDATE orders SET status = $1, updated_at = NOW() WHERE id = $2`, [status, req.params.id]);
    await query(
      `INSERT INTO order_tracking (id, order_id, delivery_partner_id, status, note, latitude, longitude)
       VALUES ($1,$2,$3,$4,$5,$6,$7)`,
      [uuidv4(), req.params.id, dpResult.rows[0].id, status, note, latitude, longitude]
    );

    if (status === 'delivered') {
      await query(
        `UPDATE orders SET actual_delivery_date = NOW() WHERE id = $1`,
        [req.params.id]
      );
      await query(
        `UPDATE delivery_partners SET total_deliveries = total_deliveries + 1 WHERE id = $1`,
        [dpResult.rows[0].id]
      );
    }

    res.json({ message: `Delivery status updated to ${status}` });
  } catch (err) { next(err); }
};

// PATCH /api/delivery/location - Update partner location
exports.updateLocation = async (req, res, next) => {
  try {
    const { latitude, longitude } = req.body;
    await query(
      `UPDATE delivery_partners SET current_latitude = $1, current_longitude = $2 WHERE user_id = $3`,
      [latitude, longitude, req.user.id]
    );
    res.json({ message: 'Location updated' });
  } catch (err) { next(err); }
};

// PATCH /api/delivery/availability - Toggle availability
exports.toggleAvailability = async (req, res, next) => {
  try {
    const { is_available } = req.body;
    await query(`UPDATE delivery_partners SET is_available = $1 WHERE user_id = $2`, [is_available, req.user.id]);
    res.json({ message: `Availability set to ${is_available}` });
  } catch (err) { next(err); }
};
