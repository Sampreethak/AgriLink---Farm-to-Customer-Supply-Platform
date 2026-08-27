-- ============================================================
-- 14_payment.sql
-- Payments, settlement processing, and commission distribution
-- Tables: payment, settlement, settlement_detail
-- Depends on: 11_order.sql (orders)
-- ============================================================

-- 1. PAYMENT
-- Records the payment transaction for an order.
-- Supports multiple payment methods. Integrates with Razorpay.
-- Business rules:
--  - amount must be > 0
--  - transaction_id is the gateway reference (Razorpay order/payment ID)
--  - One order can have at most one successful payment
--    (multiple attempts allowed until success)
CREATE TABLE IF NOT EXISTS payment (
    payment_id      UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id        UUID        NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    amount          DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
    payment_method  VARCHAR(30) CHECK (payment_method IN ('COD', 'UPI', 'Card', 'NetBanking', 'Wallet')),
    gateway_name    VARCHAR(50),            -- e.g., 'Razorpay', 'PayU', 'PhonePe'
    transaction_id  VARCHAR(100),           -- Gateway reference ID
    razorpay_order_id   VARCHAR(100) UNIQUE,
    razorpay_payment_id VARCHAR(100) UNIQUE,
    razorpay_signature  TEXT,
    payment_date    TIMESTAMPTZ DEFAULT NOW(),
    payment_status  VARCHAR(20) DEFAULT 'Pending'
                        CHECK (payment_status IN ('Success', 'Failed', 'Pending', 'Refunded'))
);

-- 2. SETTLEMENT
-- Represents a settlement batch triggered after a successful payment.
-- One payment → one settlement record.
-- Settlement is then split into details for each party.
CREATE TABLE IF NOT EXISTS settlement (
    settlement_id   UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    settlement_type VARCHAR(50),    -- e.g., 'Order Settlement', 'Refund Settlement'
    payment_id      UUID        NOT NULL REFERENCES payment(payment_id) ON DELETE RESTRICT,
    status          VARCHAR(20) DEFAULT 'Pending'
                        CHECK (status IN ('Pending', 'Processed', 'Failed')),
    settlement_date TIMESTAMPTZ,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 3. SETTLEMENT_DETAIL
-- Breakdown of how a settlement amount is distributed.
-- Business rules (total % must = 100):
--  - Farmer: typically 70–85% of order value
--  - Aggregator: 5–15% if involved
--  - Delivery: fixed fee or percentage
--  - Platform: 2–10% commission
--  - GST: applicable tax portion
CREATE TABLE IF NOT EXISTS settlement_detail (
    detail_id       UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    settlement_id   UUID        NOT NULL REFERENCES settlement(settlement_id) ON DELETE CASCADE,
    entity_type     VARCHAR(30) CHECK (entity_type IN ('Farmer', 'Aggregator', 'Delivery', 'Platform', 'GST')),
    entity_id       UUID,               -- References farmer_id, aggregator_id, delivery_partner_id, or NULL for Platform/GST
    percentage      DECIMAL(5, 2) CHECK (percentage >= 0 AND percentage <= 100),
    amount          DECIMAL(12, 2) NOT NULL CHECK (amount >= 0),
    remarks         TEXT,
    settled_at      TIMESTAMPTZ
);

-- ============================================================
-- INDEXES for payment tables
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_payment_order_id ON payment(order_id);
CREATE INDEX IF NOT EXISTS idx_payment_status ON payment(payment_status);
CREATE INDEX IF NOT EXISTS idx_payment_transaction_id ON payment(transaction_id);
CREATE INDEX IF NOT EXISTS idx_payment_razorpay_order ON payment(razorpay_order_id);
CREATE INDEX IF NOT EXISTS idx_payment_date ON payment(payment_date DESC);
CREATE INDEX IF NOT EXISTS idx_settlement_payment_id ON settlement(payment_id);
CREATE INDEX IF NOT EXISTS idx_settlement_status ON settlement(status);
CREATE INDEX IF NOT EXISTS idx_settlement_detail_settlement_id ON settlement_detail(settlement_id);
CREATE INDEX IF NOT EXISTS idx_settlement_detail_entity_type ON settlement_detail(entity_type);
CREATE INDEX IF NOT EXISTS idx_settlement_detail_entity_id ON settlement_detail(entity_id);
