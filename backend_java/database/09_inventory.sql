-- ============================================================
-- 09_inventory.sql
-- Aggregator warehouse inventory batches and reservations
-- Tables: aggregator_inventory, inventory_reservation
-- Depends on: 07_aggregator.sql (warehouse, aggregator),
--             06_farmer.sql (farmer, farmer_crop)
-- ============================================================

-- 1. AGGREGATOR_INVENTORY (Batch)
-- Represents a distinct inventory batch in a warehouse.
-- Created after procurement passes quality check.
-- Tracks available vs reserved quantities for order fulfillment.
-- Business rules:
--  - available_quantity_kg + reserved_quantity_kg should <= quantity_kg
--  - expiry_date drives batch_expiry_alert scheduling
CREATE TABLE IF NOT EXISTS aggregator_inventory (
    inventory_batch_id      UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    warehouse_id            UUID        NOT NULL REFERENCES warehouse(warehouse_id) ON DELETE CASCADE,
    aggregator_id           UUID        REFERENCES aggregator(aggregator_id) ON DELETE SET NULL,
    farmer_id               UUID        REFERENCES farmer(farmer_id) ON DELETE SET NULL,
    farmer_crop_id          UUID        REFERENCES farmer_crop(farmer_crop_id) ON DELETE SET NULL,
    batch_no                VARCHAR(50) NOT NULL UNIQUE,
    quantity_kg             DECIMAL(10, 2) NOT NULL CHECK (quantity_kg >= 0),
    unit_cost_price         DECIMAL(10, 2) NOT NULL CHECK (unit_cost_price > 0),
    available_quantity_kg   DECIMAL(10, 2) NOT NULL CHECK (available_quantity_kg >= 0),
    reserved_quantity_kg    DECIMAL(10, 2) DEFAULT 0 CHECK (reserved_quantity_kg >= 0),
    quality_status          VARCHAR(20) DEFAULT 'Passed'
                                CHECK (quality_status IN ('Passed', 'Failed', 'Pending')),
    expiry_date             TIMESTAMPTZ,
    created_at              TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT chk_inventory_qty CHECK (available_quantity_kg + reserved_quantity_kg <= quantity_kg)
);

-- 2. INVENTORY_RESERVATION
-- Tracks temporary holds placed on inventory batches
-- when an order is being processed or payment is pending.
-- Reservations expire automatically via scheduled job.
CREATE TABLE IF NOT EXISTS inventory_reservation (
    reservation_id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    inventory_batch_id      UUID        NOT NULL REFERENCES aggregator_inventory(inventory_batch_id) ON DELETE CASCADE,
    order_item_id           UUID,       -- FK to order_item added after order tables are created
    reserved_quantity_kg    DECIMAL(10, 2) NOT NULL CHECK (reserved_quantity_kg > 0),
    reserved_until          TIMESTAMPTZ NOT NULL,
    status                  VARCHAR(20) DEFAULT 'Active'
                                CHECK (status IN ('Active', 'Expired', 'Used')),
    created_at              TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- INDEXES for inventory tables
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_inventory_warehouse_id ON aggregator_inventory(warehouse_id);
CREATE INDEX IF NOT EXISTS idx_inventory_farmer_id ON aggregator_inventory(farmer_id);
CREATE INDEX IF NOT EXISTS idx_inventory_farmer_crop_id ON aggregator_inventory(farmer_crop_id);
CREATE INDEX IF NOT EXISTS idx_inventory_batch_no ON aggregator_inventory(batch_no);
CREATE INDEX IF NOT EXISTS idx_inventory_quality_status ON aggregator_inventory(quality_status);
CREATE INDEX IF NOT EXISTS idx_inventory_expiry ON aggregator_inventory(expiry_date) WHERE expiry_date IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_inventory_available ON aggregator_inventory(available_quantity_kg);
CREATE INDEX IF NOT EXISTS idx_reservation_batch_id ON inventory_reservation(inventory_batch_id);
CREATE INDEX IF NOT EXISTS idx_reservation_status ON inventory_reservation(status);
CREATE INDEX IF NOT EXISTS idx_reservation_expiry ON inventory_reservation(reserved_until);
