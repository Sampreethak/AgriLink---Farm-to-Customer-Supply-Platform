// controllers/authController.js
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const { query } = require('../config/db');

// ─── Helper: generate tokens ───────────────────────────────────────────────
function generateTokens(user) {
  const payload = { id: user.id, role: user.role, phone: user.phone };
  const token = jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_ACCESS_EXPIRES_IN || '24h',
  });
  const refreshToken = jwt.sign(payload, process.env.JWT_REFRESH_SECRET, {
    expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d',
  });
  return { token, refreshToken };
}

// ─── OTP helper (mock or Twilio) ───────────────────────────────────────────
async function sendOTPMessage(phone, otp) {
  if (process.env.TWILIO_MOCK_OTP === 'true') {
    console.log(`[MOCK OTP] Phone: ${phone} → OTP: ${otp}`);
    return true;
  }
  const twilio = require('twilio')(
    process.env.TWILIO_ACCOUNT_SID,
    process.env.TWILIO_AUTH_TOKEN
  );
  await twilio.messages.create({
    body: `Your AgriLink OTP is: ${otp}. Valid for ${process.env.OTP_EXPIRY_MINUTES || 10} minutes.`,
    from: process.env.TWILIO_PHONE_NUMBER,
    to: `+91${phone}`,
  });
  return true;
}

function generateOTP() {
  if (process.env.TWILIO_MOCK_OTP === 'true') {
    return process.env.TWILIO_MOCK_OTP_CODE || '123456';
  }
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// ─── POST /api/auth/send-otp ───────────────────────────────────────────────
exports.sendOTP = async (req, res, next) => {
  try {
    const { phone, purpose } = req.body;
    if (!phone || !purpose) return res.status(400).json({ error: 'Phone and purpose required' });

    const otp = generateOTP();
    const expiresAt = new Date(Date.now() + (parseInt(process.env.OTP_EXPIRY_MINUTES) || 10) * 60 * 1000);

    await query(
      `INSERT INTO otp_logs (id, phone, otp_code, purpose, expires_at)
       VALUES ($1, $2, $3, $4, $5)`,
      [uuidv4(), phone, otp, purpose, expiresAt]
    );

    await sendOTPMessage(phone, otp);
    res.json({ message: 'OTP sent successfully', mock: process.env.TWILIO_MOCK_OTP === 'true' });
  } catch (err) {
    next(err);
  }
};

// ─── POST /api/auth/verify-otp ─────────────────────────────────────────────
exports.verifyOTP = async (req, res, next) => {
  try {
    const { phone, code, purpose } = req.body;
    if (!phone || !code) return res.status(400).json({ error: 'Phone and OTP code required' });

    const result = await query(
      `SELECT * FROM otp_logs
       WHERE phone = $1 AND purpose = $2 AND is_used = false
         AND expires_at > NOW()
       ORDER BY created_at DESC LIMIT 1`,
      [phone, purpose]
    );

    if (!result.rows.length) {
      return res.status(400).json({ error: 'OTP expired or not found' });
    }

    const otpRecord = result.rows[0];
    if (otpRecord.otp_code !== code) {
      await query(`UPDATE otp_logs SET attempt_count = attempt_count + 1 WHERE id = $1`, [otpRecord.id]);
      return res.status(400).json({ error: 'Invalid OTP' });
    }

    // Mark OTP as used
    await query(`UPDATE otp_logs SET is_used = true WHERE id = $1`, [otpRecord.id]);

    // Find or create the user
    let userResult = await query(`SELECT * FROM users WHERE phone = $1`, [phone]);
    let user = userResult.rows[0];

    if (!user) {
      const userId = uuidv4();
      await query(
        `INSERT INTO users (id, full_name, phone, role, is_verified) VALUES ($1, $2, $3, 'customer', true)`,
        [userId, `User_${phone.slice(-4)}`, phone]
      );
      userResult = await query(`SELECT * FROM users WHERE id = $1`, [userId]);
      user = userResult.rows[0];
    } else {
      await query(`UPDATE users SET is_verified = true WHERE id = $1`, [user.id]);
    }

    const { token, refreshToken } = generateTokens(user);
    res.json({ token, refreshToken, user: { id: user.id, full_name: user.full_name, phone: user.phone, role: user.role } });
  } catch (err) {
    next(err);
  }
};

// ─── POST /api/auth/register ───────────────────────────────────────────────
exports.register = async (req, res, next) => {
  try {
    const { full_name, phone, role, email, password } = req.body;
    if (!full_name || !phone) return res.status(400).json({ error: 'Name and phone required' });

    const existing = await query(`SELECT id FROM users WHERE phone = $1`, [phone]);
    if (existing.rows.length) return res.status(409).json({ error: 'Phone number already registered' });

    const password_hash = password ? await bcrypt.hash(password, 10) : null;
    const userId = uuidv4();
    await query(
      `INSERT INTO users (id, full_name, email, phone, role, password_hash) VALUES ($1,$2,$3,$4,$5,$6)`,
      [userId, full_name, email || null, phone, role || 'customer', password_hash]
    );

    // Create role-specific record
    if (role === 'farmer') {
      await query(`INSERT INTO farmers (id, user_id, farm_name, farm_address) VALUES ($1,$2,$3,$4)`,
        [uuidv4(), userId, `${full_name}'s Farm`, 'To be updated']);
    } else if (role === 'customer') {
      await query(`INSERT INTO customers (id, user_id) VALUES ($1,$2)`, [uuidv4(), userId]);
    } else if (role === 'delivery_partner') {
      await query(`INSERT INTO delivery_partners (id, user_id) VALUES ($1,$2)`, [uuidv4(), userId]);
    } else if (role === 'aggregator') {
      await query(`INSERT INTO aggregators (id, user_id, company_name) VALUES ($1,$2,$3)`,
        [uuidv4(), userId, `${full_name} Aggregator`]);
    }

    res.status(201).json({ message: 'Registration successful. Please verify your phone with OTP.' });
  } catch (err) {
    next(err);
  }
};

// ─── POST /api/auth/login ──────────────────────────────────────────────────
exports.login = async (req, res, next) => {
  try {
    const { phone, email, password } = req.body;
    const identifier = phone || email;
    if (!identifier) return res.status(400).json({ error: 'Phone or email required' });

    const result = await query(
      `SELECT * FROM users WHERE phone = $1 OR email = $1`,
      [identifier]
    );
    const user = result.rows[0];
    if (!user) return res.status(401).json({ error: 'User not found' });

    if (password) {
      if (!user.password_hash) return res.status(401).json({ error: 'No password set — use OTP login' });
      const valid = await bcrypt.compare(password, user.password_hash);
      if (!valid) return res.status(401).json({ error: 'Incorrect password' });
    }

    const { token, refreshToken } = generateTokens(user);
    res.json({ token, refreshToken, user: { id: user.id, full_name: user.full_name, phone: user.phone, role: user.role } });
  } catch (err) {
    next(err);
  }
};

// ─── POST /api/auth/logout ─────────────────────────────────────────────────
exports.logout = async (req, res) => {
  res.json({ message: 'Logged out successfully' });
};
