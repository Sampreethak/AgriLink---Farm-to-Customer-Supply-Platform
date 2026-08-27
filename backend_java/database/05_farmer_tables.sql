-- ============================================================
-- 05_farmer_tables.sql
-- Farmer profiles, farms, and crop harvest batches
-- Tables: farmer, farm, farmer_crop
-- ============================================================

CREATE TABLE IF NOT EXISTS farmer (
    farmer_id       UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    party_id        UUID        NOT NULL UNIQUE REFERENCES party(party_id) ON DELETE CASCADE,
    farmer_code     VARCHAR(50) NOT NULL UNIQUE,
    bio             TEXT,
    kyc_status      VARCHAR(20) DEFAULT 'Pending' CHECK (kyc_status IN ('Pending', 'Approved', 'Rejected')),
    bank_account_id VARCHAR(100),
    is_verified     BOOLEAN     DEFAULT FALSE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS farm (
    farm_id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id           UUID        NOT NULL REFERENCES farmer(farmer_id) ON DELETE CASCADE,
    farm_name           VARCHAR(150) NOT NULL,
    total_area          NUMERIC(10, 2) NOT NULL CHECK (total_area > 0),
    location_id         UUID        NOT NULL REFERENCES location(location_id) ON DELETE RESTRICT,
    description         TEXT,
    organic_certified   BOOLEAN     DEFAULT FALSE,
    is_active           BOOLEAN     DEFAULT TRUE,
    created_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS farmer_crop (
    farmer_crop_id          UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
    farm_id                 UUID    NOT NULL REFERENCES farm(farm_id) ON DELETE CASCADE,
    crop_id                 UUID    NOT NULL REFERENCES crop(crop_id) ON DELETE RESTRICT,
    variety                 VARCHAR(100),
    sowing_date             DATE,
    expected_harvest_date   DATE,
    organic_level           VARCHAR(50),
    grade                   VARCHAR(10) CHECK (grade IN ('A', 'B', 'C')),
    is_active               BOOLEAN     DEFAULT TRUE,
    created_at              TIMESTAMPTZ DEFAULT NOW()
);
