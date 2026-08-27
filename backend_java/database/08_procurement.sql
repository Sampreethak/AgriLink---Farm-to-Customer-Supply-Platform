-- ============================================================
-- 08_procurement.sql
-- Farmer-to-aggregator procurement (collection receipts)
-- Table: procurement
-- Depends on: 06_farmer.sql (farmer, farmer_crop),
--             07_aggregator.sql (aggregator)
-- ============================================================

-- PROCUREMENT (Collection Receipt)
-- Captures the formal procurement transaction when an aggregator
-- purchases a harvest batch from a farmer. Each record is equivalent
-- to a collection/purchase receipt.
-- Business rules:
--  - quantity_kg and unit_price must be positive
--  - total_price is enforced via trigger/application logic
--  - quality_status gates whether the goods enter inventory
--  - payment_status tracks farmer settlement for this procurement
CREATE TABLE IF NOT EXISTS procurement (
    procurement_id      UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    farmer_id           UUID        NOT NULL REFERENCES farmer(farmer_id) ON DELETE RESTRICT,
    aggregator_id       UUID        NOT NULL REFERENCES aggregator(aggregator_id) ON DELETE RESTRICT,
    farmer_crop_id      UUID        NOT NULL REFERENCES farmer_crop(farmer_crop_id) ON DELETE RESTRICT,
    quantity_kg         DECIMAL(10, 2) NOT NULL CHECK (quantity_kg > 0),
    unit_price          DECIMAL(10, 2) NOT NULL CHECK (unit_price > 0),
    total_price         DECIMAL(12, 2) NOT NULL CHECK (total_price > 0),
    procurement_date    TIMESTAMPTZ DEFAULT NOW(),
    quality_status      VARCHAR(20) DEFAULT 'Pending'
                            CHECK (quality_status IN ('Pending', 'Passed', 'Failed')),
    payment_status      VARCHAR(20) DEFAULT 'Pending'
                            CHECK (payment_status IN ('Pending', 'Paid', 'Failed')),
    notes               TEXT,
    created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- INDEXES for procurement
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_procurement_farmer_id ON procurement(farmer_id);
CREATE INDEX IF NOT EXISTS idx_procurement_aggregator_id ON procurement(aggregator_id);
CREATE INDEX IF NOT EXISTS idx_procurement_farmer_crop_id ON procurement(farmer_crop_id);
CREATE INDEX IF NOT EXISTS idx_procurement_quality_status ON procurement(quality_status);
CREATE INDEX IF NOT EXISTS idx_procurement_payment_status ON procurement(payment_status);
CREATE INDEX IF NOT EXISTS idx_procurement_date ON procurement(procurement_date DESC);
