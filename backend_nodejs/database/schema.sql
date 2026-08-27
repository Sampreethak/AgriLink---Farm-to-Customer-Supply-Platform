/*
  AgriLink PostgreSQL schema
  Includes tables, sequences, indexes, and role‑based JSON views.
*/

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "btree_gin";

-- ENUM types
CREATE TYPE user_role AS ENUM ('customer', 'farmer', 'aggregator', 'delivery_partner', 'admin');
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'processing', 'out_for_delivery', 'delivered', 'cancelled', 'refunded');
CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed', 'refunded');
CREATE TYPE payment_method AS ENUM ('upi', 'card', 'netbanking', 'cod', 'wallet');
CREATE TYPE customer_type AS ENUM ('individual', 'hostel_pg', 'hospital', 'restaurant', 'corporate');
CREATE TYPE otp_purpose AS ENUM ('registration', 'login', 'password_reset', 'payment_confirm');
CREATE TYPE product_unit AS ENUM ('kg', 'gram', 'litre', 'ml', 'piece', 'dozen', 'bundle', 'bag');

-- USERS (base table for all roles)
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  full_name VARCHAR(150) NOT NULL,
  email VARCHAR(255) UNIQUE,
  phone VARCHAR(15) NOT NULL UNIQUE,
  password_hash VARCHAR(255),
  role user_role NOT NULL DEFAULT 'customer',
  language_pref VARCHAR(10) DEFAULT 'en',
  is_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  profile_image_url TEXT,
  fcm_token TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- OTP LOGS
CREATE TABLE otp_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  phone VARCHAR(15) NOT NULL,
  otp_code VARCHAR(6) NOT NULL,
  purpose otp_purpose NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  is_used BOOLEAN DEFAULT FALSE,
  attempt_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- REFRESH TOKENS
CREATE TABLE refresh_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token TEXT NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- FARMERS
CREATE TABLE farmers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  farm_name VARCHAR(200) NOT NULL,
  farm_address TEXT NOT NULL,
  district VARCHAR(100),
  state VARCHAR(100) DEFAULT 'Karnataka',
  pincode VARCHAR(10),
  land_area_acres DECIMAL(10,2),
  farming_type VARCHAR(50) DEFAULT 'conventional',
  organic_certified BOOLEAN DEFAULT FALSE,
  certification_doc_url TEXT,
  bank_account_number VARCHAR(30),
  bank_ifsc VARCHAR(15),
  bank_name VARCHAR(100),
  upi_id VARCHAR(100),
  rating DECIMAL(3,2) DEFAULT 0,
  total_orders_fulfilled INT DEFAULT 0,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- PRODUCT CATEGORIES
CREATE TABLE product_categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  slug VARCHAR(100) NOT NULL UNIQUE,
  icon_url TEXT,
  color_hex VARCHAR(7),
  parent_id INT REFERENCES product_categories(id),
  display_order INT DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE
);

-- PRODUCTS
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  farmer_id UUID NOT NULL REFERENCES farmers(id) ON DELETE CASCADE,
  category_id INT REFERENCES product_categories(id),
  name VARCHAR(200) NOT NULL,
  description TEXT,
  unit product_unit NOT NULL DEFAULT 'kg',
  price_per_unit DECIMAL(10,2) NOT NULL,
  min_order_quantity DECIMAL(10,2) DEFAULT 1,
  bulk_discount_threshold DECIMAL(10,2),
  bulk_discount_percent DECIMAL(5,2) DEFAULT 0,
  stock_quantity DECIMAL(10,2) NOT NULL DEFAULT 0,
  image_urls TEXT[] DEFAULT '{}',
  attributes JSONB DEFAULT '{}',
  is_organic BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  rating DECIMAL(3,2) DEFAULT 0,
  review_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- CUSTOMERS
CREATE TABLE customers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  customer_type customer_type DEFAULT 'individual',
  organization_name VARCHAR(200),
  gst_number VARCHAR(20),
  default_address_id UUID,
  loyalty_points INT DEFAULT 0,
  total_orders INT DEFAULT 0,
  total_spent DECIMAL(12,2) DEFAULT 0
);

-- ADDRESSES
CREATE TABLE addresses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  label VARCHAR(50) DEFAULT 'Home',
  full_address TEXT NOT NULL,
  city VARCHAR(100),
  district VARCHAR(100),
  state VARCHAR(100),
  pincode VARCHAR(10),
  latitude DECIMAL(10,7),
  longitude DECIMAL(10,7),
  is_default BOOLEAN DEFAULT FALSE
);

-- CART ITEMS
CREATE TABLE cart_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  quantity DECIMAL(10,2) NOT NULL,
  added_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- COUPONS
CREATE TABLE coupons (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(30) NOT NULL UNIQUE,
  description TEXT,
  discount_type VARCHAR(10) CHECK (discount_type IN ('percent', 'flat')),
  discount_value DECIMAL(10,2) NOT NULL,
  min_order_amount DECIMAL(10,2) DEFAULT 0,
  max_discount_amount DECIMAL(10,2),
  usage_limit INT,
  used_count INT DEFAULT 0,
  valid_from TIMESTAMPTZ DEFAULT NOW(),
  valid_until TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT TRUE
);

-- SEQUENCES for orders and invoices
CREATE SEQUENCE IF NOT EXISTS order_seq START 1000;
CREATE SEQUENCE IF NOT EXISTS invoice_seq START 5000;

-- ORDERS
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_number VARCHAR(20) NOT NULL UNIQUE DEFAULT ('ORD' || LPAD(nextval('order_seq')::TEXT, 8, '0')),
  customer_id UUID NOT NULL REFERENCES customers(id),
  delivery_address_id UUID REFERENCES addresses(id),
  status order_status DEFAULT 'pending',
  subtotal DECIMAL(12,2) NOT NULL,
  delivery_charge DECIMAL(10,2) DEFAULT 0,
  discount_amount DECIMAL(10,2) DEFAULT 0,
  tax_amount DECIMAL(10,2) DEFAULT 0,
  total_amount DECIMAL(12,2) NOT NULL,
  coupon_id UUID REFERENCES coupons(id),
  special_instructions TEXT,
  expected_delivery_date DATE,
  actual_delivery_date TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ORDER ITEMS
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id),
  farmer_id UUID NOT NULL REFERENCES farmers(id),
  product_name VARCHAR(200) NOT NULL,
  unit product_unit NOT NULL,
  quantity DECIMAL(10,2) NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  discount_percent DECIMAL(5,2) DEFAULT 0,
  line_total DECIMAL(12,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- PAYMENTS
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id),
  razorpay_order_id VARCHAR(100) UNIQUE,
  razorpay_payment_id VARCHAR(100) UNIQUE,
  razorpay_signature VARCHAR(255),
  amount DECIMAL(12,2) NOT NULL,
  currency VARCHAR(5) DEFAULT 'INR',
  method payment_method,
  status payment_status DEFAULT 'pending',
  failure_reason TEXT,
  refund_id VARCHAR(100),
  refund_amount DECIMAL(12,2),
  metadata JSONB DEFAULT '{}',
  paid_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- DELIVERY PARTNERS
CREATE TABLE delivery_partners (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  vehicle_type VARCHAR(50),
  vehicle_number VARCHAR(20),
  license_number VARCHAR(30),
  current_latitude DECIMAL(10,7),
  current_longitude DECIMAL(10,7),
  is_available BOOLEAN DEFAULT TRUE,
  rating DECIMAL(3,2) DEFAULT 0,
  total_deliveries INT DEFAULT 0
);

-- ORDER TRACKING
CREATE TABLE order_tracking (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  delivery_partner_id UUID REFERENCES delivery_partners(id),
  status order_status NOT NULL,
  note TEXT,
  latitude DECIMAL(10,7),
  longitude DECIMAL(10,7),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- INVOICES
CREATE TABLE invoices (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  invoice_number VARCHAR(20) NOT NULL UNIQUE DEFAULT ('INV' || LPAD(nextval('invoice_seq')::TEXT, 8, '0')),
  order_id UUID NOT NULL UNIQUE REFERENCES orders(id),
  customer_id UUID NOT NULL REFERENCES customers(id),
  issued_at TIMESTAMPTZ DEFAULT NOW(),
  due_date DATE,
  is_paid BOOLEAN DEFAULT FALSE,
  notes TEXT,
  terms TEXT DEFAULT 'Payment due within 30 days.'
);

-- REVIEWS
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID NOT NULL REFERENCES products(id),
  customer_id UUID NOT NULL REFERENCES customers(id),
  order_id UUID NOT NULL REFERENCES orders(id),
  rating INT CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  images TEXT[] DEFAULT '{}',
  is_verified_purchase BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(product_id, customer_id, order_id)
);

-- AGGREGATORS
CREATE TABLE aggregators (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  company_name VARCHAR(200) NOT NULL,
  commission_percent DECIMAL(5,2) DEFAULT 5.0,
  service_areas TEXT[] DEFAULT '{}',
  is_active BOOLEAN DEFAULT TRUE
);

-- NOTIFICATIONS
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(200) NOT NULL,
  body TEXT NOT NULL,
  type VARCHAR(50),
  data JSONB DEFAULT '{}',
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Performance indexes
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_otp_phone_purpose ON otp_logs(phone, purpose) WHERE NOT is_used;
CREATE INDEX idx_products_farmer ON products(farmer_id) WHERE is_active;
CREATE INDEX idx_products_category ON products(category_id) WHERE is_active;
CREATE INDEX idx_products_attributes ON products USING GIN(attributes);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created ON orders(created_at DESC);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_farmer ON order_items(farmer_id);
CREATE INDEX idx_cart_user ON cart_items(user_id);
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_tracking_order ON order_tracking(order_id);
CREATE INDEX idx_notifications_user_unread ON notifications(user_id) WHERE NOT is_read;
CREATE INDEX idx_products_name_search ON products USING GIN(to_tsvector('english', name || ' ' || COALESCE(description, '')));

-- Role‑based JSON views (example for farmer dashboard)
CREATE OR REPLACE VIEW farmer_dashboard_view AS
SELECT
  f.id AS farmer_id,
  json_build_object(
    'farmer', json_build_object(
      'id', f.id,
      'farm_name', f.farm_name,
      'rating', f.rating,
      'is_verified', f.is_verified,
      'organic_certified', f.organic_certified
    ),
    'user', json_build_object(
      'name', u.full_name,
      'phone', u.phone,
      'profile_image', u.profile_image_url
    ),
    'stats', json_build_object(
      'total_products', (SELECT COUNT(*) FROM products p WHERE p.farmer_id = f.id AND p.is_active),
      'total_orders', f.total_orders_fulfilled,
      'pending_orders', (SELECT COUNT(*) FROM order_items oi JOIN orders o ON oi.order_id = o.id WHERE oi.farmer_id = f.id AND o.status = 'pending'),
      'total_revenue', (SELECT COALESCE(SUM(oi.line_total), 0) FROM order_items oi JOIN orders o ON oi.order_id = o.id WHERE oi.farmer_id = f.id AND o.status = 'delivered'),
      'this_month_revenue', (SELECT COALESCE(SUM(oi.line_total), 0) FROM order_items oi JOIN orders o ON oi.order_id = o.id WHERE oi.farmer_id = f.id AND o.status = 'delivered' AND DATE_TRUNC('month', o.created_at) = DATE_TRUNC('month', NOW()))
    ),
    'recent_orders', (
      SELECT json_agg(order_data ORDER BY order_data->>'created_at' DESC)
      FROM (
        SELECT json_build_object(
          'order_id', o.id,
          'order_number', o.order_number,
          'status', o.status,
          'product_name', oi.product_name,
          'quantity', oi.quantity,
          'unit', oi.unit,
          'line_total', oi.line_total,
          'created_at', o.created_at
        ) AS order_data
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.id
        WHERE oi.farmer_id = f.id
        ORDER BY o.created_at DESC
        LIMIT 5
      ) recent
    ),
    'top_products', (
      SELECT json_agg(prod_data)
      FROM (
        SELECT json_build_object(
          'id', p.id,
          'name', p.name,
          'stock', p.stock_quantity,
          'unit', p.unit,
          'price', p.price_per_unit,
          'rating', p.rating,
          'is_active', p.is_active
        ) AS prod_data
        FROM products p
        WHERE p.farmer_id = f.id
        ORDER BY p.review_count DESC
        LIMIT 5
      ) top
    )
  ) AS dashboard_json
FROM farmers f
JOIN users u ON f.user_id = u.id;

-- Customer order history view (simplified example)
CREATE OR REPLACE VIEW customer_orders_view AS
SELECT
  c.id AS customer_id,
  json_build_object(
    'customer', json_build_object(
      'id', c.id,
      'type', c.customer_type,
      'loyalty_points', c.loyalty_points
    ),
    'orders', (
      SELECT json_agg(order_data ORDER BY order_data->>'created_at' DESC)
      FROM (
        SELECT json_build_object(
          'order_id', o.id,
          'order_number', o.order_number,
          'status', o.status,
          'total_amount', o.total_amount,
          'created_at', o.created_at,
          'items', (
            SELECT json_agg(item_data)
            FROM (
              SELECT json_build_object(
                'product_id', oi.product_id,
                'product_name', oi.product_name,
                'quantity', oi.quantity,
                'unit', oi.unit,
                'line_total', oi.line_total
              ) AS item_data
              FROM order_items oi
              WHERE oi.order_id = o.id
            ) sub_items
          )
        ) AS order_data
        FROM orders o
        WHERE o.customer_id = c.id
      ) recent_orders
    )
  ) AS orders_json
FROM customers c;
