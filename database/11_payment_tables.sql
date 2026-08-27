-- ============================================================
-- 11_payment_tables.sql
-- Payments, gateway transactions, settlements, and splits
-- Tables: payment, settlement, settlement_detail
-- ============================================================

CREATE TABLE IF NOT EXISTS payment (
    payment_id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id            UUID        NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    amount              NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    payment_method      VARCHAR(30) CHECK (payment_method IN ('COD', 'UPI', 'Card', 'NetBanking', 'Wallet')),
    gateway_name        VARCHAR(50),
    transaction_id      VARCHAR(100),
    razorpay_order_id   VARCHAR(100) UNIQUE,
    razorpay_payment_id VARCHAR(100) UNIQUE,
    razorpay_signature  TEXT,
    payment_date        TIMESTAMPTZ DEFAULT NOW(),
    payment_status      VARCHAR(20) DEFAULT 'Pending' CHECK (payment_status IN ('Success', 'Failed', 'Pending', 'Refunded'))
);

CREATE TABLE IF NOT EXISTS settlement (
    settlement_id   UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    settlement_type VARCHAR(50),
    payment_id      UUID        NOT NULL REFERENCES payment(payment_id) ON DELETE RESTRICT,
    status          VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Processed', 'Failed')),
    settlement_date TIMESTAMPTZ,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS settlement_detail (
    detail_id       UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    settlement_id   UUID        NOT NULL REFERENCES settlement(settlement_id) ON DELETE CASCADE,
    entity_type     VARCHAR(30) CHECK (entity_type IN ('Farmer', 'Aggregator', 'Delivery', 'Platform', 'GST')),
    entity_id       UUID,
    percentage      NUMERIC(5, 2) CHECK (percentage >= 0 AND percentage <= 100),
    amount          NUMERIC(12, 2) NOT NULL CHECK (amount >= 0),
    remarks         TEXT,
    settled_at      TIMESTAMPTZ
);
