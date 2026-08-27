-- ============================================================
-- 12_fulfillment.sql
-- Order fulfillment sources, split allocation, and tracking
-- Tables: fulfillment_source, order_allocation, order_tracking
-- Depends on: 11_order.sql (orders, order_item),
--             09_inventory.sql (aggregator_inventory),
--             06_farmer.sql (farmer),
--             03_master_tables.sql (location)
-- ============================================================

-- 1. FULFILLMENT_SOURCE
-- Identifies the origin of supply for an order item:
-- either a direct farmer or an aggregator warehouse batch.
-- This normalized table avoids nullable FK sprawl in allocations.
CREATE TABLE IF NOT EXISTS fulfillment_source (
    fulfillment_source_id   UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_type             VARCHAR(20) NOT NULL
                                CHECK (source_type IN ('Farmer', 'Aggregator')),
    source_name             VARCHAR(150),
    farmer_id               UUID        REFERENCES farmer(farmer_id) ON DELETE SET NULL,
    inventory_batch_id      UUID        REFERENCES aggregator_inventory(inventory_batch_id) ON DELETE SET NULL,
    created_at              TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT chk_fulfillment_source_exclusive
        CHECK (
            (source_type = 'Farmer' AND farmer_id IS NOT NULL AND inventory_batch_id IS NULL) OR
            (source_type = 'Aggregator' AND inventory_batch_id IS NOT NULL AND farmer_id IS NULL)
        )
);

-- 2. ORDER_ALLOCATION (Split Allocation)
-- Allocates a quantity from a fulfillment source to an order item.
-- An order item may be split across multiple sources
-- (e.g., partial qty from warehouse batch A, remainder from farmer B).
-- Business rules:
--  - allocation_sequence tracks split order (1, 2, 3...)
--  - Sum of allocated_quantity_kg across allocations must equal order_item.quantity
CREATE TABLE IF NOT EXISTS order_allocation (
    allocation_id           UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_item_id           UUID        NOT NULL REFERENCES order_item(order_item_id) ON DELETE CASCADE,
    fulfillment_source_id   UUID        NOT NULL REFERENCES fulfillment_source(fulfillment_source_id) ON DELETE RESTRICT,
    source_type             VARCHAR(20) NOT NULL CHECK (source_type IN ('Direct', 'Warehouse')),
    source_id               UUID        NOT NULL,   -- Points to farmer_crop_id or inventory_batch_id
    allocated_quantity_kg   DECIMAL(10, 2) NOT NULL CHECK (allocated_quantity_kg > 0),
    unit_price              DECIMAL(10, 2) NOT NULL CHECK (unit_price > 0),
    subtotal                DECIMAL(12, 2) NOT NULL CHECK (subtotal > 0),
    allocation_sequence     INT         DEFAULT 1,
    created_at              TIMESTAMPTZ DEFAULT NOW()
);

-- 3. ORDER_TRACKING
-- Immutable audit log of status changes for each order.
-- New rows are inserted (never updated) as status progresses.
-- Location is optionally captured for geo-tracking.
CREATE TABLE IF NOT EXISTS order_tracking (
    tracking_id         UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id            UUID        NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    status              VARCHAR(30) NOT NULL,
    status_updated_at   TIMESTAMPTZ DEFAULT NOW(),
    location_id         UUID        REFERENCES location(location_id) ON DELETE SET NULL,
    updated_by          UUID        REFERENCES users(user_id) ON DELETE SET NULL,
    remarks             TEXT
);

-- Back-fill FK on inventory_reservation.order_item_id now that order_item exists
ALTER TABLE inventory_reservation
    ADD CONSTRAINT fk_reservation_order_item
    FOREIGN KEY (order_item_id)
    REFERENCES order_item(order_item_id)
    ON DELETE SET NULL;

-- ============================================================
-- INDEXES for fulfillment tables
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_fulfillment_source_type ON fulfillment_source(source_type);
CREATE INDEX IF NOT EXISTS idx_fulfillment_farmer_id ON fulfillment_source(farmer_id);
CREATE INDEX IF NOT EXISTS idx_fulfillment_batch_id ON fulfillment_source(inventory_batch_id);
CREATE INDEX IF NOT EXISTS idx_allocation_order_item_id ON order_allocation(order_item_id);
CREATE INDEX IF NOT EXISTS idx_allocation_fulfillment_source ON order_allocation(fulfillment_source_id);
CREATE INDEX IF NOT EXISTS idx_allocation_source_type ON order_allocation(source_type);
CREATE INDEX IF NOT EXISTS idx_tracking_order_id ON order_tracking(order_id);
CREATE INDEX IF NOT EXISTS idx_tracking_status ON order_tracking(status);
CREATE INDEX IF NOT EXISTS idx_tracking_updated_at ON order_tracking(status_updated_at DESC);
