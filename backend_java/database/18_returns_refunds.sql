-- ============================================================
-- 18_returns_refunds.sql
-- Customer product returns, return line items, and refunds
-- Tables: returns, return_item, refund
-- Depends on: 11_order.sql (orders, order_item)
-- ============================================================

-- 1. RETURNS
-- Return request submitted by a customer for a delivered order.
-- Business rules:
--  - Returns can only be raised for 'Delivered' orders
--  - status flows: Requested → Approved/Rejected → Completed
--  - Approved returns trigger a refund record
CREATE TABLE IF NOT EXISTS returns (
    return_id       UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id        UUID        NOT NULL REFERENCES orders(order_id) ON DELETE RESTRICT,
    customer_id     UUID        REFERENCES customer(customer_id) ON DELETE SET NULL,
    return_date     TIMESTAMPTZ DEFAULT NOW(),
    reason          TEXT        NOT NULL,
    status          VARCHAR(20) DEFAULT 'Requested'
                        CHECK (status IN ('Requested', 'Approved', 'Rejected', 'Completed')),
    reviewed_by     UUID        REFERENCES users(user_id) ON DELETE SET NULL,
    reviewed_at     TIMESTAMPTZ
);

-- 2. RETURN_ITEM
-- Individual items within a return request.
-- Captures the quantity being returned and expected refund amount.
CREATE TABLE IF NOT EXISTS return_item (
    return_item_id  UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    return_id       UUID        NOT NULL REFERENCES returns(return_id) ON DELETE CASCADE,
    order_item_id   UUID        NOT NULL REFERENCES order_item(order_item_id) ON DELETE RESTRICT,
    quantity        DECIMAL(10, 2) NOT NULL CHECK (quantity > 0),
    refund_amount   DECIMAL(12, 2) NOT NULL CHECK (refund_amount >= 0),
    condition       VARCHAR(30),    -- 'Damaged', 'Wrong Item', 'Spoiled', 'Partial Spoilage'
    image_url       TEXT            -- Evidence photo uploaded to Cloudinary
);

-- 3. REFUND
-- Refund transaction created when a return is approved.
-- Tracks the gateway-level refund reference and method.
-- Business rules:
--  - refund_method can differ from original payment method (e.g., UPI refund for card payment)
--  - refund_date is set when the refund is actually processed
CREATE TABLE IF NOT EXISTS refund (
    refund_id       UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    return_id       UUID        NOT NULL UNIQUE REFERENCES returns(return_id) ON DELETE CASCADE,
    payment_id      UUID        REFERENCES payment(payment_id) ON DELETE SET NULL,
    amount          DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
    refund_method   VARCHAR(30),        -- 'UPI Refund', 'Bank Transfer', 'Wallet Credit'
    gateway_refund_id VARCHAR(100),     -- Razorpay refund ID
    status          VARCHAR(20) DEFAULT 'Pending'
                        CHECK (status IN ('Pending', 'Processed', 'Failed')),
    refund_date     TIMESTAMPTZ,
    transaction_id  VARCHAR(100),
    failure_reason  TEXT
);

-- ============================================================
-- INDEXES for returns and refund tables
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_returns_order_id ON returns(order_id);
CREATE INDEX IF NOT EXISTS idx_returns_status ON returns(status);
CREATE INDEX IF NOT EXISTS idx_returns_customer_id ON returns(customer_id);
CREATE INDEX IF NOT EXISTS idx_returns_return_date ON returns(return_date DESC);
CREATE INDEX IF NOT EXISTS idx_return_item_return_id ON return_item(return_id);
CREATE INDEX IF NOT EXISTS idx_return_item_order_item_id ON return_item(order_item_id);
CREATE INDEX IF NOT EXISTS idx_refund_return_id ON refund(return_id);
CREATE INDEX IF NOT EXISTS idx_refund_status ON refund(status);
CREATE INDEX IF NOT EXISTS idx_refund_payment_id ON refund(payment_id);
