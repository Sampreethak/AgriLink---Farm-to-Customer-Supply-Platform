-- ============================================================
-- 06_aggregator_tables.sql
-- Aggregator hub profiles and warehouse storage details
-- Tables: aggregator, warehouse
-- ============================================================

CREATE TABLE IF NOT EXISTS aggregator (
    aggregator_id       UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    party_id            UUID        NOT NULL UNIQUE REFERENCES party(party_id) ON DELETE CASCADE,
    aggregator_code     VARCHAR(50) NOT NULL UNIQUE,
    business_name       VARCHAR(150) NOT NULL,
    gstin               VARCHAR(15) UNIQUE,
    kyc_status          VARCHAR(20) DEFAULT 'Pending' CHECK (kyc_status IN ('Pending', 'Approved', 'Rejected')),
    bank_account_id     VARCHAR(100),
    is_verified         BOOLEAN     DEFAULT FALSE,
    created_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS warehouse (
    warehouse_id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    aggregator_id           UUID        NOT NULL REFERENCES aggregator(aggregator_id) ON DELETE CASCADE,
    warehouse_name          VARCHAR(150) NOT NULL,
    warehouse_type          VARCHAR(50),
    location_id             UUID        NOT NULL REFERENCES location(location_id) ON DELETE RESTRICT,
    total_capacity_kg       NUMERIC(12, 2) NOT NULL CHECK (total_capacity_kg > 0),
    occupied_capacity_kg    NUMERIC(12, 2) DEFAULT 0 CHECK (occupied_capacity_kg >= 0),
    cold_storage            BOOLEAN     DEFAULT FALSE,
    temperature_min         NUMERIC(5, 2),
    temperature_max         NUMERIC(5, 2),
    is_active               BOOLEAN     DEFAULT TRUE,
    created_at              TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT chk_capacity CHECK (occupied_capacity_kg <= total_capacity_kg)
);
