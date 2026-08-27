-- ============================================================
-- 08_inventory_tables.sql
-- Procurement, aggregator inventory, reservations, quality checks, ledger & alerts
-- Tables: procurement, aggregator_inventory, inventory_reservation, quality_check,
--         inventory_movement, inventory_adjustment, batch_expiry_alert
-- ============================================================

CREATE TABLE IF NOT EXISTS procurement (
    procurement_id      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id           UUID        NOT NULL REFERENCES farmer(farmer_id) ON DELETE RESTRICT,
    aggregator_id       UUID        NOT NULL REFERENCES aggregator(aggregator_id) ON DELETE RESTRICT,
    farmer_crop_id      UUID        NOT NULL REFERENCES farmer_crop(farmer_crop_id) ON DELETE RESTRICT,
    quantity_kg         NUMERIC(10, 2) NOT NULL CHECK (quantity_kg > 0),
    unit_price          NUMERIC(10, 2) NOT NULL CHECK (unit_price > 0),
    total_price         NUMERIC(12, 2) NOT NULL CHECK (total_price > 0),
    procurement_date    TIMESTAMPTZ DEFAULT NOW(),
    quality_status      VARCHAR(20) DEFAULT 'Pending' CHECK (quality_status IN ('Pending', 'Passed', 'Failed')),
    payment_status      VARCHAR(20) DEFAULT 'Pending' CHECK (payment_status IN ('Pending', 'Paid', 'Failed')),
    notes               TEXT,
    created_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS aggregator_inventory (
    inventory_batch_id      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    warehouse_id            UUID        NOT NULL REFERENCES warehouse(warehouse_id) ON DELETE CASCADE,
    aggregator_id           UUID        REFERENCES aggregator(aggregator_id) ON DELETE SET NULL,
    farmer_id               UUID        REFERENCES farmer(farmer_id) ON DELETE SET NULL,
    farmer_crop_id          UUID        REFERENCES farmer_crop(farmer_crop_id) ON DELETE SET NULL,
    batch_no                VARCHAR(50) NOT NULL UNIQUE,
    quantity_kg             NUMERIC(10, 2) NOT NULL CHECK (quantity_kg >= 0),
    unit_cost_price         NUMERIC(10, 2) NOT NULL CHECK (unit_cost_price > 0),
    available_quantity_kg   NUMERIC(10, 2) NOT NULL CHECK (available_quantity_kg >= 0),
    reserved_quantity_kg    NUMERIC(10, 2) DEFAULT 0 CHECK (reserved_quantity_kg >= 0),
    quality_status          VARCHAR(20) DEFAULT 'Passed' CHECK (quality_status IN ('Passed', 'Failed', 'Pending')),
    expiry_date             TIMESTAMPTZ,
    created_at              TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT chk_inventory_qty CHECK (available_quantity_kg + reserved_quantity_kg <= quantity_kg)
);

CREATE TABLE IF NOT EXISTS inventory_reservation (
    reservation_id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    inventory_batch_id      UUID        NOT NULL REFERENCES aggregator_inventory(inventory_batch_id) ON DELETE CASCADE,
    order_item_id           UUID,
    reserved_quantity_kg    NUMERIC(10, 2) NOT NULL CHECK (reserved_quantity_kg > 0),
    reserved_until          TIMESTAMPTZ NOT NULL,
    status                  VARCHAR(20) DEFAULT 'Active' CHECK (status IN ('Active', 'Expired', 'Used')),
    created_at              TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS quality_check (
    qc_id               UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
    inventory_batch_id  UUID    NOT NULL REFERENCES aggregator_inventory(inventory_batch_id) ON DELETE CASCADE,
    checked_by          UUID    REFERENCES users(user_id) ON DELETE SET NULL,
    quality_grade       VARCHAR(10) CHECK (quality_grade IN ('A', 'B', 'C')),
    qc_status           VARCHAR(20) DEFAULT 'Passed' CHECK (qc_status IN ('Passed', 'Failed')),
    moisture_level_pct  NUMERIC(5, 2),
    temperature_at_check NUMERIC(5, 2),
    remarks             TEXT,
    inspected_at        TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inventory_movement (
    movement_id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    inventory_batch_id  UUID        NOT NULL REFERENCES aggregator_inventory(inventory_batch_id) ON DELETE RESTRICT,
    movement_type       VARCHAR(20) NOT NULL CHECK (movement_type IN ('IN', 'OUT', 'RESERVED', 'RELEASED', 'HOLD', 'RETURNED', 'ADJUSTMENT', 'DAMAGED', 'EXPIRED')),
    quantity_kg         NUMERIC(10, 2) NOT NULL,
    reference_type      VARCHAR(50),
    reference_id        UUID,
    performed_by        UUID        REFERENCES users(user_id) ON DELETE SET NULL,
    notes               TEXT,
    movement_date       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inventory_adjustment (
    adjustment_id       UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    inventory_batch_id  UUID        NOT NULL REFERENCES aggregator_inventory(inventory_batch_id) ON DELETE RESTRICT,
    adjustment_type     VARCHAR(30) NOT NULL CHECK (adjustment_type IN ('Damage', 'Spoilage', 'Expiry', 'Manual Correction', 'Theft', 'Other')),
    quantity_kg         NUMERIC(10, 2) NOT NULL CHECK (quantity_kg > 0),
    reason              TEXT,
    performed_by        UUID        REFERENCES users(user_id) ON DELETE SET NULL,
    approved_by         UUID        REFERENCES users(user_id) ON DELETE SET NULL,
    approved_at         TIMESTAMPTZ,
    remarks             TEXT,
    created_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS batch_expiry_alert (
    alert_id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    inventory_batch_id  UUID        NOT NULL REFERENCES aggregator_inventory(inventory_batch_id) ON DELETE CASCADE,
    alert_type          VARCHAR(30) CHECK (alert_type IN ('Expiring Soon', 'Expired')),
    alert_time          TIMESTAMPTZ DEFAULT NOW(),
    notified_to         UUID        REFERENCES users(user_id) ON DELETE CASCADE,
    status              VARCHAR(20) DEFAULT 'Unread' CHECK (status IN ('Unread', 'Read', 'Actioned'))
);
