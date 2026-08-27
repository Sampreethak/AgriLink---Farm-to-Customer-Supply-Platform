-- ============================================================
-- 09_order_tables.sql
-- Customer orders, items, fulfillment sources, and allocation split
-- Tables: orders, order_item, fulfillment_source, order_allocation, order_tracking
-- ============================================================

CREATE TABLE IF NOT EXISTS orders (
    order_id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id         UUID        NOT NULL REFERENCES customer(customer_id) ON DELETE RESTRICT,
    order_date          TIMESTAMPTZ DEFAULT NOW(),
    order_status        VARCHAR(30) DEFAULT 'Placed'
                            CHECK (order_status IN ('Placed', 'Confirmed', 'Processing', 'OutForDelivery', 'Delivered', 'Cancelled')),
    total_amount        NUMERIC(12, 2) NOT NULL CHECK (total_amount >= 0),
    delivery_address_id UUID        REFERENCES customer_address(address_id) ON DELETE RESTRICT,
    payment_status      VARCHAR(20) DEFAULT 'Pending'
                            CHECK (payment_status IN ('Pending', 'Paid', 'Failed', 'Refunded')),
    special_instructions TEXT,
    created_at          TIMESTAMPTZ DEFAULT NOW(),
    updated_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_item (
    order_item_id   UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id        UUID        NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    crop_id         UUID        NOT NULL REFERENCES crop(crop_id) ON DELETE RESTRICT,
    quantity        NUMERIC(10, 2) NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(10, 2) NOT NULL CHECK (unit_price > 0),
    selected_type   VARCHAR(20) CHECK (selected_type IN ('Farmer', 'Aggregator')),
    subtotal        NUMERIC(12, 2) NOT NULL CHECK (subtotal > 0),
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS fulfillment_source (
    fulfillment_source_id   UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    source_type             VARCHAR(20) NOT NULL CHECK (source_type IN ('Farmer', 'Aggregator')),
    source_name             VARCHAR(150),
    farmer_id               UUID        REFERENCES farmer(farmer_id) ON DELETE SET NULL,
    inventory_batch_id      UUID        REFERENCES aggregator_inventory(inventory_batch_id) ON DELETE SET NULL,
    created_at              TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_allocation (
    allocation_id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    order_item_id           UUID        NOT NULL REFERENCES order_item(order_item_id) ON DELETE CASCADE,
    fulfillment_source_id   UUID        NOT NULL REFERENCES fulfillment_source(fulfillment_source_id) ON DELETE RESTRICT,
    source_type             VARCHAR(20) NOT NULL CHECK (source_type IN ('Direct', 'Warehouse')),
    source_id               UUID        NOT NULL,
    allocated_quantity_kg   NUMERIC(10, 2) NOT NULL CHECK (allocated_quantity_kg > 0),
    unit_price              NUMERIC(10, 2) NOT NULL CHECK (unit_price > 0),
    subtotal                NUMERIC(12, 2) NOT NULL CHECK (subtotal > 0),
    allocation_sequence     INT         DEFAULT 1,
    created_at              TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_tracking (
    tracking_id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id            UUID        NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    status              VARCHAR(30) NOT NULL,
    status_updated_at   TIMESTAMPTZ DEFAULT NOW(),
    location_id         UUID        REFERENCES location(location_id) ON DELETE SET NULL,
    updated_by          UUID        REFERENCES users(user_id) ON DELETE SET NULL,
    remarks             TEXT
);
