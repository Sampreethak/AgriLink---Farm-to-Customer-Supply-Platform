-- ============================================================
-- 07_customer_tables.sql
-- Customer entities and delivery addresses
-- Tables: customer, customer_address
-- ============================================================

CREATE TABLE IF NOT EXISTS customer (
    customer_id         UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
    party_id            UUID    NOT NULL UNIQUE REFERENCES party(party_id) ON DELETE CASCADE,
    loyalty_points      INT     DEFAULT 0 CHECK (loyalty_points >= 0),
    default_address_id  UUID,   -- Deferred FK constraint added in 16_constraints.sql
    created_at          TIMESTAMPTZ DEFAULT NOW(),
    updated_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS customer_address (
    address_id      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id     UUID        NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    location_id     UUID        NOT NULL REFERENCES location(location_id) ON DELETE RESTRICT,
    address_type    VARCHAR(20) NOT NULL CHECK (address_type IN ('Home', 'Work', 'Other')),
    address_line1   VARCHAR(255) NOT NULL,
    address_line2   VARCHAR(255),
    landmark        VARCHAR(150),
    city            VARCHAR(100) NOT NULL,
    state           VARCHAR(100) NOT NULL,
    pincode         VARCHAR(20)  NOT NULL,
    country         VARCHAR(100) DEFAULT 'India',
    latitude        NUMERIC(10, 8),
    longitude       NUMERIC(11, 8),
    is_default      BOOLEAN     DEFAULT FALSE,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);
