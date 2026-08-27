// server.js
require('dotenv').config();
const express = require('express');
const morgan = require('morgan');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();

const app = express();

// Middleware
app.use(cors({ origin: process.env.CORS_ORIGIN || '*', credentials: true }));
app.use(express.json());
app.use(morgan('dev'));

// Serve static dashboard
app.use(express.static(path.join(__dirname, 'public')));

// ==========================================
// SQLite Database Connection
// ==========================================
const dbPath = path.join(__dirname, 'database', 'agrilink_v2.db');
const db = new sqlite3.Database(dbPath, sqlite3.OPEN_READWRITE, (err) => {
  if (err) {
    console.error('⚠️  Could not open SQLite database:', err.message);
    console.error('    Make sure you have run: node setup_sqlite.js');
  } else {
    console.log('✅ SQLite database connected (AgriLink Enterprise v2.0)');
  }
});

// ==========================================
// RATE LIMITER
// ==========================================
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: 'Too many requests from this IP, please try again later.'
});
app.use('/api/auth', authLimiter);

// ==========================================
// HELPER — wrap db.all as a promise
// ==========================================
const dbAll = (sql, params = []) =>
  new Promise((resolve, reject) =>
    db.all(sql, params, (err, rows) => (err ? reject(err) : resolve(rows)))
  );

const dbGet = (sql, params = []) =>
  new Promise((resolve, reject) =>
    db.get(sql, params, (err, row) => (err ? reject(err) : resolve(row)))
  );

// ==========================================
// AUTH ROUTES — /api/auth
// ==========================================

// POST /api/auth/login  (phone or email)
app.post('/api/auth/login', async (req, res) => {
  const { phone, email, password } = req.body;
  try {
    let user = null;
    if (phone) {
      user = await dbGet(
        `SELECT u.*, r.role_name FROM users u JOIN role r ON u.role_id = r.role_id WHERE u.phone = ? LIMIT 1`,
        [phone]
      );
    } else if (email) {
      user = await dbGet(
        `SELECT u.*, r.role_name FROM users u JOIN role r ON u.role_id = r.role_id WHERE u.email = ? LIMIT 1`,
        [email]
      );
    }

    if (!user) {
      // Auto-create a demo user if not found (dev convenience)
      return res.json({
        token: 'demo_jwt_token_agrilink_2026',
        refreshToken: 'demo_refresh_token',
        user: {
          id: 'demo-001',
          full_name: 'Demo User',
          phone: phone || '',
          email: email || '',
          role: 'customer',
        },
      });
    }

    return res.json({
      token: `jwt_${user.user_id}_agrilink`,
      refreshToken: `refresh_${user.user_id}`,
      user: {
        id: user.user_id,
        full_name: user.full_name,
        phone: user.phone,
        email: user.email,
        role: (user.role_name || 'customer').toLowerCase(),
      },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// POST /api/auth/register
app.post('/api/auth/register', async (req, res) => {
  const { full_name, phone, role, email } = req.body;
  try {
    const roleRow = await dbGet(
      `SELECT role_id FROM role WHERE LOWER(role_name) = LOWER(?) LIMIT 1`,
      [role || 'customer']
    );
    const roleId = roleRow ? roleRow.role_id : 1;

    db.run(
      `INSERT INTO users (full_name, phone, email, role_id, is_active, created_at)
       VALUES (?, ?, ?, ?, 1, datetime('now'))`,
      [full_name, phone, email || null, roleId],
      function (err) {
        if (err) return res.status(400).json({ error: err.message });
        res.status(201).json({ message: 'User registered successfully', userId: this.lastID });
      }
    );
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/auth/send-otp  (mock OTP — always success in dev)
app.post('/api/auth/send-otp', (req, res) => {
  const { phone } = req.body;
  console.log(`📱 Mock OTP sent to ${phone}: 123456`);
  res.json({ message: 'OTP sent successfully', dev_otp: '123456' });
});

// POST /api/auth/verify-otp  (mock — accepts any code)
app.post('/api/auth/verify-otp', async (req, res) => {
  const { phone, code, purpose } = req.body;
  try {
    const user = await dbGet(
      `SELECT u.*, r.role_name FROM users u JOIN role r ON u.role_id = r.role_id WHERE u.phone = ? LIMIT 1`,
      [phone]
    );
    res.json({
      token: user ? `jwt_${user.user_id}_agrilink` : 'demo_jwt_token_agrilink_2026',
      refreshToken: 'demo_refresh_token',
      user: user
        ? {
            id: user.user_id,
            full_name: user.full_name,
            phone: user.phone,
            email: user.email,
            role: (user.role_name || 'customer').toLowerCase(),
          }
        : { id: 'demo-001', full_name: 'Demo User', phone, role: 'customer' },
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/auth/logout
app.post('/api/auth/logout', (req, res) => {
  res.json({ message: 'Logged out successfully' });
});

// ==========================================
// PRODUCTS ROUTES — /api/products
// ==========================================

// GET /api/products/categories
app.get('/api/products/categories', async (req, res) => {
  try {
    const categories = await dbAll(
      `SELECT category_id as id, category_name as name, description FROM crop_category ORDER BY category_name`
    );
    res.json(categories);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/products
app.get('/api/products', async (req, res) => {
  const { category, search, min_price, max_price, organic, sort, page = 1, limit = 20 } = req.query;
  const offset = (parseInt(page) - 1) * parseInt(limit);

  try {
    let conditions = [];
    let params = [];

    if (category) {
      conditions.push(`cc.category_name LIKE ?`);
      params.push(`%${category}%`);
    }
    if (search) {
      conditions.push(`c.crop_name LIKE ?`);
      params.push(`%${search}%`);
    }
    if (organic === 'true') {
      conditions.push(`f.organic_certified = 1`);
    }

    const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

    let orderClause = 'ORDER BY c.crop_name ASC';
    if (sort === 'price_asc') orderClause = 'ORDER BY ph.new_price ASC';
    if (sort === 'price_desc') orderClause = 'ORDER BY ph.new_price DESC';

    const sql = `
      SELECT
        c.crop_id as id,
        c.crop_name as name,
        c.description,
        cc.category_name as category,
        COALESCE(ph.new_price, 0) as price,
        c.unit,
        f.organic_certified,
        fa.full_name as farmer_name,
        COALESCE(ai.available_quantity, 0) as stock_quantity,
        4.5 as rating,
        (SELECT COUNT(*) FROM price_history ph2 WHERE ph2.crop_id = c.crop_id) as reviews
      FROM crop c
      LEFT JOIN crop_category cc ON c.category_id = cc.category_id
      LEFT JOIN farmer_crop fc ON fc.crop_id = c.crop_id
      LEFT JOIN farmer fr ON fc.farmer_id = fr.farmer_id
      LEFT JOIN farm f ON f.farmer_id = fr.farmer_id
      LEFT JOIN users fa ON fr.user_id = fa.user_id
      LEFT JOIN (
        SELECT crop_id, new_price FROM price_history
        WHERE recorded_at = (SELECT MAX(recorded_at) FROM price_history ph3 WHERE ph3.crop_id = price_history.crop_id)
      ) ph ON ph.crop_id = c.crop_id
      LEFT JOIN aggregator_inventory ai ON ai.crop_id = c.crop_id
      ${whereClause}
      GROUP BY c.crop_id
      ${orderClause}
      LIMIT ? OFFSET ?
    `;

    const totalSql = `
      SELECT COUNT(DISTINCT c.crop_id) as total
      FROM crop c
      LEFT JOIN crop_category cc ON c.category_id = cc.category_id
      LEFT JOIN farmer_crop fc ON fc.crop_id = c.crop_id
      LEFT JOIN farmer fr ON fc.farmer_id = fr.farmer_id
      LEFT JOIN farm f ON f.farmer_id = fr.farmer_id
      ${whereClause}
    `;

    const [products, totalRow] = await Promise.all([
      dbAll(sql, [...params, parseInt(limit), offset]),
      dbGet(totalSql, params),
    ]);

    res.json({
      products,
      total: totalRow ? totalRow.total : 0,
      page: parseInt(page),
      totalPages: Math.ceil((totalRow ? totalRow.total : 0) / parseInt(limit)),
    });
  } catch (err) {
    console.error('Products error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// GET /api/products/:id
app.get('/api/products/:id', async (req, res) => {
  try {
    const product = await dbGet(
      `SELECT c.crop_id as id, c.crop_name as name, c.description, cc.category_name as category,
              COALESCE(ph.new_price, 0) as price, c.unit, fa.full_name as farmer_name,
              4.5 as rating
       FROM crop c
       LEFT JOIN crop_category cc ON c.category_id = cc.category_id
       LEFT JOIN farmer_crop fc ON fc.crop_id = c.crop_id
       LEFT JOIN farmer fr ON fc.farmer_id = fr.farmer_id
       LEFT JOIN users fa ON fr.user_id = fa.user_id
       LEFT JOIN (SELECT crop_id, new_price FROM price_history ORDER BY recorded_at DESC LIMIT 1) ph ON ph.crop_id = c.crop_id
       WHERE c.crop_id = ?`,
      [req.params.id]
    );
    if (!product) return res.status(404).json({ error: 'Product not found' });
    res.json(product);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/products  (create crop listing)
app.post('/api/products', (req, res) => {
  const { name, description, category_id, unit, price } = req.body;
  db.run(
    `INSERT INTO crop (crop_name, description, category_id, unit, created_at) VALUES (?, ?, ?, ?, datetime('now'))`,
    [name, description, category_id, unit],
    function (err) {
      if (err) return res.status(400).json({ error: err.message });
      res.status(201).json({ message: 'Product listed successfully', id: this.lastID });
    }
  );
});

// ==========================================
// ORDERS ROUTES — /api/orders
// ==========================================

// GET /api/orders  (customer orders)
app.get('/api/orders', async (req, res) => {
  const { status } = req.query;
  try {
    let sql = `
      SELECT
        o.order_id as id,
        o.order_status as status,
        o.total_amount as amount,
        o.created_at,
        o.expected_delivery_date,
        COUNT(oi.item_id) as item_count
      FROM orders o
      LEFT JOIN order_item oi ON oi.order_id = o.order_id
    `;
    const params = [];
    if (status) {
      sql += ` WHERE o.order_status = ?`;
      params.push(status);
    }
    sql += ` GROUP BY o.order_id ORDER BY o.created_at DESC LIMIT 50`;

    const orders = await dbAll(sql, params);
    res.json(orders);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/orders/farmer/list  (farmer-side orders)
app.get('/api/orders/farmer/list', async (req, res) => {
  try {
    const orders = await dbAll(`
      SELECT
        o.order_id as id,
        o.order_status as status,
        o.total_amount as amount,
        o.created_at,
        u.full_name as customer_name,
        COUNT(oi.item_id) as item_count
      FROM orders o
      JOIN order_item oi ON oi.order_id = o.order_id
      JOIN users u ON o.customer_id = u.user_id
      GROUP BY o.order_id
      ORDER BY o.created_at DESC
      LIMIT 50
    `);
    res.json(orders);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/orders/cart  (mock empty cart)
app.get('/api/orders/cart', (req, res) => {
  res.json({ items: [], subtotal: 0.0 });
});

// POST /api/orders/cart
app.post('/api/orders/cart', (req, res) => {
  res.json({ message: 'Item added to cart' });
});

// DELETE /api/orders/cart/:productId
app.delete('/api/orders/cart/:productId', (req, res) => {
  res.json({ message: 'Item removed from cart' });
});

// DELETE /api/orders/cart
app.delete('/api/orders/cart', (req, res) => {
  res.json({ message: 'Cart cleared' });
});

// GET /api/orders/:id
app.get('/api/orders/:id', async (req, res) => {
  try {
    const order = await dbGet(
      `SELECT o.*, u.full_name as customer_name FROM orders o JOIN users u ON o.customer_id = u.user_id WHERE o.order_id = ?`,
      [req.params.id]
    );
    if (!order) return res.status(404).json({ error: 'Order not found' });

    const items = await dbAll(
      `SELECT oi.*, c.crop_name FROM order_item oi JOIN crop c ON oi.crop_id = c.crop_id WHERE oi.order_id = ?`,
      [req.params.id]
    );
    res.json({ ...order, items });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/orders  (place order)
app.post('/api/orders', (req, res) => {
  res.status(201).json({ message: 'Order placed successfully', orderId: `ORD-${Date.now()}` });
});

// PATCH /api/orders/:id/status
app.patch('/api/orders/:id/status', (req, res) => {
  const { status } = req.body;
  db.run(`UPDATE orders SET order_status = ? WHERE order_id = ?`, [status, req.params.id], function (err) {
    if (err) return res.status(400).json({ error: err.message });
    res.json({ message: 'Status updated' });
  });
});

// POST /api/orders/:id/cancel
app.post('/api/orders/:id/cancel', (req, res) => {
  db.run(`UPDATE orders SET order_status = 'cancelled' WHERE order_id = ?`, [req.params.id], function (err) {
    if (err) return res.status(400).json({ error: err.message });
    res.json({ message: 'Order cancelled' });
  });
});

// ==========================================
// USERS ROUTES — /api/users
// ==========================================
app.get('/api/users', async (req, res) => {
  try {
    const users = await dbAll(
      `SELECT u.user_id as id, u.full_name, u.phone, u.email, r.role_name as role, u.is_active, u.created_at
       FROM users u JOIN role r ON u.role_id = r.role_id ORDER BY u.created_at DESC LIMIT 100`
    );
    res.json(users);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==========================================
// FARMERS ROUTES — /api/farmers
// ==========================================
app.get('/api/farmers', async (req, res) => {
  try {
    const farmers = await dbAll(`
      SELECT fr.farmer_id as id, u.full_name, u.phone, u.email,
             fr.verification_status, fr.total_earnings,
             COUNT(DISTINCT fc.crop_id) as crop_count,
             f.farm_name, f.total_area, f.organic_certified
      FROM farmer fr
      JOIN users u ON fr.user_id = u.user_id
      LEFT JOIN farm f ON f.farmer_id = fr.farmer_id
      LEFT JOIN farmer_crop fc ON fc.farmer_id = fr.farmer_id
      GROUP BY fr.farmer_id
      ORDER BY u.full_name
    `);
    res.json(farmers);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==========================================
// PAYMENTS ROUTES — /api/payments
// ==========================================
app.get('/api/payments', async (req, res) => {
  try {
    const payments = await dbAll(
      `SELECT p.*, o.order_status FROM payment p LEFT JOIN orders o ON p.order_id = o.order_id ORDER BY p.created_at DESC LIMIT 50`
    );
    res.json(payments);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==========================================
// DELIVERY ROUTES — /api/delivery
// ==========================================
app.get('/api/delivery', async (req, res) => {
  try {
    const deliveries = await dbAll(
      `SELECT d.*, o.order_status, o.total_amount FROM delivery d JOIN orders o ON d.order_id = o.order_id ORDER BY d.created_at DESC LIMIT 50`
    );
    res.json(deliveries);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==========================================
// DASHBOARD STATS — /api/stats
// ==========================================
app.get('/api/stats/overview', async (req, res) => {
  try {
    const [userCount, orderCount, productCount, farmerCount] = await Promise.all([
      dbGet(`SELECT COUNT(*) as count FROM users`),
      dbGet(`SELECT COUNT(*) as count FROM orders`),
      dbGet(`SELECT COUNT(*) as count FROM crop`),
      dbGet(`SELECT COUNT(*) as count FROM farmer`),
    ]);
    const totalSales = await dbGet(`SELECT COALESCE(SUM(total_amount), 0) as total FROM orders WHERE order_status = 'delivered'`);
    res.json({
      totalUsers: userCount?.count || 0,
      totalOrders: orderCount?.count || 0,
      totalProducts: productCount?.count || 0,
      totalFarmers: farmerCount?.count || 0,
      totalSales: totalSales?.total || 0,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Farmer-specific stats
app.get('/api/stats/farmer/:farmerId', async (req, res) => {
  try {
    const { farmerId } = req.params;
    const [earnings, pendingOrders, products, farmer] = await Promise.all([
      dbGet(`SELECT COALESCE(total_earnings, 0) as earnings FROM farmer WHERE farmer_id = ?`, [farmerId]),
      dbGet(`SELECT COUNT(*) as count FROM orders WHERE order_status IN ('pending', 'accepted', 'processing')`, []),
      dbGet(`SELECT COUNT(*) as count FROM farmer_crop WHERE farmer_id = ?`, [farmerId]),
      dbGet(`SELECT u.full_name FROM farmer fr JOIN users u ON fr.user_id = u.user_id WHERE fr.farmer_id = ?`, [farmerId]),
    ]);
    res.json({
      earnings: earnings?.earnings || 4850,
      pendingOrders: pendingOrders?.count || 0,
      productCount: products?.count || 0,
      farmerName: farmer?.full_name || 'Farmer',
      rating: 4.8,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==========================================
// INVOICES ROUTE — /api/invoices
// ==========================================
app.get('/api/invoices/:number/download', (req, res) => {
  res.json({ message: 'Invoice download endpoint', invoice: req.params.number });
});

// ==========================================
// DB EXPLORER API ROUTES  (keep intact)
// ==========================================

app.get('/api/db/stats', (req, res) => {
  const stats = {
    databaseType: 'SQLite (AgriLink Enterprise v2.0)',
    tablesCount: 47,
    status: 'Connected',
    filePath: dbPath,
  };

  db.all("SELECT name FROM sqlite_master WHERE type='table';", [], (err, tables) => {
    if (err) return res.status(500).json({ error: err.message });
    const tableNames = tables.map((t) => t.name).filter((name) => !name.startsWith('sqlite_'));
    stats.tablesCount = tableNames.length;
    stats.tablesList = tableNames;

    let completed = 0;
    const rowCounts = {};
    if (tableNames.length === 0) return res.json(stats);

    tableNames.forEach((table) => {
      db.get(`SELECT COUNT(*) as count FROM "${table}"`, [], (err, row) => {
        if (!err) rowCounts[table] = row.count;
        completed++;
        if (completed === tableNames.length) {
          stats.rowCounts = rowCounts;
          res.json(stats);
        }
      });
    });
  });
});

app.get('/api/db/schema/:table', (req, res) => {
  const tableName = req.params.table;
  db.all(`PRAGMA table_info("${tableName}")`, [], (err, columns) => {
    if (err) return res.status(500).json({ error: err.message });
    if (columns.length === 0) return res.status(404).json({ error: `Table '${tableName}' not found.` });
    db.all(`PRAGMA foreign_key_list("${tableName}")`, [], (err, fks) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json({
        tableName,
        columns: columns.map((c) => ({
          cid: c.cid,
          name: c.name,
          type: c.type,
          notnull: c.notnull === 1,
          pk: c.pk === 1,
          defaultValue: c.dflt_value,
        })),
        foreignKeys: fks.map((f) => ({ from: f.from, toTable: f.table, toColumn: f.to })),
      });
    });
  });
});

app.get('/api/db/data/:table', (req, res) => {
  const tableName = req.params.table;
  const limit = parseInt(req.query.limit) || 100;
  const offset = parseInt(req.query.offset) || 0;

  db.all(`SELECT * FROM "${tableName}" LIMIT ? OFFSET ?`, [limit, offset], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ tableName, rowCount: rows.length, rows });
  });
});

app.post('/api/db/query', (req, res) => {
  const { sql } = req.body;
  if (!sql) return res.status(400).json({ error: 'SQL query parameter is required.' });

  const cleanSql = sql.trim().toLowerCase();
  if (!cleanSql.startsWith('select') && !cleanSql.startsWith('with') && !cleanSql.startsWith('pragma table_info')) {
    return res.status(403).json({ error: 'Only SELECT (read-only) queries are allowed in the SQL playground.' });
  }

  db.all(sql, [], (err, rows) => {
    if (err) return res.status(400).json({ error: err.message });
    res.json({
      rowCount: rows.length,
      columns: rows.length > 0 ? Object.keys(rows[0]) : [],
      rows,
    });
  });
});

// ==========================================
// GLOBAL ERROR HANDLER
// ==========================================
app.use((err, req, res, next) => {
  console.error(err);
  const status = err.status || 500;
  res.status(status).json({ error: err.message || 'Internal Server Error' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 AgriLink Server running on http://localhost:${PORT}`);
  console.log(`📊 DB Explorer Dashboard: http://localhost:${PORT}`);
  console.log(`🔌 API Base: http://localhost:${PORT}/api`);
});
