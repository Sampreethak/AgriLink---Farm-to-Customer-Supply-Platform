-- ============================================================
-- 07_aggregator.sql
-- Aggregator business profiles and their warehouses
-- Tables: aggregator, warehouse
-- Depends on: 04_user.sql (party), 03_master_tables.sql (location)
-- ============================================================

-- 1. AGGREGATOR
-- A licensed middle-party who procures crops from multiple farmers,
-- stores in their warehouses, and fulfills bulk/split orders.
-- Has own GSTIN, bank details, and KYC verification.
CREATE TABLE IF NOT EXISTS aggregator (
    aggregator_id       UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    party_id            UUID        NOT NULL UNIQUE REFERENCES party(party_id) ON DELETE CASCADE,
    aggregator_code     VARCHAR(50) NOT NULL UNIQUE,
    business_name       VARCHAR(150) NOT NULL,
    gstin               VARCHAR(15) UNIQUE,
    kyc_status          VARCHAR(20) DEFAULT 'Pending'
                            CHECK (kyc_status IN ('Pending', 'Approved', 'Rejected')),
    bank_account_id     VARCHAR(100),   -- Reference to external bank account
    is_verified         BOOLEAN     DEFAULT FALSE,
    created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- 2. WAREHOUSE
-- Physical cold/dry storage facility owned by an aggregator.
-- Tracks total vs occupied capacity, cold storage support,
-- temperature range, and location.
CREATE TABLE IF NOT EXISTS warehouse (
    warehouse_id            UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    aggregator_id           UUID        NOT NULL REFERENCES aggregator(aggregator_id) ON DELETE CASCADE,
    warehouse_name          VARCHAR(150) NOT NULL,
    warehouse_type          VARCHAR(50),    -- e.g., 'Cold Room', 'Dry Warehouse', 'Mixed'
    location_id             UUID        NOT NULL REFERENCES location(location_id) ON DELETE RESTRICT,
    total_capacity_kg       DECIMAL(12, 2) NOT NULL CHECK (total_capacity_kg > 0),
    occupied_capacity_kg    DECIMAL(12, 2) DEFAULT 0 CHECK (occupied_capacity_kg >= 0),
    cold_storage            BOOLEAN     DEFAULT FALSE,
    temperature_min         DECIMAL(5, 2),  -- Celsius, for cold storage configuration
    temperature_max         DECIMAL(5, 2),  -- Celsius
    is_active               BOOLEAN     DEFAULT TRUE,
    created_at              TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT chk_capacity CHECK (occupied_capacity_kg <= total_capacity_kg)
);

-- ============================================================
-- INDEXES for aggregator tables
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_aggregator_party_id ON aggregator(party_id);
CREATE INDEX IF NOT EXISTS idx_aggregator_code ON aggregator(aggregator_code);
CREATE INDEX IF NOT EXISTS idx_aggregator_verified ON aggregator(is_verified);
CREATE INDEX IF NOT EXISTS idx_warehouse_aggregator_id ON warehouse(aggregator_id);
CREATE INDEX IF NOT EXISTS idx_warehouse_location_id ON warehouse(location_id);
CREATE INDEX IF NOT EXISTS idx_warehouse_active ON warehouse(is_active);
CREATE INDEX IF NOT EXISTS idx_warehouse_cold_storage ON warehouse(cold_storage);
