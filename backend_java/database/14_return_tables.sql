-- ============================================================
-- 14_return_tables.sql
-- Customer product returns, items, and credit refunds
-- Tables: returns, return_item, refund
-- ============================================================

CREATE TABLE IF NOT EXISTS returns (
    return_id       UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id        UUID        NOT NULL REFERENCES orders(order_id) ON DELETE RESTRICT,
    customer_id     UUID        REFERENCES customer(customer_id) ON DELETE SET NULL,
    return_date     TIMESTAMPTZ DEFAULT NOW(),
    reason          TEXT        NOT NULL,
    status          VARCHAR(20) DEFAULT 'Requested' CHECK (status IN ('Requested', 'Approved', 'Rejected', 'Completed')),
    reviewed_by     UUID        REFERENCES users(user_id) ON DELETE SET NULL,
    reviewed_at     TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS return_item (
    return_item_id  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    return_id       UUID        NOT NULL REFERENCES returns(return_id) ON DELETE CASCADE,
    order_item_id   UUID        NOT NULL REFERENCES order_item(order_item_id) ON DELETE RESTRICT,
    quantity        NUMERIC(10, 2) NOT NULL CHECK (quantity > 0),
    refund_amount   NUMERIC(12, 2) NOT NULL CHECK (refund_amount >= 0),
    condition       VARCHAR(30),
    image_url       TEXT
);

CREATE TABLE IF NOT EXISTS refund (
    refund_id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    return_id           UUID        NOT NULL UNIQUE REFERENCES returns(return_id) ON DELETE CASCADE,
    payment_id          UUID        REFERENCES payment(payment_id) ON DELETE SET NULL,
    amount              NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    refund_method       VARCHAR(30),
    gateway_refund_id   VARCHAR(100),
    status              VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Processed', 'Failed')),
    refund_date         TIMESTAMPTZ,
    transaction_id      VARCHAR(100),
    failure_reason      TEXT
);
