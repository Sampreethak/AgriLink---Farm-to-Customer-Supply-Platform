// controllers/userController.js
const { query } = require('../config/db');
const { v4: uuidv4 } = require('uuid');

// GET /api/users/profile
exports.getProfile = async (req, res, next) => {
  try {
    const result = await query(`
      SELECT u.id, u.full_name, u.email, u.phone, u.role, u.profile_image_url, u.language_pref, u.is_verified, u.created_at
      FROM users u WHERE u.id = $1
    `, [req.user.id]);

    if (!result.rows.length) return res.status(404).json({ error: 'User not found' });
    res.json(result.rows[0]);
  } catch (err) { next(err); }
};

// PUT /api/users/profile
exports.updateProfile = async (req, res, next) => {
  try {
    const { full_name, email, language_pref, profile_image_url } = req.body;
    await query(
      `UPDATE users SET full_name = COALESCE($1, full_name), email = COALESCE($2, email),
       language_pref = COALESCE($3, language_pref), profile_image_url = COALESCE($4, profile_image_url),
       updated_at = NOW() WHERE id = $5`,
      [full_name, email, language_pref, profile_image_url, req.user.id]
    );
    res.json({ message: 'Profile updated' });
  } catch (err) { next(err); }
};

// GET /api/users/addresses
exports.getAddresses = async (req, res, next) => {
  try {
    const result = await query(
      `SELECT * FROM addresses WHERE user_id = $1 ORDER BY is_default DESC, label`,
      [req.user.id]
    );
    res.json(result.rows);
  } catch (err) { next(err); }
};

// POST /api/users/addresses
exports.addAddress = async (req, res, next) => {
  try {
    const { label, full_address, city, district, state, pincode, latitude, longitude, is_default } = req.body;
    if (!full_address) return res.status(400).json({ error: 'full_address is required' });

    if (is_default) {
      await query(`UPDATE addresses SET is_default = false WHERE user_id = $1`, [req.user.id]);
    }

    const id = uuidv4();
    await query(
      `INSERT INTO addresses (id, user_id, label, full_address, city, district, state, pincode, latitude, longitude, is_default)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)`,
      [id, req.user.id, label || 'Home', full_address, city, district, state, pincode, latitude, longitude, is_default || false]
    );
    res.status(201).json({ id, message: 'Address added' });
  } catch (err) { next(err); }
};

// PUT /api/users/addresses/:id
exports.updateAddress = async (req, res, next) => {
  try {
    const { label, full_address, city, district, state, pincode, is_default } = req.body;
    if (is_default) {
      await query(`UPDATE addresses SET is_default = false WHERE user_id = $1`, [req.user.id]);
    }
    await query(
      `UPDATE addresses SET label = COALESCE($1, label), full_address = COALESCE($2, full_address),
       city = COALESCE($3, city), district = COALESCE($4, district), state = COALESCE($5, state),
       pincode = COALESCE($6, pincode), is_default = COALESCE($7, is_default)
       WHERE id = $8 AND user_id = $9`,
      [label, full_address, city, district, state, pincode, is_default, req.params.id, req.user.id]
    );
    res.json({ message: 'Address updated' });
  } catch (err) { next(err); }
};

// DELETE /api/users/addresses/:id
exports.deleteAddress = async (req, res, next) => {
  try {
    await query(`DELETE FROM addresses WHERE id = $1 AND user_id = $2`, [req.params.id, req.user.id]);
    res.json({ message: 'Address deleted' });
  } catch (err) { next(err); }
};

// GET /api/users/notifications
exports.getNotifications = async (req, res, next) => {
  try {
    const result = await query(
      `SELECT * FROM notifications WHERE user_id = $1 ORDER BY created_at DESC LIMIT 50`,
      [req.user.id]
    );
    res.json(result.rows);
  } catch (err) { next(err); }
};

// PATCH /api/users/notifications/:id/read
exports.markNotificationRead = async (req, res, next) => {
  try {
    await query(`UPDATE notifications SET is_read = true WHERE id = $1 AND user_id = $2`, [req.params.id, req.user.id]);
    res.json({ message: 'Marked as read' });
  } catch (err) { next(err); }
};
