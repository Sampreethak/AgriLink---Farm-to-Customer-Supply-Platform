-- ============================================================
-- 05_customer.sql
-- Customer registry and address management
-- Tables: customer, customer_address
-- Depends on: 04_user.sql (party), 03_master_tables.sql (location)
-- NOTE: Circular FK between customer and customer_address is
--       resolved using a deferred ALTER TABLE at the bottom.
-- ============================================================

-- Step 1: Create customer WITHOUT the default_address_id FK first
CREATE TABLE IF NOT EXISTS customer (
    customer_id         UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
    party_id            UUID    NOT NULL UNIQUE REFERENCES party(party_id) ON DELETE CASCADE,
    loyalty_points      INT     DEFAULT 0 CHECK (loyalty_points >= 0),
    default_address_id  UUID,   -- FK added via ALTER after customer_address exists
    created_at          TIMESTAMPTZ DEFAULT NOW(),
    updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- Step 2: Create customer_address with FK to customer
CREATE TABLE IF NOT EXISTS customer_address (
    address_id      UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id     UUID        NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    location_id     UUID        NOT NULL REFERENCES location(location_id) ON DELETE RESTRICT,
    address_type    VARCHAR(20) NOT NULL
                        CHECK (address_type IN ('Home', 'Work', 'Other')),
    address_line1   VARCHAR(255) NOT NULL,
    address_line2   VARCHAR(255),
    landmark        VARCHAR(150),
    city            VARCHAR(100) NOT NULL,
    state           VARCHAR(100) NOT NULL,
    pincode         VARCHAR(20)  NOT NULL,
    country         VARCHAR(100) DEFAULT 'India',
    latitude        DECIMAL(10, 8),
    longitude       DECIMAL(11, 8),
    is_default      BOOLEAN     DEFAULT FALSE,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Step 3: Resolve the circular FK on customer.default_address_id
ALTER TABLE customer
    ADD CONSTRAINT fk_customer_default_address
    FOREIGN KEY (default_address_id)
    REFERENCES customer_address(address_id)
    ON DELETE SET NULL;

-- ============================================================
-- INDEXES for customer tables
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_customer_party_id ON customer(party_id);
CREATE INDEX IF NOT EXISTS idx_customer_address_customer_id ON customer_address(customer_id);
CREATE INDEX IF NOT EXISTS idx_customer_address_location_id ON customer_address(location_id);
CREATE INDEX IF NOT EXISTS idx_customer_address_default ON customer_address(is_default);
CREATE INDEX IF NOT EXISTS idx_customer_address_pincode ON customer_address(pincode);
