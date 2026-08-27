// controllers/productController.js
const { query } = require('../config/db');
const { v4: uuidv4 } = require('uuid');

// GET /api/products/categories
exports.getCategories = async (req, res, next) => {
  try {
    const result = await query(
      `SELECT id, name, slug, icon_url, color_hex, display_order FROM product_categories WHERE is_active = true ORDER BY display_order`
    );
    res.json(result.rows);
  } catch (err) { next(err); }
};

// GET /api/products
exports.getProducts = async (req, res, next) => {
  try {
    const { category, search, min_price, max_price, organic, sort = 'created_at', page = 1, limit = 20 } = req.query;
    const offset = (parseInt(page) - 1) * parseInt(limit);

    let conditions = ['p.is_active = true'];
    const params = [];

    if (category) { params.push(category); conditions.push(`pc.slug = $${params.length}`); }
    if (search) { params.push(`%${search}%`); conditions.push(`p.name ILIKE $${params.length}`); }
    if (min_price) { params.push(parseFloat(min_price)); conditions.push(`p.price_per_unit >= $${params.length}`); }
    if (max_price) { params.push(parseFloat(max_price)); conditions.push(`p.price_per_unit <= $${params.length}`); }
    if (organic === 'true') conditions.push('p.is_organic = true');

    const whereClause = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
    const orderMap = { 'price_asc': 'p.price_per_unit ASC', 'price_desc': 'p.price_per_unit DESC', 'rating': 'p.rating DESC', 'created_at': 'p.created_at DESC' };
    const orderBy = orderMap[sort] || 'p.created_at DESC';

    params.push(parseInt(limit), offset);

    const sql = `
      SELECT
        p.id, p.name, p.description, p.unit, p.price_per_unit, p.stock_quantity,
        p.image_urls, p.is_organic, p.rating, p.review_count, p.bulk_discount_percent,
        p.bulk_discount_threshold, p.min_order_quantity,
        json_build_object('id', f.id, 'farm_name', f.farm_name, 'district', f.district,
          'rating', f.rating, 'organic_certified', f.organic_certified,
          'farmer_name', u.full_name) AS farmer,
        json_build_object('id', pc.id, 'name', pc.name, 'slug', pc.slug) AS category
      FROM products p
      JOIN farmers f ON p.farmer_id = f.id
      JOIN users u ON f.user_id = u.id
      LEFT JOIN product_categories pc ON p.category_id = pc.id
      ${whereClause}
      ORDER BY ${orderBy}
      LIMIT $${params.length - 1} OFFSET $${params.length}
    `;

    const countResult = await query(`SELECT COUNT(*) FROM products p LEFT JOIN product_categories pc ON p.category_id = pc.id ${whereClause}`, params.slice(0, -2));
    const productsResult = await query(sql, params);

    res.json({
      products: productsResult.rows,
      total: parseInt(countResult.rows[0].count),
      page: parseInt(page),
      totalPages: Math.ceil(parseInt(countResult.rows[0].count) / parseInt(limit)),
    });
  } catch (err) { next(err); }
};

// GET /api/products/:id
exports.getProductById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const result = await query(`
      SELECT p.*,
        json_build_object('id', f.id, 'farm_name', f.farm_name, 'district', f.district,
          'state', f.state, 'rating', f.rating, 'total_orders_fulfilled', f.total_orders_fulfilled,
          'organic_certified', f.organic_certified, 'farmer_name', u.full_name, 'phone', u.phone) AS farmer,
        json_build_object('id', pc.id, 'name', pc.name) AS category,
        (SELECT json_agg(json_build_object('rating', r.rating, 'comment', r.comment, 'created_at', r.created_at))
         FROM reviews r WHERE r.product_id = p.id LIMIT 5) AS reviews
      FROM products p
      JOIN farmers f ON p.farmer_id = f.id
      JOIN users u ON f.user_id = u.id
      LEFT JOIN product_categories pc ON p.category_id = pc.id
      WHERE p.id = $1
    `, [id]);

    if (!result.rows.length) return res.status(404).json({ error: 'Product not found' });
    res.json(result.rows[0]);
  } catch (err) { next(err); }
};

// POST /api/products (farmer only)
exports.createProduct = async (req, res, next) => {
  try {
    const { name, description, unit, price_per_unit, stock_quantity, category_id, is_organic, attributes, image_urls, min_order_quantity, bulk_discount_threshold, bulk_discount_percent } = req.body;
    const farmerResult = await query(`SELECT id FROM farmers WHERE user_id = $1`, [req.user.id]);
    if (!farmerResult.rows.length) return res.status(403).json({ error: 'Only farmers can create products' });

    const id = uuidv4();
    await query(`
      INSERT INTO products (id, farmer_id, category_id, name, description, unit, price_per_unit, stock_quantity, is_organic, attributes, image_urls, min_order_quantity, bulk_discount_threshold, bulk_discount_percent)
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
    `, [id, farmerResult.rows[0].id, category_id, name, description, unit || 'kg', price_per_unit, stock_quantity || 0, is_organic || false, JSON.stringify(attributes || {}), JSON.stringify(image_urls || []), min_order_quantity || 1, bulk_discount_threshold, bulk_discount_percent || 0]);

    res.status(201).json({ id, message: 'Product created' });
  } catch (err) { next(err); }
};

// PUT /api/products/:id (farmer only)
exports.updateProduct = async (req, res, next) => {
  try {
    const { id } = req.params;
    const farmerResult = await query(`SELECT id FROM farmers WHERE user_id = $1`, [req.user.id]);
    if (!farmerResult.rows.length) return res.status(403).json({ error: 'Forbidden' });

    const fields = ['name','description','unit','price_per_unit','category_id','is_organic','attributes','image_urls','min_order_quantity','bulk_discount_threshold','bulk_discount_percent'];
    const updates = [];
    const params = [];

    fields.forEach(f => {
      if (req.body[f] !== undefined) {
        params.push(req.body[f]);
        updates.push(`${f} = $${params.length}`);
      }
    });

    if (!updates.length) return res.status(400).json({ error: 'No fields to update' });
    params.push(id, farmerResult.rows[0].id);
    await query(`UPDATE products SET ${updates.join(', ')}, updated_at = NOW() WHERE id = $${params.length - 1} AND farmer_id = $${params.length}`, params);
    res.json({ message: 'Product updated' });
  } catch (err) { next(err); }
};

// PATCH /api/products/:id/stock (farmer only)
exports.updateStock = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { stock_quantity } = req.body;
    await query(`UPDATE products SET stock_quantity = $1, updated_at = NOW() WHERE id = $2`, [stock_quantity, id]);
    res.json({ message: 'Stock updated' });
  } catch (err) { next(err); }
};
