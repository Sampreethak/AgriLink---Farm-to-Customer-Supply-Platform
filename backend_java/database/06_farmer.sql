-- ============================================================
-- 06_farmer.sql
-- Farmer profiles, farms, crop categories, and harvest batches
-- Tables: farmer, farm, farmer_crop
-- Depends on: 04_user.sql (party), 03_master_tables.sql (location, crop_category, crop)
-- ============================================================

-- 1. FARMER
-- Farmer professional profile. Extended from party.
-- Stores bank account details for settlement payouts.
CREATE TABLE IF NOT EXISTS farmer (
    farmer_id       UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    party_id        UUID        NOT NULL UNIQUE REFERENCES party(party_id) ON DELETE CASCADE,
    farmer_code     VARCHAR(50) NOT NULL UNIQUE,
    bio             TEXT,
    kyc_status      VARCHAR(20) DEFAULT 'Pending'
                        CHECK (kyc_status IN ('Pending', 'Approved', 'Rejected')),
    bank_account_id VARCHAR(100),   -- Reference to bank account (stored in secure vault or encrypted field)
    is_verified     BOOLEAN     DEFAULT FALSE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 2. FARM
-- Physical farm/land owned by a farmer.
-- A farmer may own multiple farms.
CREATE TABLE IF NOT EXISTS farm (
    farm_id             UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    farmer_id           UUID        NOT NULL REFERENCES farmer(farmer_id) ON DELETE CASCADE,
    farm_name           VARCHAR(150) NOT NULL,
    total_area          DECIMAL(10, 2) NOT NULL CHECK (total_area > 0),  -- in acres
    location_id         UUID        NOT NULL REFERENCES location(location_id) ON DELETE RESTRICT,
    description         TEXT,
    organic_certified   BOOLEAN     DEFAULT FALSE,
    is_active           BOOLEAN     DEFAULT TRUE,
    created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- 3. FARMER_CROP (Harvest Batch)
-- Represents a specific crop grown on a specific farm in a season.
-- Tracks variety, sowing/harvest dates, organic level and grade.
-- This is the core supply unit that gets procured or sold directly.
CREATE TABLE IF NOT EXISTS farmer_crop (
    farmer_crop_id          UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id                 UUID    NOT NULL REFERENCES farm(farm_id) ON DELETE CASCADE,
    crop_id                 UUID    NOT NULL REFERENCES crop(crop_id) ON DELETE RESTRICT,
    variety                 VARCHAR(100),
    sowing_date             DATE,
    expected_harvest_date   DATE,
    organic_level           VARCHAR(50),    -- e.g., 'Fully Organic', 'Partially Organic', 'Conventional'
    grade                   VARCHAR(10) CHECK (grade IN ('A', 'B', 'C')),
    is_active               BOOLEAN     DEFAULT TRUE,
    created_at              TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- INDEXES for farmer tables
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_farmer_party_id ON farmer(party_id);
CREATE INDEX IF NOT EXISTS idx_farmer_code ON farmer(farmer_code);
CREATE INDEX IF NOT EXISTS idx_farmer_verified ON farmer(is_verified);
CREATE INDEX IF NOT EXISTS idx_farm_farmer_id ON farm(farmer_id);
CREATE INDEX IF NOT EXISTS idx_farm_location_id ON farm(location_id);
CREATE INDEX IF NOT EXISTS idx_farm_active ON farm(is_active);
CREATE INDEX IF NOT EXISTS idx_farmer_crop_farm_id ON farmer_crop(farm_id);
CREATE INDEX IF NOT EXISTS idx_farmer_crop_crop_id ON farmer_crop(crop_id);
CREATE INDEX IF NOT EXISTS idx_farmer_crop_harvest_date ON farmer_crop(expected_harvest_date);
CREATE INDEX IF NOT EXISTS idx_farmer_crop_active ON farmer_crop(is_active);
