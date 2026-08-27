-- ============================================================
-- 11_order.sql
-- Customer purchase orders and order line items
-- Tables: orders, order_item
-- Depends on: 05_customer.sql (customer, customer_address),
--             03_master_tables.sql (crop)
-- ============================================================

-- 1. ORDERS
-- The root purchase transaction entity.
-- Represents a customer's complete purchase request.
-- Business rules:
--  - order_status flows: Placed → Confirmed → Processing → OutForDelivery → Delivered
--  - cancellation is allowed only before Processing
--  - payment_status is updated by payment gateway callbacks
--  - total_amount must be >= 0 (can be 0 for promotional/test orders)
CREATE TABLE IF NOT EXISTS orders (
    order_id            UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id         UUID        NOT NULL REFERENCES customer(customer_id) ON DELETE RESTRICT,
    order_date          TIMESTAMPTZ DEFAULT NOW(),
    order_status        VARCHAR(30) DEFAULT 'Placed'
                            CHECK (order_status IN ('Placed', 'Confirmed', 'Processing', 'OutForDelivery', 'Delivered', 'Cancelled')),
    total_amount        DECIMAL(12, 2) NOT NULL CHECK (total_amount >= 0),
    delivery_address_id UUID        REFERENCES customer_address(address_id) ON DELETE RESTRICT,
    payment_status      VARCHAR(20) DEFAULT 'Pending'
                            CHECK (payment_status IN ('Pending', 'Paid', 'Failed', 'Refunded')),
    special_instructions TEXT,
    created_at          TIMESTAMPTZ DEFAULT NOW(),
    updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- 2. ORDER_ITEM
-- Individual line items within an order.
-- Each item maps to a specific crop and specifies whether it
-- should be fulfilled by a Farmer (direct) or Aggregator (warehouse).
-- Business rules:
--  - quantity and unit_price must be positive
--  - subtotal = quantity × unit_price (enforced by application)
--  - selected_type guides the fulfillment allocation engine
CREATE TABLE IF NOT EXISTS order_item (
    order_item_id   UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id        UUID        NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    crop_id         UUID        NOT NULL REFERENCES crop(crop_id) ON DELETE RESTRICT,
    quantity        DECIMAL(10, 2) NOT NULL CHECK (quantity > 0),
    unit_price      DECIMAL(10, 2) NOT NULL CHECK (unit_price > 0),
    selected_type   VARCHAR(20) CHECK (selected_type IN ('Farmer', 'Aggregator')),
    subtotal        DECIMAL(12, 2) NOT NULL CHECK (subtotal > 0),
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- INDEXES for order tables
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(order_status);
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON orders(payment_status);
CREATE INDEX IF NOT EXISTS idx_orders_date ON orders(order_date DESC);
CREATE INDEX IF NOT EXISTS idx_orders_delivery_address ON orders(delivery_address_id);
CREATE INDEX IF NOT EXISTS idx_order_item_order_id ON order_item(order_id);
CREATE INDEX IF NOT EXISTS idx_order_item_crop_id ON order_item(crop_id);
CREATE INDEX IF NOT EXISTS idx_order_item_selected_type ON order_item(selected_type);
