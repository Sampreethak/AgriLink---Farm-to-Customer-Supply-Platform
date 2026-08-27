-- ============================================================
-- 19_inventory_movement.sql
-- Inventory ledger, adjustments, and expiry alerts
-- Tables: inventory_movement, inventory_adjustment, batch_expiry_alert
-- Depends on: 09_inventory.sql (aggregator_inventory),
--             04_user.sql (users)
-- ============================================================

-- 1. INVENTORY_MOVEMENT (Ledger)
-- Immutable ledger of all quantity changes for each inventory batch.
-- Every addition, removal, reservation, or adjustment creates a new row.
-- This is the single source of truth for inventory audit.
-- Business rules:
--  - movement_type drives quantity sign logic in application:
--    IN/RELEASED/RETURNED/ADJUSTMENT = positive (adding stock)
--    OUT/RESERVED/HOLD/DAMAGED/EXPIRED = negative (removing stock)
--  - reference_type + reference_id links to the triggering entity
CREATE TABLE IF NOT EXISTS inventory_movement (
    movement_id         UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    inventory_batch_id  UUID        NOT NULL REFERENCES aggregator_inventory(inventory_batch_id) ON DELETE RESTRICT,
    movement_type       VARCHAR(20) NOT NULL
                            CHECK (movement_type IN (
                                'IN', 'OUT', 'RESERVED', 'RELEASED', 'HOLD',
                                'RETURNED', 'ADJUSTMENT', 'DAMAGED', 'EXPIRED'
                            )),
    quantity_kg         DECIMAL(10, 2) NOT NULL,    -- Positive or negative depending on type
    reference_type      VARCHAR(50),    -- 'Procurement', 'Order', 'Adjustment', 'Return'
    reference_id        UUID,           -- ID in the reference table
    performed_by        UUID        REFERENCES users(user_id) ON DELETE SET NULL,
    notes               TEXT,
    movement_date       TIMESTAMPTZ DEFAULT NOW()
);

-- 2. INVENTORY_ADJUSTMENT
-- Formal record of non-order-related inventory reductions.
-- Requires approval workflow for large adjustments.
-- Business rules:
--  - adjustment_type determines the reason category
--  - quantity_kg is always positive (the amount being written off)
--  - approved_by is required before the adjustment takes effect
CREATE TABLE IF NOT EXISTS inventory_adjustment (
    adjustment_id       UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    inventory_batch_id  UUID        NOT NULL REFERENCES aggregator_inventory(inventory_batch_id) ON DELETE RESTRICT,
    adjustment_type     VARCHAR(30) NOT NULL
                            CHECK (adjustment_type IN (
                                'Damage', 'Spoilage', 'Expiry',
                                'Manual Correction', 'Theft', 'Other'
                            )),
    quantity_kg         DECIMAL(10, 2) NOT NULL CHECK (quantity_kg > 0),
    reason              TEXT,
    performed_by        UUID        REFERENCES users(user_id) ON DELETE SET NULL,
    approved_by         UUID        REFERENCES users(user_id) ON DELETE SET NULL,
    approved_at         TIMESTAMPTZ,
    remarks             TEXT,
    created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- 3. BATCH_EXPIRY_ALERT
-- System-generated alerts for batches nearing or past expiry.
-- Created by a scheduled Spring @Scheduled job.
-- Business rules:
--  - 'Expiring Soon' = within configured days threshold (e.g., 3 days)
--  - 'Expired' = past expiry_date
--  - notified_to is the aggregator/admin who should act
CREATE TABLE IF NOT EXISTS batch_expiry_alert (
    alert_id            UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    inventory_batch_id  UUID        NOT NULL REFERENCES aggregator_inventory(inventory_batch_id) ON DELETE CASCADE,
    alert_type          VARCHAR(30) CHECK (alert_type IN ('Expiring Soon', 'Expired')),
    alert_time          TIMESTAMPTZ DEFAULT NOW(),
    notified_to         UUID        REFERENCES users(user_id) ON DELETE CASCADE,
    status              VARCHAR(20) DEFAULT 'Unread'
                            CHECK (status IN ('Unread', 'Read', 'Actioned'))
);

-- ============================================================
-- INDEXES for inventory movement tables
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_inv_movement_batch_id ON inventory_movement(inventory_batch_id);
CREATE INDEX IF NOT EXISTS idx_inv_movement_type ON inventory_movement(movement_type);
CREATE INDEX IF NOT EXISTS idx_inv_movement_date ON inventory_movement(movement_date DESC);
CREATE INDEX IF NOT EXISTS idx_inv_movement_reference ON inventory_movement(reference_type, reference_id);
CREATE INDEX IF NOT EXISTS idx_inv_adjustment_batch_id ON inventory_adjustment(inventory_batch_id);
CREATE INDEX IF NOT EXISTS idx_inv_adjustment_type ON inventory_adjustment(adjustment_type);
CREATE INDEX IF NOT EXISTS idx_inv_adjustment_approved_by ON inventory_adjustment(approved_by);
CREATE INDEX IF NOT EXISTS idx_expiry_alert_batch_id ON batch_expiry_alert(inventory_batch_id);
CREATE INDEX IF NOT EXISTS idx_expiry_alert_status ON batch_expiry_alert(status);
CREATE INDEX IF NOT EXISTS idx_expiry_alert_notified_to ON batch_expiry_alert(notified_to);
